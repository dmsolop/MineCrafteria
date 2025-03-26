import 'dart:math';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../ModItemData.dart';
import 'package:morph_mods/frontend/ModItemMini.dart';
import 'package:morph_mods/backend/CacheManager.dart';
import 'package:morph_mods/frontend/ModDetailScreen.dart';
import 'package:morph_mods/frontend/ModDetailScreenPad.dart';

enum DisplayMode {
  grid,
  scroll,
}

class MiniModList extends StatefulWidget {
  final int count;
  final DisplayMode mode;
  final List<ModItemData> sourceMods;
  final int modListIndex;
  final dynamic modListScreen;
  final dynamic favoriteListScreen;

  const MiniModList({
    super.key,
    required this.count,
    required this.mode,
    required this.sourceMods,
    required this.modListIndex,
    required this.modListScreen,
    required this.favoriteListScreen,
  });

  @override
  State<MiniModList> createState() => _MiniModListState();
}

class _MiniModListState extends State<MiniModList> {
  late final List<ModItemData> _mods;

  @override
  void initState() {
    super.initState();
    final rand = Random();
    final all = widget.sourceMods;

    _mods = List.generate(widget.count, (_) {
      return all[rand.nextInt(all.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_mods.isEmpty) return const SizedBox.shrink();

    return switch (widget.mode) {
      DisplayMode.grid => Column(
          children: [
            for (int i = 0; i < _mods.length; i += 2)
              Row(
                children: [
                  Expanded(child: _buildMiniMod(_mods[i])),
                  if (i + 1 < _mods.length) Expanded(child: _buildMiniMod(_mods[i + 1])),
                ],
              ),
          ],
        ),
      DisplayMode.scroll => SizedBox(
          height: 197,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _mods.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildMiniMod(_mods[i]),
            ),
          ),
        ),
    };
  }

  Widget _buildMiniMod(ModItemData modItem) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2.2,
      height: 197,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MediaQuery.of(context).size.width > 700
                  ? ModDetailScreenPadWidget(
                      modItem: modItem,
                      modListScreen: widget.modListScreen,
                      favoritesListScreen: widget.favoriteListScreen,
                      modListIndex: widget.modListIndex,
                    )
                  : ModDetailScreenWidget(
                      modItem: modItem,
                      modListScreen: widget.modListScreen,
                      favoritesListScreen: widget.favoriteListScreen,
                      modListIndex: widget.modListIndex,
                    ),
            ),
          );
        },
        child: VisibilityDetector(
          key: Key(modItem.imageUrl + modItem.isFirestoreChecked.toString()),
          onVisibilityChanged: (visibility) async {
            if (visibility.visibleFraction > 0) {
              bool cached = await CacheManager.isCacheAvailable(modItem.downloadURL);
              if (mounted && modItem.cached != cached) {
                setState(() {
                  modItem.cached = cached;
                });
              }
            }
          },
          child: ModItemMini(modItemData: modItem),
        ),
      ),
    );
  }
}
