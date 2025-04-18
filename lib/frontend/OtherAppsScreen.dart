import 'dart:io';
import 'package:flutter/material.dart';
import 'package:minecrafteria/backend/AdManager.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'AppLocale.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:minecrafteria/extensions/color_extension.dart';
import 'ColorsInfo.dart';

class OtherAppsScreen extends StatefulWidget {
  const OtherAppsScreen({super.key});

  @override
  State<OtherAppsScreen> createState() => _OtherAppsScreenState();
}

class AppInfo {
  String name;
  String iconName;
  String iosDownloadUrl;
  String androidDownloadUrl;

  AppInfo(this.name, this.iconName, this.iosDownloadUrl, this.androidDownloadUrl);
}

class _OtherAppsScreenState extends State<OtherAppsScreen> {
  final PageController _pageController = PageController();

  List<AppInfo> apps = [
    AppInfo("Addons & Mods for Minecraft PE", "addons-mcpe.png", "", "https://play.google.com/store/apps/details?id=com.addons.mods.minecraft.pe"),
    AppInfo("Idle Restaurant Simulator", "idle-restaurant.png", "https://apps.apple.com/us/app/idle-restaurant-simulator/id6476298208", "https://play.google.com/store/apps/details?id=com.idle.restaurant.simulator.clicker.tycoon.games"),
    AppInfo("House Mods for Minecraft PE", "mcpe-houses.png", "https://apps.apple.com/us/app/house-mods-for-minecraft-pe/id6584520426", "https://play.google.com/store/apps/details?id=com.house.mods.minecraft.pe"),
    AppInfo("Furniture for Minecraft PE", "mcpe-furniture.png", "https://apps.apple.com/app/furniture-for-mcpe/id6648777412", "https://play.google.com/store/apps/details?id=com.furniture.mod.minecraft.pe"),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isPad = screenWidth > 700;
    int crossAxisCount = screenWidth > 700 ? 2 : (screenWidth < 500 ? 1 : 2);

    // Filter the apps to include only those with valid URLs
    List<AppInfo> validApps = apps.where((app) {
      return (Platform.isAndroid && app.androidDownloadUrl.isNotEmpty) || (Platform.isIOS && app.iosDownloadUrl.isNotEmpty);
    }).toList();

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
        title: Text(
          AppLocale.main_side_other_apps.getString(context),
          style: TextStyle(color: ColorsInfo.IsDark ? Colors.white : HexColor.fromHex(ColorsInfo.main_dark)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          color: ColorsInfo.GetColor(ColorType.Second),
          child: isPad
              ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 4,
                    mainAxisExtent: 200,
                    childAspectRatio: 1,
                  ),
                  itemCount: validApps.length,
                  itemBuilder: (context, index) {
                    var app = validApps[index];
                    return (Platform.isAndroid && app.androidDownloadUrl != "") || (Platform.isIOS && app.iosDownloadUrl != "")
                        ? InkWell(
                            onTap: () {
                              launchUrlString(Platform.isIOS ? app.iosDownloadUrl : app.androidDownloadUrl);
                            },
                            child: Card(
                              color: ColorsInfo.GetColor(ColorType.Main),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              elevation: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                                    child: Image.asset("assets/images/${app.iconName}", width: 165, height: 165, fit: BoxFit.cover),
                                  ),
                                  SizedBox(
                                    width: 370,
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            app.name,
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ColorsInfo.IsDark ? Colors.white : Colors.black),
                                            maxLines: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                )
              : ListView.builder(
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    var app = apps[index];
                    return (Platform.isAndroid && app.androidDownloadUrl != "") || (Platform.isIOS && app.iosDownloadUrl != "")
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                                onTap: () {
                                  launchUrlString(Platform.isIOS ? app.iosDownloadUrl : app.androidDownloadUrl);
                                },
                                child: Card(
                                  color: ColorsInfo.GetColor(ColorType.Main),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  elevation: 0,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                                        child: Image.asset("assets/images/${app.iconName}", width: 100, height: 100, fit: BoxFit.cover),
                                      ),
                                      SizedBox(
                                        width: 240,
                                        child: Padding(
                                          padding: const EdgeInsets.all(18.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                app.name,
                                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ColorsInfo.IsDark ? Colors.white : Colors.black),
                                                maxLines: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          )
                        : const SizedBox.shrink();
                  },
                ),
        ),
      ),
    );
  }
}
