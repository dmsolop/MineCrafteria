import 'package:flutter/material.dart';
import 'package:morph_mods/backend/native_ads/SingleNativeAdLoader.dart';
import '../../backend/LogService.dart';

class NativeAdSlot extends StatefulWidget {
  final double height;
  final String keyId;
  final VoidCallback? onLoaded;

  const NativeAdSlot({super.key, required this.height, required this.keyId, this.onLoaded});

  @override
  State<NativeAdSlot> createState() => _NativeAdSlotState();
}

class _NativeAdSlotState extends State<NativeAdSlot> {
  Widget _adWidget = const SizedBox.shrink();
  // bool _loading = true;
  bool _hasLoadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAdOnce();
  }

  void _loadAdOnce() {
    if (_hasLoadedOnce) return;
    _hasLoadedOnce = true;

    LogService.log('[NativeAdSlot] _loadAdOnce → keyId=${widget.keyId}');

    Future.microtask(() {
      LogService.log('[NativeAdSlot] Calling loadAd for keyId=${widget.keyId}');
      SingleNativeAdLoader().loadAd(
        context,
        keyId: widget.keyId,
        height: widget.height,
        onLoaded: () {
          if (!mounted) return;
          LogService.log('[NativeAdSlot] onLoaded → keyId=${widget.keyId}');
          setState(() {}); // 🔹 Тепер _adWidget оновиться автоматично
          widget.onLoaded?.call(); // 🔹 Додатковий кастомний колбек
        },
      ).then((ad) {
        if (!mounted || ad == null) return;
        LogService.log('[NativeAdSlot] loadAd() complete → keyId=${widget.keyId}');
        setState(() {
          _adWidget = ad;
        });
      });
    });
  }

  // void _loadAdOnce() {
  //   if (_hasLoadedOnce) return;
  //   _hasLoadedOnce = true;
  //   LogService.log('[NativeAdSlot] _loadAdOnce → keyId=${widget.keyId}');
  //   Future.microtask(() {
  //     SingleNativeAdLoader().loadAd(context, keyId: widget.keyId, height: widget.height, onLoaded: () {
  //       if (!mounted) return;
  //       // if (mounted) setState(() {});
  //       LogService.log('[NativeAdSlot] onLoaded → keyId=${widget.keyId}');
  //       widget.onLoaded?.call();
  //     }).then((ad) {
  //       if (!mounted || ad == null) return;
  //       LogService.log('[NativeAdSlot] loadAd() complete → keyId=${widget.keyId}');
  //       setState(() {
  //         _adWidget = ad; //?? const SizedBox.shrink();
  //         // _loading = false;
  //       });
  //     });
  //   });
  // }

  @override
  void dispose() {
    SingleNativeAdLoader().disposeAdByKey(widget.keyId);
    super.dispose();
  }

  // @override
  // void dispose() {
  //   SingleNativeAdLoader().forceReloadAd(widget.keyId);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: widget.height, child: _adWidget);
  }
}
