import 'package:flutter/material.dart';

/// Single source of truth for Echo Design Language (EDL).
///
/// All design primitives (colors, spacing, radius, durations, elevations,
/// border widths, opacities) must be defined here.
///
/// IMPORTANT:
/// - Keep values as constants only.
/// - No UI widgets in this file.
class DesignTokens {
  DesignTokens._();

  /// ---------------------------
  /// Colors
  /// ---------------------------
  // BRAND
  static const Color primary = Color(0xFF7C4DFF);
  static const Color secondary = Color(0xFF00D4FF);
  static const Color glow = Color(0xFF7C4DFF);

  // BACKGROUNDS
  static const Color background = Color(0xFF070B14);
  static const Color surface = Color(0xFF101826);
  static const Color surfaceVariant = Color(0xFF182234);

  // TEXT
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB8C1CC);
  static const Color textHint = Color(0xFF7B8794);

  // STATUS
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // EXTRA
  static const Color divider = Color(0xFF243244);
  static const Color card = Color(0xFF111B2B);
  static const Color glass = Color(0x33FFFFFF);

  /// ---------------------------
  /// Spacing (dp)
  /// ---------------------------
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;
  static const double spacingHuge = 64;

  /// ---------------------------
  /// Radius (dp)
  /// ---------------------------
  static const double radiusSm = 8;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 32;
  static const double radiusPill = 999;

  /// ---------------------------
  /// Durations
  /// ---------------------------
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);

  /// ---------------------------
  /// Elevations (Material-style)
  /// ---------------------------
  static const double elevation0 = 0;
  static const double elevation1 = 1;
  static const double elevation2 = 2;
  static const double elevation4 = 4;
  static const double elevation8 = 8;
  static const double elevation12 = 12;

  /// ---------------------------
  /// Border widths (dp)
  /// ---------------------------
  static const double borderWidthSm = 1;
  static const double borderWidthMd = 2;

  /// ---------------------------
  /// Opacity
  /// ---------------------------
  static const double opacity10 = 0.10;
  static const double opacity20 = 0.20;
  static const double opacity30 = 0.30;
  static const double opacity50 = 0.50;
}

