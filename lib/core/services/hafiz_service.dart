import 'package:shared_preferences/shared_preferences.dart';

class HafizYonetimi {
  // Varsayılan Hafız
  static String secilenHafizKodu = 'ar.alafasy-2';

  // Hafız Listesi (Sadece İsim ve Kod)
  static final List<Map<String, String>> hafizlar = [
    {'isim': 'Mişari Raşid el-Afasi', 'kod': 'ar.alafasy-2'},
    {'isim': 'Mahir el-Muaykili', 'kod': 'ar.mahermuaiqly-2'},
    {'isim': 'Abdüssamed (Murattal)', 'kod': 'ar.abdulbasitmurattal-2'},
    {'isim': 'Ahmed el-Acemi', 'kod': 'ar.ahmedajamy'},
  ];

  // 👇 SİHİRLİ FONKSİYON BURASI
  // Hafızın koduna bakıp doğru bitrate'i (kaliteyi) kendisi verir.
  static String getBitrate(String hafizKodu) {
    if (hafizKodu == 'ar.abdulbasitmujawwad-2' ||
        hafizKodu == 'ar.abdulbasitmurattal-2') {
      return '192';
    }

    return '128';
  }

  // Hafızı Kaydet
  static Future<void> hafizKaydet(String kod) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('secilen_hafiz', kod);
    secilenHafizKodu = kod;
  }

  // Hafızı Yükle
  static Future<void> hafizYukle() async {
    final prefs = await SharedPreferences.getInstance();
    secilenHafizKodu = prefs.getString('secilen_hafiz') ?? 'ar.alafasy';
  }

  // İsim Getir
  static String getSecilenHafizIsmi() {
    var hafiz = hafizlar.firstWhere(
      (element) => element['kod'] == secilenHafizKodu,
      orElse: () => hafizlar[0],
    );
    return hafiz['isim']!;
  }
}
