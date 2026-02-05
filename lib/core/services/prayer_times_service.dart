import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class PrayerTimesService {
  // Default location: Istanbul, Turkey
  static const double _defaultLatitude = 41.0082;
  static const double _defaultLongitude = 28.9784;

  static Coordinates? _currentCoordinates;
  static String _cityName = 'İstanbul';
  static PrayerTimes? _cachedPrayerTimes;
  static DateTime? _cachedDate;
  static DateTime? _lastGPSCheck; // Track last successful GPS

  /// Get formatted Hijri date using simplified calculation
  static String getHijriDate(DateTime date) {
    try {
      // Turkish month names for Hijri calendar
      const turkishMonths = [
        'Muharrem',
        'Safer',
        'Rebiülevvel',
        'Rebiülahir',
        'Cemaziyelevvel',
        'Cemaziyelahir',
        'Recep',
        'Şaban',
        'Ramazan',
        'Şevval',
        'Zilkade',
        'Zilhicce',
      ];

      // Convert Gregorian to Julian Day Number
      int d = date.day;
      int m = date.month;
      int y = date.year;

      if (m < 3) {
        y--;
        m += 12;
      }

      int a = (y / 100).floor();
      int b = 2 - a + (a / 4).floor();

      int jd =
          (365.25 * (y + 4716)).floor() +
          (30.6001 * (m + 1)).floor() +
          d +
          b -
          1524;

      // Convert Julian Day to Hijri
      int l = jd - 1948440 + 10632;
      int n = ((l - 1) / 10631).floor();
      l = l - 10631 * n + 354;
      int j =
          ((10985 - l) / 5316).floor() * ((50 * l) / 17719).floor() +
          ((l / 5670).floor()) * ((43 * l) / 15238).floor();
      l =
          l -
          ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
          (j / 16).floor() * ((15238 * j) / 43).floor() +
          29;

      int hMonth = ((24 * l) / 709).floor();
      int hDay = l - ((709 * hMonth) / 24).floor();

      // Validate ranges
      if (hMonth < 1 || hMonth > 12) return '';
      if (hDay < 1 || hDay > 30) return '';

      final monthName = turkishMonths[hMonth - 1];
      return '$hDay $monthName';
    } catch (e) {
      debugPrint('❌ Hicri Tarih Hatası: $e');
      return '';
    }
  }

  /// Get coordinates (from GPS or default)
  static Future<Coordinates> getCoordinates() async {
    // Use cached GPS coordinates if less than 5 minutes old
    if (_currentCoordinates != null &&
        _cityName != 'İstanbul' &&
        _lastGPSCheck != null &&
        DateTime.now().difference(_lastGPSCheck!).inMinutes < 5) {
      return _currentCoordinates!;
    }

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      // If permission is permanently denied, use cached or default
      if (permission == LocationPermission.deniedForever) {
        debugPrint(
          '📍 Konum izni kalıcı olarak reddedildi, varsayılan konum kullanılıyor: İstanbul',
        );
        if (_currentCoordinates == null) {
          _currentCoordinates = Coordinates(
            _defaultLatitude,
            _defaultLongitude,
          );
          _cityName = 'İstanbul';
        }
        return _currentCoordinates!;
      }

      // Request permission if denied
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        // If user denies, don't cache - try again next time
        if (permission == LocationPermission.denied) {
          debugPrint(
            '📍 Konum izni reddedildi (geçici), varsayılan kullanılıyor ama tekrar denenecek',
          );
          return Coordinates(_defaultLatitude, _defaultLongitude);
        }
      }

      // Try to get actual GPS position
      debugPrint('📍 GPS konumu alınıyor... (30sn timeout)');
      Position position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('GPS 30 saniye içinde yanıt vermedi');
            },
          );

      // Cache the REAL GPS coordinates
      _currentCoordinates = Coordinates(position.latitude, position.longitude);
      _lastGPSCheck = DateTime.now(); // Mark GPS check time

      // Try to get city name from cache
      final prefs = await SharedPreferences.getInstance();
      _cityName = prefs.getString('city_name') ?? 'Konumunuz';

      debugPrint(
        '✅ GPS Konumu alındı: ${position.latitude}, ${position.longitude}',
      );
      return _currentCoordinates!;
    } catch (e) {
      debugPrint('⚠️ GPS hatası: $e');

      // If we have previously cached REAL coordinates, use them
      if (_currentCoordinates != null && _cityName != 'İstanbul') {
        debugPrint('📍 Önceki GPS konumu kullanılıyor');
        return _currentCoordinates!;
      }

      // Otherwise use default but DON'T cache it
      debugPrint('📍 Geçici olarak İstanbul kullanılıyor (cache yok)');
      return Coordinates(_defaultLatitude, _defaultLongitude);
    }
  }

  /// Set city name manually
  static Future<void> setCityName(String name) async {
    _cityName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('city_name', name);
  }

  /// Get city name
  static String getCityName() => _cityName;

  /// Calculate prayer times for a given date
  static Future<PrayerTimes> getPrayerTimes([DateTime? date]) async {
    final targetDate = date ?? DateTime.now();
    final dateOnly = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    // Return cached if same date
    if (_cachedPrayerTimes != null &&
        _cachedDate != null &&
        _cachedDate!.year == dateOnly.year &&
        _cachedDate!.month == dateOnly.month &&
        _cachedDate!.day == dateOnly.day) {
      return _cachedPrayerTimes!;
    }

    // Get coordinates (GPS or default Istanbul)
    final coords = await getCoordinates();

    // CRITICAL: Use Turkey calculation method
    final params = CalculationMethod.turkey.getParameters();

    // CRITICAL: Use Shafi (Standard) for Asr time to match Diyanet
    // Hanafi calculates Asr-ı Sani (late afternoon), which is ~45 mins later
    params.madhab = Madhab.shafi;

    // CRITICAL: Use DateComponents.from() for accurate date-specific calculation
    final dateComponents = DateComponents.from(targetDate);
    final prayerTimes = PrayerTimes(coords, dateComponents, params);

    _cachedPrayerTimes = prayerTimes;
    _cachedDate = dateOnly;

    debugPrint(
      '🕌 Namaz vakitleri hesaplandı: ${dateOnly.day}/${dateOnly.month}/${dateOnly.year}',
    );
    debugPrint('   Fajr: ${formatPrayerTime(prayerTimes.fajr)}');
    debugPrint('   Dhuhr: ${formatPrayerTime(prayerTimes.dhuhr)}');
    debugPrint('   Asr: ${formatPrayerTime(prayerTimes.asr)}');
    debugPrint('   Maghrib: ${formatPrayerTime(prayerTimes.maghrib)}');
    debugPrint('   Isha: ${formatPrayerTime(prayerTimes.isha)}');

    return prayerTimes;
  }

  /// Get next prayer name and time
  static Future<Map<String, dynamic>> getNextPrayer() async {
    final now = DateTime.now();
    final prayerTimes = await getPrayerTimes();

    final prayers = [
      {'name': 'İmsak', 'time': prayerTimes.fajr, 'key': 'fajr'},
      {'name': 'Güneş', 'time': prayerTimes.sunrise, 'key': 'sunrise'},
      {'name': 'Öğle', 'time': prayerTimes.dhuhr, 'key': 'dhuhr'},
      {'name': 'İkindi', 'time': prayerTimes.asr, 'key': 'asr'},
      {'name': 'Akşam', 'time': prayerTimes.maghrib, 'key': 'maghrib'},
      {'name': 'Yatsı', 'time': prayerTimes.isha, 'key': 'isha'},
    ];

    for (var i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      if ((prayer['time'] as DateTime).isAfter(now)) {
        return prayer;
      }
    }

    // If no prayer left today, return tomorrow's Fajr
    final tomorrowPrayerTimes = await getPrayerTimes(
      now.add(const Duration(days: 1)),
    );
    return {'name': 'İmsak', 'time': tomorrowPrayerTimes.fajr, 'key': 'fajr'};
  }

  /// Get both current (start) and next (end) prayer times for progress bar
  static Future<Map<String, dynamic>> getCurrentAndNextPrayer() async {
    final now = DateTime.now();
    final prayerTimes = await getPrayerTimes();

    final prayers = [
      {'name': 'İmsak', 'time': prayerTimes.fajr, 'key': 'fajr'},
      {'name': 'Güneş', 'time': prayerTimes.sunrise, 'key': 'sunrise'},
      {'name': 'Öğle', 'time': prayerTimes.dhuhr, 'key': 'dhuhr'},
      {'name': 'İkindi', 'time': prayerTimes.asr, 'key': 'asr'},
      {'name': 'Akşam', 'time': prayerTimes.maghrib, 'key': 'maghrib'},
      {'name': 'Yatsı', 'time': prayerTimes.isha, 'key': 'isha'},
    ];

    // Find next prayer index
    int nextIndex = -1;
    for (var i = 0; i < prayers.length; i++) {
      if ((prayers[i]['time'] as DateTime).isAfter(now)) {
        nextIndex = i;
        break;
      }
    }

    if (nextIndex != -1) {
      // Normal case: We are between two prayers today
      // If it's the first prayer (Fajr) of the day, key previous is Isha of YESTERDAY
      if (nextIndex == 0) {
        final yesterdayPrayerTimes = await getPrayerTimes(
          now.subtract(const Duration(days: 1)),
        );
        return {
          'current': {
            'name': 'Yatsı',
            'time': yesterdayPrayerTimes.isha,
            'key': 'isha',
          },
          'next': prayers[0],
        };
      }

      return {'current': prayers[nextIndex - 1], 'next': prayers[nextIndex]};
    } else {
      // Late night case: After Isha, before midnight (next is tomorrow Fajr)
      // Current is Isha (last of today)
      // Next is Fajr (first of tomorrow)
      final tomorrowPrayerTimes = await getPrayerTimes(
        now.add(const Duration(days: 1)),
      );

      return {
        'current': prayers.last, // Isha
        'next': {
          'name': 'İmsak',
          'time': tomorrowPrayerTimes.fajr,
          'key': 'fajr',
        },
      };
    }
  }

  /// Get current active prayer (the last one that passed)
  static Future<String?> getCurrentPrayer() async {
    final now = DateTime.now();
    final prayerTimes = await getPrayerTimes();

    final prayers = [
      {'name': 'İmsak', 'time': prayerTimes.fajr, 'key': 'fajr'},
      {'name': 'Güneş', 'time': prayerTimes.sunrise, 'key': 'sunrise'},
      {'name': 'Öğle', 'time': prayerTimes.dhuhr, 'key': 'dhuhr'},
      {'name': 'İkindi', 'time': prayerTimes.asr, 'key': 'asr'},
      {'name': 'Akşam', 'time': prayerTimes.maghrib, 'key': 'maghrib'},
      {'name': 'Yatsı', 'time': prayerTimes.isha, 'key': 'isha'},
    ];

    String? currentPrayer;
    for (var prayer in prayers) {
      if ((prayer['time'] as DateTime).isBefore(now)) {
        currentPrayer = prayer['key'] as String;
      } else {
        break;
      }
    }

    return currentPrayer ?? 'isha'; // Default to Isha if before Fajr
  }

  /// Get duration until next prayer
  static Future<Duration> getTimeUntilNextPrayer() async {
    final nextPrayer = await getNextPrayer();
    final nextTime = nextPrayer['time'] as DateTime;
    final now = DateTime.now();
    return nextTime.difference(now);
  }

  /// Format time as HH:MM
  static String formatPrayerTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Get all 6 prayer times as a map
  static Future<Map<String, String>> getAllPrayerTimesFormatted([
    DateTime? date,
  ]) async {
    final prayerTimes = await getPrayerTimes(date);
    return {
      'fajr': formatPrayerTime(prayerTimes.fajr),
      'sunrise': formatPrayerTime(prayerTimes.sunrise),
      'dhuhr': formatPrayerTime(prayerTimes.dhuhr),
      'asr': formatPrayerTime(prayerTimes.asr),
      'maghrib': formatPrayerTime(prayerTimes.maghrib),
      'isha': formatPrayerTime(prayerTimes.isha),
    };
  }

  /// Clear cache (useful for testing)
  static void clearCache() {
    _cachedPrayerTimes = null;
    _cachedDate = null;
    _currentCoordinates = null;
  }
}
