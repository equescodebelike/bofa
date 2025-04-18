import 'dart:convert';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:random_string/random_string.dart';
import '../../../misc/misc.dart';
import '../../../models/auth/email_auth_request_dto.dart';
import '../../../models/auth/token_response_dto.dart';
import '../../../models/user_dto.dart';
import '../../../services/email_service.dart';
import '../../../utils/jwt_util.dart';

part 'auth_controller.g.dart';

class AuthService {
  @Route.post('/auth/email/part1/')
  Future<Response> requestEmailVerification(Request request) async {
    try {
      // Parse request body
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final emailRequest = EmailAuthRequestDto.fromJson(data);
      
      // Generate 4-symbol verification code
      final code = randomAlphaNumeric(4);
      
      // Store verification code in database (valid for 1 hour)
      var connection = await Connection.open(endPoint, settings: settings);
      
      // Delete any existing verification codes for this email
      await connection.execute(
        Sql.named(
          'DELETE FROM "verification_codes" WHERE email = @email',
        ),
        parameters: {
          'email': emailRequest.email,
        },
      );
      
      // Insert new verification code
      await connection.execute(
        Sql.named(
          'INSERT INTO "verification_codes" (email, code, expires_at) VALUES (@email, @code, @expires_at)',
        ),
        parameters: {
          'email': emailRequest.email,
          'code': code,
          'expires_at': DateTime.now().add(Duration(hours: 1)),
        },
      );
      await connection.close();
      
      // Send verification code via email
      await EmailService.sendVerificationCode(emailRequest.email, code);
      
      return Response.ok(
        _jsonEncode({'message': 'Verification code sent'}),
        headers: jsonHeaders,
      );
    } catch (e) {
      print('Error in requestEmailVerification: $e');
      return Response.internalServerError(
        body: _jsonEncode({'error': 'Failed to send verification code'}),
        headers: jsonHeaders,
      );
    }
  }
  
  @Route.post('/auth/email/part2/')
  Future<Response> verifyEmailCode(Request request) async {
    try {
      // Parse request body
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final email = data['email'] as String;
      final code = data['code'] as String;
      
      var connection = await Connection.open(endPoint, settings: settings);
      
      // Verify the code
      final verificationResult = await connection.execute(
        Sql.named(
          'SELECT * FROM "verification_codes" WHERE email = @email AND code = @code AND expires_at > @now',
        ),
        parameters: {
          'email': email,
          'code': code,
          'now': DateTime.now(),
        },
      );
      
      if (verificationResult.isEmpty) {
        await connection.close();
        return Response(
          401,
          body: _jsonEncode({'error': 'Invalid or expired verification code'}),
          headers: jsonHeaders,
        );
      }
      
      // Check if user exists
      final userResult = await connection.execute(
        Sql.named('SELECT * FROM "User" WHERE email = @email'),
        parameters: {'email': email},
      );
      
      int userId;
      
      if (userResult.isEmpty) {
        // Create new user
        final createUserResult = await connection.execute(
          Sql.named(
            'INSERT INTO "User" (name, email, is_active) VALUES (@name, @email, @is_active) RETURNING user_id',
          ),
          parameters: {
            'name': email.split('@')[0], // Default name from email
            'email': email,
            'is_active': true,
          },
        );
        userId = createUserResult.first[0] as int;
      } else {
        userId = userResult.first[0] as int;
      }
      
      // Generate tokens
      final accessToken = JwtUtil.generateAccessToken(userId, email);
      final refreshToken = JwtUtil.generateRefreshToken(userId, email);
      
      // Store refresh token
      await connection.execute(
        Sql.named(
          'INSERT INTO "refresh_tokens" (user_id, token, expires_at) VALUES (@userId, @token, @expiresAt)',
        ),
        parameters: {
          'userId': userId,
          'token': refreshToken,
          'expiresAt': DateTime.now().add(Duration(days: 4)),
        },
      );
      
      // Delete used verification code
      await connection.execute(
        Sql.named('DELETE FROM "verification_codes" WHERE email = @email AND code = @code'),
        parameters: {'email': email, 'code': code},
      );
      
      await connection.close();
      
      // Return tokens
      final tokenResponse = TokenResponseDto(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      
      return Response.ok(
        _jsonEncode(tokenResponse.toJson()),
        headers: jsonHeaders,
      );
    } catch (e) {
      print('Error in verifyEmailCode: $e');
      return Response.internalServerError(
        body: _jsonEncode({'error': 'Failed to verify code'}),
        headers: jsonHeaders,
      );
    }
  }
  
  @Route.get('/auth/user/')
  Future<Response> getUserData(Request request) async {
    try {
      // Extract token from Authorization header
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(
          401,
          body: _jsonEncode({'error': 'Missing or invalid token'}),
          headers: jsonHeaders,
        );
      }
      
      final token = authHeader.substring(7); // Remove 'Bearer ' prefix
      
      try {
        // Verify token
        final payload = JwtUtil.verifyToken(token);
        
        // Get user data
        var connection = await Connection.open(endPoint, settings: settings);
        final result = await connection.execute(
          Sql.named('SELECT * FROM "User" WHERE user_id = @userId'),
          parameters: {'userId': payload.userId},
        );
        await connection.close();
        
        if (result.isEmpty) {
          return Response(
            404,
            body: _jsonEncode({'error': 'User not found'}),
            headers: jsonHeaders,
          );
        }
        
        // Convert ResultRow to Map<String, dynamic>
        final Map<String, dynamic> userMap = Map<String, dynamic>.from(result.first.toColumnMap());
        
        // Convert to UserDto
        final user = UserDto.fromJson(userMap).toJson();
        
        return Response.ok(
          _jsonEncode(user),
          headers: jsonHeaders,
        );
      } catch (e) {
        return Response(
          401,
          body: _jsonEncode({'error': 'Invalid token'}),
          headers: jsonHeaders,
        );
      }
    } catch (e) {
      print('Error in getUserData: $e');
      return Response.internalServerError(
        body: _jsonEncode({'error': 'Failed to get user data'}),
        headers: jsonHeaders,
      );
    }
  }
  
