import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';

/// A subtle pulse/wave indicator below the logo.
class PulseIndicator extends StatelessWidget {
  const PulseIndicator({
    super.key,
    required this.animation,
  });

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        // Pulse once across the splash; keep it elegant.
        final wave = (sin(t * 2 * pi) + 1) / 2; // 0..1
        final scale = 0.92 + wave * 0.16;
        final opacity = 0.08 + wave * 0.25;

        return SizedBox(
          height: AppSpacing.huge * 0.25,
          child: Center(
            child: Transform.scale(
              scale: scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 92,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.glow.withValues(alpha: opacity),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Positioned(
                    child: Container(
                      width: 140,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.glow.withValues(alpha: opacity * 0.8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

