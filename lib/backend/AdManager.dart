import 'dart:async';
import 'dart:io';
import 'package:clever_ads_solutions/clever_ads_solutions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:morph_mods/frontend/ColorsInfo.dart';

class AdConfig {
  static bool isAdsEnabled = true;
}

class AdManager {
  static MediationManager? manager;
  static InterstitialListener? interstitialListener;
  static RewardedListener? rewardedListener;

  static bool hideBanner = false;
  static bool isAdPresented = false;

  static DateTime? nextTimeInterstitial;

  static void initialize() async {
    // Set your Flutter version
    CAS.settings.setTaggedAudience(Audience.notChildren);

    manager = CAS
        .buildManager()
        // Set your CAS ID
        .withCasId(Platform.isIOS ? "demo" : "demo")
        .withConsentFlow(CAS.buildConsentFlow())
        // List Ad formats used in app
        .withAdTypes(AdTypeFlags.Banner |
            AdTypeFlags.Interstitial |
            AdTypeFlags.Rewarded)
        // Use Test ads or live ads
        .withTestMode(true)
        .initialize();
  }

  static Widget getBottomBanner(BuildContext context) {
    if (AdManager.hideBanner) {
      return const SizedBox(
        width: 0,
        height: 0,
      );
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SafeArea(
          bottom: true,
          left: false,
          right: false,
          top: false,
          child: Container(
            child: SizedBox(
              height: 60,
              child: BannerWidget(
                key: const Key('banner'),
                size: AdSize.banner,
                isAutoloadEnabled: true,
                refreshInterval: 20,
                listener: BannerListener(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget getBottomBannerBackground(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 65 + MediaQuery.of(context).padding.bottom,
          color: ColorsInfo.GetColor(ColorType.Main),
        ),
      ],
    );
  }
}

Future waitWhile(bool Function() test,
    [Duration pollInterval = Duration.zero]) {
  var completer = Completer();
  check() {
    if (test()) {
      completer.complete();
    } else {
      Timer(pollInterval, check);
    }
  }

  check();
  return completer.future;
}

class InterstitialListener extends AdCallback {
  bool adEnded = false;

  @override
  void onClicked() {
    // Called when ad is clicked
  }

  @override
  void onClosed() {
    // Called when ad is dismissed
    adEnded = true;
  }

  @override
  void onComplete() {
    // Called when ad is completed
    adEnded = true;
  }

  @override
  void onImpression(AdImpression? adImpression) {
    // Called when ad is paid.
  }

  @override
  void onShowFailed(String? message) {
    // Called when ad fails to show.
    adEnded = true;
  }

  @override
  void onShown() {
    // Called when ad is shown.
  }
}

class RewardedListener extends AdCallback {
  bool adEnded = false;
  bool rewardGranted = false;

  @override
  void onClicked() {
    // Called when ad is clicked
  }

  @override
  void onClosed() {
    // Called when ad is dismissed
    adEnded = true;
  }

  @override
  void onComplete() {
    // Called when ad is completed
    adEnded = true;
    rewardGranted = true;
  }

  @override
  void onImpression(AdImpression? adImpression) {
    // Called when ad is paid.
  }

  @override
  void onShowFailed(String? message) {
    // Called when ad fails to show.
    adEnded = true;
  }

  @override
  void onShown() {
    // Called when ad is shown.
  }
}

class BannerListener extends AdViewListener {
  BannerListener();

  @override
  void onAdViewPresented() {
    AdManager.isAdPresented = true;
    // debugPrint("Banner ${this.size.toString()} ad was presented!");
  }

  @override
  void onClicked() {
    // debugPrint("Banner ${this.size.toString()} ad was pressed!");
  }

  @override
  void onFailed(String? message) {
    AdManager.isAdPresented = false;
    // debugPrint("Banner ${this.size.toString()} error! $message");
  }

  @override
  void onImpression(AdImpression? adImpression) {
    // debugPrint("Banner ${this.size.toString()} impression: $adImpression");
  }

  @override
  void onLoaded() {
    // debugPrint("Banner ${this.size.toString()} ad was loaded!");
  }
}
