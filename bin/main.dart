import 'package:postgres/postgres.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'api/api.dart';

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
  await io.serve(router.call, 'localhost', 8084);
}
