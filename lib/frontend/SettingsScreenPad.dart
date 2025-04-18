import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:minecrafteria/backend/AdManager.dart';
import 'package:minecrafteria/backend/FileManager.dart';
import 'FeedbackScreen.dart';
import 'InstructionScreen.dart';
import 'RestartWidget.dart';
import 'package:minecrafteria/extensions/color_extension.dart';
import 'package:in_app_review/in_app_review.dart';
import 'AppLocale.dart';
import 'ColorsInfo.dart';
import 'package:minecrafteria/backend/ModsManager.dart';

const double edgePadding = 20;

final LinearGradient selectedGradient = LinearGradient(colors: [HexColor.fromHex("#5092F0"), HexColor.fromHex("#636CE1")], begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight);
final LinearGradient unselectedGradient = LinearGradient(colors: [ColorsInfo.IsDark ? HexColor.fromHex("#8E8E8E") : HexColor.fromHex("#353539"), ColorsInfo.IsDark ? HexColor.fromHex("#8E8E8E") : HexColor.fromHex("#353539")], begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight);

class SettingsScreenPad extends StatelessWidget {
  const SettingsScreenPad({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ColorsInfo.IsDark ? ColorsInfo.GetColor(ColorType.Second) : HexColor.fromHex("#F8F8F8"),
      bottomNavigationBar: AdManager.getBottomBannerBackground(context),
      appBar: AppBar(
        leading: IconButton(
          icon: ColorsInfo.GetBackButton(),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        backgroundColor: ColorsInfo.GetColor(ColorType.Main),
        title: Text(
          AppLocale.settings_title.getString(context),
          style: TextStyle(color: ColorsInfo.IsDark ? Colors.white : Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(edgePadding),
                      color: (ColorsInfo.IsDark ? HexColor.fromHex(ColorsInfo.main_dark) : Colors.white),
                      height: 93,
                      width: (screenWidth / 2.1) - 13,
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(AppLocale.settings_instruction.getString(context), style: TextStyle(fontSize: 15, color: ColorsInfo.IsDark ? Colors.white : Colors.black)),
                                  // SizedBox(width: 233 - edgePadding),
                                  SizedBox(
                                      width: 26,
                                      height: 26,
                                      child: ShaderMask(
                                        shaderCallback: (rect) {
                                          return (ColorsInfo.IsDark ? ColorsInfo.ColorToGradient(Colors.white) : ColorsInfo.ColorToGradient(Colors.black)).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                                        },
                                        blendMode: BlendMode.srcATop,
                                        child: Image.asset(
                                          'assets/images/icon_pix_forward.png',
                                          // width: 35, height: 35,
                                          // fit: BoxFit.fill,
                                        ),
                                      )),
                                ],
                              ),
                              onTap: () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const InstructionScreen(),
                                  ),
                                )
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      padding: const EdgeInsets.all(edgePadding),
                      color: (ColorsInfo.IsDark ? HexColor.fromHex(ColorsInfo.main_dark) : Colors.white),
                      height: 93,
                      width: (screenWidth / 2.1) - 13,
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(AppLocale.settings_dark_mode.getString(context), style: TextStyle(fontSize: 15, color: ColorsInfo.IsDark ? Colors.white : Colors.black)),
                                  // SizedBox(width: 233 - edgePadding),
                                  SizedBox(
                                      width: 48,
                                      height: 25,
                                      child: ShaderMask(
                                        shaderCallback: (rect) {
                                          return (ColorsInfo.IsDark ? ColorsInfo.ColorToGradient(Colors.white) : ColorsInfo.ColorToGradient(Colors.black)).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                                        },
                                        blendMode: BlendMode.overlay,
                                        child: Image.asset(
                                          ColorsInfo.IsDark ? 'assets/images/switch_enabled.png' : 'assets/images/switch_disabled.png',
                                          // width: 35, height: 35,
                                          // fit: BoxFit.fill,
                                        ),
                                      )),
                                ],
                              ),
                              onTap: () => {
                                ColorsInfo.IsDark = !ColorsInfo.IsDark,
                                if (ModService.sharedPreferences != null) {ModService.sharedPreferences!.setBool("color_is_dark", ColorsInfo.IsDark)},
                                RestartWidget.restartApp(context, false, false, true)
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  // width: 398,
                  color: (ColorsInfo.IsDark ? HexColor.fromHex(ColorsInfo.main_dark) : Colors.white),
                  padding: const EdgeInsets.all(edgePadding),
                  child: Column(
                    children: [
                      Text(
                        AppLocale.settings_language.getString(context),
                        style: TextStyle(color: ColorsInfo.IsDark ? Colors.white : HexColor.fromHex("#353539"), fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            child: Container(
                                width: (screenWidth / 3.5) - 3,
                                height: 57,
                                decoration: BoxDecoration(gradient: FlutterLocalization.instance.currentLocale!.languageCode == "en" ? selectedGradient : unselectedGradient),
                                child: const Center(
                                  child: Text("ENGLISH",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.center),
                                )),
                            onTap: () => {FlutterLocalization.instance.translate("en"), RestartWidget.restartApp(context, false, false, true)},
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            child: Container(
                                width: (screenWidth / 3.5) - 3,
                                height: 57,
                                decoration: BoxDecoration(gradient: FlutterLocalization.instance.currentLocale!.languageCode == "ru" ? selectedGradient : unselectedGradient),
                                child: const Center(
                                  child: Text("РУССКИЙ", style: TextStyle(color: Colors.white, fontSize: 15), textAlign: TextAlign.center),
                                )),
                            onTap: () => {FlutterLocalization.instance.translate("ru"), RestartWidget.restartApp(context, false, false, true)},
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            child: Container(
                                width: (screenWidth / 3.5) - 3,
                                height: 57,
                                decoration: BoxDecoration(gradient: FlutterLocalization.instance.currentLocale!.languageCode == "fr" ? selectedGradient : unselectedGradient),
                                // color: HexColor.fromHex("#353539"),
                                child: const Center(
                                  child: Text(
                                    "FRENCH",
                                    style: TextStyle(color: Colors.white, fontSize: 15),
                                  ),
                                )),
                            onTap: () => {FlutterLocalization.instance.translate("fr"), RestartWidget.restartApp(context, false, false, true)},
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            child: Container(
                                width: (screenWidth / 3.5) - 3,
                                height: 57,
                                decoration: BoxDecoration(gradient: FlutterLocalization.instance.currentLocale!.languageCode == "pt" ? selectedGradient : unselectedGradient),
                                child: const Center(
                                  child: Text("PORTUGAL",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.center),
                                )),
                            onTap: () => {FlutterLocalization.instance.translate("pt"), RestartWidget.restartApp(context, false, false, true)},
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            child: Container(
                                width: (screenWidth / 3.5) - 3,
                                height: 57,
                                decoration: BoxDecoration(gradient: FlutterLocalization.instance.currentLocale!.languageCode == "es" ? selectedGradient : unselectedGradient),
                                child: const Center(
                                  child: Text("SPANISH", style: TextStyle(color: Colors.white, fontSize: 15), textAlign: TextAlign.center),
                                )),
                            onTap: () => {FlutterLocalization.instance.translate("es"), RestartWidget.restartApp(context, false, false, true)},
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            child: Container(
                                width: (screenWidth / 3.5) - 3,
                                height: 57,
                                decoration: BoxDecoration(gradient: FlutterLocalization.instance.currentLocale!.languageCode == "de" ? selectedGradient : unselectedGradient),
                                // color: HexColor.fromHex("#353539"),
                                child: const Center(
                                  child: Text(
                                    "DEUTSCH",
                                    style: TextStyle(color: Colors.white, fontSize: 15),
                                  ),
                                )),
                            onTap: () => {FlutterLocalization.instance.translate("de"), RestartWidget.restartApp(context, false, false, true)},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  // width: 398,
                  color: (ColorsInfo.IsDark ? HexColor.fromHex(ColorsInfo.main_dark) : Colors.white),
                  padding: const EdgeInsets.all(edgePadding),
                  child: Column(
                    children: [
                      Text(
                        AppLocale.settings_other.getString(context),
                        style: TextStyle(
                          color: ColorsInfo.IsDark ? Colors.white : HexColor.fromHex("#353539"),
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            child: Container(
                                width: (screenWidth / 3.5) - 3,
                                height: 57,
                                color: ColorsInfo.IsDark ? HexColor.fromHex("#8E8E8E") : HexColor.fromHex("#353539"),
                                child: Center(
                                  child: Text(AppLocale.settings_reset_purchases.getString(context),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.center),
                                )),
                            onTap: () async => {
                              // await SubscriptionManager.restorePurchases(context)
                              await FileManager.clearCache(context)
                            },
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            child: Container(
                                width: (screenWidth / 3.5) - 3,
                                height: 57,
                                color: ColorsInfo.IsDark ? HexColor.fromHex("#8E8E8E") : HexColor.fromHex("#353539"),
                                child: Center(
                                  child: Text(AppLocale.settings_feedback.getString(context), style: const TextStyle(color: Colors.white, fontSize: 15), textAlign: TextAlign.center),
                                )),
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FeedbackScreen(),
                                ),
                              )
                            },
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            child: Container(
                                width: (screenWidth / 3.5) - 3,
                                height: 57,
                                decoration: BoxDecoration(gradient: LinearGradient(colors: [HexColor.fromHex("#5092F0"), HexColor.fromHex("#636CE1")], begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight)),
                                // color: HexColor.fromHex("#353539"),
                                child: Center(
                                  child: Text(
                                    AppLocale.settings_rate_the_app.getString(context),
                                    style: const TextStyle(color: Colors.white, fontSize: 15),
                                  ),
                                )),
                            onTap: () async => {
                              if (await InAppReview.instance.isAvailable()) {InAppReview.instance.requestReview()}
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
