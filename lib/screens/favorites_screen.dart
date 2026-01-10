import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/colors.dart';
import '../core/constants/strings.dart';
import '../models/ayet_model.dart';
import '../models/sure_isimleri.dart';
import '../core/services/global_settings.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<AyetModel> tumFavoriler = [];

  @override
  void initState() {
    super.initState();
    _favorileriYukle();
  }

  Future<void> _favorileriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList('favoriler') ?? [];
    List<AyetModel> temp = [];
    for (var s in list) {
      try {
        temp.add(AyetModel.fromSavedJson(jsonDecode(s)));
      } catch (e) {
        debugPrint('Hata: $e');
      }
    }
    setState(() {
      tumFavoriler = temp.reversed.toList();
    });
  }

  Future<void> _sil(int index, AyetModel silinecekAyet) async {
    final prefs = await SharedPreferences.getInstance();

    tumFavoriler.removeWhere((element) => element.id == silinecekAyet.id);

    List<String> kayitListesi = tumFavoriler
        .map((e) => jsonEncode(e.toJson()))
        .toList();
    await prefs.setStringList('favoriler', kayitListesi);

    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('removed_msg'))));
    }
  }

  List<AyetModel> _getGosterilecekListe() {
    return tumFavoriler;
  }

  @override
  Widget build(BuildContext context) {
    List<AyetModel> gosterilecekListe = _getGosterilecekListe();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t('list_title'),
          style: const TextStyle(color: AppColors.gold),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: tumFavoriler.isEmpty
          ? Center(
              child: Text(
                t('list_empty'),
                style: const TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              itemCount: gosterilecekListe.length,
              itemBuilder: (context, index) {
                var a = gosterilecekListe[index];
                String metin = GlobalSettings.currentLanguage == 'en'
                    ? a.ingilizce
                    : a.turkce;
                String gorunurSureIsmi = a.sureAdi;
                if (GlobalSettings.currentLanguage == 'tr') {
                  gorunurSureIsmi = SureIsimleri.tr[a.sureAdi] ?? a.sureAdi;
                }
                return Card(
                  color: AppColors.cardBackground,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    title: Text(
                      "$gorunurSureIsmi, ${a.bitisAyetNo != null ? '${a.ayetNo}-${a.bitisAyetNo}' : a.ayetNo}",
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        metin,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _sil(index, a),
                    ),
                    onTap: () {
                      DateTime yilBasi = DateTime(DateTime.now().year, 1, 1);
                      DateTime gidilecekTarih = yilBasi.add(
                        Duration(days: a.id - 1),
                      );

                      Navigator.pop(context, gidilecekTarih);
                    },
                  ),
                );
              },
            ),
    );
  }
}
