// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:morph_mods/backend/AccessKeys.dart';
// import 'package:morph_mods/backend/AdManager.dart';

// class NativeAdManager {
//   static const String _adUnitId = AccessKeys.adUnitId;

//   static final Map<int, NativeAd> _adCache = {};
//   static final Set<int> _loadingIndices = {};

//   /// Preload for the first 3 positions (5, 11, 17)
//   static void preLoadAd() {
//     if (!AdConfig.isAdsEnabled) return;
//     for (int i = 5; i < 20; i += 6) {
//       loadAdForIndex(i);
//     }
//   }

//   static void loadAdForIndex(int index) {
//     if (!AdConfig.isAdsEnabled) return;
//     if (_adCache.containsKey(index) || _loadingIndices.contains(index)) {
//       return;
//     }

//     _loadingIndices.add(index);

//     final ad = NativeAd(
//       adUnitId: _adUnitId,
//       factoryId: 'customNative',
//       request: const AdRequest(),
//       listener: NativeAdListener(
//         onAdLoaded: (ad) {
//           _adCache[index] = ad as NativeAd;
//           _loadingIndices.remove(index);
//           _onAdLoadedCallback?.call();
//         },
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//           _loadingIndices.remove(index);
//         },
//         onAdClosed: (ad) {
//           ad.dispose();
//           _adCache.remove(index);
//           loadAdForIndex(index);
//         },
//       ),
//     );

//     ad.load();
//   }

//   static Widget getAdWidget(int index,
//       {required double height, required VoidCallback refresh}) {
//     if (!AdConfig.isAdsEnabled) return const SizedBox.shrink();

//     if (_adCache.containsKey(index)) {
//       final ad = _adCache[index]!;
//       final adWidget = AdWidget(ad: ad);

//       return Container(
//         height: height,
//         padding: const EdgeInsets.all(4),
//         child: adWidget,
//       );
//     } else {
//       loadAdForIndex(index);
//       return SizedBox(height: height);
//     }
//   }

//   static void disposeAllAds() {
//     for (final ad in _adCache.values) {
//       ad.dispose();
//     }
//     _adCache.clear();
//   }

//   // Callback to update GridView after loading ads
//   static VoidCallback? _onAdLoadedCallback;
//   static void setOnAdLoadedCallback(VoidCallback callback) {
//     _onAdLoadedCallback = callback;
//   }

//   // Ad positions (every 6th)
//   static bool isAdIndex(int index) {
//     return AdConfig.isAdsEnabled && (index + 1) % 6 == 0;
//   }

//   // Real index of fashion without advertising
//   static int getRealModIndex(int index) {
//     int adsBefore = AdConfig.isAdsEnabled ? index ~/ 6 : 0;
//     return index - adsBefore;
//   }

//   // Total number of items (mods + ads)
//   static int getTotalItemCount(int modCount) {
//     if (!AdConfig.isAdsEnabled) return modCount;
//     return modCount + (modCount ~/ 5);
//   }
// }
