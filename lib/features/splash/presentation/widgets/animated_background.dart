import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';

/// Slow animated aurora gradient background.
class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({
    super.key,
    required this.animation,
  });

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    // Use subtle motion; avoid fast/flashy changes.
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final angle = (t * 2 * pi) * 0.18;
        final x = sin(t * 2 * pi) * 0.08;
        final y = cos(t * 2 * pi) * 0.08;

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            gradient: LinearGradient(
              begin: Alignment(-1 + x, -1 + y),
              end: Alignment(1 - x, 1 - y),
              colors: [
                AppColors.background,
                AppColors.glow.withValues(alpha: 0.18),
                AppColors.surface,
              ],
              stops: const [0.0, 0.45, 1.0],
              transform: GradientRotation(angle),
            ),
          ),
        );
      },
    );
  }
}

