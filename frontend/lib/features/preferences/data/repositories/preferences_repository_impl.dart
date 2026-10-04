import '../../domain/repositories/preferences_repository.dart';
import '../datasources/preferences_remote_data_source.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesRemoteDataSource remoteDataSource;

  PreferencesRepositoryImpl({required this.remoteDataSource});
}
