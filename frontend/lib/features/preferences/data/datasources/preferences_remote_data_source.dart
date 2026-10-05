import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/preferences_model.dart';

abstract class PreferencesRemoteDataSource {
  Future<PreferencesModel> getPreferences();
  Future<({PreferencesModel preferences, String message})> updatePreferences({
    String? travelStyle,
    String? dietaryPreference,
    double? budget,
    String? budgetTier,
    String? pacePreference,
    String? rawPreferenceNotes,
  });
}

class PreferencesRemoteDataSourceImpl implements PreferencesRemoteDataSource {
  final Dio dio;

  PreferencesRemoteDataSourceImpl({required this.dio});

  @override
  Future<PreferencesModel> getPreferences() async {
    const endpoint = ApiConstants.userProfile;
    debugPrint('[PREFERENCES_REMOTE_DS] 🚀 GET $endpoint');

    try {
      final response = await dio.get(endpoint);
      debugPrint('[PREFERENCES_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[PREFERENCES_REMOTE_DS] 📦 Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      return PreferencesModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('[PREFERENCES_REMOTE_DS] ❌ DioError on GET: [${e.response?.statusCode}] ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? 'Failed to fetch preferences.';
      throw ServerException(msg, e.response?.statusCode);
    } catch (e) {
      debugPrint('[PREFERENCES_REMOTE_DS] 💥 Unexpected Error on GET: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<({PreferencesModel preferences, String message})> updatePreferences({
    String? travelStyle,
    String? dietaryPreference,
    double? budget,
    String? budgetTier,
    String? pacePreference,
    String? rawPreferenceNotes,
  }) async {
    const endpoint = ApiConstants.userProfile;
    final payload = <String, dynamic>{
      if (travelStyle != null && travelStyle.trim().isNotEmpty) 'travelStyle': travelStyle.trim(),
      if (dietaryPreference != null && dietaryPreference.trim().isNotEmpty) 'dietaryPreference': dietaryPreference.trim(),
      if (budget != null) 'budget': budget,
      if (budgetTier != null && budgetTier.trim().isNotEmpty) 'budgetTier': budgetTier.trim(),
      if (pacePreference != null && pacePreference.trim().isNotEmpty) 'pacePreference': pacePreference.trim(),
      if (rawPreferenceNotes != null && rawPreferenceNotes.trim().isNotEmpty) 'rawPreferenceNotes': rawPreferenceNotes.trim(),
    };

    debugPrint('[PREFERENCES_REMOTE_DS] 🚀 PATCH $endpoint Payload: $payload');

    try {
      final response = await dio.patch(endpoint, data: payload);
      debugPrint('[PREFERENCES_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[PREFERENCES_REMOTE_DS] 📦 Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final message = data['message']?.toString() ?? 'Preferences updated successfully.';
      final preferences = PreferencesModel.fromJson(data);

      return (preferences: preferences, message: message);
    } on DioException catch (e) {
      debugPrint('[PREFERENCES_REMOTE_DS] ❌ DioError on PATCH: [${e.response?.statusCode}] ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? 'Failed to update preferences.';
      throw ServerException(msg, e.response?.statusCode);
    } catch (e) {
      debugPrint('[PREFERENCES_REMOTE_DS] 💥 Unexpected Error on PATCH: $e');
      throw ServerException(e.toString());
    }
  }
}
