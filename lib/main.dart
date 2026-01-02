import 'dart:async';
import 'dart:convert';
import 'dart:io'; 
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' hide TextDirection;
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
// BİLDİRİM PAKETLERİ
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'data.dart'; // <-- Yeni oluşturduğumuz dosyayı çağırıyoruz
import 'package:flutter/services.dart'; // 👈 Titreşim için bu şart
import 'package:permission_handler/permission_handler.dart'; // 👈 Ekle
import 'hafiz_yonetimi.dart';
// --- GLOBAL AYARLAR ---
String currentLanguage = 'tr'; 
double fontSizeMultiplier = 16.0; 
bool isPremiumUser = true; 

// --- SÖZLÜK ---
final Map<String, Map<String, String>> dictionary = {
  'tr': {
    'app_name': 'Kuran Günlüğü',
    'slogan': 'Huzurla Oku',
    'splash_text': 'Bunlar hikmet dolu\nKitabın ayetleridir.',
    'today_ayah': 'GÜNÜN AYETİ',
    'save': 'Kaydet',
    'saved': 'Listemde',
    'share': 'Paylaş',
    'listen': 'Dinle',
    'stop': 'Durdur',
    'list_title': 'Listem',
    'list_empty': 'Henüz kaydedilmiş bir ayet yok.',
    'settings_title': 'Ayarlar',
    'language': 'Dil', 
    'font_size': 'Yazı Boyutu',
    'size_small': 'Küçük',
    'size_medium': 'Orta',
    'size_large': 'Büyük',
    'added_msg': 'Listene kaydedildi ✅',
    'removed_msg': 'Listeden çıkarıldı',
    'premium_locked': 'Geçmiş Kilitli',
    'premium_desc': 'Daha eskiye gitmek için\nPremium üye olmalısınız.',
    'get_premium': "PREMIUM'A GEÇ",
    'go_today': 'Bugüne Dön',
    'prem_title': 'Premium Üyelik',
    'prem_active': 'Premium Üye 👑',
    'share_loading': 'Görüntü hazırlanıyor...', 
    'prem_f1': 'Reklamsız Deneyim',
    'prem_f2': 'Sınırsız Geçmişe Erişim',
    'prem_f3': 'Özel Yazı Tipleri',
    'prem_f4': 'Geliştiriciye Destek',
    'prem_price': 'Yıllık Sadece 199.99 ₺',
    'prem_btn': 'ABONE OL',
    'prem_success': 'Tebrikler! Artık Premiumsunuz 🎉',
    'notif_title': 'Hayırlı Sabahlar ☀️',
    'notif_body': 'Bugünün ayeti seni bekliyor. Okumak ister misin?',
    'test_msg': 'Bildirimler başarıyla çalışıyor! 🚀',
    'note_title': 'Günlük Notum 📝',
    'note_hint': 'Bu ayet sana ne hissettirdi?',
    // ignore: equal_keys_in_map
    'save': 'Kaydet',
    'your_note': 'Notun:',
    'my_note': 'Notum:',
    'add_note': 'Not Ekle',
    'edit_note': 'Notu Düzenle',
    'notif_active': 'Bildirimler Aktif ✅',
    'notif_inactive': 'Bildirimler Kapalı 🔕',
    'notif_active_desc': 'Her gün ayetiniz cebinizde.',
    'notif_inactive_desc': 'Günün ayetini kaçırmamak için lütfen bildirimleri açın.',
    'turn_on': 'AÇ',
    'reciter_title': 'Seslendiren Hafız',
    'selected_reciter': 'Seçili Hafız',
    'select_reciter_title': 'Hafız Seçimi',
  },
  'en': {
    'app_name': 'Quran Diary',
    'slogan': 'Read with Peace',
    'splash_text': 'These are verses of the\nWise Book.',
    'today_ayah': 'VERSE OF THE DAY',
    'save': 'Save',
    'saved': 'Saved',
    'share': 'Share',
    'listen': 'Listen',
    'stop': 'Stop',
    'list_title': 'My List',
    'list_empty': 'No saved verses yet.',
    'settings_title': 'Settings',
    'language': 'Language', 
    'font_size': 'Font Size',
    'size_small': 'Small',
    'size_medium': 'Medium',
    'size_large': 'Large',
    'added_msg': 'Saved to your list ✅',
    'removed_msg': 'Removed from list',
    'premium_locked': 'History Locked',
    'premium_desc': 'You need Premium membership\nto go further back.',
    'get_premium': 'GET PREMIUM',
    'go_today': 'Go to Today',
    'prem_title': 'Premium Membership',
    'prem_active': 'Premium Member 👑',
    'share_loading': 'Preparing image...', 
    'prem_f1': 'Ad-Free Experience',
    'prem_f2': 'Unlimited History Access',
    'prem_f3': 'Custom Fonts',
    'prem_f4': 'Support Development',
    'prem_price': 'Yearly Only \$19.99',
    'prem_btn': 'SUBSCRIBE NOW',
    'prem_success': 'Congrats! You are Premium 🎉',
    'notif_title': 'Good Morning ☀️',
    'notif_body': 'Verse of the day is ready. Would you like to read?',
    'test_msg': 'Notifications work perfectly! 🚀',
    'note_title': 'My Daily Note 📝',
    'note_hint': 'How did this verse make you feel?',
    // ignore: equal_keys_in_map
    'save': 'SAVE',
    'your_note': 'Your Note:',
    'my_note': 'My Note:',
    'add_note': 'Add Note',
    'edit_note': 'Edit Note',
    'notif_active': 'Notifications Active ✅',
    'notif_inactive': 'Notifications Off 🔕',
    'notif_active_desc': 'Daily verse is in your pocket.',
    'notif_inactive_desc': 'Please turn on notifications to not miss the daily verse.',
    'turn_on': 'TURN ON',
    'reciter_title': 'Reciter',
    'selected_reciter': 'Selected Reciter',
    'select_reciter_title': 'Select Reciter',
  }
};

