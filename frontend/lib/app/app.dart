// Main Root Application widget providing AuthBloc, ProfileBloc, HomeBloc, InboxBloc, PreferencesBloc, ItineraryBloc, ExpenseBloc & GoRouter.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_constants.dart';
import '../core/di/service_locator.dart';
import '../core/router/app_router.dart';
import '../core/router/auth_guard.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';
import '../features/home/presentation/bloc/home_bloc.dart';
import '../features/inbox/presentation/bloc/inbox_bloc.dart';
import '../features/preferences/presentation/bloc/preferences_bloc.dart';
import '../features/itinerary/presentation/bloc/itinerary_bloc.dart';
import '../features/expenses/presentation/bloc/expense_bloc.dart';
import '../features/trips/presentation/bloc/trip_bloc.dart';
import '../features/friends/presentation/bloc/friend_bloc.dart';
import '../features/group_chat/presentation/bloc/chat_bloc.dart';
import '../features/memories/presentation/bloc/memory_bloc.dart';
import '../features/polls/presentation/bloc/poll_bloc.dart';

/// Root application widget initializing global BLoC providers and router config.
class WeTravelApp extends StatefulWidget {
  final bool autoInitialize;

  const WeTravelApp({
    super.key,
    this.autoInitialize = true,
  });

  @override
  State<WeTravelApp> createState() => _WeTravelAppState();
}

class _WeTravelAppState extends State<WeTravelApp> {
  late final AuthBloc _authBloc;
  late final ProfileBloc _profileBloc;
  late final HomeBloc _homeBloc;
  late final InboxBloc _inboxBloc;
  late final PreferencesBloc _preferencesBloc;
  late final ItineraryBloc _itineraryBloc;
  late final ExpenseBloc _expenseBloc;
  late final TripBloc _tripBloc;
  late final FriendBloc _friendBloc;
  late final ChatBloc _chatBloc;
  late final MemoryBloc _memoryBloc;
  late final PollBloc _pollBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = ServiceLocator.createAuthBloc();
    _profileBloc = ServiceLocator.createProfileBloc();
    _homeBloc = ServiceLocator.createHomeBloc();
    _inboxBloc = ServiceLocator.createInboxBloc();
    _preferencesBloc = ServiceLocator.createPreferencesBloc();
    _itineraryBloc = ServiceLocator.createItineraryBloc();
    _expenseBloc = ServiceLocator.createExpenseBloc();
    _tripBloc = ServiceLocator.createTripBloc();
    _friendBloc = ServiceLocator.createFriendBloc();
    _chatBloc = ServiceLocator.createChatBloc();
    _memoryBloc = ServiceLocator.createMemoryBloc();
    _pollBloc = ServiceLocator.createPollBloc();

    if (widget.autoInitialize) {
      _authBloc.add(const AuthCheckRequested());
    }
  }

  @override
  void dispose() {
    _authBloc.close();
    _profileBloc.close();
    _homeBloc.close();
    _inboxBloc.close();
    _preferencesBloc.close();
    _itineraryBloc.close();
    _expenseBloc.close();
    _tripBloc.close();
    _friendBloc.close();
    _chatBloc.close();
    _memoryBloc.close();
    _pollBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<ProfileBloc>.value(value: _profileBloc),
        BlocProvider<HomeBloc>.value(value: _homeBloc),
        BlocProvider<InboxBloc>.value(value: _inboxBloc),
        BlocProvider<PreferencesBloc>.value(value: _preferencesBloc),
        BlocProvider<ItineraryBloc>.value(value: _itineraryBloc),
        BlocProvider<ExpenseBloc>.value(value: _expenseBloc),
        BlocProvider<TripBloc>.value(value: _tripBloc),
        BlocProvider<FriendBloc>.value(value: _friendBloc),
        BlocProvider<ChatBloc>.value(value: _chatBloc),
        BlocProvider<MemoryBloc>.value(value: _memoryBloc),
        BlocProvider<PollBloc>.value(value: _pollBloc),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          authNotifierListenable.value = state;
        },
        child: MaterialApp.router(
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
