import 'dart:convert';
// import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:morph_mods/backend/AdManager.dart';
import 'package:morph_mods/backend/CacheManager.dart';
import 'package:mongo_dart/mongo_dart.dart' as db;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'frontend/ColorsInfo.dart';
import 'frontend/ModDetailScreenPad.dart';
import 'frontend/SideDrawer.dart';
import 'package:morph_mods/extensions/color_extension.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'frontend/AppLocale.dart';
import 'frontend/ModItem.dart';
import 'frontend/GradientElevatedButton.dart';
import 'frontend/ModItemData.dart';
import 'frontend/ModDetailScreen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'frontend/RestartWidget.dart';
import 'package:morph_mods/backend/ModsManager.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show PlatformDispatcher, kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'backend/native_ads/NativeAdManager.dart';
import 'backend/LogService.dart';

//test gap
final FlutterLocalization localization = FlutterLocalization.instance;
ModService? modService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LogService.init();
  await LogService.log('[main.dart] Clearing log...');
  await LogService.clearLog();
  await LogService.log('[main.dart] Log cleared');
  await LogService.log('[Main] ✅ Log was cleared manually before WidgetsFlutterBinding.ensureInitialized');

  await Firebase.initializeApp(); // Firebase initialization
  await fetchRemoteConfig(); // Getting settings before launching CAS and nativeAd
  NativeAdManager().preLoadAd(style: NativeAdStyle.grid);

  if (Platform.isAndroid || Platform.isIOS) {
    bool isTabletDevice = await isTablet();
    if (isTabletDevice) {
      SystemChrome.setPreferredOrientations([
        // DeviceOrientation.portraitUp,
        // DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white.withOpacity(0.002),
    ),
  );

  final String response = await rootBundle.loadString('assets/loca.json');
  var result = await AppLocale.readLocalizationJson(response);

  AppLocale.EN = result['en']!;
  AppLocale.RU = result['ru']!;
  AppLocale.FR = result['fr']!;
  AppLocale.PT = result['pt']!;
  AppLocale.ES = result['es']!;
  AppLocale.DE = result['de']!;

  List<String> currentLangs = ['en', 'ru', 'fr', 'pt', 'es', 'de'];

  await localization.init(
    mapLocales: [
      MapLocale('en', AppLocale.EN),
      MapLocale('ru', AppLocale.RU),
      MapLocale('fr', AppLocale.FR),
      MapLocale('pt', AppLocale.PT),
      MapLocale('es', AppLocale.ES),
      MapLocale('de', AppLocale.DE),
    ],
    initLanguageCode: currentLangs.contains(Platform.localeName.substring(0, Platform.localeName.indexOf('_'))) ? Platform.localeName.substring(0, Platform.localeName.indexOf('_')) : "en",
  );

  localization.onTranslatedLanguage = _onTranslatedLanguage;
  // await init();

  runApp(const RestartWidget(ModListApp()));
}

Future<void> fetchRemoteConfig() async {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 10),
    minimumFetchInterval: Duration.zero, // Forced update on every launch
  ));

  try {
    await remoteConfig.fetchAndActivate();

    Map<String, dynamic> allParams = remoteConfig.getAll();
    debugPrint("🔥 Remote Config Parameters: $allParams");

    bool enableAds = remoteConfig.getBool("enable_ads");
    debugPrint("✅ Firebase Remote Config received. enable_ads: $enableAds");

    AdConfig.isAdsEnabled = enableAds;
    if (AdConfig.isAdsEnabled) {
      AdManager.initialize();
      MobileAds.instance.initialize();
    }
  } catch (e) {
    debugPrint("❌ Remote Config download error: $e");
  }
}

Future<bool> isTablet() async {
  final deviceInfo = DeviceInfoPlugin();
  bool isTablet = false;

  if (Platform.isAndroid) {
    var androidInfo = await deviceInfo.androidInfo;
    isTablet = androidInfo.systemFeatures.contains('android.hardware.type.tablet');
  } else if (Platform.isIOS) {
    var iosInfo = await deviceInfo.iosInfo;
    isTablet = iosInfo.model.toLowerCase().contains('ipad');
  }

  return isTablet;
}

