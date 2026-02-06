import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/colors.dart';
import '../core/constants/strings.dart'; // Added strings import
import '../core/services/global_settings.dart'; // Added GlobalSettings import
import '../core/services/prayer_times_service.dart';

void showPrayerTimesBottomSheet(BuildContext context) {
  // Helper for localization
  String t(String key) {
    return dictionary[GlobalSettings.currentLanguage]?[key] ?? key;
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.background,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with decorative background
                Stack(
                  children: [
                    // Background decorative image
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Opacity(
                          opacity: 0.12,
                          child: Image.asset(
                            'assets/images/cami_motif_tr.png',
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // Foreground content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: FittedBox(
                                alignment: Alignment.centerLeft,
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  t('prayer_times_title'),
                                  style: TextStyle(
                                    color: AppColors.gold,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.textWhite,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Location Info
                        FutureBuilder<void>(
                          future: PrayerTimesService.getCoordinates(),
                          builder: (context, snapshot) {
                            final city = PrayerTimesService.getCityName();
                            final localizedCity =
                                city == 'Konumunuz' || city == 'Your Location'
                                ? t('location_default')
                                : city;

                            return Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: AppColors.gold,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    localizedCity,
                                    style: TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            t('table_date'),
                            style: TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            t('prayer_fajr'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            t('prayer_sunrise'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            t('prayer_dhuhr'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            t('prayer_asr'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            t('prayer_maghrib'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            t('prayer_isha'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Table Content
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: 30,
                    itemBuilder: (context, index) {
                      final date = DateTime.now().add(Duration(days: index));

                      return FutureBuilder<Map<String, String>>(
                        future: PrayerTimesService.getAllPrayerTimesFormatted(
                          date,
                        ),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ),
                            );
                          }

                          final times = snapshot.data!;
                          // Localize date format
                          final locale = GlobalSettings.currentLanguage == 'tr'
                              ? 'tr'
                              : 'en';
                          final formattedDate = DateFormat(
                            'dd MMM',
                            locale,
                          ).format(date);
                          final isToday =
                              DateFormat('yyyyMMdd').format(date) ==
                              DateFormat('yyyyMMdd').format(DateTime.now());

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? AppColors.gold.withOpacity(0.1)
                                  : (index.isEven
                                        ? Colors.white.withOpacity(0.03)
                                        : Colors.transparent),
                              borderRadius: BorderRadius.circular(8),
                              border: isToday
                                  ? Border.all(
                                      color: AppColors.gold.withOpacity(0.3),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          color: isToday
                                              ? AppColors.gold
                                              : AppColors.textWhite70,
                                          fontSize: 12,
                                          fontWeight: isToday
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      Builder(
                                        builder: (context) {
                                          final hijriText =
                                              PrayerTimesService.getHijriDate(
                                                date,
                                              );
                                          return Text(
                                            hijriText.isEmpty ? '' : hijriText,
                                            style: TextStyle(
                                              color: isToday
                                                  ? AppColors.gold.withOpacity(
                                                      0.8,
                                                    )
                                                  : Colors.white70,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                _buildTimeCell(
                                  times['fajr'] ?? '--:--',
                                  isToday,
                                ),
                                _buildTimeCell(
                                  times['sunrise'] ?? '--:--',
                                  isToday,
                                ),
                                _buildTimeCell(
                                  times['dhuhr'] ?? '--:--',
                                  isToday,
                                ),
                                _buildTimeCell(
                                  times['asr'] ?? '--:--',
                                  isToday,
                                ),
                                _buildTimeCell(
                                  times['maghrib'] ?? '--:--',
                                  isToday,
                                ),
                                _buildTimeCell(
                                  times['isha'] ?? '--:--',
                                  isToday,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildTimeCell(String time, bool isToday) {
  return Expanded(
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        time,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isToday ? AppColors.textWhite : AppColors.textGrey,
          fontSize: 11,
          fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    ),
  );
}
