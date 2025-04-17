// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$CartServiceRouter(CartService service) {
  final router = Router();
  router.add(
    'GET',
    r'/cart/user/<userId>',
    service.getUserCart,
  );
  router.add(
    'DELETE',
    r'/cart/product/<productId>',
    service.deleteFromCart,
  );
  router.add(
    'POST',
    r'/cart/',
    service.addToCart,
  );
  router.add(
    'PUT',
    r'/cart/product/<productId>/inc/<size>',
    service.incCount,
  );
  return router;
}
