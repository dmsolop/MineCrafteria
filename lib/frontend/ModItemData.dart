enum ModCategory {
  Morph,
  All,
  Top,
  Mods,
  Maps,
  Textures,
  Houses,
}

class ModItemData {
  String imageUrl;
  String title;
  String description;
  String author;
  List<int> rating;
  int downloads;
  String fileSize; // Add file size in MB
  bool isPremium;
  bool isRewarded;
  bool cached;
  bool favorite;
  final int categoryIndex;
  final bool isMod;
  final String authorURL;
  final String downloadURL;
  final ModCategory category;

  bool hasTags;
  List<String> screenshots;

  bool isFirestoreChecked;

  String getModID() {
    return "$title-$author";
  }

  ModItemData(
      {required this.imageUrl,
      required this.title,
      required this.description,
      required this.category,
      required this.author,
      required this.rating,
      required this.downloads,
      required this.categoryIndex,
      required this.fileSize, // Initialize file size
      required this.isPremium,
      required this.authorURL,
      required this.downloadURL,
      required this.isFirestoreChecked,
      required this.hasTags,
      required this.screenshots,
      required this.isRewarded,
      required this.cached,
      required this.favorite,
      required this.isMod});
}
