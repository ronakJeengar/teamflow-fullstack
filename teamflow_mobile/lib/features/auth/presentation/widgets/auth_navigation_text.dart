import 'package:teamflow_mobile/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
// lib/widgets/auth_navigation_text.dart
import 'package:flutter/material.dart';

class AuthNavigationText extends StatelessWidget {
  final String question;
  final String actionText;
  final VoidCallback onTap;

  const AuthNavigationText({
    super.key,
    required this.question,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            actionText,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}