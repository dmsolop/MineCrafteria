import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:morph_mods/backend/AccessKeys.dart';
import 'package:morph_mods/backend/AdManager.dart';
import 'package:morph_mods/backend/CacheManager.dart';
import 'package:morph_mods/backend/FileManager.dart';
import 'package:morph_mods/backend/FileOpener.dart';
import 'package:morph_mods/extensions/text_extension.dart';
import 'package:morph_mods/frontend/FavoritesScreen.dart';
import 'package:morph_mods/frontend/InstructionScreen.dart';
import 'package:morph_mods/frontend/ModDetailScreenPad.dart';
import 'package:morph_mods/frontend/ModItem.dart';
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
import 'package:path/path.dart' as p;
import '../backend/native_ads/SingleNativeAdLoader.dart';

bool hideDescription = false;

final blueGradient = LinearGradient(colors: [HexColor.fromHex("#E5A272"), HexColor.fromHex("#E5A272")], begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight);
final purpleGradient = LinearGradient(colors: [HexColor.fromHex("#E822F2"), HexColor.fromHex("#E822F2")], begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight);
final yellowGradient = LinearGradient(colors: [HexColor.fromHex("#5E53F1"), HexColor.fromHex("#5E53F1")], begin: FractionalOffset.topCenter, end: FractionalOffset.bottomCenter);
const whiteGradient = LinearGradient(colors: [Colors.white, Colors.white], begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight);

List<String> paths = List.empty();

class ModDetailScreenWidget extends StatefulWidget {
  final ModItemData modItem;
  final ModListScreenState? modListScreen;
  final FavoritesModListScreenState? favoritesListScreen;
  final int modListIndex;

  const ModDetailScreenWidget({super.key, required this.modItem, required this.modListScreen, required this.favoritesListScreen, required this.modListIndex});

  @override
  ModDetailScreen createState() => ModDetailScreen(modItem: modItem, modListScreen: modListScreen, favoriteListScreen: favoritesListScreen, modList: modListIndex);
}

class ModDetailScreen extends State<ModDetailScreenWidget> {
  ModItemData modItem;
  ModListScreenState? modListScreen;
  FavoritesModListScreenState? favoriteListScreen;
  int modList;
  bool cached = false;

  bool installProhibited = false;

  SharedPreferences? prefs;
  List<String>? rewardedWatched;
  // NativeAdWidget
  Widget? _nativeAdWidget;

