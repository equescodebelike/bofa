import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../misc/misc.dart';
import '../../../models/product_dto.dart';

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
    
    // Convert database results to ProductDto objects
    final products = result.map((row) {
      // Convert ResultRow to Map<String, dynamic>
      final Map<String, dynamic> productMap = Map<String, dynamic>.from(row.toColumnMap());
      return ProductDto.fromJson(productMap).toJson();
    }).toList();
    
    // Return structured response
    final responseData = {
      'products': products,
      'total': products.length
    };
    
    return Response.ok(_jsonEncode(responseData), headers: jsonHeaders);
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
    
    // Convert ResultRow to Map<String, dynamic>
    final Map<String, dynamic> productMap = Map<String, dynamic>.from(result.first.toColumnMap());
    
    // Convert to ProductDto
    final product = ProductDto.fromJson(productMap).toJson();
    
    await connection.close();
    return Response.ok(_jsonEncode(product), headers: jsonHeaders);
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
          'INSERT INTO "Product" (name, email, units, mn_step, cost, user_id, image_url, category) VALUES (@name, @email, @units, @mn_step, @cost, @user_id, @image_url, @category)'),
      parameters: {
        'name': data['name'],
        'email': data['email'],
        'units': data['units'],
        'mn_step': data['mn_step'],
        'cost': data['cost'],
        'user_id': data['user_id'],
        'image_url': data['image_url'],
        'category': data['category'],
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
          'UPDATE "Product" SET name = @name, email = @email, units = @units, mn_step = @mn_step, cost = @cost, user_id = @user_id, image_url = @image_url, category = @category WHERE product_id = @productId'),
      parameters: {
        'productId': int.parse(productId),
        'name': data['name'],
        'email': data['email'],
        'units': data['units'],
        'mn_step': data['mn_step'],
        'cost': data['cost'],
        'user_id': data['user_id'],
        'image_url': data['image_url'],
        'category': data['category'],
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

  @Route.get('/products/user/<userId>')
  Future<Response> fetchProductsByUserId(Request request, String userId) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    final result = await connection.execute(
      Sql.named('SELECT * FROM "Product" WHERE user_id = @userId'),
      parameters: {'userId': int.parse(userId)},
    );
    
    // Convert database results to ProductDto objects
    final products = result.map((row) {
      // Convert ResultRow to Map<String, dynamic>
      final Map<String, dynamic> productMap = Map<String, dynamic>.from(row.toColumnMap());
      return ProductDto.fromJson(productMap).toJson();
    }).toList();
    
    // Return structured response
    final responseData = {
      'products': products,
      'total': products.length
    };
    
    await connection.close();
    return Response.ok(_jsonEncode(responseData), headers: jsonHeaders);
  }

  String _jsonEncode(Object? data) =>
      const JsonEncoder.withIndent(' ').convert(data);

  Router get router => _$ProductServiceRouter(this);
}
