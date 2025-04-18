// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$AuthServiceRouter(AuthService service) {
  final router = Router();
  router.add(
    'POST',
    r'/auth/email/part1/',
    service.requestEmailVerification,
  );
  router.add(
    'POST',
    r'/auth/email/part2/',
    service.verifyEmailCode,
  );
  router.add(
    'GET',
    r'/auth/user/',
    service.getUserData,
  );
  router.add(
    'POST',
    r'/auth/refresh/',
    service.refreshToken,
  );
  return router;
}
