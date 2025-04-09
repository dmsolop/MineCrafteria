import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:morph_mods/backend/AdManager.dart';
import 'package:morph_mods/backend/CacheManager.dart';
import 'package:morph_mods/backend/FileManager.dart';
import 'package:morph_mods/backend/FileOpener.dart';
import 'package:morph_mods/extensions/text_extension.dart';
import 'package:morph_mods/frontend/FavoritesScreen.dart';

import 'package:morph_mods/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ColorsInfo.dart';
import 'ModItem.dart';
import 'ModItemData.dart';
import 'package:morph_mods/extensions/color_extension.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'AppLocale.dart';
import 'LoadingDialog.dart';
import 'package:path/path.dart' as p;
import '../backend/native_ads/SingleNativeAdLoader.dart';
import '../frontend/widgets/ModScreenshotGallery.dart';
import '../backend/LogService.dart';
import '../frontend/widgets/MiniModList.dart';
import '../frontend/widgets/NativeAdSlot.dart';
import 'package:morph_mods/frontend/widgets/NativeAdOverlayLoader.dart';
import '../frontend/ModItem.dart';
import '../frontend/ModItemData.dart';

bool hideDescription = false;

enum ModDetailPhase {
  description,
  instruction,
  pageDownload,
  pageLoaded,
  pageFinal,
}

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
  ModDetailPhase _phase = ModDetailPhase.description;
  ModItemData modItem;
  ModListScreenState? modListScreen;
  FavoritesModListScreenState? favoriteListScreen;
  int modList;
  bool cached = false;

  bool installProhibited = false;
  SharedPreferences? prefs;
  List<String>? rewardedWatched;
  late List<ModItemData> recommendedMods;

  OverlayEntry? _adOverlay;
  bool _overlayRemoved = false;
  bool _waitingForPhaseSwitch = false;
  Future<bool>? _adReadyFuture;

  ModDetailScreen({required this.modItem, required this.modListScreen, required this.favoriteListScreen, required this.modList});

  @override
  void initState() {
    super.initState();
    LogService.log('[ModDetailScreen] initState() — _phase=$_phase');

    _adReadyFuture = _waitForAdLoaded('description');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCacheInfo();
      LogService.log('[ModDetailScreen] PostFrame — updating cache info');
    });

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _showAdOverlay();
    // });

    SingleNativeAdLoader().preloadAd().then((_) {
      if (mounted) setState(() {});
    });

    modItem.title = TextExtension.convertUTF8(modItem.title);
    modItem.author = TextExtension.convertUTF8(modItem.author);
    modItem.description = TextExtension.convertUTF8(modItem.description);
  }

  Future<bool> _waitForAdLoaded(String keyId, {Duration timeout = const Duration(seconds: 5)}) async {
    final loader = SingleNativeAdLoader();
    await loader.preloadAd();

    final completer = Completer<bool>();
    final start = DateTime.now();

    void check() {
      if (loader.isAdReady(keyId)) {
        completer.complete(true);
      } else if (DateTime.now().difference(start) > timeout) {
        completer.complete(false);
      } else {
        Future.delayed(const Duration(milliseconds: 100), check);
      }
    }

    check();
    return completer.future;
  }

  @override
  void dispose() {
    super.dispose();
    SingleNativeAdLoader().disposeAllAds();
  }

  _updateCacheInfo() async {
    bool isCached = await CacheManager.isCacheAvailable(modItem.downloadURL);

    if (cached != isCached) {
      if (mounted) {
        setState(() {
          cached = isCached;
        });
      }
    }
  }

  void _nextPhase() async {
    _waitingForPhaseSwitch = true;
    await _showInterstitialIfAvailable();
    setState(() {
      _overlayRemoved = false;
      _waitingForPhaseSwitch = false;

      switch (_phase) {
        case ModDetailPhase.description:
          _phase = ModDetailPhase.instruction;
          break;
        case ModDetailPhase.instruction:
          _phase = ModDetailPhase.pageDownload;
          break;
        case ModDetailPhase.pageDownload:
          _phase = ModDetailPhase.pageLoaded;
          break;
        case ModDetailPhase.pageLoaded:
          _phase = ModDetailPhase.pageFinal;
          break;
        case ModDetailPhase.pageFinal:
          break;
      }
    });
  }

  Future<void> _showInterstitialIfAvailable() async {
    if (AdConfig.isAdsEnabled && await AdManager.manager!.isInterstitialReady()) {
      AdManager.interstitialListener = InterstitialListener();
      await AdManager.manager!.showInterstitial(AdManager.interstitialListener!);
      await waitWhile(() => AdManager.interstitialListener!.adEnded);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_waitingForPhaseSwitch) {
      return const Scaffold(
        backgroundColor: Colors.black54,
        body: NativeAdOverlayLoader(), // 👈 допустимо лише якщо це просто Widget, а не OverlayEntry
      );
    }
    return FutureBuilder<bool>(
      future: _adReadyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: NativeAdOverlayLoader()),
          );
        }
        return _buildScaffold(context); // 👈 Виносимо оригінальний Scaffold у метод
      },
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorsInfo.GetColor(ColorType.Second),
        bottomNavigationBar: AdManager.getBottomBannerBackground(context),
        appBar: AppBar(
          leading: IconButton(
            icon: ColorsInfo.GetBackButton(),
            onPressed: () {
              if (_phase == ModDetailPhase.description || _phase == ModDetailPhase.pageFinal) {
                Navigator.of(context).pop(); // назад до списку модів
              } else {
                setState(() {
                  _overlayRemoved = false;
                  // SingleNativeAdLoader().disposeAllAds(); // або NativeAdManager
                  _phase = ModDetailPhase.values[_phase.index - 1]; // попередня фаза
                  _showInterstitialIfAvailable();
                });
              }
            },
            // onPressed: () => Navigator.of(context).pop(),
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
            child: _buildBodyByPhase(),
          ),
        ));
  }

  Widget _buildBodyByPhase() {
    LogService.log('[ModDetailScreen] Building phase: $_phase');
    switch (_phase) {
      case ModDetailPhase.description:
        LogService.log('[ModDetailScreen] Rendering NativeAdSlot → keyId=description');
        return ListView(
          children: [
            _buildModHeaderSection(),
            const SizedBox(height: 20),
            _buildModDescription(),
            const SizedBox(height: 20),
            // const NativeAdSlot(height: 260, index: 0),
            NativeAdSlot(
                height: 240,
                keyId: 'description',
                onEnterViewport: () {
                  _showAdOverlay();
                },
                onLoaded: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    LogService.log('[ModDetailScreen] 🔚 Ad loaded for keyId=description → removing overlay');
                    if (mounted) {
                      setState(() {
                        _hideAdOverlay();
                      });
                    }
                  });
                }),
            const SizedBox(height: 20),
            _buildInstallButton(),
          ],
        );
      case ModDetailPhase.instruction:
        LogService.log('[ModDetailScreen] Rendering NativeAdSlot → keyId=instruction');
        return ListView(
          children: [
            _buildInstruction(),
            const SizedBox(height: 20),
            // const NativeAdSlot(height: 260, index: 1),
            NativeAdSlot(
                height: 240,
                keyId: 'instruction',
                onEnterViewport: () {
                  _showAdOverlay();
                },
                onLoaded: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    LogService.log('[ModDetailScreen] 🔚 Ad loaded for keyId=instruction → removing overlay');
                    if (mounted) {
                      setState(() {
                        _hideAdOverlay();
                      });
                    }
                  });
                }),
            const SizedBox(height: 20),
            _buildInstallButton(),
          ],
        );
      case ModDetailPhase.pageDownload:
        LogService.log('[ModDetailScreen] Rendering NativeAdSlot → keyId=pageDownload');
        return ListView(
          children: [
            _buildModHeaderSection(),
            const SizedBox(height: 20),
            _buildMinimodGrid(),
            const SizedBox(height: 20),
            // const NativeAdSlot(height: 260, index: 2),
            NativeAdSlot(
                height: 240,
                keyId: 'pageDownload',
                onEnterViewport: () {
                  _showAdOverlay();
                },
                onLoaded: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    LogService.log('[ModDetailScreen] 🔚 Ad loaded for keyId=pageDownload → removing overlay');
                    if (mounted) {
                      setState(() {
                        _hideAdOverlay();
                      });
                    }
                  });
                }),
            const SizedBox(height: 20),
            _buildInstallButton(),
          ],
        );
      case ModDetailPhase.pageLoaded:
        LogService.log('[ModDetailScreen] Rendering NativeAdSlot → keyId=pageLoaded');
        return ListView(
          children: [
            _buildModHeaderSection(),
            const SizedBox(height: 20),
            _buildMinimodGrid(),
            const SizedBox(height: 20),
            // const NativeAdSlot(height: 260, index: 3),
            NativeAdSlot(
                height: 240,
                keyId: 'pageLoaded',
                onEnterViewport: () {
                  _showAdOverlay();
                },
                onLoaded: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    LogService.log('[ModDetailScreen] 🔚 Ad loaded for keyId=pageLoaded → removing overlay');
                    if (mounted) {
                      setState(() {
                        _hideAdOverlay();
                      });
                    }
                  });
                }),
            const SizedBox(height: 20),
            _buildInstallButton(),
          ],
        );
      case ModDetailPhase.pageFinal:
        LogService.log('[ModDetailScreen] Rendering NativeAdSlot → keyId=pageFinal');
        return ListView(
          children: [
            _buildModHeaderSection(),
            const SizedBox(height: 20),
            _buildMinimodGrid(),
            const SizedBox(height: 20),
            NativeAdSlot(
              height: 240,
              keyId: 'pageFinal',
              onEnterViewport: () {
                _showAdOverlay();
              },
              onLoaded: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  LogService.log('[ModDetailScreen] 🔚 Ad loaded for keyId=pageFinal → removing overlay');
                  if (mounted) {
                    setState(() {
                      _hideAdOverlay();
                    });
                  }
                });
              },
            ),
            const SizedBox(height: 40),
            Text(
              "Recommended mods:",
              style: TextStyle(fontSize: 15, color: ColorsInfo.IsDark ? Colors.white : HexColor.fromHex("#353539")),
            ),
            const SizedBox(height: 10),
            _buildMinimodscroll(),
            const SizedBox(height: 20),
            _buildMoreModsButton(),
            const SizedBox(height: 20),
            _buildFinalModList(),
            const SizedBox(height: 20),
            _buildInstallButton(), // 👈 кнопка "Open mod"
          ],
        );
    }
  }

  Widget _buildInstruction() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: screenWidth > 700 ? 2 : 1, childAspectRatio: 225 / 285, mainAxisSpacing: 10, crossAxisSpacing: 10),
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              // height: 500,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocale.instruction_title_1.getString(context), style: TextStyle(color: HexColor.fromHex("#8E8E8E"), fontSize: 16), textAlign: TextAlign.start),
                  Text(AppLocale.instruction_desc_1.getString(context), style: TextStyle(color: HexColor.fromHex("#8E8E8E"), fontSize: 10), textAlign: TextAlign.start),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 600,
                    // width: 376, height: 601,
                    child: Image.asset('assets/images/instruction_1.png'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModHeaderSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModScreenshotGallery(screenshots: modItem.screenshots),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: screenWidth - 200,
              child: Text(
                modItem.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ColorsInfo.IsDark ? Colors.white : HexColor.fromHex("#353539"),
                  fontFamily: "Joystix_Bold",
                ),
                maxLines: 10,
              ),
            ),
            Row(
              children: [
                Image.asset('assets/images/file_icon.png', width: 20, height: 20),
                const SizedBox(width: 5),
                Text(
                  modItem.fileSize,
                  style: TextStyle(fontSize: 13, color: HexColor.fromHex("#8E8E8E")),
                ),
                const SizedBox(width: 14),
                Image.asset('assets/images/downloads_icon.png', width: 20, height: 20),
                const SizedBox(width: 5),
                Text(
                  modItem.downloads.toString(),
                  style: TextStyle(fontSize: 13, color: HexColor.fromHex("#8E8E8E")),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        // const SizedBox(
        //   height: 15,
        // ),
        // Text(
        //   AppLocale.mod_view_recommend.getString(context),
        //   style: TextStyle(fontSize: 15, color: ColorsInfo.IsDark ? Colors.white : HexColor.fromHex("#353539")),
        // ),
      ],
    );
  }

  Widget _buildMinimodGrid() {
    return Container(
      color: ColorsInfo.GetColor(ColorType.Second),
      child: MiniModList(
        count: 4,
        mode: DisplayMode.grid,
        sourceMods: modService!.mods[modList],
        modListIndex: modList,
        modListScreen: modListScreen,
        favoriteListScreen: favoriteListScreen,
      ),
    );
  }

  Widget _buildMinimodscroll() {
    return Container(
      color: ColorsInfo.GetColor(ColorType.Second),
      child: MiniModList(
        count: 6,
        mode: DisplayMode.scroll,
        sourceMods: modService!.mods[modList],
        modListIndex: modList,
        modListScreen: modListScreen,
        favoriteListScreen: favoriteListScreen,
      ),
    );
  }

  Widget _buildMoreModsButton() {
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      child: Container(
          height: 60,
          width: screenWidth - 110,
          decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(15)), gradient: ColorsInfo.ColorToGradient(HexColor.fromHex("#586067"))),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "More mods",
                  style: TextStyle(
                    color: cached ? HexColor.fromHex("#8D8D8D") : Colors.white,
                    fontSize: 16,
                    fontFamily: "Joystix_Bold",
                  ),
                ),
              ],
            ),
          )),
      onTap: () async {
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildFinalModList() {
    final List<ModItemData> mods = modService!.mods[modList];
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 700 ? 3 : (screenWidth < 500 ? 1 : 2);
    const spacing = 8.0;
    const itemHeight = 215.0;

    void openModFromCurrentScreen(ModItemData newModItem) async {
      if (AdConfig.isAdsEnabled && await AdManager.manager!.isInterstitialReady()) {
        AdManager.interstitialListener = InterstitialListener();
        await AdManager.manager!.showInterstitial(AdManager.interstitialListener!);
        await waitWhile(() => AdManager.interstitialListener!.adEnded);
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ModDetailScreenWidget(
            modItem: newModItem,
            modListScreen: modListScreen,
            favoritesListScreen: favoriteListScreen,
            modListIndex: modList,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: const Duration(milliseconds: 150),
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
              return child;
            }
          },
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      padding: const EdgeInsets.symmetric(vertical: 10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        mainAxisExtent: itemHeight,
        childAspectRatio: 225 / 205,
      ),
      itemBuilder: (context, index) {
        final mod = mods[index];
        return GestureDetector(
          onTap: () => openModFromCurrentScreen(mod),
          child: ModItem(modItemData: mod),
        );
      },
    );
  }

  Widget _buildInstallButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final isInstruction = _phase == ModDetailPhase.instruction;
    final isDescription = _phase == ModDetailPhase.description;
    final isDownloadPhase = _phase == ModDetailPhase.pageDownload;
    final isPageLoaded = _phase == ModDetailPhase.pageLoaded;
    final isFinal = _phase == ModDetailPhase.pageFinal;

    String buttonText = "Next";
    if (isDownloadPhase) {
      buttonText = "Download";
    } else if (isPageLoaded || isDescription || isInstruction) {
      buttonText = "Next";
    } else if (isFinal) {
      buttonText = "Open mod";
    }
    // else if (cached) {
    //   buttonText = AppLocale.mod_view_downloaded.getString(context);
    // }

    return InkWell(
      child: Container(
        height: 60,
        width: screenWidth - 110,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          gradient: isFinal
              ? ColorsInfo.ColorToGradient(HexColor.fromHex("#6522F2"))
              : cached
                  ? ColorsInfo.ColorToGradient(HexColor.fromHex("#586067"))
                  : (modItem.isRewarded ? purpleGradient : yellowGradient),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                buttonText,
                style: TextStyle(
                  color: isFinal ? Colors.white : (cached ? HexColor.fromHex("#8D8D8D") : Colors.white),
                  fontSize: 16,
                  fontFamily: "Joystix_Bold",
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () async {
        if (isDownloadPhase || _phase == ModDetailPhase.description || _phase == ModDetailPhase.instruction) {
          if (_phase == ModDetailPhase.pageDownload) {
            if (context.mounted) {
              _showLoadingDialog(context);
              LogService.log("🔄 Download started — phase=$_phase");
            }
            paths = await FileManager.downloadAndExtractFile(modItem.downloadURL);
            LogService.log("✅ Download finished — phase=$_phase, cached=$cached, paths=${paths.length}");

            setState(() {
              cached = true;
            });

            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop();
              LogService.log("🛑 Hiding dialog — phase=$_phase");
            }
          }
          _nextPhase();
          return;
        }

        if (isFinal) {
          await FileOpener.openFileWithApp(paths[0], screenWidth, screenHeight, context);
          return;
        }

        if (modItem.isPremium) {
          _showLoadingDialog(context);
          paths = await FileManager.downloadAndExtractFile(modItem.downloadURL);
          setState(() {
            cached = true;
          });

          if (paths.length == 1) {
            await FileOpener.openFileWithApp(paths[0], screenWidth, screenHeight, context);
            _nextPhase();
          } else {
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop();
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
                          children: <Widget>[
                            for (var path in paths)
                              Padding(
                                padding: const EdgeInsets.all(10),
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
                                            style: TextStyle(
                                              fontFamily: 'Joystix',
                                              color: ColorsInfo.IsDark ? Colors.white : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
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
                                                  style: TextStyle(
                                                    fontFamily: 'Joystix',
                                                    color: ColorsInfo.IsDark ? Colors.white : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          onTap: () async {
                                            await FileOpener.openFileWithApp(path, screenWidth, screenHeight, context);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }

          modService!.downloadMod(modItem);
          FileManager.downloadedModsAmount += 1;
          if (FileManager.downloadedModsAmount == 2) {
            if (await InAppReview.instance.isAvailable()) {
              InAppReview.instance.requestReview();
            }
          }
          if (paths.length == 1) {
            LogService.log('[ModDetailScreen] Closing loading dialog (single file)');
            Navigator.of(context, rootNavigator: true).pop();
          } else {
            LogService.log('[ModDetailScreen] Multiple files downloaded. Not closing dialog here.');
          }
        } else {
          installProhibited = false;

          if (modItem.isRewarded) {
            installProhibited = true;
            if (await AdManager.manager!.isRewardedAdReady()) {
              AdManager.rewardedListener = RewardedListener();
              await AdManager.manager!.showRewarded(AdManager.rewardedListener!);
              await waitWhile(() => AdManager.rewardedListener!.adEnded);

              if (AdManager.rewardedListener!.rewardGranted) {
                installProhibited = false;
                prefs = await SharedPreferences.getInstance();
                rewardedWatched = prefs!.getStringList("rewardedWatched") ?? List.empty(growable: true);
                rewardedWatched!.add(modItem.getModID());
                await prefs!.setStringList("rewardedWatched", rewardedWatched!);
                setState(() {
                  modItem.isRewarded = false;
                });
                if (modListScreen != null) {
                  modListScreen!.setState(() {
                    modService!.updateModRewarded(modItem);
                  });
                } else if (favoriteListScreen != null) {
                  favoriteListScreen!.setState(() {
                    modService!.updateModRewarded(modItem);
                  });
                }
              } else {
                return;
              }
            } else {
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.of(context, rootNavigator: true).pop();
              });
              if (context.mounted) {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
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
                );
              }
              return;
            }
          }

          if (!installProhibited) {
            if (context.mounted) _showLoadingDialog(context);
            paths = await FileManager.downloadAndExtractFile(modItem.downloadURL);
            setState(() {
              cached = true;
            });
            await FileOpener.openFileWithApp(paths[0], screenWidth, screenHeight, context);
            _nextPhase();

            modService!.downloadMod(modItem);
            FileManager.downloadedModsAmount += 1;
            if (FileManager.downloadedModsAmount == 2) {
              if (await InAppReview.instance.isAvailable()) {
                InAppReview.instance.requestReview();
              }
            }
            if (paths.length == 1) {
              if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
            } else {
              LogService.log('[ModDetailScreen] Warning: Downloaded paths.length != 1 → no dialog closed');
            }
          }
        }
      },
    );
  }

  // Widget _buildInstallButton() {
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   double screenHeight = MediaQuery.of(context).size.height;

  //   return InkWell(
  //     child: Container(
  //         height: 60,
  //         width: screenWidth - 110,
  //         decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(15)), gradient: cached ? ColorsInfo.ColorToGradient(HexColor.fromHex("#586067")) : (modItem.isRewarded ? purpleGradient : yellowGradient)),
  //         child: Center(
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Text(
  //                 _phase == ModDetailPhase.description || _phase == ModDetailPhase.instruction
  //                     ? "Next"
  //                     : cached
  //                         ? AppLocale.mod_view_downloaded.getString(context)
  //                         : _phase == ModDetailPhase.pageDownload
  //                             ? "Downloading" // 👈
  //                             : _phase == ModDetailPhase.pageFinal
  //                                 ? "Open mod"
  //                                 : "Next", // 👈 для pageLoaded
  //                 // _phase == ModDetailPhase.description || _phase == ModDetailPhase.instruction
  //                 //     ? "Next"
  //                 //     : cached
  //                 //         ? AppLocale.mod_view_downloaded.getString(context)
  //                 //         : modItem.isRewarded
  //                 //             ? AppLocale.mod_view_watchads.getString(context)
  //                 //             : AppLocale.mod_view_install.getString(context),
  //                 style: TextStyle(
  //                   color: cached ? HexColor.fromHex("#8D8D8D") : Colors.white,
  //                   fontSize: 16,
  //                   fontFamily: "Joystix_Bold",
  //                 ),
  //               ),
  //             ],
  //           ),
  //         )),
  //     onTap: () async {
  //       if (_phase != ModDetailPhase.pageFinal)
  //       //  if (_phase == ModDetailPhase.description || _phase == ModDetailPhase.instruction)
  //       {
  //         // SingleNativeAdLoader().disposeAllAds();
  //         _nextPhase();
  //         return;
  //       }

  //       if (modItem.isPremium) {
  //         _showLoadingDialog(context);
  //         paths = await FileManager.downloadAndExtractFile(modItem.downloadURL);
  //         setState(() {
  //           cached = true;
  //         });

  //         if (paths.length == 1) {
  //           await FileOpener.openFileWithApp(paths[0], screenWidth, screenHeight, context);
  //           _nextPhase();
  //         } else {
  //           if (context.mounted) {
  //             Navigator.of(context, rootNavigator: true).pop();
  //             await showModalBottomSheet<void>(
  //               context: context,
  //               backgroundColor: ColorsInfo.GetColor(ColorType.Second),
  //               builder: (BuildContext context) {
  //                 return SingleChildScrollView(
  //                   child: Container(
  //                     height: screenHeight / 3,
  //                     color: ColorsInfo.GetColor(ColorType.Main),
  //                     child: Center(
  //                       child: ListView(
  //                         children: <Widget>[
  //                           for (var path in paths)
  //                             Padding(
  //                               padding: const EdgeInsets.all(10),
  //                               child: Container(
  //                                 color: ColorsInfo.GetColor(ColorType.Second),
  //                                 width: screenWidth - 50,
  //                                 height: 50,
  //                                 child: Row(
  //                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                                   children: [
  //                                     Padding(
  //                                       padding: const EdgeInsets.all(5),
  //                                       child: SizedBox(
  //                                         width: screenWidth - 200,
  //                                         child: Text(
  //                                           p.basename(path),
  //                                           style: TextStyle(
  //                                             fontFamily: 'Joystix',
  //                                             color: ColorsInfo.IsDark ? Colors.white : Colors.black,
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                     const SizedBox(width: 10),
  //                                     Padding(
  //                                       padding: const EdgeInsets.all(5),
  //                                       child: InkWell(
  //                                         child: Container(
  //                                           height: 40,
  //                                           color: ColorsInfo.GetColor(ColorType.Main),
  //                                           child: Padding(
  //                                             padding: const EdgeInsets.all(5),
  //                                             child: Center(
  //                                               child: Text(
  //                                                 AppLocale.mod_view_install.getString(context),
  //                                                 style: TextStyle(
  //                                                   fontFamily: 'Joystix',
  //                                                   color: ColorsInfo.IsDark ? Colors.white : Colors.black,
  //                                                 ),
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         ),
  //                                         onTap: () async {
  //                                           await FileOpener.openFileWithApp(path, screenWidth, screenHeight, context);
  //                                         },
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 );
  //               },
  //             );
  //           }
  //         }

  //         modService!.downloadMod(modItem);
  //         FileManager.downloadedModsAmount += 1;
  //         if (FileManager.downloadedModsAmount == 2) {
  //           if (await InAppReview.instance.isAvailable()) {
  //             InAppReview.instance.requestReview();
  //           }
  //         }
  //         if (paths.length == 1) {
  //           Navigator.of(context, rootNavigator: true).pop();
  //         }
  //       } else {
  //         installProhibited = false;

  //         if (modItem.isRewarded) {
  //           installProhibited = true;
  //           if (await AdManager.manager!.isRewardedAdReady()) {
  //             AdManager.rewardedListener = RewardedListener();
  //             await AdManager.manager!.showRewarded(AdManager.rewardedListener!);
  //             await waitWhile(() => AdManager.rewardedListener!.adEnded);

  //             if (AdManager.rewardedListener!.rewardGranted) {
  //               installProhibited = false;
  //               prefs = await SharedPreferences.getInstance();
  //               rewardedWatched = prefs!.getStringList("rewardedWatched") ?? List.empty(growable: true);
  //               rewardedWatched!.add(modItem.getModID());
  //               await prefs!.setStringList("rewardedWatched", rewardedWatched!);
  //               setState(() {
  //                 modItem.isRewarded = false;
  //               });
  //               if (modListScreen != null) {
  //                 modListScreen!.setState(() {
  //                   modService!.updateModRewarded(modItem);
  //                 });
  //               } else if (favoriteListScreen != null) {
  //                 favoriteListScreen!.setState(() {
  //                   modService!.updateModRewarded(modItem);
  //                 });
  //               }
  //             } else {
  //               return;
  //             }
  //           } else {
  //             Future.delayed(const Duration(seconds: 1), () {
  //               Navigator.of(context, rootNavigator: true).pop();
  //             });
  //             if (context.mounted) {
  //               showDialog<void>(
  //                 context: context,
  //                 barrierDismissible: false,
  //                 builder: (BuildContext context) {
  //                   return AlertDialog(
  //                     content: SingleChildScrollView(
  //                       child: Center(
  //                         child: Text(
  //                           AppLocale.mod_view_error_ads.getString(context),
  //                           style: const TextStyle(fontFamily: "Joystix"),
  //                         ),
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               );
  //             }
  //             return;
  //           }
  //         }

  //         if (!installProhibited) {
  //           if (context.mounted) _showLoadingDialog(context);
  //           paths = await FileManager.downloadAndExtractFile(modItem.downloadURL);
  //           setState(() {
  //             cached = true;
  //           });
  //           await FileOpener.openFileWithApp(paths[0], screenWidth, screenHeight, context);
  //           _nextPhase();

  //           modService!.downloadMod(modItem);
  //           FileManager.downloadedModsAmount += 1;
  //           if (FileManager.downloadedModsAmount == 2) {
  //             if (await InAppReview.instance.isAvailable()) {
  //               InAppReview.instance.requestReview();
  //             }
  //           }
  //           if (paths.length == 1) {
  //             if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  //           }
  //         }
  //       }
  //     },
  //   );
  // }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LoadingDialog();
      },
    );
  }

  void _showAdOverlay() {
    if (_overlayRemoved) return;

    _adOverlay = OverlayEntry(
      builder: (_) => const NativeAdOverlayLoader(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Overlay.of(context).insert(_adOverlay!);
    });

    _overlayRemoved = true;
  }

  void _hideAdOverlay() {
    if (!_overlayRemoved) return;

    _adOverlay?.remove();
    _adOverlay = null;
  }
}
