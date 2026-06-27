import 'package:flutter/material.dart';

import 'package:echo/app/theme/app_colors.dart';

/// Gradient background for the full-screen player.
class PlayerBackground extends StatelessWidget {
  final Widget child;

  const PlayerBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surfaceVariant,
            AppColors.background,
            AppColors.background,
          ],
        ),
      ),
      child: child,
    );
  }
}