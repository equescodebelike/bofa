import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../misc/misc.dart';

part 'order_part_controller.g.dart';

class OrderPartService {
  @Route.get('/orderparts/')
  Future<Response> listOrderParts(Request request) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    final result =
        await connection.execute('SELECT * FROM "OrderPart" LIMIT 50');
    await connection.close();
    return Response.ok(_jsonEncode(result), headers: jsonHeaders);
  }

  @Route.get('/orderparts/<orderPartId>')
  Future<Response> fetchOrderPart(Request request, String orderPartId) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    final result = await connection.execute(
      Sql.named(
          'SELECT * FROM "OrderPart" WHERE order_part_id = @orderPartId'),
      parameters: {'orderPartId': int.parse(orderPartId)},
    );
    if (result.isEmpty) {
      await connection.close();
      return Response(201, body: 'Order part not found');
    }
    await connection.close();
    return Response.ok(_jsonEncode(result.first), headers: jsonHeaders);
  }

  @Route.post('/orderparts/')
  Future<Response> createOrderPart(Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    await connection.execute(
      Sql.named(
          'INSERT INTO "OrderPart" (product_id, count, order_id, status) VALUES (@product_id, @count, @order_id, @status)'),
      parameters: {
        'product_id': data['product_id'],
        'count': data['count'],
        'order_id': data['order_id'],
        'status': data['status'],
      },
    );
    await connection.close();
    return Response.ok('Order part created', headers: jsonHeaders);
  }

  @Route.put('/orderparts/<orderPartId>')
  Future<Response> updateOrderPart(Request request, String orderPartId) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    await connection.execute(
      Sql.named(
          'UPDATE "OrderPart" SET product_id = @product_id, count = @count, order_id = @order_id, status = @status WHERE order_part_id = @orderPartId'),
      parameters: {
        'orderPartId': int.parse(orderPartId),
        'product_id': data['product_id'],
        'count': data['count'],
        'order_id': data['order_id'],
        'status': data['status'],
      },
    );
    await connection.close();
    return Response.ok('Order part updated', headers: jsonHeaders);
  }

  @Route.delete('/orderparts/<orderPartId>')
  Future<Response> deleteOrderPart(Request request, String orderPartId) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    await connection.execute(
      Sql.named('DELETE FROM "OrderPart" WHERE order_part_id = @orderPartId'),
      parameters: {'orderPartId': int.parse(orderPartId)},
    );
    await connection.close();
    return Response.ok('Order part deleted', headers: jsonHeaders);
  }

  String _jsonEncode(Object? data) =>
      const JsonEncoder.withIndent(' ').convert(data);

  Router get router => _$OrderPartServiceRouter(this);
}
