import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minecrafteria/backend/AccessKeys.dart';
import 'package:minecrafteria/backend/FileOpener.dart';
import 'package:minecrafteria/frontend/CacheClearDialog.dart';
import 'package:minecrafteria/frontend/LoadingDialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

class FileManager {
  static int downloadedModsAmount = 0;
  static const String cacheFileName = 'cache.json';

  /// Clear the entire cache
  static Future<void> clearCache(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const CacheClearDialog();
      },
    );

    final tempDir = await FileOpener.getTempDirectory();
    final dir = Directory(tempDir.path);
    await dir.delete(recursive: true);
    await Future.delayed(const Duration(seconds: 3));

    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Download a file and extract it, updating cache as necessary
  static Future<List<String>> downloadAndExtractFile(String url) async {
    final tempDir = await FileOpener.getTempDirectory();
    final cacheFile = File(path.join(tempDir.path, cacheFileName));

    // Load cache data
    Map<String, List<String>> cache = await _loadCache(cacheFile);

    // Check if the URL is already cached
    if (cache.containsKey(url)) {
      // print("cached");
      return cache[url]!;
    }

    // Step 1: Download the file
    http.Response? response;
    try {
      response = await http.get(Uri.parse(url), headers: {"CF-Access-Client-Secret": AccessKeys.client_secret, "CF-Access-Client-Id": AccessKeys.client_id});
    } catch (e) {
      if (response?.statusCode != 200) {
        return [];
      }
    }

    if (response?.statusCode != 200) {
      return [];
    }

    // Remove query parameters from the URL file name
    final uri = Uri.parse(url);
    final fileName = path.basename(uri.path);

    final filePath = path.join(tempDir.path, fileName);

    // Save the file to the temp directory
    final file = File(filePath);
    await file.writeAsBytes(response!.bodyBytes);

    List<String> extractedFiles = [];
    extractedFiles = [filePath];

    // Step 4: Update the cache and return the paths
    cache[url] = extractedFiles;
    await _updateCache(cacheFile, cache);

    return extractedFiles;
  }

  /// Load cache from the cache file
  static Future<Map<String, List<String>>> _loadCache(File cacheFile) async {
    if (await cacheFile.exists()) {
      final content = await cacheFile.readAsString();
      final Map<String, dynamic> jsonContent = jsonDecode(content);
      return jsonContent.map((key, value) => MapEntry(key, List<String>.from(value)));
    }
    return {};
  }

  /// Update the cache file with new data
  static Future<void> _updateCache(File cacheFile, Map<String, List<String>> cache) async {
    final jsonContent = jsonEncode(cache);
    await cacheFile.writeAsString(jsonContent);
  }
}
