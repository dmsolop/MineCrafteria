import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:minecrafteria/backend/AdManager.dart';
import 'package:minecrafteria/backend/FileManager.dart';
import 'package:minecrafteria/backend/ModsManager.dart';
import 'package:in_app_review/in_app_review.dart';
import 'ColorsInfo.dart';
import 'FeedbackScreen.dart';
import 'InstructionScreen.dart';
import 'LanguageScreenPhone.dart';
import 'package:minecrafteria/extensions/color_extension.dart';
import 'AppLocale.dart';
import 'RestartWidget.dart';

const double edgePadding = 20;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  _SettingsScreenState();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      bottomNavigationBar: AdManager.getBottomBannerBackground(context),
      backgroundColor: ColorsInfo.IsDark ? ColorsInfo.GetColor(ColorType.Second) : HexColor.fromHex("#F8F8F8"),
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
                Container(
                  color: ColorsInfo.IsDark ? ColorsInfo.GetColor(ColorType.Main) : Colors.white,
                  padding: const EdgeInsets.all(edgePadding),
                  child: Column(
                    children: [
                      InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocale.settings_language.getString(context), style: TextStyle(fontSize: 15, color: ColorsInfo.IsDark ? Colors.white : Colors.black)),
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
                              builder: (context) => const LanguageScreenPhone(),
                            ),
                          )
                        },
                      ),
                      const SizedBox(height: 40),
                      InkWell(
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
                      const SizedBox(height: 40),
                      InkWell(
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
                          RestartWidget.restartApp(context, true, false, false)
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  // width: 398,
                  color: ColorsInfo.IsDark ? ColorsInfo.GetColor(ColorType.Main) : Colors.white,
                  padding: const EdgeInsets.all(edgePadding),
                  child: Column(
                    children: [
                      InkWell(
                        child: Container(
                            height: 57,
                            color: ColorsInfo.IsDark ? HexColor.fromHex("#8E8E8E") : HexColor.fromHex(ColorsInfo.main_dark),
                            child: Center(
                              child: Text(
                                AppLocale.settings_reset_purchases.getString(context),
                                style: const TextStyle(color: Colors.white, fontSize: 15),
                              ),
                            )),
                        onTap: () async => {
                          // await SubscriptionManager.restorePurchases(context)
                          await FileManager.clearCache(context)
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        child: Container(
                            height: 57,
                            color: ColorsInfo.IsDark ? HexColor.fromHex("#8E8E8E") : HexColor.fromHex(ColorsInfo.main_dark),
                            child: Center(
                              child: Text(
                                AppLocale.settings_feedback.getString(context),
                                style: const TextStyle(color: Colors.white, fontSize: 15),
                              ),
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
                        height: 20,
                      ),
                      InkWell(
                        child: Container(
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
