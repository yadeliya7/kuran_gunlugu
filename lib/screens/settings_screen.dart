import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../core/constants/colors.dart';
import '../core/constants/strings.dart';
import '../core/services/global_settings.dart';
import '../core/services/hafiz_service.dart';
import '../core/services/donation_service.dart';
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

              // SUPPORT US BUTTON
              GestureDetector(
                onTap: _showDonationSheet,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.redAccent),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('support_us'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white54,
                        size: 16,
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

  void _showDonationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height flexibility
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header: Heart Icon
              const Icon(Icons.favorite, color: Colors.redAccent, size: 48),
              const SizedBox(height: 15),

              // 2. Title
              Text(
                t('support_title'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // 3. Description
              Text(
                t('support_long_desc'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 25),

              // 4. Donation List
              Flexible(
                child: FutureBuilder<List<Package>>(
                  future: DonationService().fetchDonations(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                              color: AppColors.gold,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              t('loading_products'),
                              style: const TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          t('no_products'),
                          style: const TextStyle(color: Colors.white54),
                        ),
                      );
                    }

                    // Sort packages by price (Low to High)
                    var packages = List<Package>.from(snapshot.data!);
                    packages.sort(
                      (a, b) =>
                          a.storeProduct.price.compareTo(b.storeProduct.price),
                    );

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: packages.asMap().entries.map((entry) {
                        int index = entry.key;
                        Package package = entry.value;

                        // Custom Tier Names based on index
                        String tierName;
                        if (index == 0) {
                          tierName = t(
                            'donation_tier_1',
                          ); // "Uygulamaya Destek"
                        } else if (index == 1) {
                          tierName = t('donation_tier_2'); // "Projeye Katkı"
                        } else if (index == 2) {
                          tierName = t(
                            'donation_tier_3',
                          ); // "Geliştirmeye Destek"
                        } else {
                          tierName = t('donation_tier_default'); // "Destek Ol"
                        }

                        return Card(
                          color: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () async {
                              Navigator.pop(
                                sheetContext,
                              ); // Close sheet before purchase
                              bool success = await DonationService()
                                  .makePurchase(package);
                              if (mounted) {
                                if (success) {
                                  showDialog(
                                    context:
                                        context, // Uses SettingsScreen context
                                    builder: (context) => AlertDialog(
                                      backgroundColor: AppColors.cardBackground,
                                      title: Text(
                                        t('success_title'),
                                        style: const TextStyle(
                                          color: AppColors.gold,
                                        ),
                                      ),
                                      content: Text(
                                        t('success_body'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text("Tamam"),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(t('donation_error')),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  // Simple Bullet or Icon
                                  Icon(
                                    Icons.volunteer_activism,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      tierName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.gold.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      package.storeProduct.priceString,
                                      style: const TextStyle(
                                        color: AppColors.gold,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),
              // 5. Footer Note
              Text(
                t('support_footer'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              // Add safe area padding at bottom
              SizedBox(height: MediaQuery.of(sheetContext).padding.bottom + 10),
            ],
          ),
        );
      },
    );
  }
}
