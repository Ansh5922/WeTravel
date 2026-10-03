import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<bool> hasToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;

  const AuthLocalDataSourceImpl({required this.storage});

  @override
  Future<void> saveToken(String token) async {
    try {
      await storage.write(key: AppConstants.tokenKey, value: token);
    } catch (_) {}
  }

  @override
  Future<String?> getToken() async {
    try {
      return await storage
          .read(key: AppConstants.tokenKey)
          .timeout(const Duration(milliseconds: 300), onTimeout: () => null);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await storage.delete(key: AppConstants.tokenKey);
    } catch (_) {}
  }

  @override
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
