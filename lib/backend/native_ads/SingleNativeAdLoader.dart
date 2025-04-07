import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morph_mods/backend/native_ads/NativeAdManager.dart';
import '../AdManager.dart';
import '../../backend/LogService.dart';

class SingleNativeAdLoader {
  final NativeAdManager _adManager = NativeAdManager();
  final Map<String, Widget> _cachedAds = {};
  final Map<String, int> _adIndexes = {
    'description': 100,
    'instruction': 101,
    'pageDownload': 102,
    'pageLoaded': 103,
  };

  bool isAdReady(String keyId) {
    final index = _adIndexes[keyId];
    if (index == null) return false;
    return _adManager.isAdLoaded(index);
  }

  /// Завантажити рекламу заздалегідь під час CAS або в іншому місці
  Future<void> preloadAd() async {
    LogService.log('[AdFlow] preloadAd(0) from SingleNativeAdLoader');
    _adManager.preLoadAd(indexes: _adIndexes.values.toList()); // 🔹 Реклама вантажиться в кеш AdNativeManager
  }

  Future<Widget?> loadAd(
    BuildContext context, {
    required String keyId,
    double height = 300,
    required VoidCallback onLoaded,
  }) async {
    final index = _adIndexes[keyId];
    if (index == null) {
      LogService.log('[SingleNativeAdLoader] 🚩 Proceeding with ad load → keyId=$keyId, index=$index');
      return null;
    }

    LogService.log('[SingleNativeAdLoader] loadAd CALLED → keyId=$keyId index=$index');

    if (!AdConfig.isAdsEnabled) {
      LogService.log('⚠️ loadAd skipped: Ads disabled, keyId=$keyId');
      return null;
    }

    if (_cachedAds.containsKey(keyId)) {
      LogService.log('[SingleNativeAdLoader] ✅ Returning CACHED ad → keyId=$keyId');
      onLoaded();
      return _cachedAds[keyId]!;
    }

    if (_adManager.isAdLoaded(index)) {
      LogService.log('[SingleNativeAdLoader] ✅ Returning PRELOADED ad from NativeAdManager → keyId=$keyId index=$index');
      final widget = SizedBox(
        height: height,
        width: double.infinity,
        child: _adManager.getAdWidget(index, height: height, refresh: () {}),
      );
      _cachedAds[keyId] = widget;
      onLoaded();
      return widget;
    }

    LogService.log('[SingleNativeAdLoader] 🚀 Ad not loaded → launching async load for keyId=$keyId');

    final completer = Completer<Widget?>();

    void refresh() {
      LogService.log('[SingleNativeAdLoader] 🔁 refresh() called for keyId=$keyId');
      if (!completer.isCompleted) {
        onLoaded();
        final adWidget = SizedBox(
          height: height,
          width: double.infinity,
          child: _adManager.getAdWidget(index, height: height, refresh: () {}),
        );
        LogService.log('[SingleNativeAdLoader] refresh(): built adWidget → keyId=$keyId, type=${adWidget.runtimeType}');
        _cachedAds[keyId] = adWidget;
        LogService.log('[SingleNativeAdLoader] refresh(): completer.complete() → keyId=$keyId');
        completer.complete(adWidget);
      }
    }

    // 🔹 Тригеримо початкове завантаження
    _adManager.getAdWidget(index, height: height, refresh: refresh);

    return completer.future;
  }

  // Future<Widget?> loadAd(
  //   BuildContext context, {
  //   required String keyId,
  //   double height = 300,
  //   required VoidCallback onLoaded,
  // }) async {
  //   LogService.log('[SingleNativeAdLoader] loadAd CALLED → keyId=$keyId');
  //   if (keyId == 'description') {
  //     LogService.log('[SingleNativeAdLoader] ❗️ loadAd(description) STACK TRACE ↓↓↓');
  //     try {
  //       throw Exception('StackTrace for loadAd(description)');
  //     } catch (e, stack) {
  //       LogService.log(stack.toString());
  //     }
  //   }
  //   if (!AdConfig.isAdsEnabled) {
  //     LogService.log('⚠️ loadAd skipped: Ads disabled, keyId=$keyId');
  //     return null;
  //   }

  //   if (_cachedAds.containsKey(keyId)) {
  //     LogService.log('[SingleNativeAdLoader] Returning CACHED ad → keyId=$keyId');
  //     return _cachedAds[keyId]!;
  //   }

  //   final completer = Completer<Widget?>();
  //   LogService.log('🚀 Starting loadAd for keyId=$keyId');

  //   // 🔹 Ми передаємо refresh колбек, який спрацює, коли реклама реально готова
  //   void refresh() {
  //     LogService.log('[SingleNativeAdLoader] refresh() triggered for keyId=$keyId');
  //     if (!completer.isCompleted) {
  //       final widget = _adManager.getAdWidget(_adIndexes[keyId]!, height: height, refresh: () {});
  //       final wrapped = SizedBox(height: height, width: double.infinity, child: widget);
  //       _cachedAds[keyId] = wrapped;
  //       onLoaded();
  //       completer.complete(wrapped);
  //     }
  //   }

  //   final index = _adIndexes[keyId]!;

  //   _adManager.getAdWidget(index, height: height, refresh: refresh);

  //   if (_adManager.isAdLoaded(index)) {
  //     LogService.log('[SingleNativeAdLoader] ad already loaded, triggering refresh() manually');
  //     refresh();
  //   }

  //   return completer.future;
  // }

  void disposeAdByKey(String keyId) {
    _cachedAds.remove(keyId);
  }

  void disposeAllAds() {
    _adManager.disposeAllAds();
  }
}
