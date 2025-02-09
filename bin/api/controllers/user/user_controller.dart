import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../misc/misc.dart';

part 'user_controller.g.dart';

class UserService {
  @Route.get('/users/')
  Future<Response> listUsers(Request request) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    final result = await connection.execute(
      'SELECT * FROM "User" LIMIT 50',
    );
    await connection.close();
    return Response.ok(_jsonEncode(result), headers: jsonHeaders);
  }

  @Route.get('/users/<userId>')
  Future<Response> fetchUser(Request request, String userId) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    final result = await connection.execute(
      Sql.named(
        'SELECT * FROM "User" WHERE user_id = @userId',
      ),
      parameters: {'userId': int.parse(userId)},
    );
    if (result.isEmpty) {
      await connection.close();
      return Response(
        201,
        body: 'Not found',
      );
    }
    await connection.close();
    return Response.ok(_jsonEncode(result.first), headers: jsonHeaders);
  }

  @Route.post('/users/')
  Future<Response> createUser(Request request) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    await connection.execute(
      Sql.named(
        'INSERT INTO "User" (name, email, is_active, password, phone_number, image_url, categories) VALUES (@name, @email, @is_active, @password, @phone_number, @image_url, @categories)',
      ),
      parameters: {
        'name': data['name'],
        'email': data['email'],
        'is_active': data['is_active'],
        'password': data['password'],
        'phone_number': data['phone_number'],
        'image_url': data['image_url'],
        'categories': data['categories'],
      },
    );
    await connection.close();
    return Response.ok('User created', headers: jsonHeaders);
  }

  @Route.put('/users/<userId>')
  Future<Response> updateUser(Request request, String userId) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    await connection.execute(
      Sql.named(
        'UPDATE "User" SET name = @name, email = @email, is_active = @is_active, password = @password, phone_number = @phone_number, image_url = @image_url, categories = @categories WHERE user_id = @userId',
      ),
      parameters: {
        'userId': int.parse(userId),
        'name': data['name'],
        'email': data['email'],
        'is_active': data['is_active'],
        'password': data['password'],
        'phone_number': data['phone_number'],
        'image_url': data['image_url'],
        'categories': data['categories'],
      },
    );
    await connection.close();
    return Response.ok('User updated', headers: jsonHeaders);
  }

  @Route.delete('/users/<userId>')
  Future<Response> deleteUser(Request request, String userId) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    await connection.execute(
      Sql.named(
        'DELETE FROM "User" WHERE user_id = @userId',
      ),
      parameters: {'userId': int.parse(userId)},
    );
    await connection.close();
    return Response.ok('User deleted', headers: jsonHeaders);
  }

  String _jsonEncode(Object? data) =>
      const JsonEncoder.withIndent(' ').convert(data);

  Router get router => _$UserServiceRouter(this);
}