bool initialized = false;

Future<void> init() async {
  if (initialized) return;

  ModService.sharedPreferences = await SharedPreferences.getInstance();

  var brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
  bool isDarkMode = brightness == Brightness.dark;

  var defaultColorValue = isDarkMode;

  final isDarkSaved = ModService.sharedPreferences!.getBool("color_is_dark") ?? defaultColorValue;
  if (!ModService.sharedPreferences!.containsKey("color_is_dark")) {
    await ModService.sharedPreferences!.setBool("color_is_dark", defaultColorValue);
  }

  // ColorsInfo.IsDark = isDarkSaved;
  await Future.delayed(Duration(milliseconds: 500));

  modService = ModService();
  modService!.mods = await modService!.fetchModItems();

  // ColorsInfo.IsDark
  initialized = true;
}

// the setState function here is a must to add
void _onTranslatedLanguage(Locale? locale) {
  // setState(() {});
}

class ModListApp extends StatelessWidget {
  const ModListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morph Mods',
      supportedLocales: localization.supportedLocales,
      localizationsDelegates: localization.localizationsDelegates,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Joystix',
        scaffoldBackgroundColor: ColorsInfo.GetColor(ColorType.Main),
      ),
      home: const ModListScreen(),
    );
  }
}

class ModListScreen extends StatefulWidget {
  static BuildContext? mainContext;

  const ModListScreen({super.key});

  @override
  ModListScreenState createState() => ModListScreenState();
}

List<List<ModItemData>> searchedMods = List.empty();
String searchText = "";
String version = "";
bool isPremShown = false;

class ModListScreenState extends State<ModListScreen> with SingleTickerProviderStateMixin {
  final List<Image> _categoryIcons = [
    Image.asset('assets/images/morph_icon.png'),
    Image.asset('assets/images/all_mods_category.png'),
    Image.asset('assets/images/top_category_icon.png'),
    Image.asset('assets/images/mods_icon.png'),
    Image.asset('assets/images/maps_icon.png'),
    Image.asset('assets/images/textures_icon.png'),
    Image.asset('assets/images/houses_icon.png'),
  ];

  // Add ScrollController for the category list
  final ScrollController _scrollController = ScrollController();

  int _activeCategoryIndex = 0;
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Create an animation controller
    _controller = AnimationController(
      vsync: this, // vsync is set to this for performance reasons
      duration: const Duration(seconds: 2), // Set the duration of the animation
    );

    // Create a Tween for the rotation angle
    _animation = Tween<double>(
      begin: 0, // Start rotation angle
      end: 2 * 3.141, // End rotation angle (2 * pi for a full circle)
    ).animate(_controller);

    // Add a listener to the PageController to update the active category index when the page changes
    _pageController.addListener(() {
      int newPage = _pageController.page!.round();
      if (_activeCategoryIndex != newPage) {
        setState(() {
          _activeCategoryIndex = newPage;
          _scrollToActiveCategory();
        });
      }
    });

    _checkInitAndLoadMods();

