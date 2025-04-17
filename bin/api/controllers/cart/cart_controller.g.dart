// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$CartServiceRouter(CartService service) {
  final router = Router();
  router.add(
    'GET',
    r'/cart/',
    service.getUserCart,
  );
  router.add(
    'DELETE',
    r'/cart/item/<productId>/',
    service.deleteFromCart,
  );
  router.add(
    'POST',
    r'/cart/',
    service.addToCart,
  );
  router.add(
    'PUT',
    r'/cart/item/<productId>/<size>/',
    service.incCount,
  );
  return router;
}
