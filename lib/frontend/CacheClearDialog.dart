import 'package:flutter/material.dart';
import 'ColorsInfo.dart';

class CacheClearDialog extends StatelessWidget {
  const CacheClearDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorsInfo.GetColor(ColorType.Main),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ColorsInfo.GetColor(ColorType.Main),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: ColorsInfo.IsDark ? Colors.white : Colors.black,
            ),
            // SizedBox(height: 20),
            // Text(AppLocale.popup_loading.getString(context), style: TextStyle(fontFamily: 'Joystix', color: ColorsInfo.IsDark ? Colors.white : Colors.black),)
          ],
        ),
      ),
    );
  }
}
