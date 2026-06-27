import 'package:flutter/material.dart';

/// Small helpers for building smooth animations.
class AppAnimations {
  AppAnimations._();

  static Widget fadeIn({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  static Widget scaleIn({
    required Animation<double> animation,
    required Widget child,
  }) {
    return ScaleTransition(
      scale: animation,
      child: child,
    );
  }
}

