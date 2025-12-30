// 1. KISIM: MODEL (Senin yazdığın kısım)
class AyetModel {
  final int id;
  final String sureAdi;
  final int ayetNo;
  final String turkce;
  final String ingilizce;
  final String arapca;
  final String sesDosyasiUrl;

  const AyetModel({
    required this.id,
    required this.sureAdi,
    required this.ayetNo,
    required this.turkce,
    required this.ingilizce,
    this.arapca = "",
    this.sesDosyasiUrl = "",
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sureAdi': sureAdi,
        'ayetNo': ayetNo,
        'turkce': turkce,
        'ingilizce': ingilizce,
        'arapca': arapca,
        'sesDosyasiUrl': sesDosyasiUrl,
      };

  factory AyetModel.fromJson(Map<String, dynamic> json) {
    return AyetModel(
      id: json['id'] ?? 0,
      sureAdi: json['sureAdi'] ?? "",
      ayetNo: json['ayetNo'] ?? 0,
      turkce: json['turkce'] ?? "",
      ingilizce: json['ingilizce'] ?? "",
      arapca: json['arapca'] ?? "",
      sesDosyasiUrl: json['sesDosyasiUrl'] ?? "",
    );
  }

  // Hatayı çözen ek
  factory AyetModel.fromSavedJson(Map<String, dynamic> json) {
    return AyetModel.fromJson(json);
  }
}

// 👇 2. KISIM: EKSİK OLAN VERİ DEPOSU (Bunu ekliyoruz) 👇
class YerelVeri {
  static final List<AyetModel> _veri = [
    const AyetModel(
      id: 1,
      sureAdi: "Fatiha",
      ayetNo: 1,
      turkce: "Rahmân ve Rahîm olan Allah'ın adıyla.",
      ingilizce: "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
      arapca: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3",
    ),
    const AyetModel(
      id: 2,
      sureAdi: "Bakara",
      ayetNo: 153,
      turkce: "Ey iman edenler! Sabır ve namazla yardım dileyin. Şüphesiz Allah sabredenlerin yanındadır.",
      ingilizce: "O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient.",
      arapca: "يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/160.mp3",
    ),
    const AyetModel(
      id: 3,
      sureAdi: "İnşirah",
      ayetNo: 5,
      turkce: "Demek ki, zorlukla beraber bir kolaylık vardır.",
      ingilizce: "For indeed, with hardship [will be] ease.",
      arapca: "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/5970.mp3",
    ),
    // ... Buraya diğer ayetleri ekleyerek 365'e tamamlayabilirsin ...
    const AyetModel(
      id: 4,
      sureAdi: "Talak",
      ayetNo: 3,
      turkce: "Kim Allah'a güvenirse O, ona yeter.",
      ingilizce: "And whoever relies upon Allah - then He is sufficient for him.",
      arapca: "وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/5216.mp3",
    ),
    // 5. Gün - Huzur
    const AyetModel(
      id: 5,
      sureAdi: "Rad",
      ayetNo: 28,
      turkce: "Bilesiniz ki, kalpler ancak Allah'ı anmakla huzur bulur.",
      ingilizce: "Unquestionably, by the remembrance of Allah hearts are assured.",
      arapca: "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/1735.mp3",
    ),
    // 6. Gün - Motivasyon
    const AyetModel(
      id: 6,
      sureAdi: "Âl-i İmrân",
      ayetNo: 139,
      turkce: "Gevşemeyin, hüzünlenmeyin. Eğer (gerçekten) iman etmiş kimseler iseniz üstün olan sizlersiniz.",
      ingilizce: "So do not weaken and do not grieve, and you will be superior if you are [true] believers.",
      arapca: "وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنتُمُ الْأَعْلَوْنَ إِن كُنتُم مُّؤْمِنِينَ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/432.mp3",
    ),
    // 7. Gün - Yük ve Kapasite
    const AyetModel(
      id: 7,
      sureAdi: "Bakara",
      ayetNo: 286,
      turkce: "Allah, kimseye gücünün yeteceğinden fazlasını yüklemez.",
      ingilizce: "Allah does not charge a soul except [with that within] its capacity.",
      arapca: "لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/293.mp3",
    ),
    // 8. Gün - Dua
    const AyetModel(
      id: 8,
      sureAdi: "Mümin",
      ayetNo: 60,
      turkce: "Rabbiniz şöyle buyurdu: Bana dua edin, kabul edeyim.",
      ingilizce: "And your Lord says, 'Call upon Me; I will respond to you.'",
      arapca: "وَقَالَ رَبُّكُمُ ادْعُونِي أَسْتَجِبْ لَكُمْ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/4213.mp3",
    ),
    // 9. Gün - Umut
    const AyetModel(
      id: 9,
      sureAdi: "Zümer",
      ayetNo: 53,
      turkce: "Allah'ın rahmetinden ümidinizi kesmeyin.",
      ingilizce: "Do not despair of the mercy of Allah.",
      arapca: "لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/4105.mp3",
    ),
    // 10. Gün - Yalnız Değilsin
    const AyetModel(
      id: 10,
      sureAdi: "Duha",
      ayetNo: 3,
      turkce: "Rabbin seni terk etmedi, sana darılmadı da.",
      ingilizce: "Your Lord has not taken leave of you, [O Muhammad], nor has He detested [you].",
      arapca: "مَا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/5959.mp3",
    ),
    // 11. Gün - Yakınlık
    const AyetModel(
      id: 11,
      sureAdi: "Bakara",
      ayetNo: 186,
      turkce: "Kullarım sana beni sorduğunda (söyle onlara): Ben çok yakınım.",
      ingilizce: "And when My servants ask you, [O Muhammad], concerning Me - indeed I am near.",
      arapca: "وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/193.mp3",
    ),
    // 12. Gün - Şükür
    const AyetModel(
      id: 12,
      sureAdi: "İbrahim",
      ayetNo: 7,
      turkce: "Eğer şükrederseniz, elbette size (nimetimi) artırırım.",
      ingilizce: "If you are grateful, I will surely increase you [in favor].",
      arapca: "لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/1763.mp3",
    ),
    // 13. Gün - İyilik
    const AyetModel(
      id: 13,
      sureAdi: "Zilzal",
      ayetNo: 7,
      turkce: "Kim zerre ağırlığınca bir hayır işlerse, onun mükafatını görecektir.",
      ingilizce: "So whoever does an atom's weight of good will see it.",
      arapca: "فَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍ خَيْرًا يَرَهُ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/6145.mp3",
    ),
    // 14. Gün - Zaman
    const AyetModel(
      id: 14,
      sureAdi: "Asr",
      ayetNo: 1,
      turkce: "Asra yemin olsun ki, insan gerçekten ziyan içindedir.",
      ingilizce: "By time, Indeed, mankind is in loss.",
      arapca: "وَالْعَصْرِ * إِنَّ الْإِنسَانَ لَفِي خُسْرٍ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/6096.mp3",
    ),
    // 15. Gün - Ayetel Kürsi (Koruma)
    const AyetModel(
      id: 15,
      sureAdi: "Bakara",
      ayetNo: 255,
      turkce: "Allah, kendisinden başka ilâh olmayandır. Diridir, kayyumdur.",
      ingilizce: "Allah - there is no deity except Him, the Ever-Living, the Sustainer of [all] existence.",
      arapca: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/262.mp3",
    ),
    // 16. Gün - Müjde
    const AyetModel(
      id: 16,
      sureAdi: "Yusuf",
      ayetNo: 87,
      turkce: "Allah'ın rahmetinden ümit kesmeyin.",
      ingilizce: "Despair not of relief from Allah.",
      arapca: "وَلَا تَيْأَسُوا مِن رَّوْحِ اللَّهِ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/1684.mp3",
    ),
    // 17. Gün - Eşler Arası Sevgi
    const AyetModel(
      id: 17,
      sureAdi: "Rum",
      ayetNo: 21,
      turkce: "Aranızda sevgi ve merhamet var etmesi, O'nun varlığının delillerindendir.",
      ingilizce: "And He placed between you affection and mercy.",
      arapca: "وَجَعَلَ بَيْنَكُم مَّوَدَّةً وَرَحْمَةً",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/3430.mp3",
    ),
    // 18. Gün - Kuran
    const AyetModel(
      id: 18,
      sureAdi: "Kamer",
      ayetNo: 17,
      turkce: "Andolsun biz Kur'an'ı düşünüp öğüt almak için kolaylaştırdık.",
      ingilizce: "And We have certainly made the Qur'an easy for remembrance.",
      arapca: "وَلَقَدْ يَسَّرْنَا الْقُرْآنَ لِلذِّكْرِ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/4863.mp3",
    ),
    // 19. Gün - Anne Baba
    const AyetModel(
      id: 19,
      sureAdi: "Lokman",
      ayetNo: 14,
      turkce: "Bana ve ana-babana şükret. Dönüş banadır.",
      ingilizce: "Be grateful to Me and to your parents; to Me is the [final] destination.",
      arapca: "أَنِ اشْكُرْ لِي وَلِوَالِدَيْكَ إِلَيَّ الْمَصِيرُ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/3517.mp3",
    ),
    // 20. Gün - Namaz
    const AyetModel(
      id: 20,
      sureAdi: "Ankebut",
      ayetNo: 45,
      turkce: "Muhakkak ki namaz, hayâsızlıktan ve kötülükten alıkoyar.",
      ingilizce: "Indeed, prayer prohibits immorality and wrongdoing.",
      arapca: "إِنَّ الصَّلَاةَ تَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/3385.mp3",
    ),
    // 21. Gün - Takva
    const AyetModel(
      id: 21,
      sureAdi: "Hucurat",
      ayetNo: 13,
      turkce: "Allah katında en değerli olanınız, O'na karşı gelmekten en çok sakınanınızdır.",
      ingilizce: "Indeed, the most noble of you in the sight of Allah is the most righteous of you.",
      arapca: "إِنَّ أَكْرَمَكُمْ عِندَ اللَّهِ أَتْقَاكُمْ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/4625.mp3",
    ),
    // 22. Gün - Merhamet
    const AyetModel(
      id: 22,
      sureAdi: "Furkan",
      ayetNo: 63,
      turkce: "Rahmân'ın kulları, yeryüzünde vakar ve tevazu ile yürüyen kimselerdir.",
      ingilizce: "The servants of the Most Merciful are those who walk upon the earth easily.",
      arapca: "وَعِبَادُ الرَّحْمَٰنِ الَّذِينَ يَمْشُونَ عَلَى الْأَرْضِ هَوْنًا",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/2918.mp3",
    ),
    // 23. Gün - İhlâs
    const AyetModel(
      id: 23,
      sureAdi: "İhlas",
      ayetNo: 1,
      turkce: "De ki: O, Allah'tır, tektir.",
      ingilizce: "Say, 'He is Allah, [who is] One.'",
      arapca: "قُلْ هُوَ اللَّهُ أَحَدٌ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/6222.mp3",
    ),
    // 24. Gün - Sabah Aydınlığı (Felak)
    const AyetModel(
      id: 24,
      sureAdi: "Felak",
      ayetNo: 1,
      turkce: "De ki: Sabahın Rabbine sığınırım.",
      ingilizce: "Say, 'I seek refuge in the Lord of daybreak.'",
      arapca: "قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/6226.mp3",
    ),
    // 25. Gün - İnsanların Rabbi (Nas)
    const AyetModel(
      id: 25,
      sureAdi: "Nas",
      ayetNo: 1,
      turkce: "De ki: İnsanların Rabbine sığınırım.",
      ingilizce: "Say, 'I seek refuge in the Lord of mankind.'",
      arapca: "قُلْ أَعُوذُ بِرَبِّ النَّاسِ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/6231.mp3",
    ),
    // 26. Gün - Kevser (Bolluk)
    const AyetModel(
      id: 26,
      sureAdi: "Kevser",
      ayetNo: 1,
      turkce: "Şüphesiz biz sana Kevser'i verdik.",
      ingilizce: "Indeed, We have granted you, [O Muhammad], al-Kawthar.",
      arapca: "إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/6205.mp3",
    ),
    // 27. Gün - Zafer (Nasr)
    const AyetModel(
      id: 27,
      sureAdi: "Nasr",
      ayetNo: 1,
      turkce: "Allah'ın yardımı ve fetih geldiği zaman...",
      ingilizce: "When the victory of Allah has come and the conquest...",
      arapca: "إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/6211.mp3",
    ),
    // 28. Gün - Kadir Gecesi
    const AyetModel(
      id: 28,
      sureAdi: "Kadir",
      ayetNo: 1,
      turkce: "Şüphesiz, biz onu (Kur'an'ı) Kadir gecesinde indirdik.",
      ingilizce: "Indeed, We sent the Qur'an down during the Night of Decree.",
      arapca: "إِنَّا أَنزَلْنَاهُ فِي لَيْلَةِ الْقَدْرِ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/6126.mp3",
    ),
    // 29. Gün - Oku (Alak)
    const AyetModel(
      id: 29,
      sureAdi: "Alak",
      ayetNo: 1,
      turkce: "Yaratan Rabbinin adıyla oku!",
      ingilizce: "Recite in the name of your Lord who created.",
      arapca: "اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/6106.mp3",
    ),
    // 30. Gün - En Güzel Biçim (Tin)
    const AyetModel(
      id: 30,
      sureAdi: "Tin",
      ayetNo: 4,
      turkce: "Biz insanı en güzel biçimde yarattık.",
      ingilizce: "We have certainly created man in the best of stature.",
      arapca: "لَقَدْ خَلَقْنَا الْإِنسَانَ فِي أَحْسَنِ تَقْوِيمٍ",
      sesDosyasiUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/6102.mp3",
    ),
  ];
  

