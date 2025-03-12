import 'dart:io';

import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:morph_mods/frontend/AppLocale.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileOpener {
  static const MethodChannel _channel =
      MethodChannel('com.morph.mods.minecraft.addons/file_opener');

  static Future<Directory> getTempDirectory() async {
    if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    } else {
      return await getApplicationCacheDirectory();
    }
  }

  static Future<void> openFileWithApp(String filePath, double screenWidth,
      double screenHeight, BuildContext context) async {
    if (!(await AppCheck().isAppInstalled("com.mojang.minecraftpe")) &&
        Platform.isAndroid) {
      Navigator.of(context, rootNavigator: true).pop();
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Center(
                child: Text(
                  AppLocale.error_app.getString(context),
                  style: const TextStyle(fontFamily: "Joystix"),
                ),
              ),
            ),
          );
        },
      );
      await Future.delayed(const Duration(seconds: 3));
      return;
    }

    if (Platform.isIOS) {
      await Share.shareXFiles([XFile(filePath)],
          sharePositionOrigin:
              Rect.fromLTWH(0, 0, screenWidth, screenHeight / 2));
    } else {
      try {
        await _channel.invokeMethod('openFileWithApp', {'filePath': filePath});
      } on PlatformException catch (e) {
        print("Failed to open file: ${e.message}");
      }
    }
  }
}
