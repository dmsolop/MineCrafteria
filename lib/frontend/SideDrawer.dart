import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:minecrafteria/backend/AdManager.dart';
import 'package:minecrafteria/backend/OpenURL.dart';
import 'package:minecrafteria/frontend/LanguageScreenPhone.dart';
import 'package:minecrafteria/frontend/OtherAppsScreen.dart';
import 'package:minecrafteria/main.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'AppLocale.dart';
import 'ColorsInfo.dart';
import 'FavoritesScreen.dart';
import 'NewModScreen.dart';
import 'SettingsScreen.dart';
import 'package:minecrafteria/extensions/color_extension.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'SettingsScreenPad.dart';

enum SelectedCategory { MainMenu, Premium, Favorites, NewMod, Settings }

class SideDrawer {
  static Widget getDrawer(BuildContext context, double screenWidth, double screenHeight, String version, SelectedCategory category) {
    final selectedGradient = LinearGradient(colors: [HexColor.fromHex("#5E53F1"), HexColor.fromHex("#5E53F1")], begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight);
    final unSelectedGradient = LinearGradient(colors: [ColorsInfo.IsDark ? Colors.white : HexColor.fromHex("#353539"), ColorsInfo.IsDark ? Colors.white : HexColor.fromHex("#353539")], begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight);

    return VisibilityDetector(
        key: const Key('side-drawer'),
        onVisibilityChanged: (info) => {},
        child: SafeArea(
          bottom: false,
          left: false,
          right: false,
          top: false,
          child: Drawer(
              backgroundColor: ColorsInfo.GetColor(ColorType.Second),
              child: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight / 5.5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // padding: EdgeInsets.zero,
                            children: <Widget>[
                              ListTile(
                                // selected: true,
                                enabled: false,
                                contentPadding: const EdgeInsets.all(0),
                                leading: SizedBox(
                                  width: 38,
                                  height: 38,
                                  child: ShaderMask(
                                    shaderCallback: (rect) {
                                      return (category == SelectedCategory.MainMenu ? selectedGradient : unSelectedGradient).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                                    },
                                    blendMode: BlendMode.srcATop,
                                    child: Image.asset(
                                      'assets/images/icon_pix_home.png',
                                      height: 400,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: ShaderMask(
                                  shaderCallback: (rect) {
                                    return (category == SelectedCategory.MainMenu ? selectedGradient : unSelectedGradient).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                                  },
                                  blendMode: BlendMode.srcATop,
                                  child: Text(AppLocale.main_side_menu.getString(context), style: const TextStyle(fontSize: 15)),
                                ),
                                // title: Text(AppLocale.main_side_menu.getString(context), style: TextStyle(fontSize: 15)),
                                onTap: () {
                                  // Add navigation functionality here
                                },
                              ),
                              const SizedBox(height: 10),
                              ListTile(
                                contentPadding: const EdgeInsets.all(0),
                                leading: SizedBox(
                                  width: 38,
                                  height: 38,
                                  child: ShaderMask(
                                    shaderCallback: (rect) {
                                      return (category == SelectedCategory.Favorites ? selectedGradient : unSelectedGradient).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                                    },
                                    blendMode: BlendMode.srcATop,
                                    child: Image.asset(
                                      'assets/images/icon_pix_favorite_full.png',
                                      height: 400,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: ShaderMask(
                                  shaderCallback: (rect) {
                                    return (category == SelectedCategory.Favorites ? selectedGradient : unSelectedGradient).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                                  },
                                  blendMode: BlendMode.srcATop,
                                  child: Text(AppLocale.main_side_favorites.getString(context).toUpperCase(), style: const TextStyle(fontSize: 15)),
                                ),
                                onTap: () async {
                                  if (true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FavoritesModListScreen(
                                          favMods: modService!.getFavoriteMods(),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              // const SizedBox(height: 10),
                              // ListTile(
                              //   contentPadding: const EdgeInsets.all(0),
                              //   leading: SizedBox(
                              //     width: 38,
                              //     height: 38,
                              //     child: ShaderMask(
                              //       shaderCallback: (rect) {
                              //         return (category ==
                              //                     SelectedCategory.Favorites
                              //                 ? selectedGradient
                              //                 : unSelectedGradient)
                              //             .createShader(Rect.fromLTRB(
                              //                 0, 0, rect.width, rect.height));
                              //       },
                              //       blendMode: BlendMode.srcATop,
                              //       child: Image.asset(
                              //         'assets/images/icon_language.png',
                              //         height: 400,
                              //         fit: BoxFit.cover,
                              //       ),
                              //     ),
                              //   ),
                              //   title: ShaderMask(
                              //     shaderCallback: (rect) {
                              //       return (category ==
                              //                   SelectedCategory.Favorites
                              //               ? selectedGradient
                              //               : unSelectedGradient)
                              //           .createShader(Rect.fromLTRB(
                              //               0, 0, rect.width, rect.height));
                              //     },
                              //     blendMode: BlendMode.srcATop,
                              //     child: Text(
                              //         AppLocale.settings_language
                              //             .getString(context)
                              //             .toUpperCase(),
                              //         style: const TextStyle(fontSize: 15)),
                              //   ),
                              //   onTap: () async {
                              //     if (true) {
                              //       Navigator.push(
                              //         context,
                              //         MaterialPageRoute(
                              //             builder: (context) =>
                              //                 const LanguageScreenPhone()),
                              //       );
                              //     }
                              //   },
                              // ),
                              const SizedBox(height: 10),
                              ListTile(
                                contentPadding: const EdgeInsets.all(0),
                                leading: SizedBox(
                                  width: 38,
                                  height: 38,
                                  child: ShaderMask(
                                    shaderCallback: (rect) {
                                      return (category == SelectedCategory.Favorites ? selectedGradient : unSelectedGradient).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                                    },
                                    blendMode: BlendMode.srcATop,
                                    child: Image.asset(
                                      'assets/images/icon_rate_app.png',
                                      height: 400,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: ShaderMask(
                                  shaderCallback: (rect) {
                                    return (category == SelectedCategory.Favorites ? selectedGradient : unSelectedGradient).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                                  },
                                  blendMode: BlendMode.srcATop,
                                  child: Text(AppLocale.settings_rate_the_app.getString(context).toUpperCase(), style: const TextStyle(fontSize: 15)),
                                ),
                                onTap: () async {
                                  InAppReview.instance.requestReview();
                                },
                              ),
                              const SizedBox(height: 10),
                              ListTile(
                                contentPadding: const EdgeInsets.all(0),
                                leading: SizedBox(
                                  width: 38,
                                  height: 38,
                                  child: ShaderMask(
                                    shaderCallback: (rect) {
                                      return (category == SelectedCategory.Favorites ? selectedGradient : unSelectedGradient).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                                    },
                                    blendMode: BlendMode.srcATop,
                                    child: Image.asset(
                                      'assets/images/icon_policy.png',
                                      height: 400,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: ShaderMask(
                                  shaderCallback: (rect) {
                                    return (category == SelectedCategory.Favorites ? selectedGradient : unSelectedGradient).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                                  },
                                  blendMode: BlendMode.srcATop,
                                  child: Text(AppLocale.premium_view_policy.getString(context).toUpperCase(), style: const TextStyle(fontSize: 15)),
                                ),
                                onTap: () async {
                                  OpenURL.openURL(Platform.isIOS ? "https://bytecore.studio/privacypolicy" : "https://akstudio.site/privacypolicy");
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Text(
                              "",
                              style: TextStyle(fontSize: 10, color: ColorsInfo.IsDark ? Colors.white : HexColor.fromHex(ColorsInfo.second_dark)),
                            ),
                            // child: Text(AppLocale.main_side_version.getString(context) + ": " + version, style: TextStyle(fontSize: 10, color: ColorsInfo.IsDark ? Colors.white : HexColor.fromHex(ColorsInfo.second_dark)),),
                          )),
                    )
                  ],
                ),
              )),
        ));
  }
}