  static AyetModel getir(int gunNo) {
    if (_veri.isEmpty) {
      return const AyetModel(
          id: 0, 
          sureAdi: "Hata", 
          ayetNo: 0, 
          turkce: "Veri yok", 
          ingilizce: "No data"
      );
    }
    // Döngü mantığı: Liste bitince başa döner
    return _veri[(gunNo - 1) % _veri.length];
  }
}
// data.dart dosyasının en altına yapıştır:

class SureIsimleri {
  // API'den gelen isme (Key) karşılık Türkçe ismini (Value) verir
  static const Map<String, String> tr = {
    "Al-Faatiha": "Fâtiha",
    "Al-Baqara": "Bakara", // ✅ Düzeltildi
    "Aal-i-Imraan": "Âl-i İmrân",
    "An-Nisaa": "Nisâ",
    "Al-Maaida": "Mâide",
    "Al-An'aam": "En'âm",
    "Al-A'raaf": "A'râf",
    "Al-Anfaal": "Enfâl",
    "At-Tawba": "Tevbe",
    "Yunus": "Yûnus",
    "Hud": "Hûd",
    "Yusuf": "Yûsuf",
    "Ar-Ra'd": "Ra'd",
    "Ibrahim": "İbrahim",
    "Al-Hijr": "Hicr",
    "An-Nahl": "Nahl",
    "Al-Israa": "İsrâ",
    "Al-Kahf": "Kehf",
    "Maryam": "Meryem",
    "Taa-Haa": "Tâhâ",
    "Al-Anbiyaa": "Enbiyâ",
    "Al-Hajj": "Hac",
    "Al-Muminoon": "Mü'minûn", // ✅ Düzeltildi
    "An-Noor": "Nûr",
    "Al-Furqaan": "Furkân",
    "Ash-Shu'araa": "Şuarâ",
    "An-Naml": "Neml",
    "Al-Qasas": "Kasas",
    "Al-Ankaboot": "Ankebût",
    "Ar-Room": "Rûm",
    "Luqman": "Lokman",
    "As-Sajda": "Secde",
    "Al-Ahzaab": "Ahzâb",
    "Saba": "Sebe'",
    "Faatir": "Fâtır",
    "Yaseen": "Yâsîn",
    "As-Saaffaat": "Sâffât",
    "Saad": "Sâd",
    "Az-Zumar": "Zümer",
    "Ghafir": "Mü'min",
    "Fussilat": "Fussilet",
    "Ash-Shura": "Şûrâ",
    "Az-Zukhruf": "Zuhruf",
    "Ad-Dukhaan": "Duhân", // ✅ Düzeltildi
    "Al-Jaathiya": "Câsiye", // ✅ Düzeltildi
    "Al-Ahqaf": "Ahkâf",
    "Muhammad": "Muhammed",
    "Al-Fath": "Fetih",
    "Al-Hujuraat": "Hucurât",
    "Qaaf": "Kâf",
    "Adh-Dhaariyat": "Zâriyat", // ✅ Düzeltildi
    "At-Tur": "Tûr",
    "An-Najm": "Necm",
    "Al-Qamar": "Kamer",
    "Ar-Rahmaan": "Rahmân", // ✅ Düzeltildi
    "Al-Waaqia": "Vâkıa", // ✅ Düzeltildi
    "Al-Hadid": "Hadîd",
    "Al-Mujaadila": "Mücâdele", // ✅ Düzeltildi
    "Al-Hashr": "Haşr",
    "Al-Mumtahana": "Mümtehine",
    "As-Saff": "Saff",
    "Al-Jumu'a": "Cuma",
    "Al-Munaafiqoon": "Münâfikûn", // ✅ Düzeltildi
    "At-Taghaabun": "Tegâbün", // ✅ Düzeltildi
    "At-Talaaq": "Talâk", // ✅ Düzeltildi
    "At-Tahrim": "Tahrîm",
    "Al-Mulk": "Mülk",
    "Al-Qalam": "Kalem",
    "Al-Haaqqa": "Hâkka",
    "Al-Ma'aarij": "Meâric",
    "Nooh": "Nûh",
    "Al-Jinn": "Cin",
    "Al-Muzzammil": "Müzzemmil",
    "Al-Muddaththir": "Müddessir",
    "Al-Qiyaama": "Kıyâmet", // ✅ Düzeltildi
    "Al-Insaan": "İnsan",
    "Al-Mursalaat": "Mürselât", // ✅ Düzeltildi
    "An-Naba": "Nebe",
    "An-Naazi'aat": "Nâziât", // ✅ Düzeltildi
    "Abasa": "Abese",
    "At-Takwir": "Tekvîr",
    "Al-Infitaar": "İnfitâr", // ✅ Düzeltildi
    "Al-Mutaffifin": "Mutaffifîn",
    "Al-Inshiqaaq": "İnşikâk", // ✅ Düzeltildi
    "Al-Burooj": "Burûc",
    "At-Taariq": "Târık", // ✅ Düzeltildi
    "Al-A'laa": "A'lâ", // ✅ Düzeltildi
    "Al-Ghaashiya": "Gâşiye", // ✅ Düzeltildi
    "Al-Fajr": "Fecr",
    "Al-Balad": "Beled",
    "Ash-Shams": "Şems",
    "Al-Lail": "Leyl",
    "Ad-Dhuhaa": "Duhâ", // ✅ Düzeltildi
    "Ash-Sharh": "İnşirah",
    "At-Tin": "Tîn",
    "Al-Alaq": "Alak",
    "Al-Qadr": "Kadir",
    "Al-Bayyina": "Beyyine",
    "Az-Zalzala": "Zilzâl",
    "Al-Aadiyaat": "Âdiyât", // ✅ Düzeltildi
    "Al-Qaari'a": "Kâria", // ✅ Düzeltildi
    "At-Takaathur": "Tekâsür", // ✅ Düzeltildi
    "Al-Asr": "Asr",
    "Al-Humaza": "Hümeze",
    "Al-Fil": "Fîl",
    "Quraish": "Kureyş",
    "Al-Maa'un": "Mâûn", // ✅ Düzeltildi
    "Al-Kawthar": "Kevser",
    "Al-Kaafiroon": "Kâfirûn", // ✅ Düzeltildi
    "An-Nasr": "Nasr",
    "Al-Masad": "Tebbet",
    "Al-Ikhlaas": "İhlâs", // ✅ Düzeltildi
    "Al-Falaq": "Felâk",
    "An-Naas": "Nâs",
  };

  // Eğer İngilizce ise zaten gelen isim güzel ama "Surah" eklemek isteyebiliriz
  // Veya "The Cow" gibi tam çeviri istersen o listeyi de buraya ekleyebiliriz.
  // Şimdilik İngilizce için API'den gelen ismi kullanmak yeterli.
}