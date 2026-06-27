import 'package:flutter/material.dart';

import '../../features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  AppRouter._();

  static Widget get initialPage => const SplashPage();
}