String t(String key) {
  return dictionary[currentLanguage]?[key] ?? key;
}
// --- BİLDİRİM SERVİSİ (DÜZELTİLMİŞ) ---
// --- BİLDİRİM SERVİSİ (GÜNCELLENMİŞ - ALARM YERİNE BİLDİRİM TARZI) ---
// --- BİLDİRİM SERVİSİ (SADECE BİLDİRİM - ALARM İZNİ YOK) ---
class BildirimServisi {
  // 👇 Test için 5 saniye sonraya bildirim kurar
 
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> baslat() async {
    tz.initializeTimeZones(); 
    
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    } catch (e) {
      tz.setLocalLocation(tz.UTC);
    }

    const AndroidInitializationSettings androidAyarlari = AndroidInitializationSettings('notification_icon');
    const DarwinInitializationSettings iosAyarlari = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings ayarlar = InitializationSettings(
      android: androidAyarlari, 
      iOS: iosAyarlari
    );

    await _notifications.initialize(ayarlar);

    // 👇 ARTIK SADECE BİLDİRİM İZNİ İSTİYORUZ (Alarm İzni İstemiyoruz)
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      // ❌ await androidImplementation.requestExactAlarmsPermission(); // BU SATIRI SİLDİK
    }
  }
static Future<void> gunlukBildirimKur() async {
    // 1. Önceki tüm planları temizle (Temiz sayfa açıyoruz)
    await _notifications.cancelAll();

    try {
      final now = tz.TZDateTime.now(tz.local);
      
      // SABAH VAKTİ HESABI (Standart)
      // Eğer saat 09:30'u geçtiyse yarını verir, geçmediyse bugünü verir.
      tz.TZDateTime sabahVakti = _sonrakiZaman(09, 30);

      // AKŞAM VAKTİ HESABI (Akıllı Mod 🧠)
      // Normalde _sonrakiZaman bize en yakın akşamı verir (Bugün 20:00 veya Yarın 20:00).
      tz.TZDateTime aksamVakti = _sonrakiZaman(20, 00);

      // KRİTİK KONTROL:
      // Eğer hesaplanan akşam vakti "BUGÜN" ise, kullanıcı zaten şu an uygulamada olduğu için
      // bugünün akşam bildirimini atlayıp YARINA erteliyoruz.
      if (aksamVakti.day == now.day) {
        aksamVakti = aksamVakti.add(const Duration(days: 1));
      }

      // 3. Gelecek 30 GÜN için planla
      for (int i = 0; i < 30; i++) {
        
        // --- A) SABAH BİLDİRİMİ (Kesinlikle Gidecek) ---
        await _notifications.zonedSchedule(
          i, 
          currentLanguage == 'en' ? "Today's verse is ready ☀️" : 'Günün ayeti hazır ☀️',
          currentLanguage == 'en' 
             ? "Today's verse is waiting for you. Would you like to read?" 
             : "Bugünün ayeti seni bekliyor, okumak ister misin?",
          sabahVakti.add(Duration(days: i)), 
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'kuran_gunlugu_hatirlatici_v1',
              'Günlük Hatırlatıcı',
              channelDescription: 'Günlük okuma hatırlatması',
              importance: Importance.max,
              priority: Priority.high,
              color: Color(0xFFD4AF37),
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );

        // --- B) AKŞAM BİLDİRİMİ (Bugün Pas Geçildi, Yarından Başlar) ---
        await _notifications.zonedSchedule(
          i + 100, 
          currentLanguage == 'en' ? 'Good Evening 🌙' : 'Hayırlı Akşamlar 🌙',
          currentLanguage == 'en'
              ? "End your day with peace."
              : "Günü huzurla kapatmak için bir ayet okumaya ne dersin?",
          aksamVakti.add(Duration(days: i)), 
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'kuran_gunlugu_hatirlatici_v1',
              'Günlük Hatırlatıcı',
              channelDescription: 'Günlük okuma hatırlatması',
              importance: Importance.max,
              priority: Priority.high,
              color: Color(0xFFD4AF37),
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
      debugPrint("✅ Akıllı Bildirimler Kuruldu: Bugünün akşamı atlandı (kullanıcı aktif).");
    } catch (e) {
      debugPrint("❌ Bildirim hatası: $e");
    }
  }
  static tz.TZDateTime _sonrakiZaman(int saat, int dakika) {
    final tz.TZDateTime simdi = tz.TZDateTime.now(tz.local);
    tz.TZDateTime planlanan = tz.TZDateTime(tz.local, simdi.year, simdi.month, simdi.day, saat, dakika);
    if (planlanan.isBefore(simdi)) {
      planlanan = planlanan.add(const Duration(days: 1));
    }
    return planlanan;
  }
}
void main() {
  // Main fonksiyonunu süper hafif yaptık. Sadece uygulamayı başlatıyor.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KuranGunluguApp());
}
class KuranGunluguApp extends StatefulWidget {
  const KuranGunluguApp({super.key});

  @override
  State<KuranGunluguApp> createState() => _KuranGunluguAppState();
}
class _KuranGunluguAppState extends State<KuranGunluguApp> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kuran Günlüğü',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // DEĞİŞİKLİK BURADA:
    // İşlemleri hemen başlatma. Ekranın çizilmesini bekle.
    // Bu kod, "Uygulama arayüzü çizildikten hemen sonra" çalışır.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _baslangicYuklemeleri();
    });
  }
