import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/router/app_router.dart';
import '../core/router/auth_guard.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../features/auth/presentation/providers/auth_provider.dart';

class WeTravelApp extends ConsumerStatefulWidget {
  final bool autoInitialize;

  const WeTravelApp({
    super.key,
    this.autoInitialize = true,
  });

  @override
  ConsumerState<WeTravelApp> createState() => _WeTravelAppState();
}

class _WeTravelAppState extends ConsumerState<WeTravelApp> {
  @override
  void initState() {
    super.initState();
    // Synchronize current auth state to router listenable immediately
    authNotifierListenable.value = ref.read(authControllerProvider);
    if (widget.autoInitialize) {
      Future.microtask(() {
        ref.read(authControllerProvider.notifier).initialize();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      authNotifierListenable.value = next;
    });

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
