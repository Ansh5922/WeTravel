import '../../domain/repositories/expenses_repository.dart';
import '../datasources/expenses_remote_data_source.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  final ExpensesRemoteDataSource remoteDataSource;

  ExpensesRepositoryImpl({required this.remoteDataSource});
}
