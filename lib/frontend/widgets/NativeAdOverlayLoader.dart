import 'package:flutter/material.dart';

class NativeAdOverlayLoader extends StatelessWidget {
  const NativeAdOverlayLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(
          dismissible: false,
          color: Colors.black.withOpacity(0.5),
        ),
        const Center(
          child: CircularProgressIndicator(
            strokeWidth: 4.0,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
          ),
        ),
      ],
    );
  }
}
