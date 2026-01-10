import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/colors.dart';
import '../core/constants/strings.dart';
import '../core/services/global_settings.dart';
import '../core/services/hafiz_service.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  bool bildirimIzniVar = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _izinDurumunuKontrolEt();
    HafizYonetimi.hafizYukle().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _izinDurumunuKontrolEt();
    }
  }

  Future<void> _izinDurumunuKontrolEt() async {
    var status = await Permission.notification.status;
    if (mounted) {
      setState(() {
        bildirimIzniVar = status.isGranted;
      });
    }
  }

  Future<void> _ayarlariAc() async {
    await openAppSettings();
  }

  void _dilDegistir(String yeniDil) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', yeniDil);
    setState(() {
      GlobalSettings.currentLanguage = yeniDil;
    });
  }

  void _boyutDegistir(double yeniBoyut) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', yeniBoyut);
    setState(() {
      GlobalSettings.fontSizeMultiplier = yeniBoyut;
    });
  }

  void _hafizSecimMenusuAc() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2125),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t('select_reciter_title'),
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...HafizYonetimi.hafizlar.map((hafiz) {
                bool seciliMi = HafizYonetimi.secilenHafizKodu == hafiz['kod'];
                return ListTile(
                  leading: Icon(
                    seciliMi
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: seciliMi ? AppColors.gold : Colors.white54,
                  ),
                  title: Text(
                    hafiz['isim']!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    await HafizYonetimi.hafizKaydet(hafiz['kod']!);
                    if (mounted) {
                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _dilSecenek(String dilKod, String dilAd) {
    bool secili = GlobalSettings.currentLanguage == dilKod;
    return GestureDetector(
      onTap: () => _dilDegistir(dilKod),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: secili
              ? AppColors.gold.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: secili ? AppColors.gold : Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dilAd,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            if (secili) const Icon(Icons.check_circle, color: AppColors.gold),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t('settings_title'),
          style: const TextStyle(color: AppColors.gold),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: bildirimIzniVar
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: bildirimIzniVar ? Colors.green : Colors.redAccent,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      bildirimIzniVar
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: bildirimIzniVar ? Colors.green : Colors.redAccent,
                      size: 30,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bildirimIzniVar
                                ? t('notif_active')
                                : t('notif_inactive'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            bildirimIzniVar
                                ? t('notif_active_desc')
                                : t('notif_inactive_desc'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!bildirimIzniVar)
                      TextButton(
                        onPressed: _ayarlariAc,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          t('turn_on'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                t('reciter_title'),
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _hafizSecimMenusuAc,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('selected_reciter'),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            HafizYonetimi.getSecilenHafizIsmi(),
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white54,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                t('language'),
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _dilSecenek('tr', 'Türkçe'),
                    _dilSecenek('en', 'English'),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                t('font_size'),
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _boyutButonu(t('size_small'), 14.0),
                    _boyutButonu(t('size_medium'), 18.0),
                    _boyutButonu(t('size_large'), 24.0),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: InkWell(
                  onTap: () {
                    hakkindaGoster(context, GlobalSettings.currentLanguage);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text(
                          GlobalSettings.currentLanguage == 'tr'
                              ? "Kuran Günlüğü • v1.0.0"
                              : "Quran Diary • v1.0.0",
                          style: GoogleFonts.poppins(
                            color: Colors.white24,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          GlobalSettings.currentLanguage == 'tr'
                              ? "Hakkında & Kaynaklar"
                              : "About & Credits",
                          style: GoogleFonts.poppins(
                            color: AppColors.gold.withOpacity(0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _boyutButonu(String text, double value) {
    bool isSelected = (GlobalSettings.fontSizeMultiplier == value);
    return GestureDetector(
      onTap: () => _boyutDegistir(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.gold : Colors.white24,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
