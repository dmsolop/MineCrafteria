import 'dart:async';

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

  void _pollForReady() {
    final loader = SingleNativeAdLoader();
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (loader.isAdReady(widget.keyId)) {
        LogService.log('[NativeAdSlot] 🟢 Ad became ready by polling → keyId=${widget.keyId}');
        timer.cancel();
        widget.onLoaded?.call(); // 🔹 це погасить прелоадер
      }
    });
  }

  void _loadAdOnce() {
    if (_hasLoadedOnce) return;
    _hasLoadedOnce = true;

    final startTime = DateTime.now();
    LogService.log('[NativeAdSlot] _loadAdOnce START → keyId=${widget.keyId}');

    Future.microtask(() {
      final launchTime = DateTime.now();
      LogService.log('[NativeAdSlot] ⏱ Ad load triggered → keyId=${widget.keyId}, delay=${launchTime.difference(startTime).inMilliseconds}ms');

      SingleNativeAdLoader().loadAd(
        context,
        keyId: widget.keyId,
        height: widget.height,
        onLoaded: () {
          final loadedTime = DateTime.now();
          LogService.log('[NativeAdSlot] ✅ onLoaded → keyId=${widget.keyId}, delay=${loadedTime.difference(launchTime).inMilliseconds}ms');

          if (!mounted) return;
          LogService.log('[NativeAdSlot] onLoaded → keyId=${widget.keyId}');
          setState(() {}); // 🔹 Тепер _adWidget оновиться автоматично
          widget.onLoaded?.call(); // 🔹 Додатковий кастомний колбек
        },
      ).then((ad) {
        final endTime = DateTime.now();
        if (!mounted || ad == null) return;
        LogService.log('[NativeAdSlot] 🧩 loadAd complete → keyId=${widget.keyId}, delay=${endTime.difference(startTime).inMilliseconds}ms');
        setState(() {
          _adWidget = ad;
        });
        LogService.log('[NativeAdSlot] _adWidget set via setState → keyId=${widget.keyId}, runtimeType=${ad.runtimeType}');
      });
      _pollForReady();
    });
  }

  @override
  void dispose() {
    SingleNativeAdLoader().disposeAdByKey(widget.keyId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LogService.log('[NativeAdSlot] build START → keyId=${widget.keyId}, hasLoaded=$_hasLoadedOnce, widget=${_adWidget.runtimeType}');
    return SizedBox(height: widget.height, child: _adWidget);
  }
}
