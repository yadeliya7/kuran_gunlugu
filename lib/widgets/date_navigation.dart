import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:intl/intl.dart';
import '../core/services/global_settings.dart';

class DateNavigation extends StatelessWidget {
  final DateTime selectedDate;
  final Function(int) onDateChange;

  const DateNavigation({
    super.key,
    required this.selectedDate,
    required this.onDateChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // PREVIOUS DAY
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white70,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              onDateChange(-1);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          // DATE TEXT
          Row(
            children: [
              const SizedBox(width: 8),
              Text(
                DateFormat(
                  'd MMMM yyyy',
                  GlobalSettings.currentLanguage == 'en' ? 'en_US' : 'tr_TR',
                ).format(selectedDate),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // NEXT DAY
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              onDateChange(1);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
