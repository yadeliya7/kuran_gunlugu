import 'package:google_fonts/google_fonts.dart'; // Added for Monospace font
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:timer_builder/timer_builder.dart';
import '../core/constants/colors.dart';
import '../core/constants/strings.dart'; // Added strings import
import '../core/services/global_settings.dart'; // Added GlobalSettings import
import '../core/services/prayer_times_service.dart';

class PrayerTimesCard extends StatefulWidget {
  final VoidCallback onTap;

  const PrayerTimesCard({super.key, required this.onTap});

  @override
  State<PrayerTimesCard> createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends State<PrayerTimesCard>
    with WidgetsBindingObserver {
  String _cityName = ''; // Initialized empty, will load localized defaults
  Map<String, String> _prayerTimes = {};
  String? _currentPrayer;

  // Helper for localization
  String t(String key) {
    return dictionary[GlobalSettings.currentLanguage]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _cityName = t('loading');
    WidgetsBinding.instance.addObserver(this);
    _loadPrayerTimes();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh prayer times when app resumes (e.g., returning from Settings)
    if (state == AppLifecycleState.resumed && mounted) {
      debugPrint('🔄 App resumed - Refreshing prayer times card');
      _loadPrayerTimes();
    }
  }

  Future<void> _loadPrayerTimes() async {
    try {
      await PrayerTimesService.getCoordinates();
      final times = await PrayerTimesService.getAllPrayerTimesFormatted();
      final current = await PrayerTimesService.getCurrentPrayer();

      if (mounted) {
        setState(() {
          // If default city used, localize "Your Location"
          final city = PrayerTimesService.getCityName();
          _cityName = city == 'Konumunuz' || city == 'Your Location'
              ? t('location_default')
              : city;
          _prayerTimes = times;
          _currentPrayer = current;
        });
      }
    } catch (e) {
      debugPrint('❌ Namaz vakitleri yüklenemedi: $e');
    }
  }

  /// Check if current date is in Ramadan (Hijri month 9)
  bool _isRamadan() {
    final now = DateTime.now();
    final hijriMonth = _getHijriMonth(now);
    return hijriMonth == 9; // Ramadan is the 9th month in Hijri calendar
  }

  /// Convert Gregorian date to Hijri month (simplified algorithm)
  int _getHijriMonth(DateTime gregorian) {
    // Algorithm based on: https://www.staff.science.uu.nl/~gent0113/islam/ummalqura.htm
    // Simplified for month-only calculation

    int day = gregorian.day;
    int month = gregorian.month;
    int year = gregorian.year;

    // Adjust for calculation
    if (month < 3) {
      year -= 1;
      month += 12;
    }

    int a = (year / 100).floor();
    int b = (a / 4).floor();
    int c = 2 - a + b;
    int e = (365.25 * (year + 4716)).floor();
    int f = (30.6001 * (month + 1)).floor();

    double jd = c + day + e + f - 1524.5;

    // Convert Julian Day to Hijri
    double l = jd - 1948440 + 10632;
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    int j =
        (((10985 - l) / 5316).floor()) * (((50 * l) / 17719).floor()).toInt() +
        ((l / 5670).floor()) * (((43 * l) / 15238).floor()).toInt();
    l =
        l -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;

    int hijriMonth = ((24 * l) / 709).floor();

    return hijriMonth;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cardBackground.withValues(alpha: 0.9),
              AppColors.background.withValues(alpha: 0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.15),
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
        child: Column(
          children: [
            // City Name Row
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.gold, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _cityName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Countdown with Linear Progress
            _buildCountdownSection(),

            const SizedBox(height: 18),

            // Divider
            Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),

            const SizedBox(height: 15),

            // Prayer Times Strip
            _buildPrayerTimesStrip(),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownSection() {
    return TimerBuilder.periodic(
      const Duration(seconds: 1),
      builder: (context) {
        return FutureBuilder<Map<String, dynamic>>(
          // Use new method to get both start and end times
          future: PrayerTimesService.getCurrentAndNextPrayer(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 60,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.gold,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            final data = snapshot.data!;
            final currentPrayer = data['current'];
            final nextPrayer = data['next'];

            final startTime = currentPrayer['time'] as DateTime;
            final endTime = nextPrayer['time'] as DateTime;
            // Name is resolved via key now
            final nextPrayerKey = nextPrayer['key'] as String;
            final nextPrayerName = t('prayer_$nextPrayerKey');

            final now = DateTime.now();
            final totalDuration = endTime.difference(startTime);
            final elapsedDuration = now.difference(startTime);
            final remainingDuration = endTime.difference(now);

            // Calculate exact progress
            double progress =
                (elapsedDuration.inSeconds / totalDuration.inSeconds).clamp(
                  0.0,
                  1.0,
                );

            final hours = remainingDuration.inHours.toString().padLeft(2, '0');
            final minutes = (remainingDuration.inMinutes % 60)
                .toString()
                .padLeft(2, '0');
            final seconds = (remainingDuration.inSeconds % 60)
                .toString()
                .padLeft(2, '0');

            // Determine Label Text
            String labelText =
                '${nextPrayerName.toUpperCase()} ${t('time_remaining_general')}';
            Color labelColor = AppColors.textGrey;
            FontWeight labelWeight = FontWeight.w500;

            if (nextPrayerKey == 'fajr') {
              // Only show "Sahura Kalan Süre" during Ramadan
              if (_isRamadan()) {
                labelText = t('time_remaining_sahur');
                labelColor = AppColors.gold;
                labelWeight = FontWeight.bold;
              } else {
                // Outside Ramadan, show generic fajr countdown
                labelText =
                    '${nextPrayerName.toUpperCase()} ${t('time_remaining_general')}';
              }
            } else if (nextPrayerKey == 'maghrib') {
              // Only show "İftara Kalan Süre" during Ramadan
              if (_isRamadan()) {
                labelText = t('time_remaining_iftar');
                labelColor = AppColors.gold;
                labelWeight = FontWeight.bold;
              } else {
                // Outside Ramadan, show generic maghrib countdown
                labelText =
                    '${nextPrayerName.toUpperCase()} ${t('time_remaining_general')}';
              }
            } else if (nextPrayerKey == 'sunrise') {
              labelText = t('time_remaining_sunrise');
            }

            return Column(
              children: [
                // Top Row: Label and Countdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      labelText,
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 13,
                        fontWeight: labelWeight,
                      ),
                    ),
                    // Fixed-width Digital Clock Layout
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Hours
                        SizedBox(
                          width: 34, // Fixed width for 2 digits
                          child: Text(
                            hours,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.robotoMono(
                              color: AppColors.gold,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        Text(
                          ':',
                          style: GoogleFonts.robotoMono(
                            color: AppColors.gold,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Minutes
                        SizedBox(
                          width: 34,
                          child: Text(
                            minutes,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.robotoMono(
                              color: AppColors.gold,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        Text(
                          ':',
                          style: GoogleFonts.robotoMono(
                            color: AppColors.gold,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Seconds
                        SizedBox(
                          width: 34,
                          child: Text(
                            seconds,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.robotoMono(
                              color: AppColors.gold,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Linear Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.passiveGrey.withValues(
                      alpha: 0.2,
                    ),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.gold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPrayerTimesStrip() {
    if (_prayerTimes.isEmpty) {
      return const SizedBox(height: 60);
    }

    // List of keys to support localized names
    final prayers = [
      {'key': 'fajr', 'icon': Icons.nightlight_round},
      {'key': 'sunrise', 'icon': Icons.wb_sunny},
      {'key': 'dhuhr', 'icon': Icons.wb_sunny_outlined},
      {'key': 'asr', 'icon': Icons.sunny_snowing},
      {'key': 'maghrib', 'icon': Icons.wb_twilight},
      {'key': 'isha', 'icon': Icons.nights_stay},
    ];

    return Row(
      children: prayers.map((prayer) {
        final key = prayer['key'] as String;
        final isActive = key == _currentPrayer;
        final time = _prayerTimes[key] ?? '--:--';
        final name = t('prayer_$key');

        return Expanded(
          child: Column(
            children: [
              Icon(
                prayer['icon'] as IconData,
                color: isActive ? AppColors.gold : AppColors.passiveGrey,
                size: 20,
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  name,
                  style: TextStyle(
                    color: isActive ? AppColors.gold : AppColors.passiveGrey,
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  time,
                  style: TextStyle(
                    color: isActive ? AppColors.gold : AppColors.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
