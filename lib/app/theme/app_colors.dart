import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// AppColors is a thin facade over [DesignTokens].
///
/// Requirement: every color value must ultimately come from AppColors.
class AppColors {
  AppColors._();

  // ==========================================================
  // BRAND
  // ==========================================================
  static const Color primary = DesignTokens.primary;
  static const Color secondary = DesignTokens.secondary;

  // ==========================================================
  // BACKGROUNDS
  // ==========================================================
  static const Color background = DesignTokens.background;
  static const Color surface = DesignTokens.surface;
  static const Color surfaceVariant = DesignTokens.surfaceVariant;

  // ==========================================================
  // TEXT
  // ==========================================================
  static const Color textPrimary = DesignTokens.textPrimary;
  static const Color textSecondary = DesignTokens.textSecondary;
  static const Color textHint = DesignTokens.textHint;

  // ==========================================================
  // STATUS
  // ==========================================================
  static const Color success = DesignTokens.success;
  static const Color warning = DesignTokens.warning;
  static const Color error = DesignTokens.error;

  // ==========================================================
  // EXTRA
  // ==========================================================
  static const Color divider = DesignTokens.divider;
  static const Color card = DesignTokens.card;
  static const Color glass = DesignTokens.glass;
  static const Color glow = DesignTokens.glow;
}

