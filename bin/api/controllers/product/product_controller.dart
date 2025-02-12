import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../misc/misc.dart';

part 'product_controller.g.dart';

class ProductService {
  @Route.get('/products/')
  Future<Response> listProducts(Request request) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    final result = await connection.execute('SELECT * FROM "Product" LIMIT 50');
    connection.close();
    return Response.ok(_jsonEncode(result), headers: jsonHeaders);
  }

  @Route.get('/products/<productId>')
  Future<Response> fetchProduct(Request request, String productId) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    final result = await connection.execute(
      Sql.named('SELECT * FROM "Product" WHERE product_id = @productId'),
      parameters: {'productId': int.parse(productId)},
    );
    if (result.isEmpty) {
      await connection.close();
      return Response(
        201,
        body: 'Product not found',
      );
    }
    await connection.close();
    return Response.ok(_jsonEncode(result.first), headers: jsonHeaders);
  }

  @Route.post('/products/')
  Future<Response> createProduct(Request request) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    await connection.execute(
      Sql.named(
          'INSERT INTO "Product" (name, email, units, mn_step, cost, user_id, image_url) VALUES (@name, @email, @units, @mn_step, @cost, @user_id, @image_url)'),
      parameters: {
        'name': data['name'],
        'email': data['email'],
        'units': data['units'],
        'mn_step': data['mn_step'],
        'cost': data['cost'],
        'user_id': data['user_id'],
        'image_url': data['image_url'],
      },
    );
    await connection.close();
    return Response.ok('Product created', headers: jsonHeaders);
  }

  @Route.put('/products/<productId>')
  Future<Response> updateProduct(Request request, String productId) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    await connection.execute(
      Sql.named(
          'UPDATE "Product" SET name = @name, email = @email, units = @units, mn_step = @mn_step, cost = @cost, user_id = @user_id, image_url = @image_url WHERE product_id = @productId'),
      parameters: {
        'productId': int.parse(productId),
        'name': data['name'],
        'email': data['email'],
        'units': data['units'],
        'mn_step': data['mn_step'],
        'cost': data['cost'],
        'user_id': data['user_id'],
        'image_url': data['image_url'],
      },
    );
    await connection.close();
    return Response.ok('Product updated', headers: jsonHeaders);
  }

  @Route.delete('/products/<productId>')
  Future<Response> deleteProduct(Request request, String productId) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    await connection.execute(
      Sql.named('DELETE FROM "Product" WHERE product_id = @productId'),
      parameters: {'productId': int.parse(productId)},
    );
    await connection.close();
    return Response.ok('Product deleted', headers: jsonHeaders);
  }

  String _jsonEncode(Object? data) =>
      const JsonEncoder.withIndent(' ').convert(data);

  Router get router => _$ProductServiceRouter(this);
}
