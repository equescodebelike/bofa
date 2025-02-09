// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_part_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$OrderPartServiceRouter(OrderPartService service) {
  final router = Router();
  router.add(
    'GET',
    r'/orderparts/',
    service.listOrderParts,
  );
  router.add(
    'GET',
    r'/orderparts/<orderPartId>',
    service.fetchOrderPart,
  );
  router.add(
    'POST',
    r'/orderparts/',
    service.createOrderPart,
  );
  router.add(
    'PUT',
    r'/orderparts/<orderPartId>',
    service.updateOrderPart,
  );
  router.add(
    'DELETE',
    r'/orderparts/<orderPartId>',
    service.deleteOrderPart,
  );
  return router;
}
