import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../misc/misc.dart';
import '../../../models/order_part_dto.dart';
import '../../../models/order_dto.dart';
import '../../../models/product_add_to_cart_dto.dart';
import '../../../models/order_part_list_dto.dart';

part 'cart_controller.g.dart';

class CartService {
  @Route.get('/cart/user/<userId>')
  Future<Response> getUserCart(Request request, String userId) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    
    try {
      // First, find the active order for the user
      final userIdInt = int.parse(userId);
      final orderResult = await connection.execute(
        Sql.named('SELECT * FROM "Order" WHERE customer_id = @userId AND status = \'active\' LIMIT 1'),
        parameters: {'userId': userIdInt},
      );
      
      if (orderResult.isEmpty) {
        // No active order found
        await connection.close();
        return Response.ok(_jsonEncode({'order_parts': []}), headers: jsonHeaders);
      }
      
      final orderId = orderResult.first['order_id'] as int;
      
      // Get all order parts for this order
      final orderPartsResult = await connection.execute(
        Sql.named('SELECT * FROM "OrderPart" WHERE order_id = @orderId'),
        parameters: {'orderId': orderId},
      );
      
      // Convert database results to OrderPartDto objects
      final orderParts = orderPartsResult.map((row) {
        final Map<String, dynamic> orderPartMap = Map<String, dynamic>.from(row.toColumnMap());
        return OrderPartDto.fromJson(orderPartMap).toJson();
      }).toList();
      
      // Create response DTO
      final orderPartListDto = OrderPartListDto(orderParts: orderParts);
      
      await connection.close();
      return Response.ok(_jsonEncode(orderPartListDto.toJson()), headers: jsonHeaders);
    } catch (e) {
      await connection.close();
      return Response(500, body: 'Error getting cart: $e');
    }
  }

  @Route.delete('/cart/product/<productId>')
  Future<Response> deleteFromCart(Request request, String productId) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    
    try {
      // Delete the order part with the given product ID
      final productIdInt = int.parse(productId);
      await connection.execute(
        Sql.named('DELETE FROM "OrderPart" WHERE product_id = @productId'),
        parameters: {'productId': productIdInt},
      );
      
      await connection.close();
      return Response.ok('Product removed from cart', headers: jsonHeaders);
    } catch (e) {
      await connection.close();
      return Response(500, body: 'Error removing product from cart: $e');
    }
  }

  @Route.post('/cart/')
  Future<Response> addToCart(Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final productAddToCartDto = ProductAddToCartDto.fromJson(data);
    
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    
    try {
      // First, check if the user has an active order
      final orderResult = await connection.execute(
        Sql.named('SELECT * FROM "Order" WHERE customer_id = @userId AND status = \'active\' LIMIT 1'),
        parameters: {'userId': productAddToCartDto.userId},
      );
      
      int orderId;
      
      if (orderResult.isEmpty) {
        // Create a new order for the user
        final now = DateTime.now().toIso8601String();
        final insertOrderResult = await connection.execute(
          Sql.named('INSERT INTO "Order" (order_date, customer_id, address, status) VALUES (@orderDate, @customerId, \'\', \'active\') RETURNING order_id'),
          parameters: {
            'orderDate': now,
            'customerId': productAddToCartDto.userId,
          },
        );
        
        orderId = (insertOrderResult.first['order_id'] as int?) ?? 0;
      } else {
        orderId = (orderResult.first['order_id'] as int?) ?? 0;
      }
      
      // Check if the product is already in the cart
      final existingOrderPartResult = await connection.execute(
        Sql.named('SELECT * FROM "OrderPart" WHERE order_id = @orderId AND product_id = @productId LIMIT 1'),
        parameters: {
          'orderId': orderId,
          'productId': productAddToCartDto.productId,
        },
      );
      
      if (existingOrderPartResult.isNotEmpty) {
        // Update the existing order part
        final existingOrderPart = existingOrderPartResult.first;
        final currentCount = (existingOrderPart['count'] as int?) ?? 0;
        final newCount = currentCount + productAddToCartDto.count;
        
        await connection.execute(
          Sql.named('UPDATE "OrderPart" SET count = @count WHERE order_part_id = @orderPartId'),
          parameters: {
            'count': newCount,
            'orderPartId': existingOrderPart['order_part_id'],
          },
        );
      } else {
        // Create a new order part
        await connection.execute(
          Sql.named('INSERT INTO "OrderPart" (product_id, count, order_id, status) VALUES (@productId, @count, @orderId, \'pending\')'),
          parameters: {
            'productId': productAddToCartDto.productId,
            'count': productAddToCartDto.count,
            'orderId': orderId,
          },
        );
      }
      
      await connection.close();
      return Response.ok('Product added to cart', headers: jsonHeaders);
    } catch (e) {
      await connection.close();
      return Response(500, body: 'Error adding product to cart: $e');
    }
  }

  @Route.put('/cart/product/<productId>/inc/<size>')
  Future<Response> incCount(Request request, String productId, String size) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    
    try {
      // Find the order part with the given product ID
      final productIdInt = int.parse(productId);
      final sizeInt = int.parse(size);
      
      final orderPartResult = await connection.execute(
        Sql.named('SELECT * FROM "OrderPart" WHERE product_id = @productId LIMIT 1'),
        parameters: {'productId': productIdInt},
      );
      
      if (orderPartResult.isEmpty) {
        await connection.close();
        return Response(404, body: 'Product not found in cart');
      }
      
      final orderPart = orderPartResult.first;
      final currentCount = (orderPart['count'] as int?) ?? 0;
      final newCount = currentCount + sizeInt;
      
      // Update the count
      await connection.execute(
        Sql.named('UPDATE "OrderPart" SET count = @count WHERE order_part_id = @orderPartId'),
        parameters: {
          'count': newCount,
          'orderPartId': orderPart['order_part_id'],
        },
      );
      
      await connection.close();
      return Response.ok('Product count updated', headers: jsonHeaders);
    } catch (e) {
      await connection.close();
      return Response(500, body: 'Error updating product count: $e');
    }
  }

  String _jsonEncode(Object? data) =>
      const JsonEncoder.withIndent(' ').convert(data);

  Router get router => _$CartServiceRouter(this);
}
