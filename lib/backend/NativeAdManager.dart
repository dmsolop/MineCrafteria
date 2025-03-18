import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:morph_mods/backend/AccessKeys.dart';

class NativeAdManager {
  static const String _adUnitId = AccessKeys.adUnitId;

  // 🔹 Кеш реклами: індекс → NativeAd
  static final Map<int, NativeAd> _adCache = {};
  static final Set<int> _loadingIndices = {};

  /// 🔹 Попереднє завантаження для перших 3 позицій (5, 11, 17)
  static void preLoadAd() {
    for (int i = 5; i < 20; i += 6) {
      loadAdForIndex(i);
    }
  }

  /// 🔹 Завантажити рекламу для конкретного індекса
  static void loadAdForIndex(int index) {
    if (_adCache.containsKey(index) || _loadingIndices.contains(index)) {
      return; // 🔸 Вже є або вантажиться
    }

    _loadingIndices.add(index);

    final ad = NativeAd(
      adUnitId: _adUnitId,
      factoryId: 'customNative',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Native Ad Loaded for index $index');
          _adCache[index] = ad as NativeAd;
          _loadingIndices.remove(index);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Failed to load Native Ad for index $index: $error');
          ad.dispose();
          _loadingIndices.remove(index);
        },
        onAdClosed: (ad) {
          ad.dispose();
          _adCache.remove(index);
          loadAdForIndex(index); // 🔁 Перезавантажити
        },
      ),
    );

    ad.load();
  }

  /// 🔹 Отримати віджет реклами з передачею висоти для фабрики
  static Widget getAdWidget(int index,
      {required double height, required VoidCallback refresh}) {
    if (_adCache.containsKey(index)) {
      final ad = _adCache[index]!;
      final adWidget = AdWidget(ad: ad);

      // 🔸 Повертаємо віджет з заданою висотою
      return Container(
        height: height,
        padding: const EdgeInsets.all(4),
        child: adWidget,
      );
    } else {
      loadAdForIndex(index); // 🔹 Завантажити, якщо ще нема
      return SizedBox(height: height); // Placeholder з тією ж висотою
    }
  }

  static void disposeAllAds() {
    for (final ad in _adCache.values) {
      ad.dispose();
    }
    _adCache.clear();
  }
}

// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:morph_mods/backend/AccessKeys.dart';

// class NativeAdManager {
//   static const String _nativeAdUnitId = AccessKeys.adUnitId;

//   static NativeAd? _cachedAd;
//   static bool _isAdLoaded = false;
//   static bool _isLoading = false;

//   /// 🔹 Завантаження та кешування Native Ad
//   static void loadAd() {
//     if (_cachedAd != null || _isLoading)
//       return; // Вже є реклама або вантажиться

//     _isLoading = true;

//     _cachedAd = NativeAd(
//       adUnitId: _nativeAdUnitId,
//       factoryId: 'customNative', // 👈 Kotlin-фабрика
//       request: const AdRequest(),
//       listener: NativeAdListener(
//         onAdLoaded: (ad) {
//           debugPrint('✅ Native Ad Loaded');
//           _isAdLoaded = true;
//           _isLoading = false;
//         },
//         onAdFailedToLoad: (ad, error) {
//           debugPrint('❌ Failed to load Native Ad: $error');
//           ad.dispose();
//           _cachedAd = null;
//           _isAdLoaded = false;
//           _isLoading = false;
//         },
//         // Ми не використовуємо onAdClosed для dispose
//       ),
//     );

//     _cachedAd!.load();
//   }

//   /// 🔹 Показ реклами з кешу (без dispose)
//   static Widget getNativeAdWidget() {
//     if (_cachedAd == null || !_isAdLoaded) {
//       loadAd();
//       return const SizedBox(height: 290); // Placeholder для стабільності
//     }

//     return Container(
//       height: 290,
//       padding: const EdgeInsets.all(8),
//       child: AdWidget(ad: _cachedAd!),
//     );
//   }

//   /// 🔻 Dispose реклами вручну при виході зі сторінки
//   static void disposeAd() {
//     _cachedAd?.dispose();
//     _cachedAd = null;
//     _isAdLoaded = false;
//     debugPrint('♻️ Native Ad disposed manually');
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:morph_mods/backend/AccessKeys.dart';

// class NativeAdManager {
//   static const String _nativeAdUnitId = AccessKeys.adUnitId;

//   static NativeAd? _cachedAd;
//   static bool _isAdLoaded = false;
//   static bool _isLoading = false;

//   /// Ініціалізувати та завантажити рекламу
//   static void loadAd() {
//     if (_cachedAd != null || _isLoading) return;

//     _isLoading = true;

//     _cachedAd = NativeAd(
//       adUnitId: _nativeAdUnitId,
//       factoryId: 'customNative', // 👈 Фабрика має бути зареєстрована
//       request: const AdRequest(),
//       listener: NativeAdListener(
//         onAdLoaded: (ad) {
//           debugPrint('✅ Native Ad Loaded');
//           _isAdLoaded = true;
//           _isLoading = false;
//         },
//         onAdFailedToLoad: (ad, error) {
//           debugPrint('❌ Failed to load Native Ad: $error');
//           ad.dispose();
//           _cachedAd = null;
//           _isAdLoaded = false;
//           _isLoading = false;
//         },
//         onAdClosed: (ad) {
//           ad.dispose();
//           _cachedAd = null;
//           _isAdLoaded = false;
//           loadAd(); // 🔁 Завантажити нову
//         },
//       ),
//     );

//     _cachedAd!.load();
//   }

//   static Widget getNativeAdWidget() {
//     if (_cachedAd == null || !_isAdLoaded) {
//       loadAd();
//       return const SizedBox(height: 290);
//     }

//     final NativeAd currentAd = _cachedAd!;
//     final Widget adWidget = AdWidget(ad: currentAd);

//     _cachedAd = null;
//     _isAdLoaded = false;

//     // 🔹 Безпечна затримка перед dispose (уникаємо race condition)
//     Future.delayed(const Duration(seconds: 1), () {
//       currentAd.dispose();
//       loadAd();
//     });

//     return Container(
//       height: 290,
//       padding: const EdgeInsets.all(8),
//       child: adWidget,
//     );
//   }

//   // static Widget getAdWidget() {
//   //   if (_nativeAd == null || !_isAdLoaded) {
//   //     loadAd(); // 🔄 Завантажити, якщо ще нема
//   //     return const SizedBox(height: 290); // 🔹 Місце для реклами
//   //   }

//   //   final adWidget = AdWidget(ad: _nativeAd!);

//   //   // Очистити після використання
//   //   _nativeAd = null;
//   //   _isAdLoaded = false;
//   //   loadAd(); // 🔁 Підготуємо нову

//   //   return Container(
//   //     height: 290,
//   //     margin: const EdgeInsets.symmetric(horizontal: 8),
//   //     child: adWidget,
//   //   );
//   // }
// }

// class NativeAdManager {
//   static Map<String, dynamic>? _cachedAd;

//   Future<Map<String, dynamic>> fetchAdData() async {
//     if (_cachedAd != null) {
//       return _cachedAd!;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse(
//             'https://googleads.g.doubleclick.net/pagead/id?ad_unit=${AccessKeys.adUnitId}'),
//         headers: {
//           'User-Agent': 'FlutterApp',
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> adData = json.decode(response.body);
//         _cachedAd = adData;
//         return adData;
//       } else {
//         throw Exception("❌ Failed to load ad: ${response.statusCode}");
//       }
//     } catch (e) {
//       debugPrint("⚠️ Error fetching ad: $e");
//       return {};
//     }
//   }
// }
