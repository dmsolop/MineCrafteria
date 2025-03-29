import 'package:flutter/material.dart';
import 'package:morph_mods/backend/native_ads/SingleNativeAdLoader.dart';

class NativeAdSlot extends StatefulWidget {
  final double height;
  final String keyId; // унікальний ключ для ідентифікації реклами

  const NativeAdSlot({super.key, required this.height, required this.keyId});

  @override
  State<NativeAdSlot> createState() => _NativeAdSlotState();
}

class _NativeAdSlotState extends State<NativeAdSlot> {
  Widget _adWidget = const SizedBox.shrink();
  bool _loading = true;
  bool _hasLoadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAdOnce();
  }

  void _loadAdOnce() {
    if (_hasLoadedOnce) return;
    _hasLoadedOnce = true;

    SingleNativeAdLoader().loadAd(context, height: widget.height).then((ad) {
      if (!mounted) return;
      setState(() {
        _adWidget = ad ?? const SizedBox.shrink();
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    SingleNativeAdLoader().disposeAllAds();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _adWidget;
  }
}
