import 'package:flutter/material.dart';
import 'package:minecrafteria/extensions/color_extension.dart';

enum ColorType { Main, Second }

mixin ColorsInfo {
  static bool IsDark = true;

  static const String main_light = "#EBEAF0";
  static const String second_light = "#FFFFFF";

  static const String main_dark = "#586067";
  static const String second_dark = "#3B4246";

  static Color GetColor(ColorType color) {
    if (color == ColorType.Main) return HexColor.fromHex(IsDark ? main_dark : main_light);
    if (color == ColorType.Second) return HexColor.fromHex(IsDark ? second_dark : second_light);

    return Colors.white;
  }

  static LinearGradient ColorToGradient(Color color) {
    return LinearGradient(colors: [color, color], begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight);
  }

  static Widget GetBackButton() {
    return SizedBox(
      width: 33,
      height: 33,
      child: ShaderMask(
        shaderCallback: (rect) {
          return (ColorsInfo.IsDark ? ColorsInfo.ColorToGradient(Colors.white) : ColorsInfo.ColorToGradient(HexColor.fromHex(main_dark))).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
        },
        blendMode: BlendMode.srcATop,
        child: Image.asset(
          'assets/images/icon_pix_back.png',
          // height: 400,d
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
