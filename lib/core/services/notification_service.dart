import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'prayer_times_service.dart';

class BildirimServisi {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> baslat() async {
    tz.initializeTimeZones();

    // 🔧 DYNAMIC TIMEZONE DETECTION (iOS Fix)
    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      debugPrint('✅ Timezone set to: $currentTimeZone');
    } catch (e) {
      debugPrint('⚠️ Could not get device timezone, falling back to UTC: $e');
      tz.setLocalLocation(tz.UTC);
    }

    const AndroidInitializationSettings androidAyarlari =
        AndroidInitializationSettings('notification_icon');
    const DarwinInitializationSettings iosAyarlari =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings ayarlar = InitializationSettings(
      android: androidAyarlari,
      iOS: iosAyarlari,
    );

    await _notifications.initialize(ayarlar);

    // 👇 Request notification permissions (Android only, iOS handled in initialization)
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  static Future<void> gunlukBildirimKur() async {
    try {
      // Check if verse notifications are enabled
      final prefs = await SharedPreferences.getInstance();
      final bool verseNotificationsEnabled =
          prefs.getBool('verse_notifications_enabled') ?? true; // Default ON

      if (!verseNotificationsEnabled) {
        // Cancel all verse notifications (IDs 0-199)
        for (int i = 0; i < 200; i++) {
          await _notifications.cancel(i);
        }
        debugPrint('📵 Ayet bildirimleri kapalı, bildirimler iptal edildi.');
        return;
      }

      debugPrint('🕌 Ayet bildirimleri kuruluyor...');

      // 1. Tüm eski bildirimleri iptal et
      for (int i = 0; i < 200; i++) {
        await _notifications.cancel(i);
      }

      // 2. Şu anki saati al
      final now = tz.TZDateTime.now(tz.local);

      // SABAH VAKTİ HESABI (Standart)
      tz.TZDateTime sabahVakti = _sonrakiZaman(09, 30);

      // AKŞAM VAKTİ HESABI (Akıllı Mod 🧠)
      tz.TZDateTime aksamVakti = _sonrakiZaman(20, 00);

      // KRİTİK KONTROL: Skip today's evening notification if user is currently active
      if (aksamVakti.day == now.day) {
        aksamVakti = aksamVakti.add(const Duration(days: 1));
      }

      // 🍎 iOS 15+ Notification Details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
        threadIdentifier: 'verse_notifications',
      );

      // 3. Gelecek 7 GÜN için planla (iOS 64 limitini aşmamak için namaz bildirimleri ile dengelendi)
      for (int i = 0; i < 7; i++) {
        // --- A) SABAH BİLDİRİMİ ---
        String sabahBaslik;
        String sabahIcerik;

        if (Platform.localeName.startsWith('tr')) {
          sabahBaslik = 'Günün ayeti hazır ☀️';
          sabahIcerik = "Bugünün ayeti seni bekliyor, okumak ister misin?";
        } else {
          sabahBaslik = "Today's verse is ready ☀️";
          sabahIcerik =
              "Today's verse is waiting for you. Would you like to read?";
        }

        await _notifications.zonedSchedule(
          i,
          sabahBaslik,
          sabahIcerik,
          sabahVakti.add(Duration(days: i)),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'kuran_gunlugu_hatirlatici_v1',
              'Günlük Hatırlatıcı',
              channelDescription: 'Günlük okuma hatırlatması',
              importance: Importance.max,
              priority: Priority.high,
              color: Color(0xFFD4AF37),
            ),
            iOS: iosDetails,
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        // --- B) AKŞAM BİLDİRİMİ ---
        String aksamBaslik;
        String aksamIcerik;

        if (Platform.localeName.startsWith('tr')) {
          aksamBaslik = 'Hayırlı Akşamlar 🌙';
          aksamIcerik =
              "Günü huzurla kapatmak için bir ayet okumaya ne dersin?";
        } else {
          aksamBaslik = 'Good Evening 🌙';
          aksamIcerik = "End your day with peace.";
        }

        await _notifications.zonedSchedule(
          i + 100,
          aksamBaslik,
          aksamIcerik,
          aksamVakti.add(Duration(days: i)),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'kuran_gunlugu_hatirlatici_v1',
              'Günlük Hatırlatıcı',
              channelDescription: 'Günlük okuma hatırlatması',
              importance: Importance.max,
              priority: Priority.high,
              color: Color(0xFFD4AF37),
            ),
            iOS: iosDetails,
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
      debugPrint(
        "✅ Akıllı Bildirimler Kuruldu: Bugünün akşamı atlandı (kullanıcı aktif).",
      );
    } catch (e) {
      debugPrint("❌ Bildirim hatası: $e");
    }
  }