Future<void> _baslangicYuklemeleri() async {
    // 1. Logoyu göster (500ms bekle)
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Tarih formatını yükle
      await initializeDateFormatting('tr_TR', null);
    } catch (e) {
      debugPrint("⚠️ Tarih formatı hatası: $e");
    }

    try {
      // Bildirim servisini başlat
      // Burası hata verirse bile catch bloğuna düşer, uygulama donmaz.
      await BildirimServisi.baslat();
      BildirimServisi.gunlukBildirimKur(); 
    } catch (e) {
      debugPrint("⚠️ Bildirim servisi hatası (Önemli değil, devam et): $e");
    }

    try {
      // Ayarları çek
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          currentLanguage = prefs.getString('language') ?? 'tr';
          fontSizeMultiplier = prefs.getDouble('fontSize') ?? 18.0;
          //isPremiumUser = prefs.getBool('isPremium') ?? false;
          isPremiumUser = true;
        });
      }
    } catch (e) {
      debugPrint("⚠️ Ayarlar okunamadı: $e");
    }

    // 5. HER ŞEY BİTTİKTEN SONRA (HATA OLSA BİLE BURAYA GELİR)
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      debugPrint("🚀 Ana Ekrana Geçiş Yapılıyor...");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GununAyetiEkrani()),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    // BURASI AYNI KALACAK (Senin tasarımın)
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.8, end: 1.0),
              duration: const Duration(seconds: 1),
              curve: Curves.elasticOut,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                       Padding(
                         padding: const EdgeInsets.only(top: 20.0),
                         child: Icon(Icons.menu_book_rounded, size: 100, color: const Color(0xFFD4AF37).withValues(alpha: 0.9)),
                       ),
                      Icon(
                        Icons.auto_awesome, 
                        size: 40,
                        color: const Color(0xFFD4AF37).withValues(alpha: 1.0),
                        shadows: [BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 5)],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            Text(t('app_name'), style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 15),
            Text(
              t('splash_text'), // "Bunlar hikmet dolu..."
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri( // Biraz daha klasik/estetik dursun
                fontSize: 18, 
                color: Colors.white70,
                fontStyle: FontStyle.italic,
                height: 1.5
              ),
            ),
            const SizedBox(height: 50),
            const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD4AF37))),
          ],
        ),
      ),
    );
  }
}
class GununAyetiEkrani extends StatefulWidget {
  const GununAyetiEkrani({super.key});

  @override
  State<GununAyetiEkrani> createState() => _GununAyetiEkraniState();
}
class _GununAyetiEkraniState extends State<GununAyetiEkrani> {
  late Future<AyetModel> futureAyet;
  DateTime seciliTarih = DateTime.now();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScreenshotController _screenshotController = ScreenshotController();
  bool isPlaying = false;
  bool isFavorited = false;
  bool _isLoading = false;
  // Not işlemleri için gerekli değişkenler
  String? kaydedilenNot; // Ekranda göstereceğimiz not
  final TextEditingController _notController = TextEditingController(); // Yazı yazma kutusu kontrolcüsü
  @override
  void initState() {
    super.initState();
    // 1. Değişkenleri sıfırla (Garanti olsun)
    seciliTarih = DateTime.now();
    _isLoading = false; 
    
    
    // 2. Veriyi çekmeye başla
    futureAyet = ayetiGetir(seciliTarih);
    BildirimServisi.gunlukBildirimKur();
    // 3. SİHİRLİ DOKUNUŞ: Ekran çizildikten hemen sonra bir kez daha yenile.
    // Bu, senin "çık-gir" yapma işlemini kodla taklit eder.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          // Boş bir setState, ekranı "Kendine gel" diye sarsar.
          
          debugPrint("Ekran yerleşimi tazelendi 🔄");
        });
      }
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    });
    // 👆👆👆 EKLEME BİTTİ 👆👆👆
  }

  void ayarlariAc() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const AyarlarEkrani()));
    setState(() {});
  }

  void premiumAc() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumEkrani()));
    setState(() {}); 
  }

  void buguneGit() {
    setState(() {
      seciliTarih = DateTime.now();
      isPlaying = false;
      isFavorited = false;
      _audioPlayer.stop();
      futureAyet = ayetiGetir(seciliTarih);
    });
  }

  void tarihDegistir(int gunFarki) {
    // Eğer zaten yükleme yapılıyorsa (kilitliyse) tıklamayı yoksay
    if (_isLoading) return; 

    setState(() {
      _isLoading = true; // Kilidi aç
      
      if (isPlaying) {
        _audioPlayer.stop();
      }
      
      DateTime yeniTarih = seciliTarih.add(Duration(days: gunFarki));
      if (yeniTarih.isAfter(DateTime.now())) {
        _isLoading = false; // Geleceğe gitmeyeceksek kilidi kaldır
        return;
      }
      
      seciliTarih = yeniTarih;
      isPlaying = false;
      isFavorited = false;
      
      // Veriyi çekmeye başla
      futureAyet = ayetiGetir(seciliTarih).whenComplete(() {
        // Veri gelince veya hata verince kilidi kaldır
        setState(() {
          _isLoading = false; 
        });
      });
    });
  }
