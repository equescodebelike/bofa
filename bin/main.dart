import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'api/api.dart';
import '../bin/misc/misc.dart';

void main() async {
  final connection = await Connection.open(
    endPoint,
    settings: settings,
  );

  Response cors(Response response) => response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token, Authorization',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      });

  final fixCORS = createMiddleware(responseHandler: cors);

  final userService = UserService();
  final productService = ProductService();
  final orderService = OrderService();
  final orderPartService = OrderPartService();
  final cartService = CartService();
  final authService = AuthService();
  final cascade = Cascade()
      .add(
        authService.router.call,
      )
      .add(
        userService.router.call,
      )
      .add(
        productService.router.call,
      )
      .add(
        orderService.router.call,
      )
      .add(
        orderPartService.router.call,
      )
      .add(
        cartService.router.call,
      );

  final handler = const Pipeline().addMiddleware(fixCORS).addHandler(
        cascade.handler.call,
      );

  await io.serve(handler, 'localhost', 8084);
  await connection.close();
}
