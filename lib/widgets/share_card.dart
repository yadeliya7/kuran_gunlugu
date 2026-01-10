import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../core/constants/colors.dart';
import '../models/ayet_model.dart';
import '../models/sure_isimleri.dart';
import '../core/services/global_settings.dart';

class ShareCard extends StatelessWidget {
  final AyetModel ayet;

  const ShareCard({super.key, required this.ayet});

  @override
  Widget build(BuildContext context) {
    String appName = GlobalSettings.currentLanguage == 'en'
        ? "Quran Diary"
        : "Kuran Günlüğü";
    String gosterilecekMeal = GlobalSettings.currentLanguage == 'en'
        ? ayet.ingilizce
        : ayet.turkce;
    String gosterilecekSureIsmi = ayet.sureAdi;

    if (GlobalSettings.currentLanguage == 'tr') {
      gosterilecekSureIsmi = SureIsimleri.tr[ayet.sureAdi] ?? ayet.sureAdi;
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 400,
        height: 500,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.gold.withOpacity(0.6), width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold, width: 1),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  size: 40,
                  color: AppColors.gold,
                ),
                const SizedBox(height: 20),

                Flexible(
                  flex: 2,
                  child: AutoSizeText(
                    ayet.arapca,
                    style: GoogleFonts.amiri(
                      fontSize: 24,
                      color: AppColors.gold,
                      height: 2.2,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    minFontSize: 14,
                    maxLines: 4,
                  ),
                ),

                const SizedBox(height: 20),
                Divider(
                  color: AppColors.gold.withOpacity(0.4),
                  thickness: 1,
                  indent: 50,
                  endIndent: 50,
                ),
                const SizedBox(height: 20),

                Expanded(
                  flex: 4,
                  child: Center(
                    child: AutoSizeText(
                      gosterilecekMeal,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.white,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                      minFontSize: 12,
                      maxLines: 12,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appName.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white54,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Text(
                      "${gosterilecekSureIsmi}, ${ayet.bitisAyetNo != null ? '${ayet.ayetNo}-${ayet.bitisAyetNo}' : ayet.ayetNo}",
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