  ModDetailScreen({required this.modItem, required this.modListScreen, required this.favoriteListScreen, required this.modList});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCacheInfo();
      // NativeAdWidget
      _initNativeAd();
    });

    modItem.title = TextExtension.convertUTF8(modItem.title);
    modItem.author = TextExtension.convertUTF8(modItem.author);
    modItem.description = TextExtension.convertUTF8(modItem.description);
  }

  // NativeAdWidget initialization
  Future<void> _initNativeAd() async {
    if (!mounted) return;
    final ad = await SingleNativeAdLoader().loadAd(context, height: 260);
    if (!mounted) return;
    setState(() {
      _nativeAdWidget = ad;
    });
  }

  _updateCacheInfo() async {
    bool isCached = await CacheManager.isCacheAvailable(modItem.downloadURL);

    setState(() {
      cached = isCached;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final random = Random();

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
                    return (modService!.isFavoriteMod(modItem) ? ColorsInfo.ColorToGradient(HexColor.fromHex("#FFFFFF")) : (ColorsInfo.IsDark ? ColorsInfo.ColorToGradient(HexColor.fromHex("#25292E")) : ColorsInfo.ColorToGradient(HexColor.fromHex("#8e8e8e"))))
                        .createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                  },
                  blendMode: BlendMode.srcATop,
                  child: Image.asset(
                    modService!.isFavoriteMod(modItem) ? 'assets/images/icon_pix_favorite_full.png' : 'assets/images/icon_pix_favorite_unfilled.png',
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
                          pageBuilder: (context, animation, secondaryAnimation) => ModDetailScreenWidget(
                            modItem: modItem,
                            modListScreen: modListScreen,
                            favoritesListScreen: favoriteListScreen,
                            modListIndex: modList,
                          ),
                          transitionDuration: Duration.zero, // No animation for forward transition
                          reverseTransitionDuration: const Duration(milliseconds: 150), // Animation duration for reverse transition
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 349, maxHeight: 243),
                  child: Image.network(
                    modItem.imageUrl,
                    headers: {"CF-Access-Client-Secret": AccessKeys.client_secret, "CF-Access-Client-Id": AccessKeys.client_id},
                    fit: BoxFit.fill,
                    width: 349,
                    height: 243,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: screenWidth - 200,
                      // fit: BoxFit.fitWidth,
                      child: Text(
                        modItem.title,
                        // overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ColorsInfo.IsDark ? Colors.white : HexColor.fromHex("#353539"), fontFamily: "Joystix_Bold"),
                        maxLines: 10,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset('assets/images/file_icon.png', width: 20, height: 20),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          modItem.fileSize,
                          style: TextStyle(fontSize: 13, color: HexColor.fromHex("#8E8E8E")),
                        ),
                        const SizedBox(width: 14), // Space between icons
                        Image.asset('assets/images/downloads_icon.png', width: 20, height: 20),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(modItem.downloads.toString(), style: TextStyle(color: HexColor.fromHex("#8E8E8E"), fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      child: Container(
                          height: 57,
                          width: screenWidth - 110,
                          // constraints: BoxConstraints(maxWidth: 500),
                          decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(15)), gradient: cached ? ColorsInfo.ColorToGradient(HexColor.fromHex("#586067")) : (modItem.isRewarded ? purpleGradient : yellowGradient)),
                          // color: HexColor.fromHex("#353539"),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  cached ? AppLocale.mod_view_downloaded.getString(context) : (modItem.isRewarded ? AppLocale.mod_view_watchads.getString(context) : AppLocale.mod_view_install.getString(context)),
                                  style: TextStyle(color: cached ? HexColor.fromHex("#8D8D8D") : Colors.white, fontSize: 16, fontFamily: "Joystix_Bold"),
                                ),
                              ],
                            ),
                          )),
                      onTap: () async => {
                        if (modItem.isPremium)
                          {
                            if (!true)
                              {}
                            else
                              {
                                _showLoadingDialog(context),
                                paths = await FileManager.downloadAndExtractFile(modItem.downloadURL),
                                setState(() {
                                  cached = true;
                                }),
                                if (paths.length == 1)
                                  {
                                    await FileOpener.openFileWithApp(paths[0], screenWidth, screenHeight, context),
                                    // await Share.shareXFiles([XFile(paths[0])])
                                  }
                                else
                                  {
                                    if (context.mounted)
                                      {
                                        Navigator.of(context, rootNavigator: true).pop(),
                                        await showModalBottomSheet<void>(
                                          context: context,
                                          backgroundColor: ColorsInfo.GetColor(ColorType.Second),
                                          builder: (BuildContext context) {
                                            return SingleChildScrollView(
                                                child: Container(
                                              height: screenHeight / 3,
                                              color: ColorsInfo.GetColor(ColorType.Main),
                                              child: Center(
                                                child: ListView(
                                                  // mainAxisAlignment: MainAxisAlignment.center,
                                                  // mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    for (var path in paths)
                                                      Padding(
                                                          padding: const EdgeInsets.all(10),
                                                          child: SingleChildScrollView(
                                                            child: Container(
                                                              color: ColorsInfo.GetColor(ColorType.Second),
                                                              width: screenWidth - 50,
                                                              height: 50,
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(5),
                                                                    child: SizedBox(
                                                                      width: screenWidth - 200,
                                                                      child: Text(
                                                                        p.basename(path),
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
                                                                        // await Share.shareXFiles([XFile(path)])
                                                                        await FileOpener.openFileWithApp(path, screenWidth, screenHeight, context),
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
                                  },
                                modService!.downloadMod(modItem),
                                FileManager.downloadedModsAmount += 1,
                                if (FileManager.downloadedModsAmount == 2)
                                  {
                                    if (await InAppReview.instance.isAvailable()) {InAppReview.instance.requestReview()}
                                  },
                                if (paths.length == 1)
                                  {
                                    Navigator.of(context, rootNavigator: true).pop(),
                                  }
                              }
                          }
                        else
                          {
                            installProhibited = false,
                            if (true)
                              {
                                if (modItem.isRewarded)
                                  {
                                    installProhibited = true,
                                    if (await AdManager.manager!.isRewardedAdReady())
                                      {
                                        AdManager.rewardedListener = RewardedListener(),
                                        await AdManager.manager!.showRewarded(AdManager.rewardedListener!),

                                        await waitWhile(() => AdManager.rewardedListener!.adEnded),

                                        if (AdManager.rewardedListener!.rewardGranted)
                                          {
                                            installProhibited = false,
                                            prefs = await SharedPreferences.getInstance(),
                                            rewardedWatched = prefs!.getStringList("rewardedWatched") ?? List.empty(growable: true),
                                            rewardedWatched!.add(modItem.getModID()),
                                            await prefs!.setStringList("rewardedWatched", rewardedWatched!),
                                            setState(() {
                                              modItem.isRewarded = false;
                                            }),
                                            if (modListScreen != null)
                                              {
                                                modListScreen!.setState(() {
                                                  modService!.updateModRewarded(modItem);
                                                })
                                              }
                                            else if (favoriteListScreen != null)
                                              {
                                                favoriteListScreen!.setState(() {
                                                  modService!.updateModRewarded(modItem);
                                                })
                                              }
                                          }

                                        // AdManager.nextTimeInterstitial = DateTime.now().add(const Duration(seconds: 60)),
                                      }
                                    else
                                      {
                                        Future.delayed(const Duration(seconds: 1), () {
                                          Navigator.of(context, rootNavigator: true).pop();
                                        }),
                                        if (context.mounted)
                                          showDialog<void>(
                                            context: context,
                                            barrierDismissible: false, // user must tap button!
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                content: SingleChildScrollView(
                                                  child: Center(
                                                    child: Text(
                                                      AppLocale.mod_view_error_ads.getString(context),
                                                      style: const TextStyle(fontFamily: "Joystix"),
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
                                    if (AdManager.nextTimeInterstitial == null)
                                      {
                                        if (await AdManager.manager!.isInterstitialReady())
                                          {
                                            AdManager.interstitialListener = InterstitialListener(),
                                            await AdManager.manager!.showInterstitial(AdManager.interstitialListener!),
                                            await waitWhile(() => AdManager.interstitialListener!.adEnded),
                                            AdManager.nextTimeInterstitial = DateTime.now().add(const Duration(seconds: 60)),
                                          },
                                      }
                                    else
                                      {
                                        if (AdManager.nextTimeInterstitial!.isBefore(DateTime.now()))
                                          {
                                            if (await AdManager.manager!.isInterstitialReady())
                                              {
                                                AdManager.interstitialListener = InterstitialListener(),
                                                await AdManager.manager!.showInterstitial(AdManager.interstitialListener!),
                                                await waitWhile(() => AdManager.interstitialListener!.adEnded),
                                                AdManager.nextTimeInterstitial = DateTime.now().add(const Duration(seconds: 60)),
                                              },
                                          }
                                      }
                                  }
                              },
                            if (!installProhibited)
                              {
                                if (context.mounted) _showLoadingDialog(context),
                                paths = await FileManager.downloadAndExtractFile(modItem.downloadURL),
                                setState(() {
                                  cached = true;
                                }),
                                await FileOpener.openFileWithApp(paths[0], screenWidth, screenHeight, context),
                                modService!.downloadMod(modItem),
                                FileManager.downloadedModsAmount += 1,
                                if (FileManager.downloadedModsAmount == 2)
                                  {
                                    if (await InAppReview.instance.isAvailable()) {InAppReview.instance.requestReview()}
                                  },
                                if (paths.length == 1)
                                  {
                                    if (context.mounted) Navigator.of(context, rootNavigator: true).pop(),
                                  }
                              },
                          }
                      },
                    ),
                    // const SizedBox(
                    //   width: 10,
                    // ),
                    // InkWell(
                    //   child: Container(
                    //       height: 57,
                    //       width: 60,
                    //       // constraints: BoxConstraints(maxWidth: 500),
                    //       decoration: BoxDecoration(
                    //         gradient: ColorsInfo.ColorToGradient(
                    //             HexColor.fromHex("#586067")),
                    //         borderRadius:
                    //             const BorderRadius.all(Radius.circular(15)),
                    //       ),
                    //       // color: HexColor.fromHex("#353539"),
                    //       child: Center(
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             cached
                    //                 ? Image.asset(
                    //                     'assets/images/icon_delete.png',
                    //                     width: 40,
                    //                     height: 40)
                    //                 : Text(
                    //                     "?",
                    //                     style: TextStyle(
                    //                         color: HexColor.fromHex("#8D8D8D"),
                    //                         fontSize: 25),
                    //                   ),
                    //           ],
                    //         ),
                    //       )),
                    //   onTap: () async => {
                    //     if (cached)
                    //       {
                    //         await CacheManager.deleteCachedFiles(
                    //             modItem.downloadURL),
                    //         if (modListScreen != null)
                    //           {
                    //             modListScreen!.setState(() {
                    //               modService!.updateModCached(modItem);
                    //             })
                    //           },
                    //         setState(() {
                    //           cached = false;
                    //         })
                    //       }
                    //     else
                    //       {
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => const InstructionScreen(),
                    //           ),
                    //         )
                    //       }
                    //   },
                    // ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${AppLocale.mod_view_description.getString(context)}:",
                      style: TextStyle(fontSize: 15, color: ColorsInfo.IsDark ? Colors.white : HexColor.fromHex("#353539")),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                hideDescription
                    ? const SizedBox()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hideDescription ? '' : (modItem.description == '-' ? ('Mod ${modItem.title} from ${modItem.author} for Melon Sandbox game') : modItem.description),
                            style: TextStyle(fontSize: 12, color: ColorsInfo.IsDark ? HexColor.fromHex("#8D8D8D") : HexColor.fromHex("#353539")),
                          ),
                        ],
                      ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  AppLocale.mod_view_recommend.getString(context),
                  style: TextStyle(fontSize: 15, color: ColorsInfo.IsDark ? Colors.white : HexColor.fromHex("#353539")),
                ),
                // NativeAdWidget
                if (_nativeAdWidget != null) ...[
                  const SizedBox(height: 10),
                  _nativeAdWidget!,
                  const SizedBox(height: 10),
                ],

                const SizedBox(
                  height: 5,
                ),
                Container(
                  color: ColorsInfo.GetColor(ColorType.Second),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          getMiniMod(modService!.mods[modList][random.nextInt(modService!.mods[modList].length)], modListScreen, favoriteListScreen, context),
                          getMiniMod(modService!.mods[modList][random.nextInt(modService!.mods[modList].length)], modListScreen, favoriteListScreen, context),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          getMiniMod(modService!.mods[modList][random.nextInt(modService!.mods[modList].length)], modListScreen, favoriteListScreen, context),
                          getMiniMod(modService!.mods[modList][random.nextInt(modService!.mods[modList].length)], modListScreen, favoriteListScreen, context),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          getMiniMod(modService!.mods[modList][random.nextInt(modService!.mods[modList].length)], modListScreen, favoriteListScreen, context),
                          getMiniMod(modService!.mods[modList][random.nextInt(modService!.mods[modList].length)], modListScreen, favoriteListScreen, context),
                        ],
                      ),
                    ],
                  ),
                )
              ],
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

  Widget getMiniMod(ModItemData modItem, ModListScreenState? modListState, FavoritesModListScreenState? favListState, BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2.18,
      height: 189,
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