// 👇 DEĞİŞİKLİK 1: Parametreyi köşeli parantez [] içine aldık.
  // Yani tarih verirsen onu kullanır, vermezsen (null ise) otomatik olarak seciliTarih'i alır.
  Future<AyetModel> ayetiGetir([DateTime? tarih]) async {
    
    // Hangi tarihi kullanacağız? (Parametre geldiyse o, gelmediyse sınıfın değişkeni)
    DateTime islemTarihi = tarih ?? seciliTarih;

    int dayOfYear = int.parse(DateFormat("D").format(islemTarihi));
    int randomNum = Random().nextInt(10000); 
    
    // 6236 Kuran'daki toplam ayet sayısıdır.
    int ayetId = (dayOfYear % 6236) + 1; 
    
    // API İsteği: Arapça, Türkçe ve İngilizce aynı anda isteniyor
    String kalite = HafizYonetimi.getBitrate(HafizYonetimi.secilenHafizKodu);
    String hafiz = HafizYonetimi.secilenHafizKodu;
    
    String esasLink = 'https://api.alquran.cloud/v1/ayah/$ayetId/editions/quran-uthmani,tr.yazir,en.sahih';
    String sesLinki = "https://cdn.islamic.network/quran/audio/$kalite/$hafiz/$ayetId.mp3";
    try {
      final response = await http.get(Uri.parse(esasLink));
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        
        // 👇 DEĞİŞİKLİK 2: API Verisini Bizim Modele Elle Çeviriyoruz
        // Çünkü API'nin formatı bizim data.dart'taki formattan farklı.
        var data = jsonResponse['data']; // Bu bir listedir: [Arapça, Türkçe, İngilizce]
        _notuGetir(ayetId);
        return AyetModel(
          id: ayetId,
          sureAdi: data[1]['surah']['englishName'], // Surenin adı (Türkçe mealin içinden aldık)
          ayetNo: data[1]['numberInSurah'],
          arapca: data[0]['text'],   // 0. indeks: quran-uthmani
          turkce: data[1]['text'],   // 1. indeks: tr.yazir
          ingilizce: data[2]['text'], // 2. indeks: en.sahih
          // Ses dosyası API'den bu linkte gelmiyor, o yüzden boş veya varsayılan bırakıyoruz
          sesDosyasiUrl: sesLinki,
        );
      }
    } catch (e) {
      debugPrint('⚠️ API Hatası (Esas): $e');
    }

    // --- PROXY DENEMESİ (Yedek) ---
    try {
      final proxyUrl = Uri.parse('https://api.allorigins.win/raw?url=$esasLink&cb=$randomNum');
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
        );
      }
    } catch (e) {
      debugPrint('⚠️ Proxy Hatası: $e');
    }

    // --- SON ÇARE: İNTERNET YOKSA YEREL VERİ ---
    debugPrint("🌐 İnternet/API başarısız. Yerel veri kullanılıyor.");
    return YerelVeri.getir(dayOfYear);
  }
  
  // Notu veritabanından çeker
  Future<void> _notuGetir(int ayetId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Her ayetin kendi ID'sine göre notunu çağırıyoruz
      kaydedilenNot = prefs.getString('not_$ayetId'); 
    });
  }

  // Notu veritabanına kaydeder
  Future<void> _notuKaydet(int ayetId, String not) async {
    final prefs = await SharedPreferences.getInstance();
    if (not.trim().isEmpty) {
      await prefs.remove('not_$ayetId'); // Boşsa sil
      setState(() => kaydedilenNot = null);
    } else {
      await prefs.setString('not_$ayetId', not); // Doluysa kaydet
      setState(() => kaydedilenNot = not);
    }
  }

  // Not Ekleme Penceresini Açar
  void _notEklePenceresiAc(int ayetId) {
    _notController.text = kaydedilenNot ?? ""; // Varsa eski notu kutuya koy
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Klavye açılınca yukarı kaysın
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
          left: 20, 
          right: 20, 
          top: 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('note_title'), style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: _notController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: t('note_hint'),
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _notuKaydet(ayetId, _notController.text);
                  Navigator.pop(context); // Pencreyi kapat
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
                child: Text(t('save'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _favoriyeEkleCikar(AyetModel ayet) async {
    if (!isFavorited) {
      HapticFeedback.mediumImpact(); // Eklendiğinde tok ses
    } else {
      HapticFeedback.selectionClick(); // Silindiğinde hafif tık
    }
    final prefs = await SharedPreferences.getInstance();
    
    if (!mounted) return;

    List<String> list = prefs.getStringList('favoriler') ?? [];
    int index = -1;
    for (int i = 0; i < list.length; i++) {
       try {
         Map<String, dynamic> decoded = jsonDecode(list[i]);
         if (decoded['sureAdi'] == ayet.sureAdi && decoded['ayetNo'] == ayet.ayetNo) {
           index = i; break;
         }
       } catch (e) { continue; }
    }
    
    if (index != -1) {
      list.removeAt(index);
      setState(() => isFavorited = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('removed_msg'))));
    } else {
      list.add(jsonEncode(ayet.toJson()));
      setState(() => isFavorited = true);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('added_msg'))));
    }
    await prefs.setStringList('favoriler', list);
  }

  Future<void> _mevcutAyetFavoriMi(AyetModel ayet) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList('favoriler') ?? [];
    bool bulundu = false;
    for (var str in list) {
      try {
        Map<String, dynamic> decoded = jsonDecode(str);
        if (decoded['sureAdi'] == ayet.sureAdi && decoded['ayetNo'] == ayet.ayetNo) {
          bulundu = true; break;
        }
      } catch (e) { continue; }
    }
    if (mounted && isFavorited != bulundu) setState(() { isFavorited = bulundu; });
  }

  Future<void> _resimliPaylas(AyetModel ayet) async {
    // 1. Yükleniyor göster
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: const Color(0xFF1E293B),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  const SizedBox(width: 20),
                  Text(t('share_loading'), style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          );
        },
      );
    }

    try {
      // 2. EKRANI DEĞİL, ÖZEL TASARIMI ÇEK 📸
      // captureFromWidget: Ekranda görünmeyen bir widget'ı resme çevirir.
      final Uint8List imageBytes = await _screenshotController.captureFromWidget(
        _paylasimKartiOlustur(ayet), // <--- Hazırladığımız özel tasarım buraya
        delay: const Duration(milliseconds: 100), // Çizilmesi için minik bir süre tanı
        context: context, // Fontların düzgün yüklenmesi için context şart
        pixelRatio: 3.0,  // Yüksek çözünürlük (HD) olsun
      );

      if (!mounted) return;
      Navigator.pop(context); // Yükleniyor'u kapat

      // 3. Dosyayı oluştur ve paylaş (Burası aynı)
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/ayet_share.png').create();
      await imagePath.writeAsBytes(imageBytes);

      String metin = currentLanguage == 'en' ? ayet.ingilizce : ayet.turkce;
      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: "$metin\n\n🌙 ${t('app_name')}",
      );

    } catch (e) {
      debugPrint("Hata: $e");
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      // Hata olursa sadece yazıyı paylaş
      String metin = currentLanguage == 'en' ? ayet.ingilizce : ayet.turkce;
      Share.share('"$metin"\n\n🌙 ${t('app_name')}');
    }
  }

  void sesiCalVeyaDurdur(int ayetId) async {
    try {
      if (isPlaying) { 
        await _audioPlayer.pause(); 
        setState(() => isPlaying = false); 
      } else { 
        await _audioPlayer.stop(); 
        await _audioPlayer.release();
        String kalite = HafizYonetimi.getBitrate(HafizYonetimi.secilenHafizKodu);
        String hafiz = HafizYonetimi.secilenHafizKodu;
        String sesLinki = "https://cdn.islamic.network/quran/audio/$kalite/$hafiz/$ayetId.mp3";
        debugPrint("Çalınan Link: $sesLinki");
        _audioPlayer.play(UrlSource(sesLinki)); 
        setState(() => isPlaying = true); 
      }
    } catch (e) {
      debugPrint('Ses Hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isToday = DateFormat('yyyyMMdd').format(seciliTarih) == DateFormat('yyyyMMdd').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 1. Üst Bar
              _buildTopBar(isToday),
              
              const SizedBox(height: 10),
              
              // 2. Tarih Değiştirme
              _buildDateNavigation(),
              
              const SizedBox(height: 20),
              
              // 3. İçerik
              Expanded(
                child: Container(
                   // ❌ ESKİ KOD: key: ValueKey<String>(seciliTarih.toIso8601String()),
                   // 👇 YENİ KOD: Key satırını sildik. Artık çakışma yok.
                   // Sadece içeriği çağırıyoruz.
                   child: _buildAyetContent(), 
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTopBar(bool isToday) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // SOL TARAF: Logo ve İsim
        Row(children: [
            const Icon(Icons.auto_stories, color: Color(0xFFD4AF37), size: 24),
            const SizedBox(width: 10),
            Text(t('app_name'), style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ]),
        
        // SAĞ TARAF: Butonlar
        Row(
          children: [
             // Eğer bugün değilsek "Bugüne Dön" butonu gözüksün
             if (!isToday) 
               IconButton(
                 icon: const Icon(Icons.calendar_today, color: Color(0xFFD4AF37), size: 22),
                 tooltip: t('go_today'),
                 onPressed: buguneGit,
               ),

             // Ayarlar
             IconButton(
               icon: const Icon(Icons.settings, color: Colors.white54, size: 24), 
               onPressed: ayarlariAc
             ),

             // 👇 2. DEĞİŞİKLİK: Favoriler Butonu (Gidilen Tarihi Yakalama)
             IconButton(
               icon: const Icon(Icons.list_alt, color: Color(0xFFD4AF37), size: 28), 
               onPressed: () async {
                 // Sayfayı aç ve kapanana kadar bekle (await)
                 final gelenTarih = await Navigator.push(
                   context, 
                   MaterialPageRoute(builder: (context) => const FavorilerEkrani())
                 );

                 // Eğer favorilerden bir tarih seçip geri döndüyse:
                 if (gelenTarih != null && gelenTarih is DateTime) {
                   debugPrint("Favorilerden dönüldü, gidilecek tarih: $gelenTarih");
                   
                   setState(() {
                     // 1. Tarihi güncelle
                     seciliTarih = gelenTarih;
                     
                     // 2. Yükleniyor moduna al
                     _isLoading = true; 
                     
                     // 3. O tarihteki ayeti getir
                     futureAyet = ayetiGetir(seciliTarih).whenComplete(() {
                        // İşlem bitince yükleniyor'u kapat
                        setState(() => _isLoading = false);
                     });
                   });
                 }
               }
             ),
          ],
        ),
      ],
    );
  }

Widget _buildAyetContent() {
    return FutureBuilder<AyetModel>(
      key: ValueKey(seciliTarih.toIso8601String()),
      future: futureAyet,
      builder: (context, snapshot) {
        
        // 1. YÜKLENİYORSA BİLE AYNI İSKELETİ KORU (Donmayı Önler)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: [
              // Kartın kaplayacağı alan kadar boşluk bırak (Expanded)
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.5), // Soluk renk
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
                ),
              ),
              const SizedBox(height: 20),
              // Butonların yeri kadar boşluk
              const SizedBox(height: 80),
            ],
          );
        }
        
        // 2. HATA VARSA
        if (snapshot.hasError) {
          return const Center(child: Text("Bir hata oluştu", style: TextStyle(color: Colors.white54)));
        }

        // 3. VERİ GELDİYSE
        if (snapshot.hasData) {
          final ayet = snapshot.data!;
          
          
          _mevcutAyetFavoriMi(ayet);
          
          return Column(
            children: [
              // Expanded: Burası üstteki "Yükleniyor" Expanded ile aynı hiyerarşide
              Expanded(
                child: Screenshot(
                  controller: _screenshotController,
                  child: _buildAyetCard(ayet),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(height: 80, child: _buildActionButtons(ayet)),
            ],
          );
        }
        
        return const SizedBox();
      },
    );
  }

  // --- EKSİK OLAN PARÇA BU ---
  Widget _buildDateNavigation() {
    // Bugünün tarihini kontrol et (Geleceğe gitmeyi engellemek için)
    bool isToday = DateFormat('yyyy-MM-dd').format(seciliTarih) == 
                   DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05), // Hafif transparan arka plan
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // GERİ GİT BUTONU (<)
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact(); // 👈 EKLE: Hafif tık
              tarihDegistir(-1); 
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          
          // TARİH YAZISI (Örn: 22 Aralık 2025)
          Row(
            children: [
              //const Icon(Icons.calendar_month, color: Color(0xFFD4AF37), size: 16),
              const SizedBox(width: 8),
              Text(
                DateFormat('d MMMM yyyy', currentLanguage == 'en' ? 'en_US' : 'tr_TR').format(seciliTarih),
                style: GoogleFonts.poppins(
                  color: Colors.white, 
                  fontSize: 14, 
                  fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),

          // İLERİ GİT BUTONU (>)
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: isToday ? Colors.white10 : Colors.white70, size: 20),
            onPressed: isToday ? null : () {
               HapticFeedback.lightImpact(); // 👈 EKLE: Hafif tık
               tarihDegistir(1);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
  Widget _buildAyetCard(AyetModel veri) {
    String gosterilecekMeal = currentLanguage == 'en' ? veri.ingilizce : veri.turkce;

    if (fontSizeMultiplier < 12) fontSizeMultiplier = 18.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // 1. ARKA PLAN: Dümdüz renk yerine hafif geçişli (Gradyan) renk
        // Bu, karta derinlik ve 3 boyut hissi katar.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B).withValues(alpha: 0.9), // Sol üst biraz daha açık
            const Color(0xFF0F172A).withValues(alpha: 0.9), // Sağ alt daha koyu
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1), // %10 görünürlükte beyaz
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.1), // Çok hafif altın ışıltısı
            blurRadius: 20, // Işığı iyice yay (Yumuşak olsun)
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3), // Bir de siyah gölge (Derinlik için)
            blurRadius: 10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
            
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // 👇 YENİ PREMIUM BAŞLIK: ÇİZGİLİ, DİK VE GENİŞ ARALIKLI
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sol taraftaki ince çizgi
                Container(
                  width: 30, 
                  height: 1, 
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.5)
                ),
                
                const SizedBox(width: 10),
                
                Text(
                  t('today_ayah').toUpperCase(), // HEPSİ BÜYÜK HARF
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFD4AF37),
                    fontSize: 12,
                    fontWeight: FontWeight.w600, // Biraz dolgun (SemiBold)
                    letterSpacing: 4.0, // ✨ Harflerin arası açık (Premium hissi veren bu)
                  ),
                ),

                const SizedBox(width: 10),
                
                // Sağ taraftaki ince çizgi
                Container(
                  width: 30, 
                  height: 1, 
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.5)
                ),
              ],
            ),
            
            const SizedBox(height: 30), // Başlık ile ayet arası biraz daha ferah olsun

            // 1. ARAPÇA METİN
            Text(
              veri.arapca,
              style: GoogleFonts.amiri(
                fontSize: fontSizeMultiplier + 12,
                color: const Color(0xFFD4AF37),
                height: 2.0,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),

            const SizedBox(height: 25),
            const Divider(color: Colors.white10, thickness: 1),
            const SizedBox(height: 20),

            // 2. MEAL METNİ
            Text(
              gosterilecekMeal,
              style: GoogleFonts.poppins(
                fontSize: fontSizeMultiplier,
                color: Colors.white,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            // 3. NOT GÖSTERİM ALANI
            if (kaydedilenNot != null) ...[
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit_note, color: Color(0xFFD4AF37), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          t('your_note'),
                          style: TextStyle(
                            color: const Color(0xFFD4AF37),
                            fontSize: fontSizeMultiplier - 2,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      kaydedilenNot!,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: fontSizeMultiplier - 2,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 4. BUTON
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => _notEklePenceresiAc(veri.id),
              icon: const Icon(Icons.add_comment, color: Colors.white30, size: 20),
              label: Text(
                kaydedilenNot == null ? t('add_note') : t('edit_note'),
                style: const TextStyle(color: Colors.white30, fontSize: 14),
              ),
            ),

            const SizedBox(height: 10),

            // 5. SURE ADI VE NO
            Align(
                  alignment: Alignment.bottomRight,
                  child: Builder(
                    builder: (context) {
                      // 1. Türkçe ismini sözlükten bul
                      String sureIsmi = veri.sureAdi; 
                      
                      if (currentLanguage == 'tr') {
                        // Eğer haritada varsa Türkçe karşılığını al, yoksa geleni kullan
                        sureIsmi = SureIsimleri.tr[veri.sureAdi] ?? veri.sureAdi;
                      }

                      // 2. Ekrana Yazdır
                      return Text(
                        currentLanguage == 'tr' 
                            ? "$sureIsmi , ${veri.ayetNo}. " 
                            : " $sureIsmi,  ${veri.ayetNo}", 
                        style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      );
                    }
                  ),
                ),
          ],
        ),
      ),
    );
  }
