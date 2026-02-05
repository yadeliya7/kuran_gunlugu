import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timer_builder/timer_builder.dart';
import '../core/constants/colors.dart';
import '../core/services/prayer_times_service.dart';

class PrayerTimesCard extends StatefulWidget {
  final VoidCallback onTap;

  const PrayerTimesCard({super.key, required this.onTap});

  @override
  State<PrayerTimesCard> createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends State<PrayerTimesCard> {
  String _cityName = 'Yükleniyor...';
  Map<String, String> _prayerTimes = {};
  String? _currentPrayer;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    try {
      await PrayerTimesService.getCoordinates();
      final times = await PrayerTimesService.getAllPrayerTimesFormatted();
      final current = await PrayerTimesService.getCurrentPrayer();

      if (mounted) {
        setState(() {
          _cityName = PrayerTimesService.getCityName();
          _prayerTimes = times;
          _currentPrayer = current;
        });
      }
    } catch (e) {
      debugPrint('❌ Namaz vakitleri yüklenemedi: $e');
    }
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
            final nextPrayerName = nextPrayer['name'] as String;

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

            // Invert logic if needed (progress bar usually shows "time passed" or "time remaining")
            // Here we want "Time Passed" (growing bar)
            // 0.0 -> Start of prayer time
            // 1.0 -> End of prayer time (Adhan)

            final hours = remainingDuration.inHours.toString().padLeft(2, '0');
            final minutes = (remainingDuration.inMinutes % 60)
                .toString()
                .padLeft(2, '0');
            final seconds = (remainingDuration.inSeconds % 60)
                .toString()
                .padLeft(2, '0');

            // Determine Label Text
            String labelText = '$nextPrayerName Vaktine Kalan';
            Color labelColor = AppColors.textGrey;
            FontWeight labelWeight = FontWeight.w500;

            final key = nextPrayer['key'];
            if (key == 'fajr') {
              labelText = 'SAHURA KALAN SÜRE';
              labelColor = AppColors.gold;
              labelWeight = FontWeight.bold;
            } else if (key == 'maghrib') {
              labelText = 'İFTARA KALAN SÜRE';
              labelColor = AppColors.gold;
              labelWeight = FontWeight.bold;
            } else if (key == 'sunrise') {
              labelText = 'GÜNEŞİN DOĞUŞUNA';
            } else {
              labelText = '${nextPrayerName.toUpperCase()} VAKTİNE KALAN';
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
                    Text(
                      '$hours:$minutes:$seconds',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
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

    final prayers = [
      {'name': 'İmsak', 'key': 'fajr', 'icon': Icons.nightlight_round},
      {'name': 'Güneş', 'key': 'sunrise', 'icon': Icons.wb_sunny},
      {'name': 'Öğle', 'key': 'dhuhr', 'icon': Icons.wb_sunny_outlined},
      {'name': 'İkindi', 'key': 'asr', 'icon': Icons.sunny_snowing},
      {'name': 'Akşam', 'key': 'maghrib', 'icon': Icons.wb_twilight},
      {'name': 'Yatsı', 'key': 'isha', 'icon': Icons.nights_stay},
    ];

    return Row(
      children: prayers.map((prayer) {
        final isActive = prayer['key'] == _currentPrayer;
        final time = _prayerTimes[prayer['key']] ?? '--:--';

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
                  prayer['name'] as String,
                  style: TextStyle(
                    color: isActive ? AppColors.gold : AppColors.passiveGrey,
                    fontSize: 11,
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
                    fontSize: 10,
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
