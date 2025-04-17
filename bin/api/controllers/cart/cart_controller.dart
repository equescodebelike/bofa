import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../misc/misc.dart';

part 'cart_controller.g.dart';

class CartService {
  @Route.get('/cart/')
  Future<Response> getUserCart(Request request) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    
    try {
      // For demonstration purposes, we'll use a fixed user ID
      // In a real application, this would come from authentication
      final userIdInt = 1; // Example user ID
      
      final orderResult = await connection.execute(
        Sql.named('SELECT * FROM "Order" WHERE customer_id = @userId AND status = \'active\' LIMIT 1'),
        parameters: {'userId': userIdInt},
      );
      
      if (orderResult.isEmpty) {
        // No active order found
        await connection.close();
        return Response.ok(_jsonEncode({
          'items': [],
          'sum': 0.0
        }), headers: jsonHeaders);
      }
      
      // Convert ResultRow to Map<String, dynamic>
      final Map<String, dynamic> orderMap = Map<String, dynamic>.from(orderResult.first.toColumnMap());
      final orderId = int.parse(orderMap['order_id'].toString());
      
      // Get all order parts for this order with product information to calculate sum
      final orderPartsResult = await connection.execute(
        Sql.named('''
          SELECT op.*, p.price 
          FROM "OrderPart" op 
          JOIN "Product" p ON op.product_id = p.product_id 
          WHERE op.order_id = @orderId
        '''),
        parameters: {'orderId': orderId},
      );
      
      // Calculate total sum
      double totalSum = 0.0;
      
      // Convert database results to OrderPartMainInfo objects
      final items = orderPartsResult.map((row) {
        final Map<String, dynamic> rowMap = Map<String, dynamic>.from(row.toColumnMap());
        
        // Calculate item price and add to total
        final price = double.parse(rowMap['price']?.toString() ?? '0.0');
        final size = int.parse(rowMap['count']?.toString() ?? '0');
        totalSum += price * size;
        
        // Convert to client-side format
        return {
          'productId': int.parse(rowMap['product_id']?.toString() ?? '0'),
          'size': size,
          'orderPartId': int.parse(rowMap['order_part_id']?.toString() ?? '0'),
          'status': rowMap['status'] ?? 'pending',
          'updatedAt': DateTime.now().toIso8601String(),
          'orderedAt': DateTime.now().toIso8601String(),
        };
      }).toList();
      
      // Create response in client-side format
      final response = {
        'items': items,
        'sum': totalSum
      };
      
      await connection.close();
      return Response.ok(_jsonEncode(response), headers: jsonHeaders);
    } catch (e) {
      await connection.close();
      return Response(500, body: _jsonEncode({'message': 'Error getting cart: $e'}), headers: jsonHeaders);
    }
  }

  @Route.delete('/cart/item/<productId>/')
  Future<Response> deleteFromCart(Request request, String productId) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    
    try {
      // For demonstration purposes, we'll use a fixed user ID
      final userIdInt = 1; // Example user ID
      final productIdInt = int.parse(productId);
      
      // Find the active order for this user
      final orderResult = await connection.execute(
        Sql.named('SELECT * FROM "Order" WHERE customer_id = @userId AND status = \'active\' LIMIT 1'),
        parameters: {'userId': userIdInt},
      );
      
      if (orderResult.isEmpty) {
        await connection.close();
        return Response(404, body: _jsonEncode({'message': 'No active cart found'}), headers: jsonHeaders);
      }
      
      // Convert ResultRow to Map<String, dynamic>
      final Map<String, dynamic> orderMap = Map<String, dynamic>.from(orderResult.first.toColumnMap());
      final orderId = int.parse(orderMap['order_id'].toString());
      
      // Delete the order part with the given product ID for this specific order
      await connection.execute(
        Sql.named('DELETE FROM "OrderPart" WHERE product_id = @productId AND order_id = @orderId'),
        parameters: {
          'productId': productIdInt,
          'orderId': orderId
        },
      );
      
      await connection.close();
      return Response.ok(_jsonEncode({'message': 'Product removed from cart'}), headers: jsonHeaders);
    } catch (e) {
      await connection.close();
      return Response(500, body: _jsonEncode({'message': 'Error removing product from cart: $e'}), headers: jsonHeaders);
    }
  }

  @Route.post('/cart/')
  Future<Response> addToCart(Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    
    // Validate required fields
    if (!data.containsKey('productId') || !data.containsKey('size')) {
      return Response(400, body: _jsonEncode({'message': 'Missing required fields: productId and size'}), headers: jsonHeaders);
    }
    
    final productId = int.parse(data['productId'].toString());
    final size = int.parse(data['size'].toString());
    
    // For demonstration purposes, we'll use a fixed user ID
    final userIdInt = 1; // Example user ID
    
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    
    try {
      // First, check if the user has an active order
      final orderResult = await connection.execute(
        Sql.named('SELECT * FROM "Order" WHERE customer_id = @userId AND status = \'active\' LIMIT 1'),
        parameters: {'userId': userIdInt},
      );
      
      int orderId;
      
      if (orderResult.isEmpty) {
        // Create a new order for the user
        final now = DateTime.now().toIso8601String();
        final insertOrderResult = await connection.execute(
          Sql.named('INSERT INTO "Order" (order_date, customer_id, address, status) VALUES (@orderDate, @customerId, \'\', \'active\') RETURNING order_id'),
          parameters: {
            'orderDate': now,
            'customerId': userIdInt,
          },
        );
        
        final Map<String, dynamic> insertOrderMap = Map<String, dynamic>.from(insertOrderResult.first.toColumnMap());
        orderId = int.parse(insertOrderMap['order_id'].toString());
      } else {
        final Map<String, dynamic> orderMap = Map<String, dynamic>.from(orderResult.first.toColumnMap());
        orderId = int.parse(orderMap['order_id'].toString());
      }
      
      // Check if the product is already in the cart
      final existingOrderPartResult = await connection.execute(
        Sql.named('SELECT * FROM "OrderPart" WHERE order_id = @orderId AND product_id = @productId LIMIT 1'),
        parameters: {
          'orderId': orderId,
          'productId': productId,
        },
      );
      
      if (existingOrderPartResult.isNotEmpty) {
        // Update the existing order part
        final Map<String, dynamic> existingOrderPartMap = Map<String, dynamic>.from(existingOrderPartResult.first.toColumnMap());
        final currentSize = int.parse(existingOrderPartMap['count']?.toString() ?? '0');
        final newSize = currentSize + size;
        
        await connection.execute(
          Sql.named('UPDATE "OrderPart" SET count = @size WHERE order_part_id = @orderPartId'),
          parameters: {
            'size': newSize,
            'orderPartId': int.parse(existingOrderPartMap['order_part_id'].toString()),
          },
        );
      } else {
        // Create a new order part
        await connection.execute(
          Sql.named('INSERT INTO "OrderPart" (product_id, count, order_id, status) VALUES (@productId, @size, @orderId, \'pending\')'),
          parameters: {
            'productId': productId,
            'size': size,
            'orderId': orderId,
          },
        );
      }
      
      await connection.close();
      return Response.ok(_jsonEncode({'message': 'Product added to cart'}), headers: jsonHeaders);
    } catch (e) {
      await connection.close();
      return Response(500, body: _jsonEncode({'message': 'Error adding product to cart: $e'}), headers: jsonHeaders);
    }
  }

  @Route.put('/cart/item/<productId>/<size>/')
  Future<Response> incCount(Request request, String productId, String size) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    
    try {
      // For demonstration purposes, we'll use a fixed user ID
      final userIdInt = 1; // Example user ID
      final productIdInt = int.parse(productId);
      final sizeInt = int.parse(size);
      
      // Find the active order for this user
      final orderResult = await connection.execute(
        Sql.named('SELECT * FROM "Order" WHERE customer_id = @userId AND status = \'active\' LIMIT 1'),
        parameters: {'userId': userIdInt},
      );
      
      if (orderResult.isEmpty) {
        await connection.close();
        return Response(404, body: _jsonEncode({'message': 'No active cart found'}), headers: jsonHeaders);
      }
      
      // Convert ResultRow to Map<String, dynamic>
      final Map<String, dynamic> orderMap = Map<String, dynamic>.from(orderResult.first.toColumnMap());
      final orderId = int.parse(orderMap['order_id'].toString());
      
      // Find the order part with the given product ID for this specific order
      final orderPartResult = await connection.execute(
        Sql.named('SELECT * FROM "OrderPart" WHERE product_id = @productId AND order_id = @orderId LIMIT 1'),
        parameters: {
          'productId': productIdInt,
          'orderId': orderId
        },
      );
      
      if (orderPartResult.isEmpty) {
        await connection.close();
        return Response(404, body: _jsonEncode({'message': 'Product not found in cart'}), headers: jsonHeaders);
      }
      
      // Convert ResultRow to Map<String, dynamic>
      final Map<String, dynamic> orderPartMap = Map<String, dynamic>.from(orderPartResult.first.toColumnMap());
      final currentSize = int.parse(orderPartMap['count']?.toString() ?? '0');
      final newSize = currentSize + sizeInt;
      
      // Update the count (size)
      await connection.execute(
        Sql.named('UPDATE "OrderPart" SET count = @size WHERE order_part_id = @orderPartId'),
        parameters: {
          'size': newSize,
          'orderPartId': int.parse(orderPartMap['order_part_id'].toString()),
        },
      );
      
      await connection.close();
      return Response.ok(_jsonEncode({'message': 'Product count updated'}), headers: jsonHeaders);
    } catch (e) {
      await connection.close();
      return Response(500, body: _jsonEncode({'message': 'Error updating product count: $e'}), headers: jsonHeaders);
    }
  }

  String _jsonEncode(Object? data) =>
      const JsonEncoder.withIndent(' ').convert(data);

  Router get router => _$CartServiceRouter(this);
}
