import 'package:flutter/material.dart';
import 'package:minecrafteria/backend/AdManager.dart';
import 'AppLocale.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:minecrafteria/extensions/color_extension.dart';
import 'RestartWidget.dart';
import 'ColorsInfo.dart';

const double edgePadding = 20;

final LinearGradient selectedGradient = LinearGradient(colors: [HexColor.fromHex("#5E53F1"), HexColor.fromHex("#5E53F1")], begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight);
final LinearGradient unselectedGradient =
    LinearGradient(colors: [ColorsInfo.IsDark ? HexColor.fromHex("#30353A") : HexColor.fromHex(ColorsInfo.main_dark), ColorsInfo.IsDark ? HexColor.fromHex("#30353A") : HexColor.fromHex(ColorsInfo.main_dark)], begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight);

class LanguageScreenPhone extends StatelessWidget {
  const LanguageScreenPhone({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: AdManager.getBottomBannerBackground(context),
        backgroundColor: ColorsInfo.GetColor(ColorType.Main),
        appBar: AppBar(
          leading: IconButton(
            icon: ColorsInfo.GetBackButton(),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          backgroundColor: ColorsInfo.GetColor(ColorType.Main),
          title: Text(
            AppLocale.settings_language.getString(context),
            style: TextStyle(color: ColorsInfo.IsDark ? Colors.white : HexColor.fromHex(ColorsInfo.main_dark)),
          ),
        ),
        body: Container(
          color: ColorsInfo.GetColor(ColorType.Second),
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 482,
                  color: ColorsInfo.GetColor(ColorType.Second),
                  padding: const EdgeInsets.all(edgePadding),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            child: Container(
                              height: 57,
                              width: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.width > 700 ? 2.1 : 2.4),
                              decoration: BoxDecoration(
                                gradient: FlutterLocalization.instance.currentLocale!.languageCode == "en" ? selectedGradient : unselectedGradient,
                                borderRadius: BorderRadius.circular(35),
                              ),
                              child: const Center(
                                child: Text(
                                  "ENGLISH",
                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                ),
                              ),
                            ),
                            onTap: () => {FlutterLocalization.instance.translate("en"), RestartWidget.restartApp(context, false, true, false)},
                          ),
                          InkWell(
                            child: Container(
                                height: 57,
                                width: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.width > 700 ? 2.1 : 2.4),
                                decoration: BoxDecoration(
                                  gradient: FlutterLocalization.instance.currentLocale!.languageCode == "ru" ? selectedGradient : unselectedGradient,
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                child: const Center(
                                  child: Text(
                                    "РУССКИЙ",
                                    style: TextStyle(color: Colors.white, fontSize: 15),
                                  ),
                                )),
                            onTap: () => {FlutterLocalization.instance.translate("ru"), RestartWidget.restartApp(context, false, true, false)},
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
                                height: 57,
                                width: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.width > 700 ? 2.1 : 2.4),
                                decoration: BoxDecoration(
                                  gradient: FlutterLocalization.instance.currentLocale!.languageCode == "fr" ? selectedGradient : unselectedGradient,
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                // color: HexColor.fromHex("#353539"),
                                child: const Center(
                                  child: Text(
                                    "FRENCH",
                                    style: TextStyle(color: Colors.white, fontSize: 15),
                                  ),
                                )),
                            onTap: () => {FlutterLocalization.instance.translate("fr"), RestartWidget.restartApp(context, false, true, false)},
                          ),
                          InkWell(
                            child: Container(
                                height: 57,
                                width: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.width > 700 ? 2.1 : 2.4),
                                decoration: BoxDecoration(
                                  gradient: FlutterLocalization.instance.currentLocale!.languageCode == "pt" ? selectedGradient : unselectedGradient,
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                // color: HexColor.fromHex("#353539"),
                                child: const Center(
                                  child: Text(
                                    "PORTUGAL",
                                    style: TextStyle(color: Colors.white, fontSize: 15),
                                  ),
                                )),
                            onTap: () => {FlutterLocalization.instance.translate("pt"), RestartWidget.restartApp(context, false, true, false)},
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
                                height: 57,
                                width: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.width > 700 ? 2.1 : 2.4),
                                decoration: BoxDecoration(
                                  gradient: FlutterLocalization.instance.currentLocale!.languageCode == "es" ? selectedGradient : unselectedGradient,
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                // color: HexColor.fromHex("#353539"),
                                child: const Center(
                                  child: Text(
                                    "SPANISH",
                                    style: TextStyle(color: Colors.white, fontSize: 15),
                                  ),
                                )),
                            onTap: () => {FlutterLocalization.instance.translate("es"), RestartWidget.restartApp(context, false, true, false)},
                          ),
                          InkWell(
                            child: Container(
                                height: 57,
                                width: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.width > 700 ? 2.1 : 2.4),
                                decoration: BoxDecoration(
                                  gradient: FlutterLocalization.instance.currentLocale!.languageCode == "de" ? selectedGradient : unselectedGradient,
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                // color: HexColor.fromHex("#353539"),
                                child: const Center(
                                  child: Text(
                                    "DEUTSCH",
                                    style: TextStyle(color: Colors.white, fontSize: 15),
                                  ),
                                )),
                            onTap: () => {FlutterLocalization.instance.translate("de"), RestartWidget.restartApp(context, false, true, false)},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
