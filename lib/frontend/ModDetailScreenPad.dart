import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:morph_mods/backend/AccessKeys.dart';
import 'package:morph_mods/backend/CacheManager.dart';
import 'package:morph_mods/backend/FileManager.dart';
import 'package:morph_mods/backend/FileOpener.dart';
import 'package:morph_mods/extensions/text_extension.dart';
import 'package:morph_mods/frontend/FavoritesScreen.dart';
import 'package:morph_mods/frontend/InstructionScreen.dart';
import 'package:morph_mods/frontend/ModDetailScreen.dart';
import 'package:morph_mods/frontend/ModItemMini.dart';
import 'package:morph_mods/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'ColorsInfo.dart';
import 'ModItemData.dart';
import 'package:morph_mods/extensions/color_extension.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'AppLocale.dart';
import 'package:morph_mods/backend/OpenURL.dart';
import 'package:morph_mods/backend/ModsManager.dart';
import 'package:share_plus/share_plus.dart';
import 'LoadingDialog.dart';
import 'package:morph_mods/backend/AdManager.dart';
import 'package:path/path.dart';

bool hideDescription = false;

final blueGradient = LinearGradient(
    colors: [HexColor.fromHex("#5E53F1"), HexColor.fromHex("#5E53F1")],
    begin: FractionalOffset.centerLeft,
    end: FractionalOffset.centerRight);
final purpleGradient = LinearGradient(
    colors: [HexColor.fromHex("#E822F2"), HexColor.fromHex("#E822F2")],
    begin: FractionalOffset.centerLeft,
    end: FractionalOffset.centerRight);
final yellowGradient = LinearGradient(
    colors: [HexColor.fromHex("#5E53F1"), HexColor.fromHex("#5E53F1")],
    begin: FractionalOffset.topCenter,
    end: FractionalOffset.bottomCenter);
const whiteGradient = LinearGradient(
    colors: [Colors.white, Colors.white],
    begin: FractionalOffset.centerLeft,
    end: FractionalOffset.centerRight);

List<String> paths = List.empty();

class ModDetailScreenPadWidget extends StatefulWidget {
  final ModItemData modItem;
  final ModListScreenState? modListScreen;
  final FavoritesModListScreenState? favoritesListScreen;
  final int modListIndex;

  const ModDetailScreenPadWidget(
      {super.key,
      required this.modItem,
      required this.modListScreen,
      required this.favoritesListScreen,
      required this.modListIndex});

  @override
  ModDetailScreenPad createState() => ModDetailScreenPad(
      modItem: modItem,
      modListScreen: modListScreen,
      favoriteListScreen: favoritesListScreen,
      modList: modListIndex);
}

class ModDetailScreenPad extends State<ModDetailScreenPadWidget> {
  final ModItemData modItem;
  bool installProhibited = false;

  ModListScreenState? modListScreen;
  FavoritesModListScreenState? favoriteListScreen;
  int modList;
  bool cached = false;

  SharedPreferences? prefs;
  List<String>? rewardedWatched;

