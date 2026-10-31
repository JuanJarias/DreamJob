import 'package:flutter/material.dart';
import '../../theme.dart';

class AuthErrorBanner extends StatelessWidget {
  final String? error;

  const AuthErrorBanner({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final text = error?.trim();
    if (text == null || text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: DjColors.errorBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DjColors.errorLine),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: DjColors.errorInk,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: DjColors.errorInk,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
