import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:morph_mods/backend/AccessKeys.dart';
import 'package:morph_mods/extensions/color_extension.dart';
import 'package:morph_mods/extensions/text_extension.dart';
import 'ColorsInfo.dart';
import 'ModItemData.dart';

class ModItem extends StatefulWidget {
  final ModItemData modItemData;

  const ModItem({super.key, required this.modItemData});

  @override
  _ModItemState createState() => _ModItemState();
}

class _ModItemState extends State<ModItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorsInfo.GetColor(ColorType.Main),
      shape: const RoundedRectangleBorder(
        // col: gradient,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                child: Image.network(widget.modItemData.imageUrl,
                    headers: {
                      "CF-Access-Client-Secret": AccessKeys.client_secret,
                      "CF-Access-Client-Id": AccessKeys.client_id
                    },
                    width: 1000,
                    height: 170,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                  return loadingProgress == null
                      ? child
                      : SizedBox(
                          width: 1000,
                          height: 150,
                          child: Center(
                            child: Container(
                              child:
                                  LoadingAnimationWidget.horizontalRotatingDots(
                                      color: Colors.white, size: 50),
                            ),
                          ),
                        );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Image.asset(
                    widget.modItemData.isPremium
                        ? 'assets/images/mod_card_overlay_premium.png'
                        : 'assets/images/button_ads.png',
                    width: widget.modItemData.isPremium ||
                            widget.modItemData.isRewarded
                        ? 40
                        : 0,
                    height: widget.modItemData.isPremium ||
                            widget.modItemData.isRewarded
                        ? 40
                        : 0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Align(
                    //   alignment: Alignment.topRight,
                    //   child: Image.asset(
                    //     'assets/images/mod_card_overlay_favorite.png',
                    //     width: widget.modItemData.favo ? 30 : 0,
                    //     height: widget.modItemData.cached ? 30 : 0,
                    //   ),
                    // ),

                    Align(
                      alignment: Alignment.topRight,
                      child: Image.asset(
                        'assets/images/mod_card_overlay_cached.png',
                        width: widget.modItemData.cached ? 30 : 0,
                        height: widget.modItemData.cached ? 30 : 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 218,
                  child: Text(
                    TextExtension.convertUTF8(widget.modItemData.title),
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: ColorsInfo.IsDark ? Colors.white : Colors.black,
                        overflow: TextOverflow.ellipsis,
                        fontFamily: "Joystick_Bold"),
                    maxLines: 1,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/file_icon.png',
                        width: 15, height: 15),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      widget.modItemData.fileSize,
                      style: TextStyle(
                          fontSize: 10, color: HexColor.fromHex("#8E8E8E")),
                    ),
                    const SizedBox(width: 8), // Space between icons
                    Image.asset('assets/images/downloads_icon.png',
                        width: 15, height: 15),
                    const SizedBox(
                      width: 4,
                    ),
                    Text('${widget.modItemData.downloads}',
                        style: TextStyle(
                            color: HexColor.fromHex("#8E8E8E"), fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
