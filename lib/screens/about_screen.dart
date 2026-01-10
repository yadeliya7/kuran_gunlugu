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
    "Abdul Basit Abdul Samad"
  ];

  // 2. Pencereyi (Dialog) Açan Kod
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFF1E293B), // Koyu Zemin
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1), // Altın Çerçeve
        ),
        child: SingleChildScrollView(
          // Küçük ekranlarda taşma yapmaması için kaydırma özelliği
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // İkon
                const Icon(Icons.info_outline_rounded, size: 40, color: Color(0xFFD4AF37)),
                const SizedBox(height: 16),
                
                // Başlık
                Text(
                  baslik,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 18, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),

                // Genel Açıklama
                Text(
                  aciklama,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 20),

                // Veri Sağlayıcı (API)
                _bilgiSatiri(
                  tr ? "Veri Sağlayıcı" : "Data Provider", 
                  "Islamic Network (alquran.cloud)"
                ),
                
                const SizedBox(height: 12),
                
                // Mealler
                _bilgiSatiri(
                  tr ? "Mealler" : "Translations", 
                  tr ? "Diyanet / Elmalılı (TR)\nSahih International (EN)" : "Sahih International (EN)\nDiyanet / Elmalılı (TR)"
                ),

                const SizedBox(height: 12),

                // Kıraat Başlığı
                Text(
                  tr ? "Kıraat (Seslendirenler)" : "Recitations by",
                  style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                
                // Hafızları Listele
                ...hafizlar.map((isim) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(isim, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                )).toList(),

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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(tr ? "Kapat" : "Close", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
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
        style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold),
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