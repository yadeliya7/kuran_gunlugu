import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';
import '../core/constants/strings.dart';

class TopBar extends StatelessWidget {
  final bool isToday;
  final VoidCallback onGoToday;
  final VoidCallback onSettings;
  final VoidCallback onFavorites;

  const TopBar({
    super.key,
    required this.isToday,
    required this.onGoToday,
    required this.onSettings,
    required this.onFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Logo and Name
        Row(
          children: [
            const Icon(Icons.auto_stories, color: AppColors.gold, size: 24),
            const SizedBox(width: 7),
            Text(
              t('app_name'),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        // Right: Buttons
        Row(
          children: [
            if (!isToday)
              IconButton(
                icon: const Icon(
                  Icons.calendar_today,
                  color: AppColors.gold,
                  size: 22,
                ),
                tooltip: t('go_today'),
                onPressed: onGoToday,
              ),
            IconButton(
              icon: const Icon(Icons.list_alt, color: AppColors.gold, size: 28),
              onPressed: onFavorites,
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white54, size: 24),
              onPressed: onSettings,
            ),
          ],
        ),
      ],
    );
  }
}
