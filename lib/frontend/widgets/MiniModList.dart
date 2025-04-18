import 'dart:math';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../backend/AdManager.dart';
import '../../main.dart';
import '../ModItemData.dart';
import 'package:minecrafteria/frontend/ModItemMini.dart';
import 'package:minecrafteria/backend/CacheManager.dart';
import 'package:minecrafteria/frontend/ModDetailScreen.dart';
import 'package:minecrafteria/frontend/ModDetailScreenPad.dart';
import '../../backend/LogService.dart';

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
      DisplayMode.grid => GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _mods.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 349 / 243, // 👈 або 1.44
          ),
          itemBuilder: (context, index) {
            return _buildMiniMod(_mods[index], 349 / 243);
          },
        ),
      DisplayMode.scroll => SizedBox(
          height: 197,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _mods.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildMiniMod(_mods[i], 1.0),
            ),
          ),
        ),
    };
  }

  Widget _buildMiniMod(ModItemData modItem, double aspectRatio) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 24) / 2; // 🔹 12+12 padding або spacing
    LogService.log("MiniModList build() triggered");

    return SizedBox(
      width: itemWidth,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: InkWell(
          onTap: () async {
            final mod = modItem;
            final allowEnter = await AdManager.handleRewardedEntry(
              mod: mod,
              refreshUI: () => setState(() {}),
            );
            if (!allowEnter) return;

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
            child: ModItemMini(
              modItemData: modItem,
              compact: widget.mode == DisplayMode.grid,
            ),
          ),
        ),
      ),
    );
  }
}
