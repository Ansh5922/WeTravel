import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/signup_usecase.dart';
import '../../features/auth/domain/usecases/google_signin_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_trips_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

import '../../features/inbox/data/datasources/inbox_remote_data_source.dart';
import '../../features/inbox/data/repositories/inbox_repository_impl.dart';
import '../../features/inbox/domain/repositories/inbox_repository.dart';
import '../../features/inbox/domain/usecases/get_my_invites_usecase.dart';
import '../../features/inbox/domain/usecases/respond_to_invite_usecase.dart';
import '../../features/inbox/presentation/bloc/inbox_bloc.dart';

import '../../features/preferences/data/datasources/preferences_remote_data_source.dart';
import '../../features/preferences/data/repositories/preferences_repository_impl.dart';
import '../../features/preferences/domain/repositories/preferences_repository.dart';
import '../../features/preferences/domain/usecases/get_preferences_usecase.dart';
import '../../features/preferences/domain/usecases/update_preferences_usecase.dart';
import '../../features/preferences/presentation/bloc/preferences_bloc.dart';

import '../../features/itinerary/data/datasources/itinerary_remote_data_source.dart';
import '../../features/itinerary/data/repositories/itinerary_repository_impl.dart';
import '../../features/itinerary/domain/repositories/itinerary_repository.dart';
import '../../features/itinerary/domain/usecases/generate_itinerary_usecase.dart';
import '../../features/itinerary/domain/usecases/get_itineraries_usecase.dart';
import '../../features/itinerary/domain/usecases/get_itinerary_detail_usecase.dart';
import '../../features/itinerary/domain/usecases/select_itinerary_usecase.dart';
import '../../features/itinerary/presentation/bloc/itinerary_bloc.dart';

import '../../features/expenses/data/datasources/expense_remote_data_source.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/expenses/domain/usecases/create_expense_usecase.dart';
import '../../features/expenses/domain/usecases/get_group_expenses_usecase.dart';
import '../../features/expenses/domain/usecases/get_group_ledger_usecase.dart';
import '../../features/expenses/domain/usecases/get_settlements_usecase.dart';
import '../../features/expenses/presentation/bloc/expense_bloc.dart';

import '../../features/trips/data/datasources/trip_remote_data_source.dart';
import '../../features/trips/data/repositories/trip_repository_impl.dart';
import '../../features/trips/domain/repositories/trip_repository.dart';
import '../../features/trips/domain/usecases/create_trip_usecase.dart';
import '../../features/trips/domain/usecases/get_group_consensus_usecase.dart';
import '../../features/trips/domain/usecases/get_my_trips_usecase.dart';
import '../../features/trips/domain/usecases/get_trip_details_usecase.dart';
import '../../features/trips/domain/usecases/invite_trip_member_usecase.dart';
import '../../features/trips/domain/usecases/join_trip_via_token_usecase.dart';
import '../../features/trips/presentation/bloc/trip_bloc.dart';

import '../../features/friends/data/datasources/friend_remote_data_source.dart';
import '../../features/friends/data/repositories/friend_repository_impl.dart';
import '../../features/friends/domain/repositories/friend_repository.dart';
import '../../features/friends/domain/usecases/friend_usecases.dart';
import '../../features/friends/presentation/bloc/friend_bloc.dart';

import '../../features/group_chat/data/datasources/chat_remote_data_source.dart';
import '../../features/group_chat/data/repositories/chat_repository_impl.dart';
import '../../features/group_chat/domain/repositories/chat_repository.dart';
import '../../features/group_chat/domain/usecases/chat_usecases.dart';
import '../../features/group_chat/presentation/bloc/chat_bloc.dart';

import '../../features/memories/data/datasources/memory_remote_data_source.dart';
import '../../features/memories/data/repositories/memory_repository_impl.dart';
import '../../features/memories/domain/repositories/memory_repository.dart';
import '../../features/memories/domain/usecases/memory_usecases.dart';
import '../../features/memories/presentation/bloc/memory_bloc.dart';

import '../../features/polls/data/datasources/poll_remote_data_source.dart';
import '../../features/polls/data/repositories/poll_repository_impl.dart';
import '../../features/polls/domain/repositories/poll_repository.dart';
import '../../features/polls/domain/usecases/poll_usecases.dart';
import '../../features/polls/presentation/bloc/poll_bloc.dart';

/// Centralized Factory for creating Clean Architecture layers and BLoC instances.
class ServiceLocator {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.backendBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint('--------------------------------------------------');
          debugPrint('📡 [DIO REQ] ${options.method} ${options.baseUrl}${options.path}');
          
