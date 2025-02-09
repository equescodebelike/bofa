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
  router.add(
    'POST',
    r'/users/',
    service.createUser,
  );
  router.add(
    'PUT',
    r'/users/<userId>',
    service.updateUser,
  );
  router.add(
    'DELETE',
    r'/users/<userId>',
    service.deleteUser,
  );
  return router;
}
