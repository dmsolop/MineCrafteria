import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../AccessKeys.dart';

class AdMobOnlyManager {
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static BannerAd? bannerAd;

  static Future<void> initialize() async {
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: AccessKeys.testDeviceIds),
    );
    await MobileAds.instance.initialize();

    _loadInterstitial();
    _loadRewarded();
  }

  static void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AccessKeys.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) {
          debugPrint('[AdMob] Failed to load Interstitial: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  static void _loadRewarded() {
    RewardedAd.load(
      adUnitId: AccessKeys.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) {
          debugPrint('[AdMob] Failed to load Rewarded: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  static void showInterstitial() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _loadInterstitial(); // reload for next time
    }
  }

  static void showRewarded(VoidCallback onRewarded) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (_, __) => onRewarded(),
      );
      _rewardedAd = null;
      _loadRewarded(); // reload for next time
    }
  }

  static BannerAd createBanner({
    required AdSize size,
    required void Function(Ad) onLoaded,
    required void Function(Ad, LoadAdError) onFailed,
  }) {
    bannerAd = BannerAd(
      adUnitId: AccessKeys.bannerAdUnitId ?? AccessKeys.adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: onFailed,
      ),
    )..load();

    return bannerAd!;
  }

  static void disposeBanner() {
    bannerAd?.dispose();
    bannerAd = null;
  }
}
