import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/colors.dart';
import '../core/constants/strings.dart';
import '../core/services/global_settings.dart';
import '../core/services/notification_service.dart';
import '../core/services/hafiz_service.dart';
import '../core/services/daily_verse_service.dart';
import '../models/ayet_model.dart';
import '../models/yerel_veri.dart';
import '../widgets/top_bar.dart';
import '../widgets/date_navigation.dart';
import '../widgets/verse_card.dart';
import '../widgets/action_buttons.dart';
import '../widgets/share_card.dart';
import '../widgets/prayer_times_card.dart';
import '../widgets/prayer_times_bottom_sheet.dart';
import 'settings_screen.dart';
import 'premium_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<AyetModel> futureAyet;
  DateTime seciliTarih = DateTime.now();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScreenshotController _screenshotController = ScreenshotController();
  bool isPlaying = false;
  bool isFavorited = false;
  bool _isLoading = false;

  // Counter to force Prayer Times Card refresh
  int _prayerTimesRefreshCounter = 0;

  String? kaydedilenNot;
  final TextEditingController _notController = TextEditingController();

  // Audio playlist management
  List<String> _audioPlaylist = [];
  int _currentAudioIndex = 0;
  StreamSubscription<void>? _playerCompleteSubscription;

  @override
  void initState() {
    super.initState();
    seciliTarih = DateTime.now();
    _isLoading = false;

    futureAyet = ayetiGetir(seciliTarih);
    BildirimServisi.gunlukBildirimKur();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          debugPrint("Ekran yerleşimi tazelendi 🔄");
        });
      }
    });

    // Set up audio player completion listener for sequential playback
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      debugPrint(
        "🎵 Track completed. Current index: $_currentAudioIndex, Playlist length: ${_audioPlaylist.length}",
      );

      if (!mounted) return;

      // Check if there are more tracks to play
      if (_audioPlaylist.isNotEmpty &&
          _currentAudioIndex < _audioPlaylist.length - 1) {
        // Move to next track
        _currentAudioIndex++;
        debugPrint(
          "⏭️ Moving to next track: $_currentAudioIndex/${_audioPlaylist.length}",
        );
        _playCurrentTrack();
      } else {
        // Playlist finished - reset to initial state
        debugPrint("✅ Playlist completed. Resetting player state.");
        setState(() {
          isPlaying = false;
          _currentAudioIndex = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    _notController.dispose();
    super.dispose();
  }

  void ayarlariAc() async {
    // Store current reciter before opening settings
    String previousReciter = HafizYonetimi.secilenHafizKodu;
    debugPrint("🎙️ Current Reciter before settings: $previousReciter");

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );

    // Check if reciter has changed after returning from settings
    String currentReciter = HafizYonetimi.secilenHafizKodu;

    if (previousReciter != currentReciter) {
      debugPrint("🔄 Reciter changed: $previousReciter → $currentReciter");

      // Stop current playback and clear playlist
      await _audioPlayer.stop();

      setState(() {
        isPlaying = false;
        _audioPlaylist.clear();
        _currentAudioIndex = 0;
      });

      debugPrint("✅ Audio source cleared. Next playback will use new reciter.");
    }

    setState(() {});
  }

  void premiumAc() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PremiumScreen()),
    );
    setState(() {});
  }

  void buguneGit() {
    setState(() {
      seciliTarih = DateTime.now();
      isPlaying = false;
      isFavorited = false;
      _audioPlayer.stop();

      // Clear audio playlist
      _audioPlaylist.clear();
      _currentAudioIndex = 0;

      futureAyet = ayetiGetir(seciliTarih);
    });
  }

  void tarihDegistir(int gunFarki) {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;

      if (isPlaying) {
        _audioPlayer.stop();
      }

      DateTime yeniTarih = seciliTarih.add(Duration(days: gunFarki));
      if (yeniTarih.isAfter(DateTime.now())) {
        _isLoading = false;
        return;
      }

      seciliTarih = yeniTarih;
      isPlaying = false;
      isFavorited = false;

      // Clear audio playlist when changing dates
      _audioPlaylist.clear();
      _currentAudioIndex = 0;

      futureAyet = ayetiGetir(seciliTarih).whenComplete(() {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  Future<AyetModel> ayetiGetir([DateTime? tarih]) async {
    DateTime islemTarihi = tarih ?? seciliTarih;
    // 1. Try Online First (Strict Calendar-Based)
    try {
      var verse = await DailyVerseService().getVerseForDate(islemTarihi);
      _notuGetir(verse.id);
      return verse;
    } catch (e) {
      debugPrint("⚠️ Online fetch failed: $e. Falling back to Local Data.");
    }

    // 2. Offline Fallback (Calendar-Based)
    int dayOfYear = int.parse(DateFormat("D").format(islemTarihi));

    // Using YerelVeri's pre-grouped list logic
    var verse = YerelVeri.getir(dayOfYear);
    _notuGetir(verse.id);
    return verse;
  }

  Future<void> _notuGetir(int ayetId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      kaydedilenNot = prefs.getString('not_$ayetId');
    });
  }

  Future<void> _notuKaydet(int ayetId, String not) async {
    final prefs = await SharedPreferences.getInstance();
    if (not.trim().isEmpty) {
      await prefs.remove('not_$ayetId');
      setState(() => kaydedilenNot = null);
    } else {
      await prefs.setString('not_$ayetId', not);
      setState(() => kaydedilenNot = not);
    }
  }

  void _notEklePenceresiAc(int ayetId) {
    _notController.text = kaydedilenNot ?? "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('note_title'),
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _notuKaydet(ayetId, _notController.text);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                ),
                child: Text(
                  t('save'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _favoriyeEkleCikar(AyetModel ayet) async {
    if (!isFavorited) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    List<String> list = prefs.getStringList('favoriler') ?? [];
    int index = -1;
    for (int i = 0; i < list.length; i++) {
      try {
        Map<String, dynamic> decoded = jsonDecode(list[i]);
        if (decoded['sureAdi'] == ayet.sureAdi &&
            decoded['ayetNo'] == ayet.ayetNo) {
          index = i;
          break;
        }
      } catch (e) {
        continue;
      }
    }

    if (index != -1) {
      list.removeAt(index);
      setState(() => isFavorited = false);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t('removed_msg'))));
    } else {
      Map<String, dynamic> ayetMap = ayet.toJson();
      ayetMap['savedForDate'] = seciliTarih.toIso8601String();
      list.add(jsonEncode(ayetMap));

      setState(() => isFavorited = true);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t('added_msg'))));
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
        if (decoded['sureAdi'] == ayet.sureAdi &&
            decoded['ayetNo'] == ayet.ayetNo) {
          bulundu = true;
          break;
        }
      } catch (e) {
        continue;
      }
    }
    if (mounted && isFavorited != bulundu)
      setState(() {
        isFavorited = bulundu;
      });
  }

  Future<void> _resimliPaylas(AyetModel ayet) async {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: AppColors.cardBackground,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.gold),
                  const SizedBox(width: 20),
                  Text(
                    t('share_loading'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    try {
      final Uint8List imageBytes = await _screenshotController
          .captureFromWidget(
            ShareCard(ayet: ayet),
            delay: const Duration(milliseconds: 100),
            context: context,
            pixelRatio: 3.0,
          );

      if (!mounted) return;
      Navigator.pop(context);

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/ayet_share.png').create();
      final box = context.findRenderObject() as RenderBox?;
      await imagePath.writeAsBytes(imageBytes);
      String metin = GlobalSettings.currentLanguage == 'en'
          ? ayet.ingilizce
          : ayet.turkce;
      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: "$metin\n\n🌙 ${t('app_name')}",
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      debugPrint("Hata: $e");
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      String metin = GlobalSettings.currentLanguage == 'en'
          ? ayet.ingilizce
          : ayet.turkce;
      Share.share('"$metin"\n\n🌙 ${t('app_name')}');
    }
  }

  void sesiCalVeyaDurdur(AyetModel ayet) async {
    try {
      if (isPlaying) {
        // Pause current playback
        await _audioPlayer.pause();
        setState(() => isPlaying = false);
        debugPrint(
          "⏸️ Audio paused at track ${_currentAudioIndex + 1}/${_audioPlaylist.length}",
        );
      } else {
        // Check if we're resuming or starting fresh
        final playerState = _audioPlayer.state;

        if (playerState == PlayerState.paused && _audioPlaylist.isNotEmpty) {
          // Resume from pause
          await _audioPlayer.resume();
          setState(() => isPlaying = true);
          debugPrint(
            "▶️ Resuming track ${_currentAudioIndex + 1}/${_audioPlaylist.length}",
          );
        } else {
          // Start fresh playback
          await _audioPlayer.stop();
          _audioPlaylist.clear();
          _currentAudioIndex = 0;

          // Dynamic Audio Construction (Hot Reload Support)
          String kalite = HafizYonetimi.getBitrate(
            HafizYonetimi.secilenHafizKodu,
          );
          String hafiz = HafizYonetimi.secilenHafizKodu;

          // Robust Strategy: Parse Global ID from the existing URL
          int globalStartId = ayet.id;
          try {
            final uriSegments = Uri.parse(ayet.sesDosyasiUrl).pathSegments;
            if (uriSegments.isNotEmpty) {
              String last = uriSegments.last;
              String idStr = last.replaceAll('.mp3', '');
              globalStartId = int.tryParse(idStr) ?? ayet.id;
            }
          } catch (_) {}

          // Build playlist for merged verses
          int count = 1;
          if (ayet.bitisAyetNo != null) {
            count = (ayet.bitisAyetNo! - ayet.ayetNo) + 1;
            debugPrint(
              "📋 Merged verse detected: ${ayet.ayetNo}-${ayet.bitisAyetNo} ($count tracks)",
            );
          }

          for (int i = 0; i < count; i++) {
            int currentId = globalStartId + i;
            String url =
                "https://cdn.islamic.network/quran/audio/$kalite/$hafiz/$currentId.mp3";
            _audioPlaylist.add(url);
          }

          if (_audioPlaylist.isNotEmpty) {
            debugPrint(
              "🎵 Playlist built (Reciter: $hafiz): ${_audioPlaylist.length} track(s)",
            );
            for (int i = 0; i < _audioPlaylist.length; i++) {
              debugPrint("   Track ${i + 1}: ${_audioPlaylist[i]}");
            }
            await _playCurrentTrack();
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Audio Error: $e');
      setState(() {
        isPlaying = false;
        _audioPlaylist.clear();
        _currentAudioIndex = 0;
      });
    }
  }

  Future<void> _playCurrentTrack() async {
    if (_currentAudioIndex >= _audioPlaylist.length) {
      debugPrint("⚠️ Attempted to play beyond playlist bounds");
      setState(() {
        isPlaying = false;
        _currentAudioIndex = 0;
      });
      return;
    }

    if (!mounted) return;

    try {
      String url = _audioPlaylist[_currentAudioIndex];
      debugPrint(
        "▶️ Playing Track ${_currentAudioIndex + 1}/${_audioPlaylist.length}: $url",
      );

      // Stop any previous playback
      await _audioPlayer.stop();

      // Release previous source
      await _audioPlayer.release();

      // Set new source and play
      await _audioPlayer.setSourceUrl(url);
      await _audioPlayer.resume();

      if (mounted) {
        setState(() => isPlaying = true);
      }
    } catch (e) {
      debugPrint("❌ Audio Play Error on track ${_currentAudioIndex + 1}: $e");
      debugPrint("📍 URL: ${_audioPlaylist[_currentAudioIndex]}");

      if (mounted) {
        setState(() {
          isPlaying = false;
        });

        // Kullanıcıya bilgi ver
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              GlobalSettings.currentLanguage == 'tr'
                  ? 'Ses dosyası yüklenemedi. İnternet bağlantınızı kontrol edin.'
                  : 'Failed to load audio. Check your internet connection.',
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isToday =
        DateFormat('yyyyMMdd').format(seciliTarih) ==
        DateFormat('yyyyMMdd').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 1. Üst Bar
              TopBar(
                isToday: isToday,
                onGoToday: buguneGit,
                onSettings: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                  // Refresh UI to update Prayer Times Card
                  setState(() {
                    _prayerTimesRefreshCounter++;
                    debugPrint(
                      '🔄 Returned from Settings - Refreshing UI #$_prayerTimesRefreshCounter',
                    );
                  });
                },
                onFavorites: () async {
                  final gelenTarih = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoritesScreen(),
                    ),
                  );

                  if (gelenTarih != null && gelenTarih is DateTime) {
                    setState(() {
                      seciliTarih = gelenTarih;
                      _isLoading = true;
                      futureAyet = ayetiGetir(seciliTarih).whenComplete(() {
                        setState(() => _isLoading = false);
                      });
                    });
                  }
                },
              ),

              const SizedBox(height: 10),

              // 2. Tarih Değiştirme
              DateNavigation(
                selectedDate: seciliTarih,
                onDateChange: tarihDegistir,
              ),

              const SizedBox(height: 20),

              // 3. İçerik (Scrollable)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Prayer Times Card - Key forces rebuild when counter changes
                      PrayerTimesCard(
                        key: ValueKey(
                          'prayer_times_$_prayerTimesRefreshCounter',
                        ),
                        onTap: () => showPrayerTimesBottomSheet(context),
                      ),

                      const SizedBox(height: 20),

                      // Verse Content - Full height, no cut-off
                      _buildAyetContent(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAyetContent() {
    return FutureBuilder<AyetModel>(
      key: ValueKey(seciliTarih.toIso8601String()),
      future: futureAyet,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 400,
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 80),
            ],
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Bir hata oluştu",
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        if (snapshot.hasData) {
          final ayet = snapshot.data!;

          _mevcutAyetFavoriMi(ayet);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Screenshot(
                controller: _screenshotController,
                child: VerseCard(
                  ayet: ayet,
                  kaydedilenNot: kaydedilenNot,
                  onAddNote: () => _notEklePenceresiAc(ayet.id),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 80,
                child: ActionButtons(
                  isFavorited: isFavorited,
                  isPlaying: isPlaying,
                  onToggleFavorite: () => _favoriyeEkleCikar(ayet),
                  onShare: () => _resimliPaylas(ayet),
                  onTogglePlay: () => sesiCalVeyaDurdur(ayet),
                ),
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }
}
