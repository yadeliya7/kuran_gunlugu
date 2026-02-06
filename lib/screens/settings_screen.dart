import 'package:flutter/foundation.dart';
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
import '../core/services/prayer_times_service.dart';
import '../core/services/notification_service.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  bool bildirimIzniVar = false;
  String _selectedPrayerMethod = 'auto'; // Default to auto
  bool _prayerNotificationsEnabled = false;
  bool _verseNotificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _izinDurumunuKontrolEt();
    _loadPrayerMethod(); // Load saved prayer method
    _loadPrayerNotificationsSetting(); // Load prayer notifications setting
    _loadVerseNotificationsSetting(); // Load verse notifications setting
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

  // Prayer Method Management
  Future<void> _loadPrayerMethod() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMethod = prefs.getString('prayer_calculation_method') ?? 'auto';
    if (mounted) {
      setState(() {
        _selectedPrayerMethod = savedMethod;
      });
    }
  }

  Future<void> _savePrayerMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prayer_calculation_method', method);

    // Clear cache to force recalculation
    PrayerTimesService.clearCache();

    if (mounted) {
      setState(() {
        _selectedPrayerMethod = method;
      });
      Navigator.pop(context); // Close dialog
    }
  }

  // Prayer Notifications Management
  /// Load verse notifications setting from SharedPreferences
  Future<void> _loadVerseNotificationsSetting() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _verseNotificationsEnabled =
            prefs.getBool('verse_notifications_enabled') ?? true; // Default ON
      });
    }
  }

  Future<void> _loadPrayerNotificationsSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('prayer_notifications_enabled') ?? false;
    if (mounted) {
      setState(() {
        _prayerNotificationsEnabled = enabled;
      });
    }
  }

  Future<void> _togglePrayerNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayer_notifications_enabled', value);

    if (mounted) {
      setState(() {
        _prayerNotificationsEnabled = value;
      });
    }

    // Re-schedule prayer notifications
    await BildirimServisi.namazBildirimleriniKur();
  }

  /// Toggle verse notifications on/off
  Future<void> _toggleVerseNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('verse_notifications_enabled', value);

    if (mounted) {
      setState(() {
        _verseNotificationsEnabled = value;
      });
    }

    // Re-schedule verse notifications
    await BildirimServisi.gunlukBildirimKur();
  }

  String _getPrayerMethodName(String methodKey) {
    switch (methodKey) {
      case 'auto':
        return t('prayer_method_auto');
      case 'turkey':
        return t('prayer_method_turkey');
      case 'mwl':
        return t('prayer_method_mwl');
      case 'isna':
        return t('prayer_method_isna');
      case 'makkah':
        return t('prayer_method_makkah');
      case 'egypt':
        return t('prayer_method_egypt');
      default:
        return t('prayer_method_auto');
    }
  }

  void _showPrayerMethodDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height if needed
      backgroundColor: const Color(0xFF1F2125),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6, // Start at 60% height
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t('prayer_method_title'),
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t('prayer_method_subtitle'),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _prayerMethodOption(
                      'auto',
                      Icons.settings_suggest,
                      t('prayer_method_auto'),
                      t('prayer_method_auto_desc'),
                    ),
                    _prayerMethodOption(
                      'turkey',
                      Icons.mosque,
                      t('prayer_method_turkey'),
                      null,
                    ),
                    _prayerMethodOption(
                      'mwl',
                      Icons.public,
                      t('prayer_method_mwl'),
                      null,
                    ),
                    _prayerMethodOption(
                      'isna',
                      Icons.location_city,
                      t('prayer_method_isna'),
                      null,
                    ),
                    _prayerMethodOption(
                      'makkah',
                      Icons.location_on,
                      t('prayer_method_makkah'),
                      null,
                    ),
                    _prayerMethodOption(
                      'egypt',
                      Icons.terrain,
                      t('prayer_method_egypt'),
                      null,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _prayerMethodOption(
    String key,
    IconData icon,
    String title,
    String? subtitle,
  ) {
    bool isSelected = _selectedPrayerMethod == key;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.gold : Colors.white54),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.gold : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            )
          : null,
      trailing: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? AppColors.gold : Colors.white54,
      ),
      onTap: () => _savePrayerMethod(key),
    );
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
              // PREMIUM SUPPORT CARD (Moved to Top)
              GestureDetector(
                onTap: _showDonationSheet,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20), // Spacing below
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gold, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Leading Gold Icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: AppColors.gold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Text Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('support_us'), // "Projeye Destek Ol"
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t(
                                'support_gold_subtitle',
                              ), // "Bu hayra ortak olun ✨"
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Trailing Arrow
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.gold,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              // Notifications Section
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

              // Prayer Calculation Method Section
              Text(
                t('prayer_method_title'),
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _showPrayerMethodDialog,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('prayer_method_title'),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _getPrayerMethodName(_selectedPrayerMethod),
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
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

              // === REMINDERS SECTION ===
              Text(
                t('reminders_section'),
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 15),

              // Verse Notifications Toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t('verse_notif_toggle'),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Switch(
                      value: _verseNotificationsEnabled,
                      onChanged: _toggleVerseNotifications,
                      activeColor: AppColors.gold,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Prayer Notifications Toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t('prayer_notif_title'),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Switch(
                      value: _prayerNotificationsEnabled,
                      onChanged: _togglePrayerNotifications,
                      activeColor: AppColors.gold,
                    ),
                  ],
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
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      isDismissible: true, // Kullanıcı dışarı tıklayarak kapatabilir
      enableDrag: true, // Sürükleyerek kapatabilir
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            bool isLoading = false;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 0. Top Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.gold, // Gold handle
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. Header: Icon
                  const Icon(
                    Icons.volunteer_activism,
                    color: AppColors.gold,
                    size: 48,
                  ), // Gold icon
                  const SizedBox(height: 15),

                  // 2. Title
                  Text(
                    GlobalSettings.currentLanguage == 'tr'
                        ? "Bu Hayra Ortak Olun"
                        : "Support Our Mission",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // 3. Benefits List (Compact Vertical)
                  _buildCompactBenefit(
                    icon: Icons.volunteer_activism,
                    titleTr: "İyiliği Paylaşın",
                    titleEn: "Share the Goodness",
                    subtitleTr:
                        "Uygulamanın herkes için ücretsiz kalmasına vesile olun.",
                    subtitleEn: "Help keep the app free for everyone.",
                  ),
                  const SizedBox(height: 12),
                  _buildCompactBenefit(
                    icon: Icons.block,
                    titleTr: "Reklamsız Deneyim",
                    titleEn: "Ad-Free Experience",
                    subtitleTr:
                        "Dikkatiniz dağılmadan sadece maneviyata odaklanın.",
                    subtitleEn:
                        "Focus purely on spirituality without distractions.",
                  ),
                  const SizedBox(height: 12),
                  _buildCompactBenefit(
                    icon: Icons.auto_awesome,
                    titleTr: "Geliştirmeye Destek",
                    titleEn: "Support Development",
                    subtitleTr: "Yeni özellikler eklememize güç verin.",
                    subtitleEn: "Empower us to build new features.",
                  ),
                  const SizedBox(height: 25),

                  // 4. Donation List
                  Flexible(
                    child: FutureBuilder<List<Package>>(
                      future: DonationService().fetchDonations(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(
                              color: AppColors.gold,
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

                        // Sort: Low to High
                        var packages = List<Package>.from(snapshot.data!);
                        packages.sort(
                          (a, b) => a.storeProduct.price.compareTo(
                            b.storeProduct.price,
                          ),
                        );

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: packages.length,
                          itemBuilder: (context, index) {
                            Package package = packages[index];

                            // Tier Names
                            String tierName;
                            IconData tierIcon;
                            if (index == 0) {
                              tierName = t('donation_tier_1');
                              tierIcon = Icons.coffee_rounded; // ☕ equivalent
                            } else if (index == 1) {
                              tierName = t('donation_tier_2');
                              tierIcon = Icons.local_florist; // 🌹 equivalent
                            } else if (index == 2) {
                              tierName = t('donation_tier_3');
                              tierIcon = Icons.diamond; // 💎 equivalent
                            } else {
                              tierName = t('donation_tier_default');
                              tierIcon = Icons.favorite;
                            }

                            // Middle card (index 1) gets special gold border
                            bool isHighlight = (index == 1);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                // Lighter dark blue for card bg
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isHighlight
                                      ? AppColors.gold
                                      : Colors.white12,
                                  width: isHighlight ? 2.0 : 0.5,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: isLoading
                                      ? null
                                      : () async {
                                          // 1. LOADING STATE BAŞLAT
                                          setSheetState(() {
                                            isLoading = true;
                                          });

                                          try {
                                            // 2. SATIN ALMA İŞLEMİ
                                            bool success =
                                                await DonationService()
                                                    .makePurchase(package);

                                            // 3. MOUNTED CHECK (await sonrası)
                                            if (!mounted) return;

                                            // 4. Loading state'i kapat
                                            setSheetState(() {
                                              isLoading = false;
                                            });

                                            // 5. Bottom sheet'i kapat
                                            if (Navigator.canPop(
                                              sheetContext,
                                            )) {
                                              Navigator.pop(sheetContext);
                                            }

                                            // 6. MOUNTED CHECK (Navigator.pop sonrası)
                                            if (!mounted) return;

                                            // 7. Sadece başarılı satın almada dialog göster
                                            // İptal edildiğinde (success=false) sessizce kapat
                                            if (success) {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      backgroundColor: AppColors
                                                          .cardBackground,
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
                                                          child: const Text(
                                                            "Tamam",
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .gold,
                                                            ),
                                                          ),
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                            }
                                            // İptal veya hata durumunda hiçbir şey gösterme
                                          } catch (e) {
                                            // 8. HATA YAKALAMA
                                            debugPrint(
                                              'Purchase error in UI: $e',
                                            );

                                            // 9. MOUNTED CHECK (catch bloğunda)
                                            if (!mounted) return;

                                            // Loading state'i kapat
                                            setSheetState(() {
                                              isLoading = false;
                                            });

                                            // Bottom sheet'i kapat (sessizce)
                                            if (Navigator.canPop(
                                              sheetContext,
                                            )) {
                                              Navigator.pop(sheetContext);
                                            }
                                            // Hata durumunda da hiçbir mesaj gösterme
                                            // Kullanıcı zaten iptal ettiğini biliyor
                                          }
                                        },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    child: isLoading
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                              color: AppColors.gold,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Row(
                                            children: [
                                              // Leading Icon
                                              Icon(
                                                tierIcon,
                                                color: AppColors.gold,
                                                size: 24,
                                              ),
                                              const SizedBox(width: 15),

                                              // Title & Subtitle
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      tierName,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Price Tag
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppColors.gold, // Gold BG
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  package
                                                      .storeProduct
                                                      .priceString,
                                                  style: const TextStyle(
                                                    color: Color(
                                                      0xFF0F172A,
                                                    ), // Dark Text (Navy/Black)
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                  // 5. Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.verified_user,
                        color: AppColors.gold,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t('secure_payment'), // "Güvenli Ödeme & Gizli Bağış"
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  // Safe area padding
                  SizedBox(
                    height: MediaQuery.of(sheetContext).padding.bottom + 10,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCompactBenefit({
    required IconData icon,
    required String titleTr,
    required String titleEn,
    required String subtitleTr,
    required String subtitleEn,
  }) {
    final isTurkish = GlobalSettings.currentLanguage == 'tr';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon (Yeşil, sol taraf)
        Icon(icon, color: Colors.green.shade400, size: 22),
        const SizedBox(width: 12),
        // Text Column (Başlık + Açıklama)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isTurkish ? titleTr : titleEn,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isTurkish ? subtitleTr : subtitleEn,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
