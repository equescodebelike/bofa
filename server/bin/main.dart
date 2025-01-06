import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;

part 'main.g.dart'; // generated with 'pub run build_runner build'

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

void main() async {
  // You can setup context, database connections, cache connections, email
  // services, before you create an instance of your service.
  // var connection = await DatabaseConnection.connect('localhost:1234');
  var connection = await Connection.open(
    Endpoint(
      host: 'localhost',
      port: 8090,
      database: 'mypod',
      username: 'postgres',
      password: '2qBi9o2Bhvv7U3YgeN1dItQpxL1izTBR',
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );

  // Create an instance of your service, usine one of the constructors you've
  // defined.
  var service = UserService(connection);
  // Service request using the router, note the router can also be mounted.
  var router = service.router;
  var server = await io.serve(router.call, 'localhost', 8084);
}
