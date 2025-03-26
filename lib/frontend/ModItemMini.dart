import 'package:flutter/material.dart';
import 'package:morph_mods/backend/AccessKeys.dart';
import 'ColorsInfo.dart';
import 'ModItemData.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ModItemMini extends StatefulWidget {
  final ModItemData modItemData;
  final bool compact;

  const ModItemMini({
    super.key,
    required this.modItemData,
    this.compact = false,
  });

  @override
  _ModItemMiniState createState() => _ModItemMiniState();
}

class _ModItemMiniState extends State<ModItemMini> {
  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return ClipRRect(
        borderRadius: BorderRadius.zero,
        child: Image.network(
          widget.modItemData.imageUrl,
          headers: {
            "CF-Access-Client-Secret": AccessKeys.client_secret,
            "CF-Access-Client-Id": AccessKeys.client_id,
          },
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
        ),
      );
    }

    return Card(
      color: ColorsInfo.GetColor(ColorType.Main),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                child: Image.network(widget.modItemData.imageUrl, headers: {"CF-Access-Client-Secret": AccessKeys.client_secret, "CF-Access-Client-Id": AccessKeys.client_id}, width: 1000, height: MediaQuery.of(context).size.width > 700 ? 140 : 150, fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                  return loadingProgress == null
                      ? child
                      : SizedBox(
                          width: 1000,
                          height: 70,
                          child: Center(
                            child: Container(
                              child: LoadingAnimationWidget.horizontalRotatingDots(color: Colors.white, size: 50),
                            ),
                          ),
                        );
                }),
              ),
              // Image.network(widget.modItemData.imageUrl, width: 1000, height: MediaQuery.of(context).size.width > 700 ? 70 : 85, fit: BoxFit.cover),
              Transform.scale(
                alignment: Alignment.topRight,
                scale: 0.7,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Image.asset(
                      widget.modItemData.isPremium ? 'assets/images/mod_cardmini_overlay_premium.png' : 'assets/images/mod_cardmini_overlay_ads.png',
                      width: widget.modItemData.isPremium || widget.modItemData.isRewarded ? 55 : 0,
                      height: widget.modItemData.isPremium || widget.modItemData.isRewarded ? 55 : 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Transform.scale(
            alignment: Alignment.topLeft,
            scale: 0.7,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text(
                      widget.modItemData.title,
                      // textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ColorsInfo.IsDark ? Colors.white : Colors.black),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
