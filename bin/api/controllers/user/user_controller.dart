import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../misc/misc.dart';
import '../../../models/user_dto.dart';

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
    
    // Convert database results to UserDto objects
    final users = result.map((row) {
      // Convert ResultRow to Map<String, dynamic>
      final Map<String, dynamic> userMap = Map<String, dynamic>.from(row.toColumnMap());
      return UserDto.fromJson(userMap).toJson();
    }).toList();
    
    // Return structured response
    final responseData = {
      'users': users
    };
    
    return Response.ok(_jsonEncode(responseData), headers: jsonHeaders);
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
    
    // Convert ResultRow to Map<String, dynamic>
    final Map<String, dynamic> userMap = Map<String, dynamic>.from(result.first.toColumnMap());
    
    // Convert to UserDto
    final user = UserDto.fromJson(userMap).toJson();
    
    await connection.close();
    return Response.ok(_jsonEncode(user), headers: jsonHeaders);
  }

  @Route.post('/users/')
  Future<Response> createUser(Request request) async {
    var connection = await Connection.open(
      endPoint,
      settings: settings,
    );
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    // Build SQL query dynamically based on provided fields
    final List<String> fields = ['name', 'email', 'is_active'];
    final List<String> placeholders = ['@name', '@email', '@is_active'];
    final Map<String, dynamic> parameters = {
      'name': data['name'],
      'email': data['email'],
      'is_active': data['is_active'],
    };
    
    // Add optional fields if they exist
    if (data['phone_number'] != null) {
      fields.add('phone_number');
      placeholders.add('@phone_number');
      parameters['phone_number'] = data['phone_number'];
    }
    
    if (data['image_url'] != null) {
      fields.add('image_url');
      placeholders.add('@image_url');
      parameters['image_url'] = data['image_url'];
    }
    
    if (data['categories'] != null) {
      fields.add('categories');
      placeholders.add('@categories');
      parameters['categories'] = data['categories'];
    }
    
    // Only include password if it's provided
    if (data['password'] != null) {
      fields.add('password');
      placeholders.add('@password');
      parameters['password'] = data['password'];
    }
    
    final query = 'INSERT INTO "User" (${fields.join(', ')}) VALUES (${placeholders.join(', ')})';
    
    await connection.execute(
      Sql.named(query),
      parameters: parameters,
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
    
    // Build SET clause and parameters dynamically
    final List<String> setClauses = ['name = @name', 'email = @email', 'is_active = @is_active'];
    final Map<String, dynamic> parameters = {
      'userId': int.parse(userId),
      'name': data['name'],
      'email': data['email'],
      'is_active': data['is_active'],
    };
    
    // Add optional fields if they exist
    if (data['phone_number'] != null) {
      setClauses.add('phone_number = @phone_number');
      parameters['phone_number'] = data['phone_number'];
    }
    
    if (data['image_url'] != null) {
      setClauses.add('image_url = @image_url');
      parameters['image_url'] = data['image_url'];
    }
    
    if (data['categories'] != null) {
      setClauses.add('categories = @categories');
      parameters['categories'] = data['categories'];
    }
    
    // Only include password if it's provided
    if (data['password'] != null) {
      setClauses.add('password = @password');
      parameters['password'] = data['password'];
    }
    
    final query = 'UPDATE "User" SET ${setClauses.join(', ')} WHERE user_id = @userId';
    
    await connection.execute(
      Sql.named(query),
      parameters: parameters,
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
