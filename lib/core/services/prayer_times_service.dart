import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'global_settings.dart'; // Added GlobalSettings import

class PrayerTimesService {
  // Default location: Istanbul, Turkey
  static const double _defaultLatitude = 41.0082;
  static const double _defaultLongitude = 28.9784;

  static Coordinates? _currentCoordinates;
  static String _cityName = 'İstanbul';
  static PrayerTimes? _cachedPrayerTimes;
  static DateTime? _cachedDate;

  /// Apply manual offset to align with Diyanet (Turkey)
  /// Currently applying -1 day offset (e.g. Feb 19 -> Feb 20 effectively for calculation)
  /// WAITING: User reported Feb 18 is calculated as Ramadan 1, but Diyanet says Feb 19.
  /// This means our algo is 1 day EARLY. We need to SUBTRACT 1 day from the date to push it back?
  /// Wait, if Algo says 18th is Ramadan 1, and Diyanet says 19th is Ramadan 1.
  /// Then on 18th, Algo says "1 Ramazan", Diyanet says "30 Shaban".
  /// So Algo is AHEAD. To fix "1 Ramazan" to appear on 19th instead of 18th:
  /// On 18th: Algo(18) = 1 Ram. We want Algo(18) = 30 Shab.
  /// On 19th: Algo(19) = 2 Ram. We want Algo(19) = 1 Ram.
  /// So effectively we need to simulate a date that is 1 day BEHIND?
  /// If we pass (Date - 1 day) to Algo:
  /// On 19th (Real): Pass 18th. Algo(18) = 1 Ram. Matches Diyanet(19) = 1 Ram.
  /// CORRECT. Offset is -1 Day.
  static DateTime _applyHijriOffset(DateTime date) {
    return date.subtract(const Duration(days: 1));
  }

  /// Get formatted Hijri date using simplified calculation with offset
  static String getHijriDate(DateTime date) {
    try {
      // Apply offset first
      final adjustedDate = _applyHijriOffset(date);

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

      // English month names for Hijri calendar
      const englishMonths = [
        'Muharram',
        'Safar',
        'Rabi’ al-Awwal',
        'Rabi’ al-Thani',
        'Jumada al-Awwal',
        'Jumada al-Thani',
        'Rajab',
        'Sha’ban',
        'Ramadan',
        'Shawwal',
        'Dhu al-Qi’dah',
        'Dhu al-Hijjah',
      ];

      final months = GlobalSettings.currentLanguage == 'tr'
          ? turkishMonths
          : englishMonths;

      // Convert Gregorian (adjusted) to Julian Day Number
      int d = adjustedDate.day;
      int m = adjustedDate.month;
      int y = adjustedDate.year;

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

      final monthName = months[hMonth - 1];
      return '$hDay $monthName';
    } catch (e) {
      debugPrint('❌ Hicri Tarih Hatası: $e');
      return '';
    }
  }

  /// Get Hijri month number (1-12) with offset
  /// Used for Ramadan detection (Month 9)
  static int getHijriMonth(DateTime date) {
    try {
      final adjustedDate = _applyHijriOffset(date);

      int d = adjustedDate.day;
      int m = adjustedDate.month;
      int y = adjustedDate.year;

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
      return hMonth;
    } catch (e) {
      return 0;
    }
  }

  /// Get coordinates (from GPS or persistent cache)
  /// Strategy: Get GPS once when app opens, save to persistent storage
  /// Avoids background location requests (iOS restriction)
  static Future<Coordinates> getCoordinates() async {
    // First, check memory cache
    if (_currentCoordinates != null) {
      debugPrint('📍 Using memory-cached coordinates');
      return _currentCoordinates!;
    }

    // If not in memory, try to load from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedLat = prefs.getDouble('cached_latitude');
      final cachedLng = prefs.getDouble('cached_longitude');

      if (cachedLat != null && cachedLng != null) {
        _currentCoordinates = Coordinates(cachedLat, cachedLng);
        _cityName = prefs.getString('city_name') ?? 'Konumunuz';
        debugPrint(
          '📍 Loaded coordinates from storage: $cachedLat, $cachedLng ($_cityName)',
        );

        // Now try to refresh GPS in background (non-blocking)
        // This will update for next time, but return cached immediately
        _refreshGPSInBackground();

        return _currentCoordinates!;
      }
    } catch (e) {
      debugPrint('⚠️ Could not load cached coordinates: $e');
    }