Widget _buildActionButtons(AyetModel ayet) {
    // 👇 1. DİKKAT: Dikey boşluğu azalttık (20 -> 5 yaptık)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          
          // 1. SOL TARAF (KAYDET)
          SizedBox(
            width: 70, // Genişliği de biraz topladık
            child: GestureDetector(
              onTap: () => _favoriyeEkleCikar(ayet),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFavorited ? Icons.bookmark : Icons.bookmark_border,
                    color: isFavorited ? const Color(0xFFD4AF37) : Colors.white,
                    size: 28, // 👇 30 -> 28 yaptık
                  ),
                  const SizedBox(height: 4), // Aradaki boşluğu kıstık
                  Text(
                    t('save').toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      color: isFavorited ? const Color(0xFFD4AF37) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10, // 👇 11 -> 10 yaptık (Daha kibar)
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. ORTA BUTON (PAYLAŞ)
          Container(
            height: 65, width: 65, // 👇 70 -> 60 yaptık (Biraz küçüldü, sığması için)
            decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle),
            child: IconButton(
              // İkonu ortalamak için padding ayarı gerekebilir, o yüzden alignment ekledik
              alignment: Alignment.center,
              icon: const Icon(Icons.share, color: Color(0xFF0F172A), size: 26), 
              onPressed: () {
                 HapticFeedback.heavyImpact(); 
                 _resimliPaylas(ayet);
              }
            ),
          ),

          // 3. SAĞ TARAF (DİNLE)
          SizedBox(
            width: 70, // Genişliği topladık
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                sesiCalVeyaDurdur(ayet.id);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow_outlined,
                    color: isPlaying ? const Color(0xFFD4AF37) : Colors.white,
                    size: 28, // 👇 30 -> 28 yaptık
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (isPlaying ? t('stop') : t('listen')).toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      color: isPlaying ? const Color(0xFFD4AF37) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10, // 👇 11 -> 10 yaptık
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
   // 👇 Sadece fotoğraf çekmek için kullanılacak özel tasarım
  Widget _paylasimKartiOlustur(AyetModel veri) {
    String gosterilecekMeal = currentLanguage == 'en' ? veri.ingilizce : veri.turkce;
    String gosterilecekSureIsmi = veri.sureAdi; // Varsayılan (İngilizce)
    // Arka planın koyu ve şık olması için Material ve Container ile sarıyoruz
    if (currentLanguage == 'tr') {
      // Türkçe ise haritadan bak, bulamazsan eskisini koy
      // NOT: SureIsimleri haritasının bu dosyada tanımlı olduğunu varsayıyorum
      gosterilecekSureIsmi = SureIsimleri.tr[veri.sureAdi] ?? veri.sureAdi;
    }
    
    return Material(
      color: Colors.transparent, // Arka plan şeffaf olsun ki Container görünsün
      child: Container(
        width: 400, // Sabit genişlik (Instagram postu gibi)
        height: 500, // Sabit yükseklik
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Koyu Lacivert Arka Plan
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD4AF37), width: 2), // Altın Çerçeve
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            const Icon(Icons.menu_book_rounded, size: 40, color: Color(0xFFD4AF37)),
            const SizedBox(height: 20),
            
            // Arapça (Esnek)
            Flexible(
              flex: 2,
              child: AutoSizeText(
                veri.arapca,
                style: GoogleFonts.amiri(fontSize: 24, color: const Color(0xFFD4AF37),height: 2.2),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                minFontSize: 14,
                maxLines: 4,
                
              ),
            ),
            
            const SizedBox(height: 20),
            const Divider(color: Colors.white24, thickness: 1, indent: 50, endIndent: 50),
            const SizedBox(height: 20),

            // Türkçe Meal (Sığdırılmış)
            Expanded(
              flex: 4,
              child: Center(
                child: AutoSizeText(
                  gosterilecekMeal,
                  style: GoogleFonts.poppins(fontSize: 20, color: Colors.white, height: 1.5, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                  minFontSize: 12, // Sığmazsa 12'ye kadar düş
                  maxLines: 12,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Alt bilgi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Kuran Günlüğü", style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54)),
                Text(
                  "$gosterilecekSureIsmi, ${veri.ayetNo}", 
                  style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)
                  )
              ],
            )
          ],
        ),
      ),
    );
  }
}
class PremiumEkrani extends StatelessWidget {
  const PremiumEkrani({super.key});

