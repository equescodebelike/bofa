// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$UserServiceRouter(UserService service) {
  final router = Router();
  router.add(
    'GET',
    r'/users/',
    service.listUsers,
  );
  router.add(
    'GET',
    r'/users/<userId>',
    service.fetchUser,
  );
  return router;
}
