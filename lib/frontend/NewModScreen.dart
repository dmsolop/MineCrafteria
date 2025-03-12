import 'dart:io';
import 'package:flutter/material.dart';
import 'package:morph_mods/backend/AdManager.dart';
import 'package:morph_mods/frontend/GradientElevatedButton.dart';
import 'AppLocale.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:morph_mods/extensions/color_extension.dart';
import 'ColorsInfo.dart';

class NewModScreen extends StatefulWidget {
  const NewModScreen({super.key});

  static String email = Platform.isIOS ? "" : "";

  @override
  State<NewModScreen> createState() => _NewModScreenState();
}

class _NewModScreenState extends State<NewModScreen> {
  final textNameController = TextEditingController();
  final textDescController = TextEditingController();

  int _activeCategoryIndex = 0;

  final List<Image> _categoryIcons = [
    Image.asset('assets/images/vehicles_category_icon.png'),
    Image.asset('assets/images/items_category_icon.png'),
    Image.asset('assets/images/npcs_category_icon.png'),
    Image.asset('assets/images/weapons_category_icon.png'),
  ];

  @override
  void dispose() {
    textNameController.dispose();
    textDescController.dispose();

    super.dispose();
  }

  String GetModCategory() {
    if (_activeCategoryIndex == 0) return "Vehicles";
    if (_activeCategoryIndex == 1) return "Items";
    if (_activeCategoryIndex == 2) return "NPCs";
    if (_activeCategoryIndex == 3) return "Weapons";

    return "";
  }

  Widget GetCategoryButton(int index, int nameIndex) {
    return SizedBox(
      width: 150,
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: GradientElevatedButton(
          onPressed: () {
            setState(() {
              _activeCategoryIndex = index;
              // _scrollToActiveCategory();
            });
          },
          gradient: _activeCategoryIndex == index
              ? LinearGradient(
                  colors: [
                      HexColor.fromHex("#5092F0"),
                      HexColor.fromHex("#636CE1")
                    ],
                  begin: FractionalOffset.centerLeft,
                  end: FractionalOffset.centerRight)
              : LinearGradient(
                  colors: [
                      ColorsInfo.GetColor(ColorType.Second),
                      ColorsInfo.GetColor(ColorType.Second)
                    ],
                  begin: FractionalOffset.centerLeft,
                  end: FractionalOffset.centerRight),
          child: Row(
            children: [
              SizedBox(
                width: 31,
                height: 31,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: _categoryIcons[index].image,
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        (_activeCategoryIndex == index
                                ? Colors.white
                                : (ColorsInfo.IsDark
                                    ? Colors.white
                                    : HexColor.fromHex("#8E8E8E")))
                            .withOpacity(1),
                        BlendMode.srcATop,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppLocale.categoryIndexToString(nameIndex, context),
                    style: TextStyle(
                        fontSize: 10,
                        color: _activeCategoryIndex == index
                            ? Colors.white
                            : (ColorsInfo.IsDark
                                ? Colors.white
                                : HexColor.fromHex("#8E8E8E"))),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:
          ColorsInfo.IsDark ? HexColor.fromHex("#262626") : Colors.white,
      bottomNavigationBar: AdManager.getBottomBannerBackground(context),
      appBar: AppBar(
        leading: IconButton(
          icon: ColorsInfo.GetBackButton(),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          AppLocale.new_mod_title.getString(context),
          style: TextStyle(
              color: ColorsInfo.IsDark
                  ? Colors.white
                  : HexColor.fromHex(ColorsInfo.main_dark)),
        ),
        backgroundColor: ColorsInfo.GetColor(ColorType.Main),
      ),
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: screenHeight / 1.5,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: Image.asset(screenWidth > 700
                              ? (ColorsInfo.IsDark
                                  ? 'assets/images/new_mod_screen_ipad_dark.png'
                                  : 'assets/images/new_mod_screen_ipad.png')
                              : (ColorsInfo.IsDark
                                  ? 'assets/images/new_mod_screen_dark.png'
                                  : 'assets/images/new_mod_screen.png'))
                          .image)),
            ),
            Container(
              alignment: Alignment.center,
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          color: ColorsInfo.GetColor(ColorType.Main),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 900),
                                  child: Text(
                                    AppLocale.new_mod_subtitle1
                                        .getString(context),
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: ColorsInfo.IsDark
                                            ? Colors.white
                                            : Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                  controller: textNameController,
                                  textAlign: TextAlign.start,
                                  textAlignVertical: TextAlignVertical.top,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                  decoration: InputDecoration(
                                      filled: true,
                                      contentPadding: const EdgeInsets.all(15),
                                      fillColor:
                                          ColorsInfo.GetColor(ColorType.Second),
                                      hintStyle: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                      labelStyle: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.zero,
                                          borderSide: BorderSide.none,
                                          gapPadding: 0),
                                      hintText: AppLocale.new_mod_hint1
                                          .getString(context)),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 900),
                                  child: Text(
                                    AppLocale.new_mod_subtitle2
                                        .getString(context),
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: ColorsInfo.IsDark
                                            ? Colors.white
                                            : Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 200,
                                  child: TextField(
                                    controller: textDescController,
                                    textAlign: TextAlign.start,
                                    textAlignVertical: TextAlignVertical.top,
                                    expands: true,
                                    minLines: null,
                                    maxLines: null,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                    decoration: InputDecoration(
                                        filled: true,
                                        contentPadding:
                                            const EdgeInsets.all(15),
                                        fillColor: ColorsInfo.GetColor(
                                            ColorType.Second),
                                        hintStyle: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                        labelStyle: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                        border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.zero,
                                            borderSide: BorderSide.none,
                                            gapPadding: 0),
                                        hintText: AppLocale.new_mod_hint2
                                            .getString(context)),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GetCategoryButton(0, 4),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    GetCategoryButton(1, 6),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GetCategoryButton(2, 2),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    GetCategoryButton(3, 3),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Container(
                          height: 57,
                          constraints: const BoxConstraints(maxWidth: 500),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                HexColor.fromHex("#5092F0"),
                                HexColor.fromHex("#636CE1")
                              ],
                                  begin: FractionalOffset.centerLeft,
                                  end: FractionalOffset.centerRight)),
                          // color: HexColor.fromHex("#353539"),
                          child: Center(
                            child: Text(
                              AppLocale.new_mod_button.getString(context),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                          )),
                    ),
                    onTap: () => {},
                  ),
                  // SizedBox(height: 20,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
