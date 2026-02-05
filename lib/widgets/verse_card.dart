import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';
import '../core/constants/strings.dart';
import '../models/ayet_model.dart';
import '../models/sure_isimleri.dart';
import '../core/services/global_settings.dart';

class VerseCard extends StatelessWidget {
  final AyetModel ayet;
  final String? kaydedilenNot;
  final VoidCallback onAddNote;

  const VerseCard({
    super.key,
    required this.ayet,
    this.kaydedilenNot,
    required this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    String gosterilecekMeal = GlobalSettings.currentLanguage == 'en'
        ? ayet.ingilizce
        : ayet.turkce;
    double fontSize = GlobalSettings.fontSizeMultiplier;
    if (fontSize < 12) fontSize = 18.0;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 600, // Increased for taller verse display with scrolling
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground.withValues(alpha: 0.9),
            AppColors.background.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // PREMIUM HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 1,
                  color: AppColors.gold.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 10),
                Text(
                  t('today_ayah').toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 30,
                  height: 1,
                  color: AppColors.gold.withValues(alpha: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // ARABIC TEXT
            Text(
              ayet.arapca,
              style: GoogleFonts.amiri(
                fontSize: fontSize + 12,
                color: AppColors.gold,
                height: 2.5,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 25),
            const Divider(color: Colors.white10, thickness: 1),
            const SizedBox(height: 20),

            // TRANSLATION TEXT
            Text(
              gosterilecekMeal,
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                color: Colors.white,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            // NOTE SECTION
            if (kaydedilenNot != null) ...[
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.edit_note,
                          color: AppColors.gold,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t('your_note'),
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: fontSize - 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      kaydedilenNot!,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: fontSize - 2,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ADD NOTE BUTTON
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onAddNote,
              icon: const Icon(
                Icons.add_comment,
                color: Colors.white30,
                size: 20,
              ),
              label: Text(
                kaydedilenNot == null ? t('add_note') : t('edit_note'),
                style: const TextStyle(color: Colors.white30, fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),

            // SURAH NAME
            Align(
              alignment: Alignment.bottomRight,
              child: Builder(
                builder: (context) {
                  String sureIsmi = ayet.sureAdi;
                  if (GlobalSettings.currentLanguage == 'tr') {
                    sureIsmi = SureIsimleri.tr[ayet.sureAdi] ?? ayet.sureAdi;
                  }
                  String ayetNoStr = ayet.bitisAyetNo != null
                      ? "${ayet.ayetNo}-${ayet.bitisAyetNo}"
                      : "${ayet.ayetNo}";
                  return Text(
                    GlobalSettings.currentLanguage == 'tr'
                        ? "$sureIsmi, $ayetNoStr. "
                        : " $sureIsmi, $ayetNoStr",
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
