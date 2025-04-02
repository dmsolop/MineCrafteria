import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../AccessKeys.dart';
import '../AdManager.dart';
import '../../backend/LogService.dart';

class NativeAdManager {
  // Singleton інстанс
  static final NativeAdManager _instance = NativeAdManager._internal();
  factory NativeAdManager() => _instance;
  NativeAdManager._internal();

  // 🔹 Поля кешу та стану
  final Map<int, NativeAd> _nativeAds = {};
  final Map<int, bool> _adLoadedFlags = {};

  static const int _adFrequency = 5;
  int _lastPreloadedAdIndex = 17; // 🔹 5,11,17 — preloaded by default
  static const String _adUnitId = AccessKeys.adUnitId; // 🔹 Як у проекті

  bool isAdLoaded(int index) {
    return _adLoadedFlags[index] == true;
  }

  // 🔹 Перевірити: чи цей індекс — реклама
  bool isAdIndex(int index) {
    final result = AdConfig.isAdsEnabled && ((index + 1) % (_adFrequency + 1) == 0);
    LogService.log('isAdIndex: index=$index → $result');
    return result;
  }

  // 🔹 Отримати реальний індекс моду (без реклами)
  int getRealModIndex(int index) {
    int adsBefore = (index / (_adFrequency + 1)).floor();
    return index - adsBefore;
  }

  // 🔹 Скільки всього елементів (моди + реклама)
  int getTotalItemCount(int modCount) {
    final total = AdConfig.isAdsEnabled ? modCount + (modCount / _adFrequency).floor() : modCount;
    LogService.log('getTotalItemCount: modCount=$modCount → total=$total');
    return total;
  }

  // 🔹 Отримати рекламний віджет (кеш або загрузка)
  Widget getAdWidget(int index, {double? height, required VoidCallback refresh}) {
    LogService.log('getAdWidget called with index=$index, adLoaded=${_adLoadedFlags[index] == true}');
    LogService.log('🟡 getAdWidget CALLED from=${StackTrace.current}');
    if (!AdConfig.isAdsEnabled) {
      LogService.log('❌ Ads disabled. Returning SizedBox for index=$index');
      return const SizedBox.shrink(); // 🔹 Реклама вимкнена
    }

    if (_nativeAds[index] == null) {
      if (_nativeAds.containsKey(index)) {
        LogService.log('🟠 getAdWidget using existing ad for index=$index');
      } else {
        LogService.log('🟢 getAdWidget creating new ad for index=$index');
      }
      _nativeAds[index] = NativeAd(
        adUnitId: _adUnitId,
        factoryId: 'customNative',
        customOptions: {
          'containerHeight': height!.toInt(),
        },
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            _adLoadedFlags[index] = true;
            LogService.log('✅ Ad loaded for index=$index → triggering refresh()');
            refresh();
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            LogService.log('❌ Ad failed to load for index=$index → $error');
          },
        ),
        request: const AdRequest(),
      )..load();
    }

    return _adLoadedFlags[index] == true
        ? Container(
            height: height ?? 300,
            child: AdWidget(ad: _nativeAds[index]!),
          )
        : const SizedBox.shrink();
  }

  // 🔹 Pre-load реклами для вказаних індексів
  void preLoadAd({List<int> indexes = const [5, 11, 17]}) {
    LogService.log('preLoadAd called with indexes: $indexes');
    if (!AdConfig.isAdsEnabled) return; // 🔹 Не вантажити, якщо реклама вимкнена

    for (int index in indexes) {
      if (_nativeAds[index] == null) {
        LogService.log('preLoadAd creating NativeAd for index=$index');
        _nativeAds[index] = NativeAd(
          adUnitId: _adUnitId,
          factoryId: 'customNative',
          listener: NativeAdListener(
            onAdLoaded: (ad) {
              LogService.log('NativeAd loaded for index=$index');
              _adLoadedFlags[index] = true;
            },
            onAdFailedToLoad: (ad, error) {
              ad.dispose();
            },
          ),
          request: const AdRequest(),
        )..load();
      }
    }
  }

  // 🔹 Динамічний pre-load при скролі з захистом від виходу за межі
  void maybePreloadAds(int currentIndex, int totalMods) {
    LogService.log('maybePreloadAds at currentIndex=$currentIndex');
    if (!AdConfig.isAdsEnabled) return; // 🔹 Без реклами — нічого не робити

    if (currentIndex >= _lastPreloadedAdIndex - 4) {
      List<int> newIndexes = [];

      for (int i = 1; i <= 3; i++) {
        int nextAdIndex = _lastPreloadedAdIndex + i * 6;
        int maxAllowedAdIndex = getTotalItemCount(totalMods) - 1;
        if (nextAdIndex <= maxAllowedAdIndex) {
          newIndexes.add(nextAdIndex);
        }
      }

      if (newIndexes.isNotEmpty) {
        preLoadAd(indexes: newIndexes);
        _lastPreloadedAdIndex = newIndexes.last;
      }
      LogService.log('maybePreloadAds: newIndexes to load: $newIndexes');
    }
  }

  // 🔹 Очистити всі ресурси та скинути стан
  void disposeAllAds() {
    LogService.log('disposeAllAds called. Clearing ${_nativeAds.length} ads.');
    for (var ad in _nativeAds.values) {
      ad.dispose();
    }
    _nativeAds.clear();
    _adLoadedFlags.clear();
    _lastPreloadedAdIndex = 17; // 🔹 Reset
  }
}
