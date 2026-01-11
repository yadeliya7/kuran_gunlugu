import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/ayet_model.dart';
import '../constants/daily_verse_map.dart';
import 'hafiz_service.dart';

class DailyVerseService {
  /// Reverse Lookup: Finds which Day Index contains a specific Verse ID.
  ///
  /// This is crucial for navigation from favorites because we cannot assume
  /// DayIndex == VerseID due to Smart Merge logic.
  ///
  /// Example: If dailyStartIds is [1, 3, 5] and targetVerseId is 4:
  /// - Index 0 (Start ID 1) <= 4? Yes.
  /// - Index 1 (Start ID 3) <= 4? Yes.
  /// - Index 2 (Start ID 5) <= 4? No.
  /// Result: Verse 4 belongs to Day Index 1.
  static int getDayIndexForVerseId(int targetVerseId) {
    final List<int> startIds = DailyVerseMap.dailyStartIds;

    // Find the last index where startIds[index] <= targetVerseId
    int dayIndex = 0;
    for (int i = 0; i < startIds.length; i++) {
      if (startIds[i] <= targetVerseId) {
        dayIndex = i;
      } else {
        // Once we find a start ID greater than target, we've gone too far
        break;
      }
    }

    return dayIndex;
  }

  /// Gets the verse for a specific date using strict Calendar-based logic.
  /// Anchor Date: January 1, 2026.
  Future<AyetModel> getVerseForDate(DateTime date) async {
    // 1. Calculate Target Index from Static Map
    final DateTime startDate = DateTime(2026, 1, 1);

    // Reset time components for accurate day difference
    final DateTime d1 = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final DateTime d2 = DateTime(date.year, date.month, date.day);

    int totalDays = DailyVerseMap.dailyStartIds.length;
    int daysElapsed = d2.difference(d1).inDays;

    // Calculate circular index handling negative values
    // Dart's % operator returns negative for negative operands, so we adjust.
    int mapIndex = daysElapsed % totalDays;
    if (mapIndex < 0) mapIndex += totalDays;

    // Fetch Start ID from Static Map
    int targetIndex = DailyVerseMap.dailyStartIds[mapIndex];

    debugPrint(
      "📅 Date: $d2 | Map Index: $mapIndex | Target Verse ID: $targetIndex",
    );

    // 2. Try Fetching from API
    try {
      AyetModel currentVerse = await _fetchVerseFromApi(targetIndex);

      // 3. Smart Merging Logic (Dynamic)
      if (currentVerse.turkce.length < 60) {
        try {
          // Optimistically fetch next verse to check Surah
          // Note: Next verse depends on index + 1
          int nextIndex = (targetIndex % 6236) + 1;
          AyetModel nextVerse = await _fetchVerseFromApi(nextIndex);

          if (currentVerse.sureAdi == nextVerse.sureAdi) {
            debugPrint("🔗 Smart Merge Success: $targetIndex & $nextIndex");
            return AyetModel(
              id: currentVerse.id,
              sureAdi: currentVerse.sureAdi,
              ayetNo: currentVerse.ayetNo,
              bitisAyetNo: nextVerse.ayetNo,
              turkce: "${currentVerse.turkce} ${nextVerse.turkce}",
              ingilizce: "${currentVerse.ingilizce} ${nextVerse.ingilizce}",
              arapca: "${currentVerse.arapca} ${nextVerse.arapca}",
              sesDosyasiUrl: currentVerse.sesDosyasiUrl,
              ekSesDosyalari: [nextVerse.sesDosyasiUrl],
            );
          }
        } catch (e) {
          debugPrint("⚠️ Merge Attempt Failed (Next Verse Unreachable): $e");
        }
      }

      // No merge needed or failed
      return currentVerse;
    } catch (e) {
      debugPrint("❌ API Fetch Failed (Offline?): $e");
      rethrow; // Propagate error to trigger Local Fallback
    }
  }

  Future<AyetModel> _fetchVerseFromApi(int ayetId) async {
    String kalite = HafizYonetimi.getBitrate(HafizYonetimi.secilenHafizKodu);
    String hafiz = HafizYonetimi.secilenHafizKodu;
    int randomNum = Random().nextInt(10000);

    String esasLink =
        'https://api.alquran.cloud/v1/ayah/$ayetId/editions/quran-uthmani,tr.yazir,en.sahih';
    String sesLinki =
        "https://cdn.islamic.network/quran/audio/$kalite/$hafiz/$ayetId.mp3";

    try {
      final response = await http.get(Uri.parse(esasLink));
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var data = jsonResponse['data'];
        return AyetModel(
          id: ayetId,
          sureAdi: data[1]['surah']['englishName'], // data[1] is tr.yazir
          ayetNo: data[1]['numberInSurah'],
          arapca: data[0]['text'], // data[0] is quran-uthmani
          turkce: data[1]['text'],
          ingilizce: data[2]['text'], // data[2] is en.sahih
          sesDosyasiUrl: sesLinki,
          bitisAyetNo: null,
        );
      }
    } catch (e) {
      debugPrint('⚠️ APIs Error (Main): $e');
      rethrow; // Don't hide error here
    }

    // Proxy fallback
    try {
      final proxyUrl = Uri.parse(
        'https://api.allorigins.win/raw?url=$esasLink&cb=$randomNum',
      );
      final response = await http.get(proxyUrl);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var data = jsonResponse['data'];

        return AyetModel(
          id: ayetId,
          sureAdi: data[1]['surah']['englishName'],
          ayetNo: data[1]['numberInSurah'],
          arapca: data[0]['text'],
          turkce: data[1]['text'],
          ingilizce: data[2]['text'],
          sesDosyasiUrl: sesLinki,
          bitisAyetNo: null,
        );
      }
    } catch (e) {
      debugPrint('⚠️ Proxy Error: $e');
    }

    throw Exception("Failed to fetch verse: $ayetId");
  }
}