          // Inject Bearer token if present
          final token = await authLocalDataSource.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (options.headers.isNotEmpty) {
            debugPrint('🔑 Headers: ${options.headers}');
          }
          if (options.data != null) {
            debugPrint('📤 Body: ${options.data}');
          }
          debugPrint('--------------------------------------------------');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('--------------------------------------------------');
          debugPrint('📥 [DIO RES] ${response.statusCode} ${response.requestOptions.path}');
          debugPrint('📦 Payload: ${response.data}');
          debugPrint('--------------------------------------------------');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('--------------------------------------------------');
          debugPrint('❌ [DIO ERR] ${e.response?.statusCode ?? 'NETWORK'} ${e.requestOptions.path}');
          debugPrint('💥 Message: ${e.message}');
          if (e.response?.data != null) {
            debugPrint('📦 Response Data: ${e.response?.data}');
          }
          debugPrint('--------------------------------------------------');
          return handler.next(e);
        },
      ),
    );

    return dio;
  }

  // ── Auth Singletons ─────────────────────────────────────────────────────────
  static final AuthLocalDataSource authLocalDataSource =
      AuthLocalDataSourceImpl(storage: _storage);

  static final AuthRemoteDataSource authRemoteDataSource =
      AuthRemoteDataSourceImpl(dio: _dio);

  static final AuthRepository authRepository =
      AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);

  static final LoginUseCase loginUseCase = LoginUseCase(authRepository);
  static final SignupUseCase signupUseCase = SignupUseCase(authRepository);
  static final GoogleSignInUseCase googleSignInUseCase =
      GoogleSignInUseCase(authRepository);
  static final GetCurrentUserUseCase getCurrentUserUseCase =
      GetCurrentUserUseCase(authRepository);

  // ── Profile Singletons ──────────────────────────────────────────────────────
  static final ProfileRemoteDataSource profileRemoteDataSource =
      ProfileRemoteDataSourceImpl(dio: _dio);

  static final ProfileRepository profileRepository =
      ProfileRepositoryImpl(remoteDataSource: profileRemoteDataSource);

  static final GetProfileUseCase getProfileUseCase =
      GetProfileUseCase(profileRepository);

  static final UpdateProfileUseCase updateProfileUseCase =
      UpdateProfileUseCase(profileRepository);

  // ── Home Singletons ─────────────────────────────────────────────────────────
  static final HomeRemoteDataSource homeRemoteDataSource =
      HomeRemoteDataSourceImpl(dio: _dio);

  static final HomeRepository homeRepository =
      HomeRepositoryImpl(remoteDataSource: homeRemoteDataSource);

  static final GetHomeTripsUseCase getHomeTripsUseCase =
      GetHomeTripsUseCase(homeRepository);

  // ── Inbox Singletons ────────────────────────────────────────────────────────
  static final InboxRemoteDataSource inboxRemoteDataSource =
      InboxRemoteDataSourceImpl(dio: _dio);

  static final InboxRepository inboxRepository =
      InboxRepositoryImpl(remoteDataSource: inboxRemoteDataSource);

  static final GetMyInvitesUseCase getMyInvitesUseCase =
      GetMyInvitesUseCase(inboxRepository);

  static final RespondToInviteUseCase respondToInviteUseCase =
      RespondToInviteUseCase(inboxRepository);

  // ── Preferences Singletons ──────────────────────────────────────────────────
  static final PreferencesRemoteDataSource preferencesRemoteDataSource =
      PreferencesRemoteDataSourceImpl(dio: _dio);

  static final PreferencesRepository preferencesRepository =
      PreferencesRepositoryImpl(remoteDataSource: preferencesRemoteDataSource);

  static final GetPreferencesUseCase getPreferencesUseCase =
      GetPreferencesUseCase(preferencesRepository);

  static final UpdatePreferencesUseCase updatePreferencesUseCase =
      UpdatePreferencesUseCase(preferencesRepository);

  // ── Itinerary Singletons ────────────────────────────────────────────────────
  static final ItineraryRemoteDataSource itineraryRemoteDataSource =
      ItineraryRemoteDataSourceImpl(dio: _dio);

  static final ItineraryRepository itineraryRepository =
      ItineraryRepositoryImpl(remoteDataSource: itineraryRemoteDataSource);

  static final GetItinerariesUseCase getItinerariesUseCase =
      GetItinerariesUseCase(itineraryRepository);

  static final GetItineraryDetailUseCase getItineraryDetailUseCase =
      GetItineraryDetailUseCase(itineraryRepository);

  static final GenerateItineraryUseCase generateItineraryUseCase =
      GenerateItineraryUseCase(itineraryRepository);

  static final SelectItineraryUseCase selectItineraryUseCase =
      SelectItineraryUseCase(itineraryRepository);

  // ── Expense Singletons ──────────────────────────────────────────────────────
  static final ExpenseRemoteDataSource expenseRemoteDataSource =
      ExpenseRemoteDataSourceImpl(dio: _dio);

  static final ExpenseRepository expenseRepository =
      ExpenseRepositoryImpl(remoteDataSource: expenseRemoteDataSource);

  static final GetGroupExpensesUseCase getGroupExpensesUseCase =
      GetGroupExpensesUseCase(expenseRepository);

  static final CreateExpenseUseCase createExpenseUseCase =
      CreateExpenseUseCase(expenseRepository);

  static final GetGroupLedgerUseCase getGroupLedgerUseCase =
      GetGroupLedgerUseCase(expenseRepository);

  static final GetSettlementsUseCase getSettlementsUseCase =
      GetSettlementsUseCase(expenseRepository);

  // ── Trip Singletons ─────────────────────────────────────────────────────────
  static final TripRemoteDataSource tripRemoteDataSource =
      TripRemoteDataSourceImpl(dio: _dio);

  static final TripRepository tripRepository =
      TripRepositoryImpl(remoteDataSource: tripRemoteDataSource);

  static final CreateTripUseCase createTripUseCase =
      CreateTripUseCase(tripRepository);

  static final GetMyTripsUseCase getMyTripsUseCase =
      GetMyTripsUseCase(tripRepository);

  static final GetTripDetailsUseCase getTripDetailsUseCase =
      GetTripDetailsUseCase(tripRepository);

  static final InviteTripMemberUseCase inviteTripMemberUseCase =
      InviteTripMemberUseCase(tripRepository);

  static final JoinTripViaTokenUseCase joinTripViaTokenUseCase =
      JoinTripViaTokenUseCase(tripRepository);

  static final GetGroupConsensusUseCase getGroupConsensusUseCase =
      GetGroupConsensusUseCase(tripRepository);

  // ── Friends Singletons ──────────────────────────────────────────────────────
  static final FriendRemoteDataSource friendRemoteDataSource =
      FriendRemoteDataSourceImpl(dio: _dio);

  static final FriendRepository friendRepository =
      FriendRepositoryImpl(remoteDataSource: friendRemoteDataSource);

  static final GetFriendsUseCase getFriendsUseCase =
      GetFriendsUseCase(friendRepository);

  static final GetPendingFriendRequestsUseCase getPendingFriendRequestsUseCase =
      GetPendingFriendRequestsUseCase(friendRepository);

  static final SendFriendRequestUseCase sendFriendRequestUseCase =
      SendFriendRequestUseCase(friendRepository);

  static final RespondFriendRequestUseCase respondFriendRequestUseCase =
      RespondFriendRequestUseCase(friendRepository);

  // ── Chat Singletons ─────────────────────────────────────────────────────────
  static final ChatRemoteDataSource chatRemoteDataSource =
      ChatRemoteDataSourceImpl(dio: _dio);

  static final ChatRepository chatRepository =
      ChatRepositoryImpl(remoteDataSource: chatRemoteDataSource);

  static final GetChatMessagesUseCase getChatMessagesUseCase =
      GetChatMessagesUseCase(chatRepository);

  static final GetImageKitAuthUseCase getImageKitAuthUseCase =
      GetImageKitAuthUseCase(chatRepository);

  static final SendImageMessageUseCase sendImageMessageUseCase =
      SendImageMessageUseCase(chatRepository);

  // ── Memories Singletons ─────────────────────────────────────────────────────
  static final MemoryRemoteDataSource memoryRemoteDataSource =
      MemoryRemoteDataSourceImpl(dio: _dio);

  static final MemoryRepository memoryRepository =
      MemoryRepositoryImpl(remoteDataSource: memoryRemoteDataSource);

  static final GetMemoriesTimelineUseCase getMemoriesTimelineUseCase =
      GetMemoriesTimelineUseCase(memoryRepository);

  static final GetMemoryHighlightsUseCase getMemoryHighlightsUseCase =
      GetMemoryHighlightsUseCase(memoryRepository);

  static final UploadMemoriesUseCase uploadMemoriesUseCase =
      UploadMemoriesUseCase(memoryRepository);

  static final ToggleMemoryHighlightUseCase toggleMemoryHighlightUseCase =
      ToggleMemoryHighlightUseCase(memoryRepository);

  static final DeleteMemoryUseCase deleteMemoryUseCase =
      DeleteMemoryUseCase(memoryRepository);

  // ── Polls Singletons ────────────────────────────────────────────────────────
  static final PollRemoteDataSource pollRemoteDataSource =
      PollRemoteDataSourceImpl(dio: _dio);

  static final PollRepository pollRepository =
      PollRepositoryImpl(remoteDataSource: pollRemoteDataSource);

  static final GetPollsUseCase getPollsUseCase =
      GetPollsUseCase(pollRepository);

  static final CreatePollUseCase createPollUseCase =
      CreatePollUseCase(pollRepository);

  static final CastVoteUseCase castVoteUseCase =
      CastVoteUseCase(pollRepository);

  static final ClosePollUseCase closePollUseCase =
      ClosePollUseCase(pollRepository);

  // ── BLoC Factories ──────────────────────────────────────────────────────────

  static AuthBloc createAuthBloc() => AuthBloc(
        loginUseCase: loginUseCase,
        signupUseCase: signupUseCase,
        googleSignInUseCase: googleSignInUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
        localDataSource: authLocalDataSource,
      );

  static ProfileBloc createProfileBloc() => ProfileBloc(
        getProfileUseCase: getProfileUseCase,
        updateProfileUseCase: updateProfileUseCase,
      );

  static HomeBloc createHomeBloc() => HomeBloc(
        getHomeTripsUseCase: getHomeTripsUseCase,
      );

  static InboxBloc createInboxBloc() => InboxBloc(
        getMyInvitesUseCase: getMyInvitesUseCase,
        respondToInviteUseCase: respondToInviteUseCase,
      );

  static PreferencesBloc createPreferencesBloc() => PreferencesBloc(
        getPreferencesUseCase: getPreferencesUseCase,
        updatePreferencesUseCase: updatePreferencesUseCase,
      );

  static ItineraryBloc createItineraryBloc() => ItineraryBloc(
        getItinerariesUseCase: getItinerariesUseCase,
        getItineraryDetailUseCase: getItineraryDetailUseCase,
        generateItineraryUseCase: generateItineraryUseCase,
        selectItineraryUseCase: selectItineraryUseCase,
      );

  static ExpenseBloc createExpenseBloc() => ExpenseBloc(
        getGroupExpensesUseCase: getGroupExpensesUseCase,
        createExpenseUseCase: createExpenseUseCase,
        getGroupLedgerUseCase: getGroupLedgerUseCase,
        getSettlementsUseCase: getSettlementsUseCase,
      );

  static TripBloc createTripBloc() => TripBloc(
        createTripUseCase: createTripUseCase,
        getMyTripsUseCase: getMyTripsUseCase,
        getTripDetailsUseCase: getTripDetailsUseCase,
        inviteTripMemberUseCase: inviteTripMemberUseCase,
        joinTripViaTokenUseCase: joinTripViaTokenUseCase,
        getGroupConsensusUseCase: getGroupConsensusUseCase,
      );

  static FriendBloc createFriendBloc() => FriendBloc(
        getFriendsUseCase: getFriendsUseCase,
        getPendingFriendRequestsUseCase: getPendingFriendRequestsUseCase,
        sendFriendRequestUseCase: sendFriendRequestUseCase,
        respondFriendRequestUseCase: respondFriendRequestUseCase,
      );

  static ChatBloc createChatBloc() => ChatBloc(
        getChatMessagesUseCase: getChatMessagesUseCase,
        getImageKitAuthUseCase: getImageKitAuthUseCase,
        sendImageMessageUseCase: sendImageMessageUseCase,
        repository: chatRepository,
      );

  static MemoryBloc createMemoryBloc() => MemoryBloc(
        getMemoriesTimelineUseCase: getMemoriesTimelineUseCase,
        getMemoryHighlightsUseCase: getMemoryHighlightsUseCase,
        uploadMemoriesUseCase: uploadMemoriesUseCase,
        toggleMemoryHighlightUseCase: toggleMemoryHighlightUseCase,
        deleteMemoryUseCase: deleteMemoryUseCase,
      );

  static PollBloc createPollBloc() => PollBloc(
        getPollsUseCase: getPollsUseCase,
        createPollUseCase: createPollUseCase,
        castVoteUseCase: castVoteUseCase,
        closePollUseCase: closePollUseCase,
      );
}
