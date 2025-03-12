import 'package:flutter/material.dart';
import 'package:morph_mods/backend/AdManager.dart';
import 'package:morph_mods/extensions/color_extension.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:morph_mods/main.dart';
import 'AppLocale.dart';
import 'ModItem.dart';
import 'GradientElevatedButton.dart';
import 'ModItemData.dart';
import 'ModDetailScreen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'ColorsInfo.dart';

class FavoritesModListScreen extends StatefulWidget {
  final List<List<ModItemData>> favMods;

  const FavoritesModListScreen({super.key, required this.favMods});

  @override
  FavoritesModListScreenState createState() =>
      FavoritesModListScreenState(favMods: favMods);
}

List<List<ModItemData>> searchedMods = List.empty();
String searchText = "";

class FavoritesModListScreenState extends State<FavoritesModListScreen> {
  final List<Image> _categoryIcons = [
    Image.asset('assets/images/morph_icon.png'),
    // Image.asset('assets/images/all_mods_category.png'),
    // Image.asset('assets/images/top_category_icon.png'),
    Image.asset('assets/images/mods_icon.png'),
    Image.asset('assets/images/maps_icon.png'),
    Image.asset('assets/images/textures_icon.png'),
    Image.asset('assets/images/houses_icon.png'),
  ];

  List<List<ModItemData>> favMods = List.empty();

  FavoritesModListScreenState({required this.favMods});

  int _activeCategoryIndex = 0;
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    int crossAxisCount = screenWidth > 700 ? 3 : (screenWidth < 500 ? 1 : 2);

    String version = "";

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      version = packageInfo.version;
    });

    return Scaffold(
      bottomNavigationBar: AdManager.getBottomBannerBackground(context),
      backgroundColor: ColorsInfo.GetColor(ColorType.Main),
      appBar: AppBar(
        backgroundColor: ColorsInfo.GetColor(ColorType.Main),
        leading: IconButton(
          icon: ColorsInfo.GetBackButton(),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          AppLocale.favorites_title.getString(context),
          style: TextStyle(
              color: ColorsInfo.IsDark
                  ? Colors.white
                  : HexColor.fromHex(ColorsInfo.main_dark),
              fontFamily: "Joystix_Bold"),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 13, right: 13, top: 8, bottom: 10),
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        hintText: AppLocale.main_top_search.getString(context),
                        border: InputBorder.none,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Image.asset('assets/images/search_icon.png'),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 7),
                        fillColor: ColorsInfo.GetColor(ColorType.Second),
                        filled: true,
                        hintStyle:
                            TextStyle(color: HexColor.fromHex("#8D8D8D"))),
                    onSubmitted: (value) => {
                      setState(() {
                        searchText = value;
                        searchedMods = modService!
                            .searchModsSpecificList(favMods, searchText);
                      })
                    },
                  ),
                ),
              ),
              Container(
                height: 45.0,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(bottom: 8, left: 5),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: crossAxisCount < 3 ? 120 : (screenWidth / 6),
                      height: 45,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GradientElevatedButton(
                          onPressed: () {
                            setState(() {
                              _activeCategoryIndex = index;
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            });
                          },
                          gradient: _activeCategoryIndex == index
                              ? LinearGradient(
                                  colors: [
                                      HexColor.fromHex("#5E53F1"),
                                      HexColor.fromHex("#5E53F1")
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
                                                    : HexColor.fromHex(
                                                        "#8E8E8E")))
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
                                    AppLocale.categoryIndexToString(
                                        index == 0 ? 0 : index + 2, context),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _activeCategoryIndex == index
                                          ? Colors.white
                                          : (ColorsInfo.IsDark
                                              ? Colors.white
                                              : HexColor.fromHex("#8E8E8E")),
                                      fontFamily: "Joystix_Bold",
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: ColorsInfo.GetColor(ColorType.Second),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _activeCategoryIndex = index;
            });
          },
          children: (searchText != "" ? searchedMods : favMods).map((modItems) {
            return Container(
              color: ColorsInfo.GetColor(ColorType.Second),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      mainAxisExtent: 215,
                      childAspectRatio: 225 / 205,
                    ),
                    itemCount: modItems.length,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        // width: 394,
                        // height: 238,
                        child: InkWell(
                            onTap: () async {
                              final value = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ModDetailScreenWidget(
                                    modItem: modItems[index],
                                    modListScreen: null,
                                    favoritesListScreen: this,
                                    modListIndex: _activeCategoryIndex,
                                  ),
                                ),
                              );
                              setState(() {
                                favMods = modService!.getFavoriteMods();
                              });
                            },
                            child: ModItem(
                              modItemData: modItems[index],
                            )),
                      );
                    },
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
