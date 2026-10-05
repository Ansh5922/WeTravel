import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/expense_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getGroupExpenses(String tripId, {String? status});
  Future<ExpenseModel> createExpense({
    required String tripId,
    double? amount,
    String? description,
    String? category,
    String? receiptImageUrl,
    List<String>? splitMemberIds,
  });
  Future<ExpenseLedgerModel> getGroupLedger(String tripId);
  Future<List<ExpenseSettlementModel>> getSettlements(String tripId);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final Dio dio;

  ExpenseRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ExpenseModel>> getGroupExpenses(String tripId, {String? status}) async {
    final endpoint = '${ApiConstants.trips}/$tripId/expenses';
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    debugPrint('[EXPENSE_REMOTE_DS] 🚀 GET $endpoint Params: $queryParams');

    try {
      final response = await dio.get(endpoint, queryParameters: queryParams);
      debugPrint('[EXPENSE_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[EXPENSE_REMOTE_DS] 📦 Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final list = (data['data'] as Map<String, dynamic>?)?['expenses'] as List<dynamic>? ?? [];

      return list
          .map((item) => ExpenseModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('[EXPENSE_REMOTE_DS] ❌ DioError on getGroupExpenses: [${e.response?.statusCode}] ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? 'Failed to fetch trip expenses.';
      throw ServerException(msg, e.response?.statusCode);
    } catch (e) {
      debugPrint('[EXPENSE_REMOTE_DS] 💥 Unexpected Error on getGroupExpenses: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ExpenseModel> createExpense({
    required String tripId,
    double? amount,
    String? description,
    String? category,
    String? receiptImageUrl,
    List<String>? splitMemberIds,
  }) async {
    final endpoint = '${ApiConstants.trips}/$tripId/expenses';
    final payload = <String, dynamic>{
      if (amount != null) 'amount': amount,
      if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
      if (category != null && category.trim().isNotEmpty) 'category': category.trim(),
      if (receiptImageUrl != null && receiptImageUrl.trim().isNotEmpty) 'receiptImageUrl': receiptImageUrl.trim(),
      if (splitMemberIds != null && splitMemberIds.isNotEmpty) 'splitMemberIds': splitMemberIds,
    };

    debugPrint('[EXPENSE_REMOTE_DS] 🚀 POST $endpoint Payload: $payload');

    try {
      final response = await dio.post(endpoint, data: payload);
      debugPrint('[EXPENSE_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[EXPENSE_REMOTE_DS] 📦 Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final expenseJson = (data['data'] as Map<String, dynamic>?)?['expense'] as Map<String, dynamic>? ?? data;

      return ExpenseModel.fromJson(expenseJson);
    } on DioException catch (e) {
      debugPrint('[EXPENSE_REMOTE_DS] ❌ DioError on createExpense: [${e.response?.statusCode}] ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? 'Failed to create expense.';
      throw ServerException(msg, e.response?.statusCode);
    } catch (e) {
      debugPrint('[EXPENSE_REMOTE_DS] 💥 Unexpected Error on createExpense: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ExpenseLedgerModel> getGroupLedger(String tripId) async {
    final endpoint = '${ApiConstants.trips}/$tripId/expenses/ledger';
    debugPrint('[EXPENSE_REMOTE_DS] 🚀 GET $endpoint');

    try {
      final response = await dio.get(endpoint);
      debugPrint('[EXPENSE_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[EXPENSE_REMOTE_DS] 📦 Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      return ExpenseLedgerModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('[EXPENSE_REMOTE_DS] ❌ DioError on getGroupLedger: [${e.response?.statusCode}] ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? 'Failed to fetch group ledger.';
      throw ServerException(msg, e.response?.statusCode);
    } catch (e) {
      debugPrint('[EXPENSE_REMOTE_DS] 💥 Unexpected Error on getGroupLedger: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ExpenseSettlementModel>> getSettlements(String tripId) async {
    final endpoint = '${ApiConstants.trips}/$tripId/expenses/settlements';
    debugPrint('[EXPENSE_REMOTE_DS] 🚀 GET $endpoint');

    try {
      final response = await dio.get(endpoint);
      debugPrint('[EXPENSE_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[EXPENSE_REMOTE_DS] 📦 Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final list = (data['data'] as Map<String, dynamic>?)?['settlements'] as List<dynamic>? ?? [];

      return list
          .map((item) => ExpenseSettlementModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('[EXPENSE_REMOTE_DS] ❌ DioError on getSettlements: [${e.response?.statusCode}] ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? 'Failed to fetch settlements.';
      throw ServerException(msg, e.response?.statusCode);
    } catch (e) {
      debugPrint('[EXPENSE_REMOTE_DS] 💥 Unexpected Error on getSettlements: $e');
      throw ServerException(e.toString());
    }
  }
}