  void _satinAl(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', true);
    isPremiumUser = true; 
    
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('prem_success')), backgroundColor: Colors.green));
    
    Future.delayed(const Duration(seconds: 1), () { 
      if (context.mounted) Navigator.pop(context); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium, size: 80, color: Color(0xFFD4AF37)),
            const SizedBox(height: 20),
            Text(t('prem_title'), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            _avantajSatiri(Icons.block, t('prem_f1')),
            _avantajSatiri(Icons.history, t('prem_f2')),
            _avantajSatiri(Icons.text_fields, t('prem_f3')),
            _avantajSatiri(Icons.favorite, t('prem_f4')),
            const Spacer(),
            Text(t('prem_price'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _satinAl(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: Text(t('prem_btn'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _avantajSatiri(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 28),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16))),
        ],
      ),
    );
  }
}
class AyarlarEkrani extends StatefulWidget {
  const AyarlarEkrani({super.key});
  @override
  State<AyarlarEkrani> createState() => _AyarlarEkraniState();
}

class _AyarlarEkraniState extends State<AyarlarEkrani> with WidgetsBindingObserver {
  bool bildirimIzniVar = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _izinDurumunuKontrolEt();
    HafizYonetimi.hafizYukle().then((_) {
      if(mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _izinDurumunuKontrolEt();
    }
  }

  Future<void> _izinDurumunuKontrolEt() async {
    var status = await Permission.notification.status;
    if (mounted) {
      setState(() {
        bildirimIzniVar = status.isGranted;
      });
    }
  }

  Future<void> _ayarlariAc() async {
    await openAppSettings();
  }

  void _dilDegistir(String yeniDil) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', yeniDil);
    setState(() {
      currentLanguage = yeniDil;
    });
  }

