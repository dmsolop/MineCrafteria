import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:morph_mods/backend/AccessKeys.dart';
import 'package:morph_mods/backend/CacheManager.dart';
import 'package:morph_mods/backend/FileOpener.dart';
import 'package:morph_mods/frontend/ModItemData.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class ModService {
  final String jsonUrl =
      'https://${AccessKeys.domain}/mcpe-houses/app/documentsv5.zip';
  final String versionUrl =
      'https://${AccessKeys.domain}/mcpe-houses/app/version.json';

  static Db? mongoDB;
  static SharedPreferences? sharedPreferences;

  bool containsIgnoreCase(String source, String query) {
    return source.toLowerCase().contains(query.toLowerCase());
  }

  List<List<ModItemData>> mods = List.empty();

  void updateModCached(ModItemData modData) async {
    int modListIndex = -1;
    int modIndex = -1;
    ModItemData? modInstance;

    for (final modList in mods) {
      if (modList.any((x) => x.getModID() == modData.getModID())) {
        modListIndex = mods.indexOf(modList);
        modInstance =
            modList.firstWhere((x) => x.getModID() == modData.getModID());
        modIndex = modList.indexOf(modInstance);

        modInstance.cached =
            await CacheManager.isCacheAvailable(modData.downloadURL);

        break;
      }
    }

    if (modListIndex != -1 && modIndex != -1 && modInstance != null) {
      mods[modListIndex][modIndex] = modInstance;
    }
  }

  void updateModRewarded(ModItemData modData) {
    int modListIndex = -1;
    int modIndex = -1;
    ModItemData? modInstance;

    for (final modList in mods) {
      if (modList.any((x) => x.getModID() == modData.getModID())) {
        modListIndex = mods.indexOf(modList);
        modInstance =
            modList.firstWhere((x) => x.getModID() == modData.getModID());
        modIndex = modList.indexOf(modInstance);

        modInstance.isRewarded = false;

        break;
      }
    }

    if (modListIndex != -1 && modIndex != -1 && modInstance != null) {
      mods[modListIndex][modIndex] = modInstance;
    }
  }

  List<List<ModItemData>> searchModsSpecificList(
      List<List<ModItemData>> modsList, String text) {
    List<List<ModItemData>> searchedMods = List.empty(growable: true);

    for (var modsList in modsList) {
      List<ModItemData> searchMods = List.empty(growable: true);

      for (var mod in modsList) {
        if (containsIgnoreCase(mod.title, text)) {
          searchMods.add(mod);
        }
      }

      searchedMods.add(searchMods);
    }

    return searchedMods;
  }

  String decryptAES(String base64Encrypted, String key) {
    try {
      // Convert the Base64 encoded string to bytes
      final encryptedBytes = base64.decode(base64Encrypted);

      // Create the AES key and initialization vector (ECB mode doesn't need IV)
      final keyBytes = utf8.encode(key); // AES-128 requires a 16-byte key

      // Ensure the key length is exactly 16 bytes (128 bits) for AES-128
      if (keyBytes.length != 16) {
        throw ArgumentError('The key must be 16 bytes long.');
      }

      // Create an Encrypter instance for AES
      final aesKey = encrypt.Key(Uint8List.fromList(keyBytes));
      final encrypter =
          encrypt.Encrypter(encrypt.AES(aesKey, mode: encrypt.AESMode.ecb));

      // Decrypt the data
      final decrypted =
          encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes));

      // Convert the decrypted bytes back to a string
      return utf8.decode(decrypted);
    } catch (e) {
      print("Decryption error: $e");
      return "Decryption failed";
    }
  }

  List<List<ModItemData>> searchMods(String text) {
    return searchModsSpecificList(mods, text);
  }

  Future<List<List<ModItemData>>> fetchModItems() async {
    final versionResponse = await http.get(Uri.parse(versionUrl), headers: {
      "CF-Access-Client-Secret": AccessKeys.client_secret,
      "CF-Access-Client-Id": AccessKeys.client_id
    });
    var jsonBody = "";
    print("fetching version from web");
    if (versionResponse.statusCode == 200) {
      print("fetched version success");
      final appDir = await FileOpener.getTempDirectory();

      File fileMods = File('${appDir.path}/mods.json');
      File versionFile = File('${appDir.path}/version.txt');

      bool exists = await fileMods.exists();

      if (!exists) {
        print("temp mod file not exists, downloading...");
        final response = await http.get(Uri.parse(jsonUrl), headers: {
          "Cache-Control": "no-cache",
          "CF-Access-Client-Secret": AccessKeys.client_secret,
          "CF-Access-Client-Id": AccessKeys.client_id
        });

        if (response.statusCode == 200) {
          // Decode the Zip file
          final archive = ZipDecoder().decodeBytes(response.bodyBytes);

          for (final file in archive) {
            if (file.isFile) {
              final data = file.content as List<int>;
              jsonBody = utf8.decode(data);
              await fileMods.writeAsString(jsonBody);
              jsonBody = decryptAES(jsonBody, "tNpPDY8V7Lwb3412");
            }
          }

          print("downloaded successfully");

          // jsonBody = utf8.decode(data);

          await versionFile.writeAsString(versionResponse.body);

          print("written everything and passed to jsonBody");
        }
      } else {
        print("temp mod file exists");

        bool versionFileExists = await versionFile.exists();

        if (versionFileExists) {
          print("version file exists, checking");
          String contents = await versionFile.readAsString();

          if (contents != versionResponse.body) {
            print(
                "current temp version not equals to the new remote version, deleting everything and restarting fetch");

            await fileMods.delete();
            await versionFile.delete();

            return fetchModItems();
          } else {
            try {
              print("everything equals and good, checking json");

              String fileContentsEncrypted = await fileMods.readAsString();
              String fileContents =
                  decryptAES(fileContentsEncrypted, 'tNpPDY8V7Lwb3412');

              Map<String, dynamic> modsJson = jsonDecode(fileContents);
              if (modsJson.isEmpty) throw Exception();
              if (!modsJson.containsKey("mods")) throw Exception();

              print("json is good, passing to jsonBody");

              jsonBody = fileContents;
            } catch (e) {
              print("json is broken, deleting everything and fetching again");
              await fileMods.delete();
              await versionFile.delete();

              return fetchModItems();
            }
          }
        } else {
          print(
              "version file not exists, deleting everything and restarting fetch progress");
          await fileMods.delete();
          return fetchModItems();
        }
      }
    }

    // jsonBody = jsonBody.replaceAll("mcpe-houses.bytecore.space", AccessKeys.domain);

    // Decode the JSON into a map
    Map<String, dynamic> modsJson = jsonDecode(jsonBody);
    List<List<ModItemData>> modsList = List.empty(growable: true);

    int randomList = sharedPreferences!.getInt("random_list") ?? 0;
    var randomizer = Random(randomList);
    var rewardedWatched =
        sharedPreferences!.getStringList("rewardedWatched") ?? [];

    var mainList =
        await getModsFromCollection('all-documents', modsJson, 0, null);

    modsList.add(await getModsFromCollection("morphs", modsJson, 10, null));

    modsList[0].shuffle(randomizer);
    modsList[0] = sortRewardeds(modsList[0], rewardedWatched);

    modsList.add(mainList);

    modsList[1].shuffle(randomizer);
    modsList[1] = sortRewardeds(modsList[1], rewardedWatched);

    modsList
        .add(await getModsFromCollection("top-mods", modsJson, 1, mainList));

    // modsList[2].shuffle(randomizer);
    modsList[2] = sortRewardeds(modsList[2], rewardedWatched);

    modsList.add(await getModsFromCollection("mods", modsJson, 8, mainList));

    modsList[3].shuffle(randomizer);
    modsList[3] = sortRewardeds(modsList[3], rewardedWatched);

    modsList.add(
        (await getModsFromCollection("medieval", modsJson, 4, mainList) +
            await getModsFromCollection("city", modsJson, 5, mainList) +
            await getModsFromCollection("tower", modsJson, 7, mainList)));

    modsList[4].shuffle(randomizer);
    modsList[4] = sortRewardeds(modsList[4], rewardedWatched);

    modsList.add(
        await getModsFromCollection("texture-packs", modsJson, 9, mainList));

    modsList[5].shuffle(randomizer);
    modsList[5] = sortRewardeds(modsList[5], rewardedWatched);

    modsList.add(
        (await getModsFromCollection("mansion", modsJson, 6, mainList) +
            await getModsFromCollection("modern", modsJson, 3, mainList)));

    modsList[6].shuffle(randomizer);
    modsList[6] = sortRewardeds(modsList[6], rewardedWatched);

    return modsList;
  }

  List<ModItemData> sortRewardeds(
      List<ModItemData> mods, List<String> rewardedWatched) {
    int i = 0;

    while (i < mods.length) {
      var mod = mods[i];

      // Calculate if the mod is premium or rewarded based on the specified sequence
      int sequencePosition = (i) % 5;
      bool isPremium = (sequencePosition == 3); // Premium: 4, 9, 14, 19, ...
      bool isRewarded =
          (sequencePosition == 2); // Rewarded: 3, 5, 8, 10, 13, 15, 18, 20, ...

      if (isRewarded) {
        if (rewardedWatched.contains(mod.getModID())) {
          isRewarded = false;
        }
      }

      mod.isRewarded = isRewarded || isPremium;
      mod.isPremium = false;

      i++;
    }

    return mods;
  }

  Future<void> updateModRating(ModItemData modData, int rating) async {
    if (sharedPreferences != null) {
      if (!sharedPreferences!.containsKey(modData.getModID())) {
        await sharedPreferences!.setInt(modData.getModID(), rating);

        if (modData.isPremium) {
          return;
        }

        List<int> newRatings = List.from(modData.rating, growable: true);
        newRatings.add(rating);

        updateModInfo(modData, modData.downloads, newRatings);
      }
    }
  }

  Future<void> updateModInfo(
      ModItemData modData, int targetDownloads, List<int> ratings) async {
    try {
      ModService.mongoDB = await Db.create(
          "mongodb+srv://public_morph:DiIvc0hdiYHMo3@morphs-mcpe.lyngp4r.mongodb.net/?retryWrites=true&w=majority&appName=morphs-mcpe");
      await ModService.mongoDB!.open();

      final collection = ModService.mongoDB!.collection('mods-info');
      final documentId = '${modData.title}-${modData.author}';

      // Update the document in the collection
      await collection.updateOne(
        where.eq('_id', documentId),
        modify.set('downloads', targetDownloads).set('rating', ratings),
        upsert: true, // If the document does not exist, it will be created
      );

      await ModService.mongoDB?.close();
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  void downloadMod(ModItemData modData) {
    updateModInfo(modData, modData.downloads + 1, modData.rating);
  }

  Future<void> action_favorite(ModItemData data) async {
    if (isFavoriteMod(data)) {
      if (sharedPreferences != null) {
        if (sharedPreferences!.containsKey("favorite_mods")) {
          String rawJSON = sharedPreferences!.getString("favorite_mods")!;

          Map<String, dynamic> jsonMap = jsonDecode(rawJSON);
          FavoriteModsData favoriteMods = FavoriteModsData.fromJson(jsonMap);

          favoriteMods.remove_mod(data);
          await sharedPreferences!
              .setString("favorite_mods", jsonEncode(favoriteMods.toJson()));
        }
      }
    } else {
      if (sharedPreferences != null) {
        if (sharedPreferences!.containsKey("favorite_mods")) {
          String rawJSON = sharedPreferences!.getString("favorite_mods")!;

          Map<String, dynamic> jsonMap = jsonDecode(rawJSON);
          FavoriteModsData favoriteMods = FavoriteModsData.fromJson(jsonMap);

          favoriteMods.add_mod(data, data.category);
          await sharedPreferences!
              .setString("favorite_mods", jsonEncode(favoriteMods.toJson()));
        } else {
          FavoriteModsData favoriteMods = FavoriteModsData(
              mods_morph: [],
              mods_all: [],
              mods_tops: [],
              mods_mods: [],
              mods_maps: [],
              mods_textures: [],
              mods_houses: []);

          favoriteMods.add_mod(data, data.category);
          await sharedPreferences!
              .setString("favorite_mods", jsonEncode(favoriteMods.toJson()));
        }
      }
    }
  }

  bool isFavoriteMod(ModItemData data) {
    if (sharedPreferences != null) {
      if (sharedPreferences!.containsKey("favorite_mods")) {
        String rawJSON = sharedPreferences!.getString("favorite_mods")!;

        Map<String, dynamic> jsonMap = jsonDecode(rawJSON);
        FavoriteModsData favoriteMods = FavoriteModsData.fromJson(jsonMap);

        if (favoriteMods.mods_all.contains(data.getModID())) return true;
        if (favoriteMods.mods_morph.contains(data.getModID())) return true;
        if (favoriteMods.mods_tops.contains(data.getModID())) return true;
        if (favoriteMods.mods_mods.contains(data.getModID())) return true;
        if (favoriteMods.mods_maps.contains(data.getModID())) return true;
        if (favoriteMods.mods_textures.contains(data.getModID())) return true;
        if (favoriteMods.mods_houses.contains(data.getModID())) return true;
      }
    }

    return false;
  }

  List<List<ModItemData>> getFavoriteMods() {
    List<List<ModItemData>> favMods = List.empty(growable: true);

    if (sharedPreferences != null) {
      if (sharedPreferences!.containsKey("favorite_mods")) {
        String rawJSON = sharedPreferences!.getString("favorite_mods")!;

        Map<String, dynamic> jsonMap = jsonDecode(rawJSON);
        FavoriteModsData favoriteMods = FavoriteModsData.fromJson(jsonMap);

        List<ModItemData> modsMorphs = List.empty(growable: true);
        List<ModItemData> modsAll = List.empty(growable: true);
        List<ModItemData> modsTops = List.empty(growable: true);

        for (final mod_id in favoriteMods.mods_morph) {
          var foundMod = mods[0]
              .firstWhereOrNull((element) => element.getModID() == mod_id);
          var foundModTop = mods[2]
              .firstWhereOrNull((element) => element.getModID() == mod_id);

          if (foundMod != null) modsMorphs.add(foundMod);
          if (foundModTop != null) modsTops.add(foundModTop);
        }

        favMods.add(modsMorphs);
        // favMods.add(mods_all);
        // favMods.add(mods_tops);

        for (final mod_id in favoriteMods.mods_all) {
          var foundMod = mods[1]
              .firstWhereOrNull((element) => element.getModID() == mod_id);
          var foundModTop = mods[2]
              .firstWhereOrNull((element) => element.getModID() == mod_id);
          if (foundMod != null) modsAll.add(foundMod);
          if (foundModTop != null) modsTops.add(foundModTop);
        }

        List<ModItemData> modsMods = List.empty(growable: true);

        for (final mod_id in favoriteMods.mods_mods) {
          var foundMod = mods[3]
              .firstWhereOrNull((element) => element.getModID() == mod_id);
          var foundModTop = mods[2]
              .firstWhereOrNull((element) => element.getModID() == mod_id);
          if (foundMod != null) modsMods.add(foundMod);
          if (foundModTop != null) modsTops.add(foundModTop);
        }

        favMods.add(modsMods);

        List<ModItemData> modsMaps = List.empty(growable: true);

        for (final mod_id in favoriteMods.mods_maps) {
          var foundMod = mods[4]
              .firstWhereOrNull((element) => element.getModID() == mod_id);
          var foundModTop = mods[2]
              .firstWhereOrNull((element) => element.getModID() == mod_id);
          if (foundMod != null) modsMaps.add(foundMod);
          if (foundModTop != null) modsTops.add(foundModTop);
        }

        favMods.add(modsMaps);

        List<ModItemData> modsTextures = List.empty(growable: true);

        for (final mod_id in favoriteMods.mods_textures) {
          var foundMod = mods[5]
              .firstWhereOrNull((element) => element.getModID() == mod_id);
          var foundModTop = mods[2]
              .firstWhereOrNull((element) => element.getModID() == mod_id);
          if (foundMod != null) modsTextures.add(foundMod);
          if (foundModTop != null) modsTops.add(foundModTop);
        }

        favMods.add(modsTextures);

        List<ModItemData> modsHouses = List.empty(growable: true);

        for (final mod_id in favoriteMods.mods_houses) {
          var foundMod = mods[6]
              .firstWhereOrNull((element) => element.getModID() == mod_id);
          var foundModTop = mods[2]
              .firstWhereOrNull((element) => element.getModID() == mod_id);
          if (foundMod != null) modsHouses.add(foundMod);
          if (foundModTop != null) modsTops.add(foundModTop);
        }

        favMods.add(modsHouses);
      }
    }

    return favMods;
  }

  bool isFavoriteModByID(String modID) {
    if (sharedPreferences != null) {
      if (sharedPreferences!.containsKey("favorite_mods")) {
        String rawJSON = sharedPreferences!.getString("favorite_mods")!;

        Map<String, dynamic> jsonMap = jsonDecode(rawJSON);
        FavoriteModsData favoriteMods = FavoriteModsData.fromJson(jsonMap);

        if (favoriteMods.mods_all.contains(modID)) return true;
        if (favoriteMods.mods_morph.contains(modID)) return true;
        if (favoriteMods.mods_tops.contains(modID)) return true;
        if (favoriteMods.mods_mods.contains(modID)) return true;
        if (favoriteMods.mods_maps.contains(modID)) return true;
        if (favoriteMods.mods_textures.contains(modID)) return true;
        if (favoriteMods.mods_houses.contains(modID)) return true;
      }
    }

    return false;
  }

  static double calculateAverage(List<int> numbers) {
    if (numbers.isEmpty) {
      return 0.0; // Return 0.0 if the list is empty to avoid division by zero
    }

    List<int> newNumbers = [];

    for (final number in numbers) {
      if (number == 0 || number > 5) continue;
      newNumbers.add(number);
    }

    if (newNumbers.isEmpty) {
      return 0.0;
    }

    int sum =
        newNumbers.reduce((a, b) => a + b); // Sum all elements in the list
    double average = sum / newNumbers.length; // Calculate the average

    // Format the average to one decimal place
    return double.parse(average.toStringAsFixed(1));
  }

  Future<List<ModItemData>> getModsFromCollection(
      String collectionName,
      Map<String, dynamic> modsJson,
      int index,
      List<ModItemData>? mainList) async {
    List<ModItemData> modList = List.empty(growable: true);

    if (modsJson.containsKey(collectionName)) {
      if (collectionName == "all-documents" || collectionName == "morphs") {
        List<dynamic> modsAll = modsJson[collectionName];

        for (Map<String, dynamic> modJson in modsAll) {
          String name = modJson['name'];
          String description = modJson['description'];
          String downloadUrl = (modJson['download_url'] as String)
              .replaceAll("mcpe-houses.bytecore.space", AccessKeys.domain);
          String iconUrl = (modJson['screenshots'][0] as String)
              .replaceAll("mcpe-houses.bytecore.space", AccessKeys.domain);
          String fileSizeStr = modJson['file_size'] ?? '0.0 MB';
          String author = modJson['author'] ?? 'Unknown';
          bool hasTags = modJson['hasTags'] ?? false;

          List<String> screenshots = List.empty(growable: true);

          for (var item in modJson['screenshots']) {
            if (item.runtimeType == String) {
              var screenshot = item as String;
              screenshot = screenshot.replaceAll(
                  "mcpe-houses.bytecore.space", AccessKeys.domain);
              screenshots.add(screenshot);
            }
          }

          List<int> rating = [0];
          int downloads = 0;

          if (modJson.containsKey('ratings')) {
            var ratingsData = modJson['ratings'];
            if (ratingsData is List<dynamic>) {
              rating = ratingsData.cast<int>();
            }
          }

          if (modJson.containsKey("downloads")) {
            downloads = modJson["downloads"] as int;
          }

          if (author == "N/A") continue;

          bool isRewarded = modJson['isRewarded'];
          bool isPremium = modJson['isPremium'];
          isRewarded = isRewarded == false ? isPremium : isRewarded;

          var rewardedWatched =
              ModService.sharedPreferences!.getStringList("rewardedWatched") ??
                  [];

          if (isRewarded) {
            if (rewardedWatched.contains("$name-$author")) isRewarded = false;
          }

          ModItemData modItem = ModItemData(
              imageUrl: iconUrl,
              title: name,
              description: description,
              downloadURL: downloadUrl,
              screenshots: screenshots,
              category: collectionNameToEnum(collectionName),
              author: author, // Replace with actual author if available
              rating: rating,
              downloads: downloads,
              fileSize: fileSizeStr,
              isPremium:
                  isPremium, // Replace with actual premium status if available
              isRewarded:
                  isRewarded, // (modJson['is_rewarded'] ?? false) == true ? !SubscriptionManager.isPremiumUser : false, // Replace with actual premium status if available
              cached: false,
              authorURL: (collectionName == "all"
                  ? (hasTags
                      ? 'https://www.modscraft.net/'
                      : 'https://www.9minecraft.net/')
                  : (hasTags
                      ? 'https://www.planetminecraft.com/'
                      : 'https://www.9minecraft.net/')),
              isFirestoreChecked: false,
              hasTags: hasTags,
              isMod: collectionName == "all",
              categoryIndex: index,
              favorite: isFavoriteModByID("$name-$author"));

          modList.add(modItem);
        }
      } else {
        List<dynamic> modsIndexes = modsJson[collectionName];
        for (var index in modsIndexes) {
          modList.add(mainList![index]);
        }
      }
    }

    return modList;
  }
}

ModCategory collectionNameToEnum(String collectionName) {
  switch (collectionName) {
    case "morphs":
      return ModCategory.Morph;

    case "all-documents":
      return ModCategory.All;

    case "top-mods":
      return ModCategory.Top;

    case "mods":
      return ModCategory.Mods;

    case "medieval":
      return ModCategory.Maps;

    case "city":
      return ModCategory.Maps;

    case "tower":
      return ModCategory.Maps;

    case "texture-packs":
      return ModCategory.Textures;

    case "mansion":
      return ModCategory.Houses;
  }

  return ModCategory.All;
}

class FavoriteModsData {
  List<String> mods_morph;
  List<String> mods_all;
  List<String> mods_tops;
  List<String> mods_mods;
  List<String> mods_maps;
  List<String> mods_textures;
  List<String> mods_houses;

  FavoriteModsData({
    required this.mods_morph,
    required this.mods_all,
    required this.mods_tops,
    required this.mods_mods,
    required this.mods_maps,
    required this.mods_textures,
    required this.mods_houses,
  });

  factory FavoriteModsData.fromJson(Map<String, dynamic> json) {
    return FavoriteModsData(
      mods_morph: List<String>.from(json['mods_morph'] ?? []),
      mods_all: List<String>.from(json['mods_all'] ?? []),
      mods_tops: List<String>.from(json['mods_tops'] ?? []),
      mods_mods: List<String>.from(json['mods_mods'] ?? []),
      mods_maps: List<String>.from(json['mods_maps'] ?? []),
      mods_textures: List<String>.from(json['mods_textures'] ?? []),
      mods_houses: List<String>.from(json['mods_houses'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mods_morph': mods_morph,
      'mods_all': mods_all,
      'mods_tops': mods_tops,
      'mods_mods': mods_mods,
      'mods_maps': mods_maps,
      'mods_textures': mods_textures,
      'mods_houses': mods_houses
    };
  }

  void remove_mod(ModItemData data) {
    if (mods_morph.remove(data.getModID())) return;
    if (mods_all.remove(data.getModID())) return;
    if (mods_tops.remove(data.getModID())) return;
    if (mods_mods.remove(data.getModID())) return;
    if (mods_maps.remove(data.getModID())) return;
    if (mods_textures.remove(data.getModID())) return;
    if (mods_houses.remove(data.getModID())) return;
  }

  void add_mod(ModItemData data, ModCategory category) {
    switch (category) {
      case ModCategory.All:
        mods_all.add(data.getModID());
        break;

      case ModCategory.Morph:
        mods_morph.add(data.getModID());
        break;

      case ModCategory.Houses:
        mods_houses.add(data.getModID());
        break;

      case ModCategory.Maps:
        mods_maps.add(data.getModID());
        break;

      case ModCategory.Mods:
        mods_mods.add(data.getModID());
        break;

      case ModCategory.Textures:
        mods_textures.add(data.getModID());
        break;

      case ModCategory.Top:
        mods_tops.add(data.getModID());
        break;
    }
  }
}

class JSONModItemData {
  String file_size = "";
  String author = "";
  String name = "";
  String icon_url = "";
  String download_url = "";
  String description = "";
}

class FirestoreData {
  final List<int> rating;
  final int downloads;

  FirestoreData({required this.rating, required this.downloads});
}