  @Route.post('/auth/refresh/')
  Future<Response> refreshToken(Request request) async {
    try {
      // Parse request body
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final refreshToken = data['refresh_token'] as String;
      
      try {
        // Verify refresh token
        final payload = JwtUtil.verifyToken(refreshToken);
        
        var connection = await Connection.open(endPoint, settings: settings);
        
        // Check if refresh token exists in database
        final tokenResult = await connection.execute(
          Sql.named(
            'SELECT * FROM "refresh_tokens" WHERE user_id = @userId AND token = @token AND expires_at > @now',
          ),
          parameters: {
            'userId': payload.userId,
            'token': refreshToken,
            'now': DateTime.now(),
          },
        );
        
        if (tokenResult.isEmpty) {
          await connection.close();
          return Response(
            401,
            body: _jsonEncode({'error': 'Invalid refresh token'}),
            headers: jsonHeaders,
          );
        }
        
        // Generate new tokens
        final newAccessToken = JwtUtil.generateAccessToken(payload.userId, payload.email);
        final newRefreshToken = JwtUtil.generateRefreshToken(payload.userId, payload.email);
        
        // Delete old refresh token
        await connection.execute(
          Sql.named(
            'DELETE FROM "refresh_tokens" WHERE user_id = @userId AND token = @token',
          ),
          parameters: {
            'userId': payload.userId,
            'token': refreshToken,
          },
        );
        
        // Store new refresh token
        await connection.execute(
          Sql.named(
            'INSERT INTO "refresh_tokens" (user_id, token, expires_at) VALUES (@userId, @token, @expiresAt)',
          ),
          parameters: {
            'userId': payload.userId,
            'token': newRefreshToken,
            'expiresAt': DateTime.now().add(Duration(days: 4)),
          },
        );
        
        await connection.close();
        
        // Return both tokens
        final tokenResponse = TokenResponseDto(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
        
        return Response.ok(
          _jsonEncode(tokenResponse.toJson()),
          headers: jsonHeaders,
        );
      } catch (e) {
        return Response(
          401,
          body: _jsonEncode({'error': 'Invalid refresh token'}),
          headers: jsonHeaders,
        );
      }
    } catch (e) {
      print('Error in refreshToken: $e');
      return Response.internalServerError(
        body: _jsonEncode({'error': 'Failed to refresh token'}),
        headers: jsonHeaders,
      );
    }
  }
  
  String _jsonEncode(Object? data) => const JsonEncoder.withIndent(' ').convert(data);
  
  Router get router => _$AuthServiceRouter(this);
}
