import 'package:shared_preferences/shared_preferences.dart';

class HafizYonetimi {
  // Varsayılan Hafız
  static String secilenHafizKodu = 'ar.alafasy';

  // Hafız Listesi (Sadece İsim ve Kod)
  static final List<Map<String, String>> hafizlar = [
    {'isim': 'Mişari Raşid el-Afasi', 'kod': 'ar.alafasy'},
    {'isim': 'Mahir el-Muaykili', 'kod': 'ar.mahermuaiqly'},
    {'isim': 'Abdüssamed (Murattal)', 'kod': 'ar.abdulbasitmurattal'},
    {'isim': 'Ahmed el-Acemi', 'kod': 'ar.ahmedajamy'},
  ];

  // 👇 SİHİRLİ FONKSİYON BURASI
  // Hafızın koduna bakıp doğru bitrate'i (kaliteyi) kendisi verir.
  static String getBitrate(String hafizKodu) {
    if (        
        hafizKodu == 'ar.abdulbasitmujawwad' ||
        hafizKodu == 'ar.abdulbasitmurattal') {
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