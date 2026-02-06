import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/colors.dart';
import '../core/constants/strings.dart';
import '../core/services/global_settings.dart';
import '../core/services/notification_service.dart';
import '../core/services/donation_service.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _baslangicYuklemeleri();
    });
  }

  Future<void> _baslangicYuklemeleri() async {
    // 1. Logoyu göster (500ms bekle)
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Tarih formatını yükle
      await initializeDateFormatting('tr_TR', null);
    } catch (e) {
      debugPrint("⚠️ Tarih formatı hatası: $e");
    }

    try {
      // Initialize RevenueCat Donation Service
      await DonationService().init();
    } catch (e) {
      debugPrint("⚠️ Bağış servisi hatası: $e");
    }

    try {
      // Bildirim servisini başlat
      await BildirimServisi.baslat();
      BildirimServisi.gunlukBildirimKur();
      BildirimServisi.namazBildirimleriniKur(); // Prayer notifications
    } catch (e) {
      debugPrint("⚠️ Bildirim servisi hatası (Önemli değil, devam et): $e");
    }

    try {
      // Ayarları çek
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          GlobalSettings.currentLanguage = prefs.getString('language') ?? 'tr';
          GlobalSettings.fontSizeMultiplier =
              prefs.getDouble('fontSize') ?? 18.0;
          GlobalSettings.isPremiumUser =
              true; //prefs.getBool('isPremium') ?? false;
        });
      }
    } catch (e) {
      debugPrint("⚠️ Ayarlar okunamadı: $e");
    }

    // 5. HER ŞEY BİTTİKTEN SONRA
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      debugPrint("🚀 Ana Ekrana Geçiş Yapılıyor...");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.8, end: 1.0),
              duration: const Duration(seconds: 1),
              curve: Curves.elasticOut,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 100,
                          color: AppColors.gold.withValues(alpha: 0.9),
                        ),
                      ),
                      Icon(
                        Icons.auto_awesome,
                        size: 40,
                        color: AppColors.gold.withValues(alpha: 1.0),
                        shadows: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            Text(
              t('app_name'),
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              t('splash_text'),
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 18,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 50),
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
