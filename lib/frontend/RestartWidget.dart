import 'package:flutter/material.dart';

class RestartWidget extends StatefulWidget {
  const RestartWidget(this.child, {super.key});

  static bool settings = false;
  static bool languagePhone = false;
  static bool settingsPad = false;

  final Widget child;

  static void restartApp(BuildContext context, bool restartToSettings,
      bool restartToLanguagePhone, bool restartToSettingsPad) {
    context.findAncestorStateOfType<_RestartWidgetState>()!.restartApp(
        restartToSettings, restartToLanguagePhone, restartToSettingsPad);
  }

  static void restartState(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()!.restartState();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartState() {
    setState(() {
      key = UniqueKey();
    });
  }

  void restartApp(bool restartToSettings, bool restartToLanguagePhone,
      bool restartToSettingsPad) async {
    setState(() {
      key = UniqueKey();

      RestartWidget.settings = restartToSettings;
      RestartWidget.languagePhone = restartToLanguagePhone;
      RestartWidget.settingsPad = restartToSettingsPad;

      // await Future.delayed(Duration(seconds: 3), () {
      //   if(restartToSettingsPad) {
      //     Navigator.pushReplacement(
      //       context,
      //       PageRouteBuilder(
      //         pageBuilder: (context, animation, secondaryAnimation) => SettingsScreenPad(),
      //         transitionDuration: Duration.zero, // No animation for forward transition
      //         reverseTransitionDuration: const Duration(milliseconds: 150), // Animation duration for reverse transition
      //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //           if (animation.status == AnimationStatus.reverse) {
      //             return SlideTransition(
      //               position: Tween<Offset>(
      //                 begin: const Offset(1, 0),
      //                 end: const Offset(0, 0),
      //               ).animate(animation),
      //               child: child,
      //             );
      //           } else {
      //             return child; // No animation for forward transition
      //           }
      //         },
      //       ),
      //     );
      //   }

      //   if(restartToLanguagePhone) {
      //     Navigator.pushReplacement(
      //       context,
      //       PageRouteBuilder(
      //         pageBuilder: (context, animation, secondaryAnimation) => LanguageScreenPhone(),
      //         transitionDuration: Duration.zero, // No animation for forward transition
      //         reverseTransitionDuration: const Duration(milliseconds: 150), // Animation duration for reverse transition
      //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //           if (animation.status == AnimationStatus.reverse) {
      //             return SlideTransition(
      //               position: Tween<Offset>(
      //                 begin: const Offset(1, 0),
      //                 end: const Offset(0, 0),
      //               ).animate(animation),
      //               child: child,
      //             );
      //           } else {
      //             return child; // No animation for forward transition
      //           }
      //         },
      //       ),
      //     );
      //   }

      //   if(restartToSettings) {
      //     Navigator.pushReplacement(
      //       context,
      //       PageRouteBuilder(
      //         pageBuilder: (context, animation, secondaryAnimation) => SettingsScreen(),
      //         transitionDuration: Duration.zero, // No animation for forward transition
      //         reverseTransitionDuration: const Duration(milliseconds: 150), // Animation duration for reverse transition
      //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //           if (animation.status == AnimationStatus.reverse) {
      //             return SlideTransition(
      //               position: Tween<Offset>(
      //                 begin: const Offset(1, 0),
      //                 end: const Offset(0, 0),
      //               ).animate(animation),
      //               child: child,
      //             );
      //           } else {
      //             return child; // No animation for forward transition
      //           }
      //         },
      //       ),
      //     );
      //   }
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
