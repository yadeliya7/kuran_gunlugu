import 'package:flutter/material.dart';

// Bu fonksiyonu diğer sayfalardan çağıracaksın
// Çağırırken: hakkindaGoster(context, currentLanguage); şeklinde kullanmalısın.
void hakkindaGoster(BuildContext context, String dilKodu) {
  // 1. Dil Ayarları (Türkçe mi İngilizce mi?)
  bool tr = dilKodu == 'tr';

  String baslik = tr ? "Kaynaklar ve Teşekkür" : "Credits & Acknowledgements";

  String aciklama = tr
      ? "Bu uygulama, Kuran-ı Kerim'in hayatımıza ışık tutması ve ayetlerin güzelliğinin paylaşılması amacıyla hazırlanmıştır."
      : "This app is designed to illuminate our lives with the Holy Quran and share the beauty of its verses.";

  String altBilgi = tr
      ? "Tüm içerikler bilgilendirme ve manevi gelişim amaçlıdır."
      : "All content is for educational and spiritual purposes.";

  // Hafız İsimleri Listesi (Senin kullandıkların)
  List<String> hafizlar = [
    "Mishary Rashid Alafasy",
    "Maher Al-Muaiqly",
    "Ahmed Al-Ajmy",
    "Abdul Basit Abdul Samad",
  ];

  // 2. Pencereyi (Dialog) Açan Kod
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFF1E293B), // Koyu Zemin
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color(0xFFD4AF37),
            width: 1,
          ), // Altın Çerçeve
        ),
        child: SingleChildScrollView(
          // Küçük ekranlarda taşma yapmaması için kaydırma özelliği
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // İkon
                const Icon(
                  Icons.info_outline_rounded,
                  size: 40,
                  color: Color(0xFFD4AF37),
                ),
                const SizedBox(height: 16),

                // Başlık
                Text(
                  baslik,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),

                // Genel Açıklama
                Text(
                  aciklama,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Veri Sağlayıcı (API)
                _bilgiSatiri(
                  tr ? "Veri Sağlayıcı" : "Data Provider",
                  "Islamic Network (alquran.cloud)",
                ),

                const SizedBox(height: 12),

                // Mealler
                _bilgiSatiri(
                  tr ? "Mealler" : "Translations",
                  tr
                      ? "Diyanet / Elmalılı (TR)\nSahih International (EN)"
                      : "Sahih International (EN)\nDiyanet / Elmalılı (TR)",
                ),

                const SizedBox(height: 12),

                // Kıraat Başlığı
                Text(
                  tr ? "Kıraat (Seslendirenler)" : "Recitations by",
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),

                // Hafızları Listele
                ...hafizlar
                    .map(
                      (isim) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          isim,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                    .toList(),

                const SizedBox(height: 20),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),

                // Prayer Times Disclaimer Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: const Color(0xFFD4AF37),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tr
                                  ? 'Namaz Vakitleri & Yasal Uyarı'
                                  : 'Prayer Times & Disclaimer',
                              style: const TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tr
                            ? 'Namaz vakitleri, cihazınızın konumu (GPS) kullanılarak astronomik hesaplamalarla anlık üretilir. Türkiye için Diyanet İşleri Başkanlığı kriterleri (Temkin süreleri) esas alınmıştır.\n\nUyarı: Matematiksel hesaplama ve coğrafi farklar nedeniyle vakitlerde ±1-2 dakikalık sapmalar olabilir. İbadetlerinizde (özellikle İmsak ve İftar) temkinli olmak adına yerel ezan sesini veya cami vakitlerini teyit etmeniz tavsiye edilir.\n\nGizlilik: Konum veriniz sadece vakit hesaplaması için cihazınızda işlenir; sunucularımıza kaydedilmez veya paylaşılmaz.'
                            : 'Prayer times are generated instantly using astronomical calculations based on your device\'s location. For Turkey, the criteria of the Presidency of Religious Affairs (Diyanet) are adopted.\n\nDisclaimer: Due to mathematical calculations and local geographical differences, deviations of ±1-2 minutes may occur. It is recommended to follow the local adhan or mosque times for caution, especially for Fasting.\n\nPrivacy: Your location data is processed locally solely for calculation purposes and is never stored on our servers or shared.',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(color: Colors.white24),
                const SizedBox(height: 10),

                // Yasal Uyarı / Alt Bilgi
                Text(
                  altBilgi,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white30, fontSize: 10),
                ),

                const SizedBox(height: 20),

                // Kapat Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37), // Buton Rengi
                      foregroundColor: const Color(0xFF1E293B), // Yazı Rengi
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      tr ? "Kapat" : "Close",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// Bu dosya içinde kullanılan küçük yardımcı widget
Widget _bilgiSatiri(String baslik, String icerik) {
  return Column(
    children: [
      Text(
        baslik,
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        icerik,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      ),
    ],
  );
}
