import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// Theme extension for additional visual layers used across Echo.
///
/// Currently reserved for future glass/gradient/glow system.
@immutable
class AppThemeExtensions extends ThemeExtension<AppThemeExtensions> {
  const AppThemeExtensions({
    required this.glassColor,
    required this.glowColor,
  });

  final Color glassColor;
  final Color glowColor;

  @override
  AppThemeExtensions copyWith({
    Color? glassColor,
    Color? glowColor,
  }) {
    return AppThemeExtensions(
      glassColor: glassColor ?? this.glassColor,
      glowColor: glowColor ?? this.glowColor,
    );
  }

  @override
  ThemeExtension<AppThemeExtensions> lerp(
    ThemeExtension<AppThemeExtensions>? other,
    double t,
  ) {
    if (other is! AppThemeExtensions) return this;

    return AppThemeExtensions(
      glassColor: Color.lerp(glassColor, other.glassColor, t)!,
      glowColor: Color.lerp(glowColor, other.glowColor, t)!,
    );
  }

  static AppThemeExtensions get light => const AppThemeExtensions(
        glassColor: DesignTokens.glass,
        glowColor: DesignTokens.glow,
      );

  static AppThemeExtensions get dark => const AppThemeExtensions(
        glassColor: DesignTokens.glass,
        glowColor: DesignTokens.glow,
      );
}

