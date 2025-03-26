import 'package:flutter/material.dart';
import 'package:morph_mods/backend/native_ads/NativeAdManager.dart';
import 'package:morph_mods/frontend/LoadingDialog.dart';
import '../AdManager.dart';

class SingleNativeAdLoader {
  final NativeAdManager _adManager = NativeAdManager();

  /// Завантажити рекламу заздалегідь під час CAS або в іншому місці
  Future<void> preloadAd() async {
    _adManager.preLoadAd(indexes: [0]); // 🔹 Реклама вантажиться в кеш
  }

  /// Показати рекламу (з кешу або з прелоадером)
  Future<Widget?> loadAd(BuildContext context, {double height = 300}) async {
    if (!AdConfig.isAdsEnabled) return null;
    // 🔹 Отримуємо AdWidget (з кешу або створюється)
    Widget adWidget = _adManager.getAdWidget(0, height: height, refresh: () {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // ховаємо прелоадер
      }
    });

    // 🔹 Якщо реклама вже завантажена — повертаємо одразу
    if (_adManager.isAdLoaded(0)) {
      return SizedBox(height: height, width: double.infinity, child: adWidget);
    }

    // 🔹 Якщо ні — показати прелоадер
    if (!context.mounted) return null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingDialog(),
    );

    // Дати трохи часу на завантаження та побудову
    await Future.delayed(const Duration(milliseconds: 500));

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    return SizedBox(height: height, width: double.infinity, child: adWidget);
  }
}
