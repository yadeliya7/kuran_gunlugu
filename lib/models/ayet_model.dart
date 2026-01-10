class AyetModel {
  final int id;
  final String sureAdi;
  final int ayetNo;
  final String turkce;
  final String ingilizce;
  final String arapca;
  final String sesDosyasiUrl;
  final int? bitisAyetNo;
  final List<String>? ekSesDosyalari;

  const AyetModel({
    required this.id,
    required this.sureAdi,
    required this.ayetNo,
    required this.turkce,
    required this.ingilizce,
    this.arapca = "",
    this.sesDosyasiUrl = "",
    this.bitisAyetNo,
    this.ekSesDosyalari,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'sureAdi': sureAdi,
    'ayetNo': ayetNo,
    'turkce': turkce,
    'ingilizce': ingilizce,
    'arapca': arapca,
    'sesDosyasiUrl': sesDosyasiUrl,
    'bitisAyetNo': bitisAyetNo,
    'ekSesDosyalari': ekSesDosyalari,
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
      bitisAyetNo: json['bitisAyetNo'],
      ekSesDosyalari: json['ekSesDosyalari'] != null
          ? List<String>.from(json['ekSesDosyalari'])
          : null,
    );
  }

  // Hatayı çözen ek
  factory AyetModel.fromSavedJson(Map<String, dynamic> json) {
    return AyetModel.fromJson(json);
  }
}
