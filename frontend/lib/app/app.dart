// Main Root Application widget providing AuthBloc, ProfileBloc & GoRouter.
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

  @override
  void initState() {
    super.initState();
    _authBloc = ServiceLocator.createAuthBloc();
    _profileBloc = ServiceLocator.createProfileBloc();
    if (widget.autoInitialize) {
      _authBloc.add(const AuthCheckRequested());
    }
  }

  @override
  void dispose() {
    _authBloc.close();
    _profileBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<ProfileBloc>.value(value: _profileBloc),
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
