// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$ProductServiceRouter(ProductService service) {
  final router = Router();
  router.add(
    'GET',
    r'/products/',
    service.listProducts,
  );
  router.add(
    'GET',
    r'/products/<productId>',
    service.fetchProduct,
  );
  router.add(
    'POST',
    r'/products/',
    service.createProduct,
  );
  router.add(
    'PUT',
    r'/products/<productId>',
    service.updateProduct,
  );
  router.add(
    'DELETE',
    r'/products/<productId>',
    service.deleteProduct,
  );
  return router;
}
