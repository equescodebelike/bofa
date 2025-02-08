import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'user_controller.g.dart';

const jsonHeaders = {
  'content-type': 'application/json',
};

class UserService {
  final Connection connection;

  UserService(
    this.connection,
  );

  @Route.get('/users/')
  Future<Response> listUsers(Request request) async {
    final result = await connection.execute('SELECT * FROM "user" LIMIT 50');
    print(result);
    return Response.ok(
      _jsonEncode(result),
      headers: jsonHeaders,
    );
  }

  String _jsonEncode(Object? data) =>
      const JsonEncoder.withIndent(' ').convert(data);

  @Route.get('/users/<userId>')
  Future<Response> fetchUser(Request request, String userId) async {
    if (userId == 'user1') {
      return Response.ok('user1');
    }
    return Response.notFound('no such user');
  }

  // Create router using the generate function defined in 'userservice.g.dart'.
  Router get router => _$UserServiceRouter(this);
}