  static Future<void> namazBildirimleriniKur() async {
    final prefs = await SharedPreferences.getInstance();
    final bool bildirimlerAktif =
        prefs.getBool('prayer_notifications_enabled') ?? true;

    // Cancel all prayer notifications (IDs 200-399) first
    for (int id = 200; id <= 399; id++) {
      await _notifications.cancel(id);
    }

    if (!bildirimlerAktif) {
      debugPrint('📵 Namaz bildirimleri kapalı, bildirimler iptal edildi.');
      return;
    }

    debugPrint('🕌 Namaz bildirimleri kuruluyor (7 günlük)...');

    try {
      final now = tz.TZDateTime.now(tz.local);

      int notificationId = 200; // Start from ID 200

      // 🍎 iOS 15+ Prayer Notification Details (Time Sensitive)
      const iosPrayerDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
        threadIdentifier: 'prayer_times_group',
      );

      // Schedule for next 7 days
      for (int day = 0; day < 7; day++) {
        final targetDate = now.add(Duration(days: day));

        // Get prayer times for this date
        final prayerTimes = await PrayerTimesService.getPrayerTimes(
          DateTime(targetDate.year, targetDate.month, targetDate.day),
        );

        // Define prayers to schedule (excluding sunrise)
        final prayers = [
          {'time': prayerTimes.fajr, 'key': 'fajr'},
          {'time': prayerTimes.dhuhr, 'key': 'dhuhr'},
          {'time': prayerTimes.asr, 'key': 'asr'},
          {'time': prayerTimes.maghrib, 'key': 'maghrib'},
          {'time': prayerTimes.isha, 'key': 'isha'},
        ];

        for (var prayer in prayers) {
          final prayerTime = prayer['time'] as DateTime;
          final prayerKey = prayer['key'] as String;

          // Calculate notification time: 15 minutes before prayer
          final notifTime = prayerTime.subtract(const Duration(minutes: 15));

          // Only schedule if in the future
          if (notifTime.isAfter(DateTime.now())) {
            // Convert to TZDateTime
            final tzNotifTime = tz.TZDateTime.from(notifTime, tz.local);

            // Get localized message with Ramadan awareness
            String title;
            String body;
            final isRamadan = _isRamadan();

            if (Platform.localeName.startsWith('tr')) {
              body = _getPrayerNotificationTextTR(prayerKey, isRamadan);
              title = _getPrayerNotificationTitleTR(prayerKey, isRamadan);
            } else {
              body = _getPrayerNotificationTextEN(prayerKey, isRamadan);
              title = _getPrayerNotificationTitleEN(prayerKey, isRamadan);
            }

            await _notifications.zonedSchedule(
              notificationId,
              title,
              body,
              tzNotifTime,
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'namaz_hatirlatici',
                  'Namaz Hatırlatıcıları',
                  channelDescription: 'Namaz vakti hatırlatmaları',
                  importance: Importance.high,
                  priority: Priority.high,
                  color: Color(0xFFD4AF37),
                  icon: 'notification_icon',
                ),
                iOS: iosPrayerDetails,
              ),
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );

            debugPrint(
              '✅ Namaz bildirimi planlandı: $prayerKey - ${PrayerTimesService.formatPrayerTime(notifTime)} (ID: $notificationId)',
            );
            notificationId++;
          }
        }
      }

      debugPrint('✅ Namaz bildirimleri kuruldu (7 günlük plan).');
    } catch (e) {
      debugPrint('❌ Namaz bildirimi hatası: $e');
    }
  }

  /// Check if current date is in Ramadan (Hijri month 9)
  static bool _isRamadan() {
    final now = DateTime.now();
    final hijriMonth = PrayerTimesService.getHijriMonth(now);
    return hijriMonth == 9;
  }

  static String _getPrayerNotificationTitleTR(
    String prayerKey,
    bool isRamadan,
  ) {
    if (isRamadan) {
      if (prayerKey == 'fajr') return 'Sahur Vakti 🥛';
      if (prayerKey == 'maghrib') return 'İftar Vakti 🍲';
    }
    return 'Vakit Yaklaşıyor ⏳';
  }

  static String _getPrayerNotificationTitleEN(
    String prayerKey,
    bool isRamadan,
  ) {
    if (isRamadan) {
      if (prayerKey == 'fajr') return 'Suhoor Time 🥛';
      if (prayerKey == 'maghrib') return 'Iftar Time 🍲';
    }
    return 'Prayer Time Approaching ⏳';
  }

  static String _getPrayerNotificationTextTR(String prayerKey, bool isRamadan) {
    // Ramadan-specific messages for Fajr and Maghrib
    if (isRamadan) {
      if (prayerKey == 'fajr') {
        return 'İmsak vaktine 15 dakika kaldı. Niyet etmeyi unutmayın.';
      }
      if (prayerKey == 'maghrib') {
        return 'İftara 15 dakika kaldı. Allah kabul etsin.';
      }
    }

    // Generic messages for all other cases
    switch (prayerKey) {
      case 'fajr':
        return 'Sabah namazı vaktine 15 dakika kaldı.';
      case 'dhuhr':
        return 'Öğle namazı vaktine 15 dakika kaldı.';
      case 'asr':
        return 'İkindi namazı vaktine 15 dakika kaldı.';
      case 'maghrib':
        return 'Akşam namazı vaktine 15 dakika kaldı.';
      case 'isha':
        return 'Yatsı namazı vaktine 15 dakika kaldı.';
      default:
        return 'Namaz vaktine 15 dakika kaldı.';
    }
  }

  static String _getPrayerNotificationTextEN(String prayerKey, bool isRamadan) {
    // Ramadan-specific messages for Fajr and Maghrib
    if (isRamadan) {
      if (prayerKey == 'fajr') {
        return '15 minutes until Suhoor. Don\'t forget to make your intention.';
      }
      if (prayerKey == 'maghrib') {
        return '15 minutes until Iftar. May Allah accept it.';
      }
    }

    // Generic messages for all other cases
    switch (prayerKey) {
      case 'fajr':
        return '15 minutes until Fajr prayer.';
      case 'dhuhr':
        return '15 minutes until Dhuhr prayer.';
      case 'asr':
        return '15 minutes until Asr prayer.';
      case 'maghrib':
        return '15 minutes until Maghrib prayer.';
      case 'isha':
        return '15 minutes until Isha prayer.';
      default:
        return '15 minutes until prayer.';
    }
  }

  static tz.TZDateTime _sonrakiZaman(int saat, int dakika) {
    final tz.TZDateTime simdi = tz.TZDateTime.now(tz.local);
    tz.TZDateTime planlanan = tz.TZDateTime(
      tz.local,
      simdi.year,
      simdi.month,
      simdi.day,
      saat,
      dakika,
    );
    if (planlanan.isBefore(simdi)) {
      planlanan = planlanan.add(const Duration(days: 1));
    }
    return planlanan;
  }
}
