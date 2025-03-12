import 'dart:io';

import 'package:flutter/material.dart';
import 'package:morph_mods/backend/AdManager.dart';
import 'AppLocale.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:morph_mods/extensions/color_extension.dart';
import 'ColorsInfo.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  static String email = Platform.isIOS ? "" : "";

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
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
          AppLocale.feedback_title.getString(context),
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
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          color: ColorsInfo.GetColor(ColorType.Main),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 900),
                                  child: Text(
                                    AppLocale.feedback_desc.getString(context),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: ColorsInfo.IsDark
                                            ? Colors.white
                                            : Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  height: 350,
                                  child: TextField(
                                    controller: textController,
                                    expands: true,
                                    minLines: null,
                                    maxLines: null,
                                    textAlign: TextAlign.start,
                                    textAlignVertical: TextAlignVertical.top,
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
                                        hintText: 'Feedback'),
                                  ),
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
                              AppLocale.feedback_button.getString(context),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                          )),
                    ),
                    onTap: () => {
                      // launchUrlString(Mailto(
                      //   to: [FeedbackScreen.email],
                      //   subject: 'Addons for Melon Sandbox: Feedback',
                      //   body: textController.text
                      // ).toString()),
                    },
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
