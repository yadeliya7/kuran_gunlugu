import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class DonationService {
  static final DonationService _instance = DonationService._internal();

  factory DonationService() => _instance;

  DonationService._internal();

  static const _apiKey = 'appl_TvDhEzKItnkNKGFLiVxWkhywiRW';

  Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_apiKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_apiKey);
    } else {
      return;
    }

    await Purchases.configure(configuration);
  }

  Future<List<Package>> fetchDonations() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages;
      } else {
        debugPrint("No current offering configured in RevenueCat.");
        return [];
      }
    } on PlatformException catch (e) {
      debugPrint("Error fetching donations: $e");
      return [];
    }
  }

  Future<bool> makePurchase(Package package) async {
    try {
      // Satın alma işlemini başlat
      await Purchases.purchasePackage(package);

      // Consumable (bağış) için sadece transaction'ın başarılı olmasına bakarız
      // Entitlement kontrolü yapmamıza gerek yok
      debugPrint('Purchase successful for package: ${package.identifier}');
      return true;
    } on PlatformException catch (e) {
      // Hata kodunu kontrol et
      var errorCode = PurchasesErrorHelper.getErrorCode(e);

      // Kullanıcı iptal ettiyse sessizce false döndür
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('Purchase cancelled by user');
        return false;
      }

      // Diğer hatalar için log tut
      debugPrint('Purchase error: Code=$errorCode, Message=${e.message}');
      return false;
    } catch (e) {
      // Beklenmeyen hatalar
      debugPrint('Unexpected purchase error: $e');
      return false;
    }
  }
}
