import 'package:flutter/material.dart';
import 'package:minecrafteria/backend/AdManager.dart';
import 'AppLocale.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:minecrafteria/extensions/color_extension.dart';
import 'ColorsInfo.dart';

class InstructionScreen extends StatelessWidget {
  const InstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
          AppLocale.settings_instruction.getString(context),
          style: TextStyle(color: ColorsInfo.IsDark ? Colors.white : HexColor.fromHex(ColorsInfo.main_dark), fontFamily: "Joystix_Bold"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: screenWidth > 700 ? 2 : 1, childAspectRatio: 225 / 285, mainAxisSpacing: 10, crossAxisSpacing: 10),
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                // height: 500,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocale.instruction_title_1.getString(context), style: TextStyle(color: HexColor.fromHex("#8E8E8E"), fontSize: 16), textAlign: TextAlign.start),
                    Text(AppLocale.instruction_desc_1.getString(context), style: TextStyle(color: HexColor.fromHex("#8E8E8E"), fontSize: 10), textAlign: TextAlign.start),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 600,
                      // width: 376, height: 601,
                      child: Image.asset('assets/images/instruction_1.png'),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
