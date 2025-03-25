import 'package:flutter/material.dart';
import 'package:morph_mods/backend/AdManager.dart';
import 'package:morph_mods/backend/native_ads/SingleNativeAdLoader.dart';

class AdFlowManager extends AdManager {
  /// Показ interstitial і прелоад нативної реклами перед відкриттям екрана
  static Future<void> showInterstitialWithNativePreload({
    required BuildContext context,
    required Future<void> Function() showInterstitialFlow,
  }) async {
    // ✅ Прелоад нативної реклами на index = 0
    await SingleNativeAdLoader().preloadAd();

    // 🔹 Далі викликаємо логіку, яка вже керується AdManager
    await showInterstitialFlow();
  }
}
