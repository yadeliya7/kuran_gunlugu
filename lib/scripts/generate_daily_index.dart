import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print("Downloading Quran data (tr.yazir)...");

  // Fetch full Quran (Turkish translation for length check)
  // This endpoint returns all 114 surahs and their verses
  final url = Uri.parse("http://api.alquran.cloud/v1/quran/tr.yazir");

  try {
    final response = await http.get(url);

    if (response.statusCode != 200) {
      print("Error: Failed to fetch data. Status Code: ${response.statusCode}");
      return;
    }

    final jsonResponse = jsonDecode(response.body);
    final data = jsonResponse['data'];
    final List<dynamic> surahs = data['surahs'];

    // Flatten into a single list of verses for easy iteration
    List<Map<String, dynamic>> allVerses = [];

    for (var surah in surahs) {
      int surahNumber = surah['number'];
      // surah['ayahs'] is a list of verses
      for (var ayah in surah['ayahs']) {
        allVerses.add({
          'id': ayah['number'], // Global Verse ID (1 to 6236)
          'text': ayah['text'],
          'surah': surahNumber,
          'numberInSurah': ayah['numberInSurah'],
        });
      }
    }

    print("Total Verses: ${allVerses.length}");

    // Logic Verification
    List<int> dailyStartIds = [];
    int i = 0;
    int dayCount = 0;

    while (i < allVerses.length) {
      dayCount++;
      var current = allVerses[i];

      // Record the start ID for this "Day"
      dailyStartIds.add(current['id']); // Store 1-based Global ID

      // Smart Merging Logic
      // Check if short (< 60) AND next verse exists AND next verse is same Surah
      bool shouldMerge = false;

      if (current['text'].toString().length < 60) {
        if ((i + 1) < allVerses.length) {
          var next = allVerses[i + 1];
          if (current['surah'] == next['surah']) {
            shouldMerge = true;
          }
        }
      }

      if (shouldMerge) {
        // Consume 2 verses (Current + Next)
        // Next day will start at i + 2
        i += 2;
      } else {
        // Consume 1 verse
        // Next day will start at i + 1
        i += 1;
      }
    }

    print("Generation Complete! Writing to file...");

    StringBuffer buffer = StringBuffer();
    buffer.writeln("class DailyVerseMap {");
    buffer.writeln("  static const List<int> dailyStartIds = [");

    for (int j = 0; j < dailyStartIds.length; j++) {
      buffer.write("${dailyStartIds[j]},");
      if ((j + 1) % 20 == 0) {
        buffer.writeln(); // New line every 20 items
      }
    }

    buffer.writeln("  ];");
    buffer.writeln("}");

    // Write to file
    // Assumes script is run from project root
    final File file = File('lib/core/constants/daily_verse_map.dart');
    await file.writeAsString(buffer.toString());

    print("Successfully wrote to lib/core/constants/daily_verse_map.dart");
    print("Total Days: ${dailyStartIds.length}");
  } catch (e) {
    print("Exception occurred: $e");
  }
}
