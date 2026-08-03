import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Badge for freshly added products — plain red text, no background pill,
/// so it reads clearly over the product photo without competing for
/// space with the save/share icons.
class NewArrivalBadge extends StatelessWidget {
  final String text;

  const NewArrivalBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppFonts.label(
        text: text,
        size: 12,
        color: const Color(0xFFE33A3A),
        letterSpacing: 1.2,
      ).copyWith(
        fontWeight: FontWeight.w800,
        shadows: [
          Shadow(color: Colors.black.withOpacity(0.55), blurRadius: 4),
        ],
      ),
    );
  }
}