  void _boyutDegistir(double yeniBoyut) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', yeniBoyut);
    setState(() {
      fontSizeMultiplier = yeniBoyut;
    });
  }
  void _hafizSecimMenusuAc() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2125), // Arka plan rengin
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t('select_reciter_title'),
                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Hafız Listesi
              ...HafizYonetimi.hafizlar.map((hafiz) {
                bool seciliMi = HafizYonetimi.secilenHafizKodu == hafiz['kod'];
                return ListTile(
                  leading: Icon(
                    seciliMi ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: seciliMi ? const Color(0xFFD4AF37) : Colors.white54,
                  ),
                  title: Text(
                    hafiz['isim']!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    await HafizYonetimi.hafizKaydet(hafiz['kod']!);
                    if (mounted) {
                      Navigator.pop(context); // Menüyü kapat
                      setState(() {}); // Ekranı yenile ki isim değişsin
                    }
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
  Widget _dilSecenek(String dilKod, String dilAd) {
    bool secili = currentLanguage == dilKod;
    return GestureDetector(
      onTap: () => _dilDegistir(dilKod),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: secili
              ? const Color(0xFFD4AF37).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: secili ? const Color(0xFFD4AF37) : Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dilAd, style: const TextStyle(color: Colors.white, fontSize: 16)),
            if (secili) const Icon(Icons.check_circle, color: Color(0xFFD4AF37)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(t('settings_title'),
              style: const TextStyle(color: Color(0xFFD4AF37))),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👇 GÜNCELLENMİŞ BİLDİRİM KARTI (Çeviri destekli)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: bildirimIzniVar
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: bildirimIzniVar ? Colors.green : Colors.redAccent,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    bildirimIzniVar
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: bildirimIzniVar ? Colors.green : Colors.redAccent,
                    size: 30,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bildirimIzniVar
                              ? t('notif_active') // "Bildirimler Aktif"
                              : t('notif_inactive'), // "Bildirimler Kapalı"
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          bildirimIzniVar
                              ? t('notif_active_desc')
                              : t('notif_inactive_desc'),
                          style:
                              const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (!bildirimIzniVar)
                    TextButton(
                      onPressed: _ayarlariAc,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(t('turn_on'), style: const TextStyle(fontWeight: FontWeight.bold)), // "AÇ"
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(t('reciter_title'), // t('reciter') gibi bir şey yapabilirsin
              style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 10),
          
          GestureDetector(
            onTap: _hafizSecimMenusuAc, // Menüyü açan fonksiyon
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('selected_reciter'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 5),
                      Text(
                        HafizYonetimi.getSecilenHafizIsmi(), // Şu anki hafız ismi
                        style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
                ],
              ),
            ),
          ),
            const SizedBox(height: 30),

            Text(t('language'),
                style: const TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  _dilSecenek('tr', 'Türkçe'),
                  _dilSecenek('en', 'English'),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            Text(t('font_size'),
                style: const TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _boyutButonu(t('size_small'), 14.0),
                    _boyutButonu(t('size_medium'), 18.0),
                    _boyutButonu(t('size_large'), 24.0)
                  ]),
            ),
            
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _boyutButonu(String text, double value) {
    bool isSelected = (fontSizeMultiplier == value);
    return GestureDetector(
      onTap: () => _boyutDegistir(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isSelected
                    ? const Color(0xFFD4AF37)
                    : Colors.white24)),
        child: Text(text,
            style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}
class FavorilerEkrani extends StatefulWidget {
  const FavorilerEkrani({super.key});
  @override
  State<FavorilerEkrani> createState() => _FavorilerEkraniState();
}
class _FavorilerEkraniState extends State<FavorilerEkrani> {
  
  // Tüm favoriler (Gizli olanlar dahil hepsi burada durur)
  List<AyetModel> tumFavoriler = []; 

  @override
  void initState() { super.initState(); _favorileriYukle(); }

  // 👇 1. YÜKLEME: HİÇBİR ŞEY SİLMEDEN HEPSİNİ ÇEKİYORUZ
  Future<void> _favorileriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList('favoriler') ?? [];
    List<AyetModel> temp = [];
    for(var s in list) { 
      try { temp.add(AyetModel.fromSavedJson(jsonDecode(s))); } catch(e){ debugPrint('Hata: $e'); } 
    }
    // Listeyi ters çevirelim ki en son eklenen en üstte olsun
    setState(() { tumFavoriler = temp.reversed.toList(); });
  }

  Future<void> _sil(int index, AyetModel silinecekAyet) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ana listeden bul ve sil
    tumFavoriler.removeWhere((element) => element.id == silinecekAyet.id);
    
    // Veritabanını güncelle
    // (Listeyi tekrar düzeltip kaydediyoruz)
    List<String> kayitListesi = tumFavoriler.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('favoriler', kayitListesi);
    
    setState(() {}); // Ekranı yenile
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('removed_msg'))));
  }

  // 👇 2. FİLTRELEME MANTIĞI BURADA
  List<AyetModel> _getGosterilecekListe() {
    //if (isPremiumUser) {
    //  return tumFavoriler; // Premium ise hepsi serbest
    //}

    // Premium değilse: Sadece son 4 günün (Bugün + 3 geçmiş) ayetlerini bul
    
    // Listeyi filtrele: Sadece izinli ID'leri göster
    return tumFavoriler;
  }

  // Paylaşım ve Kart Tasarımları (Aynı kalıyor)


  @override
  Widget build(BuildContext context) {
    // Ekranda gösterilecekleri hesapla
    List<AyetModel> gosterilecekListe = _getGosterilecekListe();
    
    // Kaç tane gizlediğimizi hesapla

    return Scaffold(
      appBar: AppBar(title: Text(t('list_title'), style: const TextStyle(color: Color(0xFFD4AF37))), backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      
      body: tumFavoriler.isEmpty 
        ? Center(child: Text(t('list_empty'), style: const TextStyle(color: Colors.white54))) 
        : ListView.builder(
            // Eğer gizli ayet varsa en alta fazladan 1 kutu (Kilit Kutusu) ekle
            itemCount: gosterilecekListe.length,
            itemBuilder: (context, index) {
              
              // 👇 EN SONDAKİ KİLİTLİ KUTU TASARIMI
              

              // 👇 NORMAL AYET KARTI
              var a = gosterilecekListe[index];
              String metin = currentLanguage == 'en' ? a.ingilizce : a.turkce;
              
              return Card(
                color: const Color(0xFF1E293B),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  title: Text("${a.sureAdi}, ${a.ayetNo}", style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(metin, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
                  ),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _sil(index, a)),
                  onTap: () {
                    // 1. Ayetin ID'sinden o günün tarihini hesapla
                    // Mantık: Yılın başı + (AyetID - 1) gün = O Ayetin Günü
                    DateTime yilBasi = DateTime(DateTime.now().year, 1, 1);
                    DateTime gidilecekTarih = yilBasi.add(Duration(days: a.id - 2));

                    // 2. Ekranı kapat ve bu tarihi geriye (Ana Ekrana) fırlat
                    Navigator.pop(context, gidilecekTarih);
                  },
                ),
              );
            }
          ),
        );
      }
    }
  // Kodun en altına, tüm sınıfların dışına yapıştır:
class PremiumDesenRessami extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03) // Çok çok silik beyaz (%3)
      ..strokeWidth = 1; // İncecik

    double step = 30.0; // Çizgilerin ne kadar sık olacağı (30px aralık)

    // Ekranı baştan aşağı çapraz tarıyoruz
    for (double i = -size.height; i < size.width; i += step) {
      // Çizgiyi çek: (x1, y1) -> (x2, y2)
      canvas.drawLine(
        Offset(i, 0), 
        Offset(i + size.height, size.height), 
        paint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}