    // Repeat the animation indefinitely
    _controller.repeat();
  }

  void _checkInitAndLoadMods() {
    if ((modService != null ? modService!.mods.isEmpty : true) && !isPremShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await init();

          if (mounted) {
            setState(() {
              _isInitialized = true;
            });
          }
        } catch (e) {
          LogService.log('INIT ERROR: $e');
        }
      });
    }
  }

  void _scrollToActiveCategory() {
    _scrollController.animateTo(
      _activeCategoryIndex * 70.0, // Assume each category item has a width of 100.0
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _scrollController.dispose(); // Dispose the scroll controller
    _controller.dispose();
    NativeAdManager().disposeAllAds();
    super.dispose();
  }

  late AnimationController _controller;
  late Animation<double> _animation;

  bool isBannerHidden = true;

  void _addBanner(BuildContext context) {
    if (isBannerHidden == AdManager.hideBanner) return;
    isBannerHidden = AdManager.hideBanner;

    return Overlay.of(context).insert(
      OverlayEntry(builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: AdManager.getBottomBanner(context),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    int crossAxisCount = screenWidth > 700 ? 3 : (screenWidth < 500 ? 1 : 2);

    if ((modService != null ? modService!.mods.isEmpty : true) && !isPremShown && !_isInitialized) {
      return Scaffold(
        backgroundColor: HexColor.fromHex("#25292e"),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width > 700 ? MediaQuery.sizeOf(context).width * 0.85 : MediaQuery.of(context).size.width,
                child: Image.asset(
                  MediaQuery.sizeOf(context).width > 700 ? 'assets/images/loading_background_pad.png' : 'assets/images/loading_background.png',
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 600),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animation.value,
                      child: Image.asset(
                        'assets/images/icon_pix_loading.png',
                        width: 70,
                        height: 70,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocale.popup_loading.getString(context),
                  style: const TextStyle(
                    fontFamily: 'Joystix',
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // if ((modService != null ? modService!.mods.isEmpty : true) && !isPremShown) {
    //   return Scaffold(
    //       backgroundColor: HexColor.fromHex("#25292e"),
    //       body: VisibilityDetector(
    //         key: const Key('loading-widget'),
    //         child: Stack(
    //           alignment: Alignment.center,
    //           children: [
    //             Align(
    //               alignment: Alignment.center,
    //               child: SizedBox(
    //                   width: MediaQuery.of(context).size.width > 700 ? MediaQuery.sizeOf(context).width * 0.85 : MediaQuery.of(context).size.width, child: Image.asset(MediaQuery.sizeOf(context).width > 700 ? 'assets/images/loading_background_pad.png' : 'assets/images/loading_background.png')),
    //             ),
    //             Column(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 const SizedBox(
    //                   height: 600,
    //                 ),
    //                 AnimatedBuilder(
    //                   animation: _animation,
    //                   builder: (context, child) {
    //                     // Use Transform.rotate to rotate the
    //                     // Image based on the animation value
    //                     return Transform.rotate(
    //                       angle: _animation.value,
    //                       child: Image.asset(
    //                         'assets/images/icon_pix_loading.png', // Replace with your image asset
    //                         width: 70,
    //                         height: 70,
    //                       ),
    //                     );
    //                   },
    //                 ),
    //                 const SizedBox(
    //                   height: 10,
    //                 ),
    //                 Text(AppLocale.popup_loading.getString(context), style: const TextStyle(fontFamily: 'Joystix', color: Colors.white, fontSize: 20))
    //               ],
    //             ),
    //           ],
    //         ),
    //         onVisibilityChanged: (visibilityInfo) async {
    //           if (visibilityInfo.visibleFraction == 1) {
    //             try {
    //               // Navigator.push(
    //               //   context,
    //               //   MaterialPageRoute(
    //               //     builder: (context) => PremiumScreen4(),
    //               //   ),
    //               // );

    //               await init();
    //               LogService.log('RESTART TRIGGERED BY VISIBILITY');
    //               RestartWidget.restartApp(context, false, false, false);

    //               // if(isPremShown) {
    //               //   RestartWidget.restartApp(context, false, false, false);
    //               // }
    //               // else {
    //               //   if(!(await SubscriptionManager.isSubscriptionActive(context)) && SubscriptionManager.weekItem != null) {
    //               //     isPremShown = true;
    //               //     Navigator.push(
    //               //       context,
    //               //       MaterialPageRoute(
    //               //         builder: (context) => Platform.isIOS ? PremiumScreen1() : PremiumScreen4(),
    //               //       ),
    //               //     );
    //               //   }
    //               //   else {
    //               //     if(SubscriptionManager.weekItem == null) SubscriptionManager.premium_week_price = AppLocale.premium_view4_button_buy.getString(context);
    //               //     RestartWidget.restartApp(context, false, false, false);
    //               //   }
    //               // }
    //             } catch (e) {}
    //           }
    //         },
    //       ));
    // }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });

    return MaterialApp(
      title: 'Mods for Melon Playground',
      supportedLocales: localization.supportedLocales,
      localizationsDelegates: localization.localizationsDelegates,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Joystix',
        scaffoldBackgroundColor: ColorsInfo.GetColor(ColorType.Main),
      ),
      builder: (context, child) {
        WidgetsBinding.instance.addPersistentFrameCallback((_) => _addBanner(context));

        return Stack(
          children: [child!],
        );
      },
      home: Scaffold(
          backgroundColor: ColorsInfo.GetColor(ColorType.Main),
          bottomNavigationBar: AdManager.getBottomBannerBackground(context),
          appBar: AppBar(
            backgroundColor: ColorsInfo.GetColor(ColorType.Main),
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: ShaderMask(
                    shaderCallback: (rect) {
                      return (ColorsInfo.IsDark ? ColorsInfo.ColorToGradient(Colors.white) : ColorsInfo.ColorToGradient(HexColor.fromHex("#353539"))).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                    },
                    blendMode: BlendMode.srcATop,
                    child: Image.asset(
                      'assets/images/icon_pix_menu.png',
                      // height: 400,d
                      fit: BoxFit.fill,
                    ),
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            actions: const [
              // IconButton(
              //   icon: Image.asset('assets/images/button_premium.png'),
              //   onPressed: () {
              //     AdManager.hideBanner = true;
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => PremiumScreen4(),
              //         fullscreenDialog: true
              //       ),
              //     );
              //   },
              // ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 13, right: 13, top: 0, bottom: 10),
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: HexColor.fromHex("#8D8D8D")),
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          hintText: AppLocale.main_top_search.getString(context),
                          border: InputBorder.none,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Image.asset('assets/images/search_icon.png'),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 7),
                          fillColor: ColorsInfo.GetColor(ColorType.Second),
                          filled: true,
                          hintStyle: TextStyle(color: HexColor.fromHex("#8D8D8D")),
                        ),
                        onSubmitted: (value) => {
                          setState(() {
                            searchText = value;
                            searchedMods = modService!.searchMods(searchText);
                          })
                        },
                      ),
                    ),
                  ),
                  Container(
                    height: 45.0,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(bottom: 8, left: 5),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController, // Use the scroll controller here
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: crossAxisCount < 3 ? 120 : (screenWidth / 6),
                          height: 45,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: GradientElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _activeCategoryIndex = index;
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                  // _scrollToActiveCategory();
                                });
                              },
                              gradient: _activeCategoryIndex == index
                                  ? LinearGradient(colors: [HexColor.fromHex("#5E53F1"), HexColor.fromHex("#5E53F1")], begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight)
                                  : LinearGradient(colors: [ColorsInfo.GetColor(ColorType.Second), ColorsInfo.GetColor(ColorType.Second)], begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 31,
                                    height: 31,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: _categoryIcons[index].image,
                                          fit: BoxFit.cover,
                                          colorFilter: ColorFilter.mode(
                                            (_activeCategoryIndex == index ? Colors.white : (ColorsInfo.IsDark ? Colors.white : HexColor.fromHex("#8E8E8E"))).withOpacity(1),
                                            BlendMode.srcATop,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        AppLocale.categoryIndexToString(index, context),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: _activeCategoryIndex == index ? Colors.white : (ColorsInfo.IsDark ? Colors.white : HexColor.fromHex("#8E8E8E")),
                                          fontFamily: "Joystix_Bold",
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          drawer: SideDrawer.getDrawer(context, screenWidth, screenHeight, version, SelectedCategory.MainMenu),
          onDrawerChanged: (isOpened) => {
                // setState(() {
                //   hideBanner = isOpened;
                // })
              },
          body: VisibilityDetector(
            key: const Key('main-vis'),
            onVisibilityChanged: (info) => {
              ModListScreen.mainContext = context,
              if (AdManager.hideBanner)
                {
                  if (info.visibleFraction == 1) {AdManager.hideBanner = false, _addBanner(context)}
                }
            },
            child: Container(
              color: ColorsInfo.GetColor(ColorType.Second),
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _activeCategoryIndex = index;
                  });
                },
                children: (searchText != "" ? searchedMods : modService!.mods).map((modItems) {
                  return Container(
                    color: ColorsInfo.GetColor(ColorType.Second),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double modItemHeight = 215; // Current mod height
                        double adItemHeight = modItemHeight;
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            mainAxisExtent: modItemHeight,
                            childAspectRatio: 225 / 205,
                          ),
                          itemCount: NativeAdManager().getTotalItemCount(modItems.length),
                          itemBuilder: (context, index) {
                            if (NativeAdManager().isAdIndex(index)) {
                              NativeAdManager().maybePreloadAds(index, modItems.length, style: NativeAdStyle.grid); // 👈 Один виклик

                              return NativeAdManager().getAdWidget(index, height: adItemHeight, style: NativeAdStyle.grid, refresh: () {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) setState(() {});
                                });
                              });
                            }

                            // Real mod index (excluding advertising)
                            int actualIndex = NativeAdManager().getRealModIndex(index);

                            // Protection against going outside the array boundaries
                            if (actualIndex >= modItems.length) {
                              return const SizedBox.shrink();
                            }
                            return SizedBox(
                              child: InkWell(
                                onTap: () async {
                                  final mod = modItems[actualIndex];
                                  final allowEnter = await AdManager.handleRewardedEntry(
                                    mod: mod,
                                    refreshUI: () => setState(() {}),
                                  );
                                  if (!allowEnter) return;

                                  // 🔹 Показ interstitial (без preLoadAd!)
                                  if (AdConfig.isAdsEnabled) {
                                    if (AdManager.nextTimeInterstitial == null || AdManager.nextTimeInterstitial!.isBefore(DateTime.now())) {
                                      if (await AdManager.manager!.isInterstitialReady()) {
                                        AdManager.interstitialListener = InterstitialListener();
                                        await AdManager.manager!.showInterstitial(AdManager.interstitialListener!);
                                        await waitWhile(() => AdManager.interstitialListener!.adEnded);
                                        // AdManager.nextTimeInterstitial = DateTime.now().add(const Duration(seconds: 60));
                                      }
                                    }
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => screenWidth > 700
                                          ? ModDetailScreenPadWidget(
                                              modItem: modItems[actualIndex],
                                              modListScreen: this,
                                              favoritesListScreen: null,
                                              modListIndex: _activeCategoryIndex,
                                            )
                                          : ModDetailScreenWidget(
                                              modItem: modItems[actualIndex],
                                              modListScreen: this,
                                              favoritesListScreen: null,
                                              modListIndex: _activeCategoryIndex,
                                            ),
                                    ),
                                  );
                                },
                                child: VisibilityDetector(
                                  key: Key(modItems[actualIndex].imageUrl + modItems[actualIndex].isFirestoreChecked.toString()),
                                  onVisibilityChanged: (visibility) async {
                                    if (visibility.visibleFraction > 0 && !modItems[actualIndex].isFirestoreChecked) {
                                    } else if (visibility.visibleFraction > 0) {
                                      bool cached = await CacheManager.isCacheAvailable(modItems[actualIndex].downloadURL);
                                      setState(() {
                                        modItems[actualIndex].cached = cached;
                                      });
                                    }
                                  },
                                  child: ModItem(modItemData: modItems[actualIndex]),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          )),
    );
  }
}
