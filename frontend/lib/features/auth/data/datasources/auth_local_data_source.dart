import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<bool> hasToken();
  Future<void> setPreferencesCompleted({required String userId, required bool completed});
  Future<bool> hasCompletedPreferences(String userId);
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
      return await storage.read(key: AppConstants.tokenKey);
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

  @override
  Future<void> setPreferencesCompleted({required String userId, required bool completed}) async {
    try {
      final key = 'preferences_completed_$userId';
      await storage.write(key: key, value: completed.toString());
      await storage.write(key: 'preferences_completed_global', value: completed.toString());
    } catch (_) {}
  }

  @override
  Future<bool> hasCompletedPreferences(String userId) async {
    try {
      final key = 'preferences_completed_$userId';
      final val = await storage.read(key: key);
      if (val == 'true') return true;
      final globalVal = await storage.read(key: 'preferences_completed_global');
      return globalVal == 'true';
    } catch (_) {
      return false;
    }
  }
}
