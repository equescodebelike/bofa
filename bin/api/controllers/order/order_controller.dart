import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../misc/misc.dart';
import '../../../models/order_dto.dart';

part 'order_controller.g.dart';

class OrderService {
  @Route.get('/orders/')
  Future<Response> listOrders(Request request) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    final result = await connection.execute('SELECT * FROM "Order" LIMIT 50');
    await connection.close();
    
    // Convert database results to OrderDto objects
    final orders = result.map((row) {
      // Convert ResultRow to Map<String, dynamic>
      final Map<String, dynamic> orderMap = Map<String, dynamic>.from(row.toColumnMap());
      return OrderDto.fromJson(orderMap).toJson();
    }).toList();
    
    // Return structured response
    final responseData = {
      'orders': orders
    };
    
    return Response.ok(_jsonEncode(responseData), headers: jsonHeaders);
  }

  @Route.get('/orders/<orderId>')
  Future<Response> fetchOrder(Request request, String orderId) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    final result = await connection.execute(
      Sql.named('SELECT * FROM "Order" WHERE order_id = @orderId'),
      parameters: {'orderId': int.parse(orderId)},
    );
    if (result.isEmpty) {
      await connection.close();
      return Response(
        201,
        body: 'Order not found',
      );
    }
    
    // Convert ResultRow to Map<String, dynamic>
    final Map<String, dynamic> orderMap = Map<String, dynamic>.from(result.first.toColumnMap());
    
    // Convert to OrderDto
    final order = OrderDto.fromJson(orderMap).toJson();
    
    await connection.close();
    return Response.ok(_jsonEncode(order), headers: jsonHeaders);
  }

  @Route.post('/orders/')
  Future<Response> createOrder(Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    await connection.execute(
      Sql.named(
          'INSERT INTO "Order" (order_date, customer_id, address) VALUES (@order_date, @customer_id, @address)'),
      parameters: {
        'order_date': data['order_date'],
        'customer_id': data['customer_id'],
        'address': data['address'],
      },
    );
    await connection.close();
    return Response.ok('Order created', headers: jsonHeaders);
  }

  @Route.put('/orders/<orderId>')
  Future<Response> updateOrder(Request request, String orderId) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    await connection.execute(
      Sql.named(
          'UPDATE "Order" SET order_date = @order_date, customer_id = @customer_id, address = @address WHERE order_id = @orderId'),
      parameters: {
        'orderId': int.parse(orderId),
        'order_date': data['order_date'],
        'customer_id': data['customer_id'],
        'address': data['address'],
      },
    );
    await connection.close();
    return Response.ok('Order updated', headers: jsonHeaders);
  }

  @Route.delete('/orders/<orderId>')
  Future<Response> deleteOrder(Request request, String orderId) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    await connection.execute(
      Sql.named('DELETE FROM "Order" WHERE order_id = @orderId'),
      parameters: {'orderId': int.parse(orderId)},
    );
    await connection.close();
    return Response.ok('Order deleted', headers: jsonHeaders);
  }

  String _jsonEncode(Object? data) =>
      const JsonEncoder.withIndent(' ').convert(data);

  Router get router => _$OrderServiceRouter(this);
}
