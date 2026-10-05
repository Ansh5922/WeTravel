import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/inbox_invite_model.dart';

abstract class InboxRemoteDataSource {
  Future<List<InboxInviteModel>> getMyInvites();
  Future<String> respondToInvite({required String inviteId, required String action});
}

class InboxRemoteDataSourceImpl implements InboxRemoteDataSource {
  final Dio dio;

  InboxRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<InboxInviteModel>> getMyInvites() async {
    const endpoint = ApiConstants.myInvites;
    debugPrint('[INBOX_REMOTE_DS] 🚀 GET $endpoint');

    try {
      final response = await dio.get(endpoint);
      debugPrint('[INBOX_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[INBOX_REMOTE_DS] 📦 Response Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final invitesData = (data['data'] as Map<String, dynamic>?)?['invites'] as List<dynamic>? ?? [];

      return invitesData
          .map((json) => InboxInviteModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('[INBOX_REMOTE_DS] ❌ DioError: [${e.response?.statusCode}] ${e.message}');
      final errorMessage = e.response?.data?['message']?.toString() ??
          'Failed to fetch trip invitations.';
      throw ServerException(errorMessage, e.response?.statusCode);
    } catch (e) {
      debugPrint('[INBOX_REMOTE_DS] 💥 Unexpected Error: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> respondToInvite({required String inviteId, required String action}) async {
    final endpoint = '${ApiConstants.trips}/invites/$inviteId';
    final requestBody = {'action': action};

    debugPrint('[INBOX_REMOTE_DS] 🚀 PATCH $endpoint Body: $requestBody');

    try {
      final response = await dio.patch(endpoint, data: requestBody);
      debugPrint('[INBOX_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[INBOX_REMOTE_DS] 📦 Response Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      return data['message']?.toString() ?? 'Invitation status updated successfully.';
    } on DioException catch (e) {
      debugPrint('[INBOX_REMOTE_DS] ❌ DioError: [${e.response?.statusCode}] ${e.message}');
      final errorMessage = e.response?.data?['message']?.toString() ??
          'Failed to update invitation status.';
      throw ServerException(errorMessage, e.response?.statusCode);
    } catch (e) {
      debugPrint('[INBOX_REMOTE_DS] 💥 Unexpected Error: $e');
      throw ServerException(e.toString());
    }
  }
}
