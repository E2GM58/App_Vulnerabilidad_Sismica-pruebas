import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: const Icon(Icons.image, size: 36, color: AppColors.gray500),
        ),
        const SizedBox(height: 8),
        Text(
          'LOGO',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.text),
        ),
      ],
    );
  }
}
