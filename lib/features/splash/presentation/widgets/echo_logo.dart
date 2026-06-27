import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

/// Echo logo widget for splash.
class EchoLogo extends StatelessWidget {
  const EchoLogo({
    super.key,
    this.size = 96,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    // Use the existing iconography but style it according to the design system.
    return Icon(
      Icons.graphic_eq_rounded,
      size: size,
      color: AppColors.textPrimary,
    );
  }
}

