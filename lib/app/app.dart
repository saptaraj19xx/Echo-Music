import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:echo/app/theme/app_theme.dart';
import 'package:echo/features/splash/presentation/pages/splash_page.dart';

class EchoApp extends StatelessWidget {
  const EchoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Echo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _AppShell(),
      ),
    );
  }
}

/// App shell that manages high-level navigation flow.
///
/// Splash -> Onboarding -> Auth -> Home
class _AppShell extends StatelessWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context) {
    return const SplashPage();
  }
}