  ModDetailScreenPad(
      {required this.modItem,
      required this.modListScreen,
      required this.favoriteListScreen,
      required this.modList});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCacheInfo();
    });

    modItem.title = TextExtension.convertUTF8(modItem.title);
    modItem.author = TextExtension.convertUTF8(modItem.author);
    modItem.description = TextExtension.convertUTF8(modItem.description);
  }

  _updateCacheInfo() async {
    bool isCached = await CacheManager.isCacheAvailable(modItem.downloadURL);

    setState(() {
      cached = isCached;
    });
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: ColorsInfo.GetColor(ColorType.Second),
        bottomNavigationBar: AdManager.getBottomBannerBackground(context),
        appBar: AppBar(
          leading: IconButton(
            icon: ColorsInfo.GetBackButton(),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          backgroundColor: ColorsInfo.GetColor(ColorType.Main),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return (modService!.isFavoriteMod(modItem)
                            ? ColorsInfo.ColorToGradient(
                                HexColor.fromHex("#f02424"))
                            : (ColorsInfo.IsDark
                                ? ColorsInfo.ColorToGradient(
                                    HexColor.fromHex("#25292E"))
                                : ColorsInfo.ColorToGradient(
                                    HexColor.fromHex("#8e8e8e"))))
                        .createShader(
                            Rect.fromLTRB(0, 0, rect.width, rect.height));
                  },
                  blendMode: BlendMode.srcATop,
                  child: Image.asset(
                    modService!.isFavoriteMod(modItem)
                        ? 'assets/images/icon_pix_favorite_full.png'
                        : 'assets/images/icon_pix_favorite_unfilled.png',
                    width: 35,
                    height: 35,
                    fit: BoxFit.fill,
                  ),
                ),
                onTap: () async => {
                  if (true)
                    {
                      await modService!.action_favorite(modItem),
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  ModDetailScreenPadWidget(
                            modItem: modItem,
                            modListScreen: modListScreen,
                            favoritesListScreen: favoriteListScreen,
                            modListIndex: modList,
                          ),
                          transitionDuration: Duration
                              .zero, // No animation for forward transition
                          reverseTransitionDuration: const Duration(
                              milliseconds:
                                  150), // Animation duration for reverse transition
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            if (animation.status == AnimationStatus.reverse) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: const Offset(0, 0),
                                ).animate(animation),
                                child: child,
                              );
                            } else {
                              return child; // No animation for forward transition
                            }
                          },
                        ),
                      )
                    }
                },
              ),
            )
          ],
          // title: Text(modItem.title),
        ),
        body: Container(
          color: ColorsInfo.GetColor(ColorType.Second),
          child: Padding(
            padding: const EdgeInsets.only(top: 16, left: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: screenWidth / 2,
                                maxHeight: screenHeight / 2,
                              ),
                              child: Image.network(
                                modItem.imageUrl,
                                headers: {
                                  "CF-Access-Client-Secret":
                                      AccessKeys.client_secret,
                                  "CF-Access-Client-Id": AccessKeys.client_id
                                },
                                width: 1000,
                                height: 459,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              constraints:
                                  BoxConstraints(maxWidth: screenWidth / 2.37),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: (screenWidth / 2.37) - 200,
                                    child: Text(
                                      modItem.title,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Joystix_Bold",
                                          color: ColorsInfo.IsDark
                                              ? Colors.white
                                              : HexColor.fromHex("#353539")),
                                      maxLines: 10,
                                    ),
                                  ),
                                  Container(
                                    // constraints: BoxConstraints(maxWidth: screenWidth / 2.37),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                            'assets/images/file_icon.png',
                                            width: 20,
                                            height: 20),
                                        const SizedBox(width: 6),
                                        Text(
                                          modItem.fileSize,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  HexColor.fromHex("#8E8E8E")),
                                        ),
                                        const SizedBox(
                                            width: 12), // Space between icons
                                        Image.asset(
                                            'assets/images/downloads_icon.png',
                                            width: 20,
                                            height: 20),
                                        const SizedBox(width: 6),
                                        Text(modItem.downloads.toString(),
                                            style: TextStyle(
                                                color:
                                                    HexColor.fromHex("#8E8E8E"),
                                                fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  child: Container(
                                      height: 57,
                                      constraints: BoxConstraints(
                                          maxWidth: screenWidth / 2.77),
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(15)),
                                          gradient: cached
                                              ? ColorsInfo.ColorToGradient(
                                                  HexColor.fromHex("#586067"))
                                              : (modItem.isPremium
                                                  ? yellowGradient
                                                  : (modItem.isRewarded
                                                      ? purpleGradient
                                                      : blueGradient))),
                                      // color: HexColor.fromHex("#353539"),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              cached
                                                  ? AppLocale
                                                      .mod_view_downloaded
                                                      .getString(context)
                                                  : (modItem.isRewarded
                                                      ? AppLocale
                                                          .mod_view_watchads
                                                          .getString(context)
                                                      : AppLocale
                                                          .mod_view_install
                                                          .getString(context)),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontFamily: "Joystix_Bold"),
                                            ),
                                          ],
                                        ),
                                      )),
                                  onTap: () async => {
                                    installProhibited = false,
                                    if (modItem.isPremium)
                                      {
                                        _showLoadingDialog(context),
                                        paths = await FileManager
                                            .downloadAndExtractFile(
                                                modItem.downloadURL),
                                        setState(() {
                                          cached = true;
                                        }),
                                        if (paths.length == 1)
                                          {
                                            await FileOpener.openFileWithApp(
                                                paths[0],
                                                MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                context)
                                          }
                                        else if (paths.length > 1)
                                          {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop(),
                                            await showModalBottomSheet<void>(
                                              backgroundColor:
                                                  ColorsInfo.GetColor(
                                                      ColorType.Second),
                                              context: context,
                                              constraints: const BoxConstraints(
                                                  maxWidth: 540),
                                              builder: (BuildContext context) {
                                                return SingleChildScrollView(
                                                    child: Container(
                                                  height: screenHeight / 2.5,
                                                  color: ColorsInfo.GetColor(
                                                      ColorType.Main),
                                                  child: Center(
                                                    child: ListView(
                                                      // mainAxisAlignment: MainAxisAlignment.center,
                                                      // mainAxisSize: MainAxisSize.min,
                                                      children: <Widget>[
                                                        for (var path in paths)
                                                          Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              child:
                                                                  SingleChildScrollView(
                                                                child:
                                                                    Container(
                                                                  color: ColorsInfo
                                                                      .GetColor(
                                                                          ColorType
                                                                              .Second),
                                                                  height: 50,
                                                                  constraints:
                                                                      const BoxConstraints(
                                                                          maxWidth:
                                                                              540 - 50),
                                                                  // width: (screenWidth / 2) - 50, height: 50,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            5),
                                                                        child:
                                                                            Container(
                                                                          constraints:
                                                                              const BoxConstraints(maxWidth: 540 - 150),
                                                                          child:
                                                                              Text(
                                                                            basename(path),
                                                                            style:
                                                                                TextStyle(fontFamily: 'Joystix', color: ColorsInfo.IsDark ? Colors.white : Colors.black),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            5),
                                                                        child:
                                                                            InkWell(
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                40,
                                                                            color:
                                                                                ColorsInfo.GetColor(ColorType.Main),
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(5),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  AppLocale.mod_view_install.getString(context),
                                                                                  style: TextStyle(fontFamily: 'Joystix', color: ColorsInfo.IsDark ? Colors.white : Colors.black),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap:
                                                                              () async => {
                                                                            await FileOpener.openFileWithApp(
                                                                                path,
                                                                                MediaQuery.of(context).size.width,
                                                                                MediaQuery.of(context).size.height,
                                                                                context)
                                                                          },
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ))
                                                      ],
                                                    ),
                                                  ),
                                                ));
                                              },
                                            ),
                                          }
                                        else
                                          {print("NO PATHS")},
                                        modService!.downloadMod(modItem),
                                        FileManager.downloadedModsAmount += 1,
                                        if (FileManager.downloadedModsAmount ==
                                            2)
                                          {
                                            if (await InAppReview.instance
                                                .isAvailable())
                                              {
                                                InAppReview.instance
                                                    .requestReview()
                                              }
                                          },
                                        if (paths.length == 1)
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop(),
                                      }
                                    else
                                      {
                                        if (modItem.isRewarded)
                                          {
                                            installProhibited = true,
                                            if (await AdManager.manager!
                                                .isRewardedAdReady())
                                              {
                                                AdManager.rewardedListener =
                                                    RewardedListener(),
                                                await AdManager.manager!
                                                    .showRewarded(AdManager
                                                        .rewardedListener!),

                                                await waitWhile(() => AdManager
                                                    .rewardedListener!.adEnded),

                                                if (AdManager.rewardedListener!
                                                    .rewardGranted)
                                                  {
                                                    installProhibited = false,
                                                    prefs =
                                                        await SharedPreferences
                                                            .getInstance(),
                                                    rewardedWatched = prefs!
                                                            .getStringList(
                                                                "rewardedWatched") ??
                                                        List.empty(
                                                            growable: true),
                                                    rewardedWatched!.add(
                                                        modItem.getModID()),
                                                    await prefs!.setStringList(
                                                        "rewardedWatched",
                                                        rewardedWatched!),
                                                    setState(() {
                                                      modItem.isRewarded =
                                                          false;
                                                    }),
                                                    if (modListScreen != null)
                                                      {
                                                        modListScreen!
                                                            .setState(() {
                                                          modService!
                                                              .updateModRewarded(
                                                                  modItem);
                                                        })
                                                      }
                                                    else if (favoriteListScreen !=
                                                        null)
                                                      {
                                                        favoriteListScreen!
                                                            .setState(() {
                                                          modService!
                                                              .updateModRewarded(
                                                                  modItem);
                                                        })
                                                      }
                                                  }

                                                // AdManager.nextTimeInterstitial = DateTime.now().add(const Duration(seconds: 60)),
                                              }
                                            else
                                              {
                                                Future.delayed(
                                                    const Duration(seconds: 1),
                                                    () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop();
                                                }),
                                                if (context.mounted)
                                                  showDialog<void>(
                                                    context: context,
                                                    barrierDismissible:
                                                        false, // user must tap button!
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        content:
                                                            SingleChildScrollView(
                                                          child: Center(
                                                            child: Text(
                                                              AppLocale
                                                                  .mod_view_error_ads
                                                                  .getString(
                                                                      context),
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      "Joystix"),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                              }
                                          }
                                        else
                                          {
                                            if (AdManager
                                                    .nextTimeInterstitial ==
                                                null)
                                              {
                                                if (await AdManager.manager!
                                                    .isInterstitialReady())
                                                  {
                                                    AdManager
                                                            .interstitialListener =
                                                        InterstitialListener(),
                                                    await AdManager.manager!
                                                        .showInterstitial(AdManager
                                                            .interstitialListener!),
                                                    await waitWhile(() =>
                                                        AdManager
                                                            .interstitialListener!
                                                            .adEnded),
                                                    AdManager
                                                            .nextTimeInterstitial =
                                                        DateTime.now().add(
                                                            const Duration(
                                                                seconds: 60)),
                                                  },
                                              }
                                            else
                                              {
                                                if (AdManager
                                                    .nextTimeInterstitial!
                                                    .isBefore(DateTime.now()))
                                                  {
                                                    if (await AdManager.manager!
                                                        .isInterstitialReady())
                                                      {
                                                        AdManager
                                                                .interstitialListener =
                                                            InterstitialListener(),
                                                        await AdManager.manager!
                                                            .showInterstitial(
                                                                AdManager
                                                                    .interstitialListener!),
                                                        await waitWhile(() =>
                                                            AdManager
                                                                .interstitialListener!
                                                                .adEnded),
                                                        AdManager
                                                                .nextTimeInterstitial =
                                                            DateTime.now().add(
                                                                const Duration(
                                                                    seconds:
                                                                        60)),
                                                      },
                                                  }
                                              }
                                          },
                                        if (installProhibited == false)
                                          {
                                            _showLoadingDialog(context),
                                            paths = await FileManager
                                                .downloadAndExtractFile(
                                                    modItem.downloadURL),
                                            setState(() {
                                              cached = true;
                                            }),
                                            if (paths.length == 1)
                                              {
                                                await FileOpener
                                                    .openFileWithApp(
                                                        paths[0],
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height,
                                                        context)
                                              }
                                            else if (paths.length > 1)
                                              {
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop(),
                                                await showModalBottomSheet<
                                                    void>(
                                                  backgroundColor:
                                                      ColorsInfo.GetColor(
                                                          ColorType.Second),
                                                  context: context,
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 540),
                                                  builder:
                                                      (BuildContext context) {
                                                    return SizedBox(
                                                      height: 420,
                                                      child: Column(
                                                        children: [
                                                          SingleChildScrollView(
                                                              child: Container(
                                                            height:
                                                                screenHeight /
                                                                    2.5,
                                                            color: ColorsInfo
                                                                .GetColor(
                                                                    ColorType
                                                                        .Main),
                                                            child: Center(
                                                              child: ListView(
                                                                // mainAxisAlignment: MainAxisAlignment.center,
                                                                // mainAxisSize: MainAxisSize.min,
                                                                children: <Widget>[
                                                                  for (var path
                                                                      in paths)
                                                                    Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            10),
                                                                        child:
                                                                            SingleChildScrollView(
                                                                          child:
                                                                              Container(
                                                                            color:
                                                                                ColorsInfo.GetColor(ColorType.Second),
                                                                            height:
                                                                                50,
                                                                            constraints:
                                                                                const BoxConstraints(maxWidth: 540 - 50),
                                                                            // width: (screenWidth / 2) - 50, height: 50,
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.all(5),
                                                                                  child: Container(
                                                                                    constraints: const BoxConstraints(maxWidth: 540 - 150),
                                                                                    child: Text(
                                                                                      basename(path),
                                                                                      style: TextStyle(fontFamily: 'Joystix', color: ColorsInfo.IsDark ? Colors.white : Colors.black),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 10,
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.all(5),
                                                                                  child: InkWell(
                                                                                    child: Container(
                                                                                      height: 40,
                                                                                      color: ColorsInfo.GetColor(ColorType.Main),
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.all(5),
                                                                                        child: Center(
                                                                                          child: Text(
                                                                                            AppLocale.mod_view_install.getString(context),
                                                                                            style: TextStyle(fontFamily: 'Joystix', color: ColorsInfo.IsDark ? Colors.white : Colors.black),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    onTap: () async => {
                                                                                      await FileOpener.openFileWithApp(path, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height, context)
                                                                                    },
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ))
                                                                ],
                                                              ),
                                                            ),
                                                          )),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              }
                                            else
                                              {print("NO PATHS")},
                                            modService!.downloadMod(modItem),
                                            FileManager.downloadedModsAmount +=
                                                1,
                                            if (FileManager
                                                    .downloadedModsAmount ==
                                                2)
                                              {
                                                if (await InAppReview.instance
                                                    .isAvailable())
                                                  {
                                                    InAppReview.instance
                                                        .requestReview()
                                                  }
                                              },
                                            if (paths.length == 1)
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop(),
                                          }
                                      }
                                  },
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  child: Container(
                                      height: 57,
                                      width: 60,
                                      // constraints: BoxConstraints(maxWidth: 500),
                                      decoration: BoxDecoration(
                                        gradient: ColorsInfo.ColorToGradient(
                                            HexColor.fromHex("#586067")),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      // color: HexColor.fromHex("#353539"),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            cached
                                                ? Image.asset(
                                                    'assets/images/icon_delete.png',
                                                    width: 40,
                                                    height: 40)
                                                : Text(
                                                    "?",
                                                    style: TextStyle(
                                                        color: HexColor.fromHex(
                                                            "#8D8D8D"),
                                                        fontSize: 25),
                                                  ),
                                          ],
                                        ),
                                      )),
                                  onTap: () async => {
                                    if (cached)
                                      {
                                        await CacheManager.deleteCachedFiles(
                                            modItem.downloadURL),
                                        if (modListScreen != null)
                                          {
                                            modListScreen!.setState(() {
                                              modService!
                                                  .updateModCached(modItem);
                                            })
                                          },
                                        setState(() {
                                          cached = false;
                                        })
                                      }
                                    else
                                      {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const InstructionScreen(),
                                          ),
                                        )
                                      }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              constraints:
                                  BoxConstraints(maxWidth: screenWidth / 2.37),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${AppLocale.mod_view_description.getString(context)}:",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: ColorsInfo.IsDark
                                            ? Colors.white
                                            : HexColor.fromHex("#353539")),
                                  ),
                                ],
                              ),
                            ),
                            hideDescription
                                ? const SizedBox()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                            maxWidth: screenWidth / 2.37),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            hideDescription
                                                ? ''
                                                : (modItem.description == '-'
                                                    ? ('Mod ${modItem.title} from ${modItem.author} for Melon Sandbox game')
                                                    : modItem.description),
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: ColorsInfo.IsDark
                                                    ? HexColor.fromHex(
                                                        "#8D8D8D")
                                                    : HexColor.fromHex(
                                                        "#353539")),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    AppLocale.mod_view_recommend.getString(context),
                    style: TextStyle(
                        fontSize: 15,
                        color: ColorsInfo.IsDark
                            ? Colors.white
                            : HexColor.fromHex("#353539")),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    color: ColorsInfo.GetColor(ColorType.Second),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (int i = 0;
                                i <
                                    (MediaQuery.of(context).size.width /
                                        (150 * 1.4));
                                i++)
                              getMiniMod(
                                  modService!.mods[modList][random.nextInt(
                                      modService!.mods[modList].length)],
                                  modListScreen,
                                  favoriteListScreen,
                                  context),
                            const SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LoadingDialog();
      },
    );
  }

  Widget getMiniMod(ModItemData modItem, ModListScreenState? modListState,
      FavoritesModListScreenState? favListState, BuildContext context) {
    return SizedBox(
      width: 150 * 1.2,
      height: 150 * 1.2,
      child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MediaQuery.of(context).size.width > 700
                    ? ModDetailScreenPadWidget(
                        modItem: modItem,
                        modListScreen: modListState,
                        favoritesListScreen: favListState,
                        modListIndex: modList,
                      )
                    : ModDetailScreenWidget(
                        modItem: modItem,
                        modListScreen: modListState,
                        favoritesListScreen: favListState,
                        modListIndex: modList,
                      ),
              ),
            );
          },
          child: VisibilityDetector(
            key: Key(modItem.imageUrl + modItem.isFirestoreChecked.toString()),
            onVisibilityChanged: (visibility) async {},
            child: ModItemMini(modItemData: modItem),
          )),
    );
  }
}
