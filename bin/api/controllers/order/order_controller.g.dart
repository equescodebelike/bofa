// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$OrderServiceRouter(OrderService service) {
  final router = Router();
  router.add(
    'GET',
    r'/orders/',
    service.listOrders,
  );
  router.add(
    'GET',
    r'/orders/<orderId>',
    service.fetchOrder,
  );
  router.add(
    'POST',
    r'/orders/',
    service.createOrder,
  );
  router.add(
    'PUT',
    r'/orders/<orderId>',
    service.updateOrder,
  );
  router.add(
    'DELETE',
    r'/orders/<orderId>',
    service.deleteOrder,
  );
  return router;
}