    // If no cache exists, must get GPS now (first-time user)
    debugPrint('📍 No cached coordinates, requesting GPS...');
    return await _fetchAndSaveGPS();
  }

  /// Force refresh location (called when user explicitly wants to update)
  static Future<void> forceRefreshLocation() async {
    debugPrint('🔄 Force refreshing GPS location...');
    _currentCoordinates = null;
    await _fetchAndSaveGPS();
  }

  /// Background GPS refresh (non-blocking)
  static void _refreshGPSInBackground() async {
    try {
      debugPrint('🔄 Attempting background GPS refresh...');

      // Check permission first
      LocationPermission permission = await Geolocator.checkPermission();

      // If denied, skip silently
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint(
          '📍 Location permission denied, skipping background refresh',
        );
        return;
      }

      // Try to get GPS with timeout
      Position position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('GPS timeout after 10 seconds');
            },
          );

      // Save new coordinates
      _currentCoordinates = Coordinates(position.latitude, position.longitude);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('cached_latitude', position.latitude);
      await prefs.setDouble('cached_longitude', position.longitude);
      await prefs.setString(
        'last_location_update',
        DateTime.now().toIso8601String(),
      );

      debugPrint(
        '✅ Background GPS refresh successful: ${position.latitude}, ${position.longitude}',
      );
    } catch (e) {
      debugPrint('⚠️ Background GPS refresh failed (not critical): $e');
    }
  }

  /// Fetch GPS and save to persistent storage
  static Future<Coordinates> _fetchAndSaveGPS() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      // If permission is permanently denied, use default
      if (permission == LocationPermission.deniedForever) {
        debugPrint(
          '📍 Location permission permanently denied, using default: Istanbul',
        );
        _currentCoordinates = Coordinates(_defaultLatitude, _defaultLongitude);
        _cityName = 'İstanbul';
        return _currentCoordinates!;
      }

      // Request permission if denied
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          debugPrint('📍 Location permission denied, using default: Istanbul');
          _currentCoordinates = Coordinates(
            _defaultLatitude,
            _defaultLongitude,
          );
          _cityName = 'İstanbul';
          return _currentCoordinates!;
        }
      }

      // Get GPS position
      debugPrint('📍 Requesting GPS position (30s timeout)...');
      Position position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('GPS did not respond within 30 seconds');
            },
          );

      // Save to memory cache
      _currentCoordinates = Coordinates(position.latitude, position.longitude);

      // Save to persistent storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('cached_latitude', position.latitude);
      await prefs.setDouble('cached_longitude', position.longitude);
      await prefs.setString(
        'last_location_update',
        DateTime.now().toIso8601String(),
      );

      // Try to get city name
      _cityName = prefs.getString('city_name') ?? 'Konumunuz';

      debugPrint(
        '✅ GPS position obtained and saved: ${position.latitude}, ${position.longitude}',
      );
      return _currentCoordinates!;
    } catch (e) {
      debugPrint('❌ GPS error: $e');

      // If we have previously cached coordinates in memory, use them
      if (_currentCoordinates != null) {
        debugPrint('📍 Using previous memory cache due to GPS error');
        return _currentCoordinates!;
      }

      // Check SharedPreferences one more time
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedLat = prefs.getDouble('cached_latitude');
        final cachedLng = prefs.getDouble('cached_longitude');

        if (cachedLat != null && cachedLng != null) {
          _currentCoordinates = Coordinates(cachedLat, cachedLng);
          debugPrint('📍 Using stored cache due to GPS error');
          return _currentCoordinates!;
        }
      } catch (e2) {
        debugPrint('❌ Could not load fallback cache: $e2');
      }

      // Last resort: use default Istanbul
      debugPrint('📍 All location methods failed, using default: Istanbul');
      _currentCoordinates = Coordinates(_defaultLatitude, _defaultLongitude);
      _cityName = 'İstanbul';
      return _currentCoordinates!;
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

  /// Clear cached prayer times (call when settings change)
  static void clearCache() {
    _cachedPrayerTimes = null;
    _cachedDate = null;
    debugPrint('🗑️ Prayer times cache cleared');
  }

  /// Get calculation method based on user preference
  static Future<CalculationMethod> _getCalculationMethod(
    Coordinates coords,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final methodKey = prefs.getString('prayer_calculation_method') ?? 'auto';

    // If auto, detect based on location
    if (methodKey == 'auto') {
      return _getAutoMethod(coords);
    }

    // Map string to CalculationMethod
    switch (methodKey) {
      case 'turkey':
        return CalculationMethod.turkey;
      case 'mwl':
        return CalculationMethod.muslim_world_league;
      case 'isna':
        return CalculationMethod.north_america;
      case 'makkah':
        return CalculationMethod.umm_al_qura;
      case 'egypt':
        return CalculationMethod.egyptian;
      default:
        return _getAutoMethod(coords); // Fallback to auto
    }
  }

  /// Auto-detect calculation method based on coordinates
  static CalculationMethod _getAutoMethod(Coordinates coords) {
    final lat = coords.latitude;
    final long = coords.longitude;

    // Turkey bounds: 36° ≤ Lat ≤ 42° and 26° ≤ Long ≤ 45°
    if (lat >= 36 && lat <= 42 && long >= 26 && long <= 45) {
      debugPrint('📍 Auto-detection: Turkey');
      return CalculationMethod.turkey;
    }

    // Americas: Long < -30
    if (long < -30) {
      debugPrint('📍 Auto-detection: North America');
      return CalculationMethod.north_america;
    }

    // Default: Muslim World League (Europe/Global)
    debugPrint('📍 Auto-detection: Muslim World League');
    return CalculationMethod.muslim_world_league;
  }

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

    // Get calculation method (user preference or auto-detect)
    final method = await _getCalculationMethod(coords);
    final params = method.getParameters();

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
      {'time': prayerTimes.fajr, 'key': 'fajr'},
      {'time': prayerTimes.sunrise, 'key': 'sunrise'},
      {'time': prayerTimes.dhuhr, 'key': 'dhuhr'},
      {'time': prayerTimes.asr, 'key': 'asr'},
      {'time': prayerTimes.maghrib, 'key': 'maghrib'},
      {'time': prayerTimes.isha, 'key': 'isha'},
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
    return {'time': tomorrowPrayerTimes.fajr, 'key': 'fajr'};
  }

  /// Get both current (start) and next (end) prayer times for progress bar
  static Future<Map<String, dynamic>> getCurrentAndNextPrayer() async {
    final now = DateTime.now();
    final prayerTimes = await getPrayerTimes();

    final prayers = [
      {'time': prayerTimes.fajr, 'key': 'fajr'},
      {'time': prayerTimes.sunrise, 'key': 'sunrise'},
      {'time': prayerTimes.dhuhr, 'key': 'dhuhr'},
      {'time': prayerTimes.asr, 'key': 'asr'},
      {'time': prayerTimes.maghrib, 'key': 'maghrib'},
      {'time': prayerTimes.isha, 'key': 'isha'},
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
          'current': {'time': yesterdayPrayerTimes.isha, 'key': 'isha'},
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
        'next': {'time': tomorrowPrayerTimes.fajr, 'key': 'fajr'},
      };
    }
  }

  /// Get current active prayer (the last one that passed)
  static Future<String?> getCurrentPrayer() async {
    final now = DateTime.now();
    final prayerTimes = await getPrayerTimes();

    final prayers = [
      {'time': prayerTimes.fajr, 'key': 'fajr'},
      {'time': prayerTimes.sunrise, 'key': 'sunrise'},
      {'time': prayerTimes.dhuhr, 'key': 'dhuhr'},
      {'time': prayerTimes.asr, 'key': 'asr'},
      {'time': prayerTimes.maghrib, 'key': 'maghrib'},
      {'time': prayerTimes.isha, 'key': 'isha'},
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
}
