import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend/features/auth/data/models/auth_response_model.dart';
import 'package:frontend/features/auth/data/models/user_model.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';

class MockAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;
  MockAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('UserModel Serialization', () {
    test('parses full signup/me payload safely with username and timestamps', () {
      final json = {
        'id': 'uuid-1234',
        'email': 'traveler@wetravel.test',
        'username': 'globetrotter',
        'fullName': 'Aria Vance',
        'phone': '+1234567890',
        'isPremium': true,
        'createdAt': '2026-10-02T10:00:00.000Z',
      };

      final model = UserModel.fromJson(json);

      expect(model.id, 'uuid-1234');
      expect(model.email, 'traveler@wetravel.test');
      expect(model.username, 'globetrotter');
      expect(model.fullName, 'Aria Vance');
      expect(model.phone, '+1234567890');
      expect(model.isPremium, true);
      expect(model.createdAt, DateTime.parse('2026-10-02T10:00:00.000Z'));

      final serialized = model.toJson();
      expect(serialized['id'], 'uuid-1234');
      expect(serialized['email'], 'traveler@wetravel.test');
      expect(serialized['username'], 'globetrotter');
      expect(serialized['fullName'], 'Aria Vance');
      expect(serialized['phone'], '+1234567890');
      expect(serialized['isPremium'], true);
      expect(serialized['createdAt'], '2026-10-02T10:00:00.000Z');
    });

    test('parses stripped login payload safely when username is omitted', () {
      // Backend login response does NOT include username
      final json = {
        'id': 'uuid-5678',
        'email': 'login_user@wetravel.test',
        'fullName': 'Jordan Lee',
        'phone': null,
        'isPremium': false,
        'createdAt': '2026-10-01T08:30:00.000Z',
      };

      final model = UserModel.fromJson(json);

      expect(model.id, 'uuid-5678');
      expect(model.email, 'login_user@wetravel.test');
      expect(model.username, isNull);
      expect(model.fullName, 'Jordan Lee');
      expect(model.phone, isNull);
      expect(model.isPremium, false);
      expect(model.createdAt, isNotNull);
    });

    test('copyWith produces updated model correctly', () {
      const initial = UserModel(
        id: '1',
        email: 'test@wetravel.test',
        username: 'user1',
      );

      final updated = initial.copyWith(username: 'user2', isPremium: true);

      expect(updated.id, '1');
      expect(updated.email, 'test@wetravel.test');
      expect(updated.username, 'user2');
      expect(updated.isPremium, true);
    });
  });

  group('AuthResponseModel Serialization', () {
    test('parses standard backend wrapped success response with token', () {
      final backendResponse = {
        'status': 'success',
        'message': 'Logged in successfully.',
        'data': {
          'user': {
            'id': 'usr_99',
            'email': 'wanderer@wetravel.test',
            'fullName': 'Sam River',
            'isPremium': false,
          },
          'token': 'jwt.token.string',
        },
      };

      final authResponse = AuthResponseModel.fromJson(backendResponse);

      expect(authResponse.token, 'jwt.token.string');
      expect(authResponse.user.id, 'usr_99');
      expect(authResponse.user.email, 'wanderer@wetravel.test');
      expect(authResponse.user.fullName, 'Sam River');
    });

    test('parses me payload where token is null', () {
      final backendResponse = {
        'status': 'success',
        'data': {
          'user': {
            'id': 'usr_100',
            'email': 'current@wetravel.test',
            'username': 'currentexplorer',
          },
        },
      };

      final authResponse = AuthResponseModel.fromJson(backendResponse);

      expect(authResponse.token, isNull);
      expect(authResponse.user.id, 'usr_100');
      expect(authResponse.user.email, 'current@wetravel.test');
      expect(authResponse.user.username, 'currentexplorer');
    });
  });

  group('AuthRemoteDataSource', () {
    late Dio dio;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: ApiConstants.backendBaseUrl));
    });

    test('login sends credentials and returns parsed AuthResponseModel', () async {
      dio.httpClientAdapter = MockAdapter((options) async {
        expect(options.path, '/api/auth/login');
        expect(options.method, 'POST');
        final data = options.data as Map<String, dynamic>;
        expect(data['email'], 'alex@wetravel.test');
        expect(data['password'], 'Password123!');

        final payload = jsonEncode({
          'status': 'success',
          'message': 'Logged in successfully.',
          'data': {
            'user': {
              'id': 'usr_1',
              'email': 'alex@wetravel.test',
              'fullName': 'Alex Morgan',
            },
            'token': 'mock-jwt-token',
          },
        });

        return ResponseBody.fromString(
          payload,
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final dataSource = AuthRemoteDataSourceImpl(dio: dio);
      final result = await dataSource.login(
        email: 'alex@wetravel.test',
        password: 'Password123!',
      );

      expect(result.token, 'mock-jwt-token');
      expect(result.user.id, 'usr_1');
      expect(result.user.email, 'alex@wetravel.test');
    });

    test('signup sends contract payload and returns AuthResponseModel', () async {
      dio.httpClientAdapter = MockAdapter((options) async {
        expect(options.path, '/api/auth/signup');
        expect(options.method, 'POST');
        final data = options.data as Map<String, dynamic>;
        expect(data['email'], 'newuser@wetravel.test');
        expect(data['username'], 'newtraveler');
        expect(data['fullName'], 'New Traveler');
        expect(data['phone'], '+15550001');

        final payload = jsonEncode({
          'status': 'success',
          'message': 'Account created successfully.',
          'data': {
            'user': {
              'id': 'usr_2',
              'email': 'newuser@wetravel.test',
              'username': 'newtraveler',
              'fullName': 'New Traveler',
              'phone': '+15550001',
              'isPremium': false,
            },
            'token': 'signup-jwt-token',
          },
        });

        return ResponseBody.fromString(
          payload,
          201,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final dataSource = AuthRemoteDataSourceImpl(dio: dio);
      final result = await dataSource.signup(
        email: 'newuser@wetravel.test',
        password: 'Password123!',
        username: 'newtraveler',
        fullName: 'New Traveler',
        phone: '+15550001',
      );

      expect(result.token, 'signup-jwt-token');
      expect(result.user.id, 'usr_2');
      expect(result.user.username, 'newtraveler');
    });

    test('getCurrentUser attaches Authorization header and returns UserModel', () async {
      dio.httpClientAdapter = MockAdapter((options) async {
        expect(options.path, '/api/auth/me');
        expect(options.method, 'GET');
        expect(options.headers['Authorization'], 'Bearer valid-jwt-token');

        final payload = jsonEncode({
          'status': 'success',
          'data': {
            'user': {
              'id': 'usr_me',
              'email': 'me@wetravel.test',
              'username': 'myprofile',
              'isPremium': true,
            },
          },
        });

        return ResponseBody.fromString(
          payload,
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final dataSource = AuthRemoteDataSourceImpl(dio: dio);
      final user = await dataSource.getCurrentUser('valid-jwt-token');

      expect(user.id, 'usr_me');
      expect(user.email, 'me@wetravel.test');
      expect(user.username, 'myprofile');
      expect(user.isPremium, true);
    });

    test('throws AuthException with backend message on 400 Bad Request', () async {
      dio.httpClientAdapter = MockAdapter((options) async {
        final payload = jsonEncode({
          'status': 'error',
          'message': 'Password must be at least 8 characters long.',
        });

        return ResponseBody.fromString(
          payload,
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final dataSource = AuthRemoteDataSourceImpl(dio: dio);

      expect(
        () => dataSource.login(email: 'test@wetravel.test', password: '123'),
        throwsA(
          isA<AuthException>()
              .having((e) => e.message, 'message', 'Password must be at least 8 characters long.')
              .having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });

    test('throws AuthException on 401 Unauthorized', () async {
      dio.httpClientAdapter = MockAdapter((options) async {
        final payload = jsonEncode({
          'status': 'error',
          'message': 'Invalid email or password.',
        });

        return ResponseBody.fromString(
          payload,
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final dataSource = AuthRemoteDataSourceImpl(dio: dio);

      expect(
        () => dataSource.login(email: 'test@wetravel.test', password: 'wrong'),
        throwsA(
          isA<AuthException>()
              .having((e) => e.message, 'message', 'Invalid email or password.')
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('throws AuthException on 409 Conflict', () async {
      dio.httpClientAdapter = MockAdapter((options) async {
        final payload = jsonEncode({
          'status': 'error',
          'message': 'Email is already registered.',
        });

        return ResponseBody.fromString(
          payload,
          409,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final dataSource = AuthRemoteDataSourceImpl(dio: dio);

      expect(
        () => dataSource.signup(
          email: 'duplicate@wetravel.test',
          password: 'Password123!',
          username: 'dupuser',
        ),
        throwsA(
          isA<AuthException>()
              .having((e) => e.message, 'message', 'Email is already registered.')
              .having((e) => e.statusCode, 'statusCode', 409),
        ),
      );
    });
  });

  group('AuthRepositoryImpl', () {
    late Dio dio;
    late AuthRemoteDataSource remoteDataSource;
    late AuthRepositoryImpl repository;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: ApiConstants.backendBaseUrl));
      remoteDataSource = AuthRemoteDataSourceImpl(dio: dio);
      repository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);
    });

    test('returns AuthResponseEntity on successful login', () async {
      dio.httpClientAdapter = MockAdapter((options) async {
        final payload = jsonEncode({
          'status': 'success',
          'data': {
            'user': {
              'id': 'repo_usr_1',
              'email': 'success@wetravel.test',
            },
            'token': 'repo-token',
          },
        });
        return ResponseBody.fromString(payload, 200);
      });

      final result = await repository.login(
        email: 'success@wetravel.test',
        password: 'Password123!',
      );

      expect(result.token, 'repo-token');
      expect(result.user.id, 'repo_usr_1');
    });

    test('maps 401 error into AuthFailure preserving backend message', () async {
      dio.httpClientAdapter = MockAdapter((options) async {
        final payload = jsonEncode({
          'status': 'error',
          'message': 'Invalid email or password.',
        });
        return ResponseBody.fromString(payload, 401);
      });

      expect(
        () => repository.login(
          email: 'wrong@wetravel.test',
          password: 'wrong',
        ),
        throwsA(
          isA<AuthFailure>()
              .having((f) => f.message, 'message', 'Invalid email or password.')
              .having((f) => f.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('maps 409 error into AuthFailure preserving backend message', () async {
      dio.httpClientAdapter = MockAdapter((options) async {
        final payload = jsonEncode({
          'status': 'error',
          'message': 'Username is already taken. Please choose another.',
        });
        return ResponseBody.fromString(payload, 409);
      });

      expect(
        () => repository.signup(
          email: 'test@wetravel.test',
          password: 'Password123!',
          username: 'taken',
        ),
        throwsA(
          isA<AuthFailure>()
              .having((f) => f.message, 'message', 'Username is already taken. Please choose another.')
              .having((f) => f.statusCode, 'statusCode', 409),
        ),
      );
    });

    test('maps 500 error into ServerFailure', () async {
      dio.httpClientAdapter = MockAdapter((options) async {
        final payload = jsonEncode({
          'status': 'error',
          'message': 'Internal database connection error.',
        });
        return ResponseBody.fromString(payload, 500);
      });

      expect(
        () => repository.getCurrentUser('token'),
        throwsA(
          isA<ServerFailure>()
              .having((f) => f.message, 'message', 'Internal database connection error.')
              .having((f) => f.statusCode, 'statusCode', 500),
        ),
      );
    });
  });
}
