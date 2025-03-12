import 'dart:convert';
import 'dart:io';
import 'package:morph_mods/backend/FileOpener.dart';
import 'package:path/path.dart' as path;

class CacheManager {
  static const String cacheFileName = 'cache.json';

  /// Load cache from the cache file
  static Future<Map<String, List<String>>> _loadCache() async {
    final tempDir = await FileOpener.getTempDirectory();
    final cacheFile = File(path.join(tempDir.path, cacheFileName));

    if (await cacheFile.exists()) {
      final content = await cacheFile.readAsString();
      final Map<String, dynamic> jsonContent = jsonDecode(content);
      return jsonContent
          .map((key, value) => MapEntry(key, List<String>.from(value)));
    }
    return {};
  }

  /// Update the cache file with new data
  static Future<void> _updateCache(Map<String, List<String>> cache) async {
    final tempDir = await FileOpener.getTempDirectory();
    final cacheFile = File(path.join(tempDir.path, cacheFileName));
    final jsonContent = jsonEncode(cache);
    await cacheFile.writeAsString(jsonContent);
  }

  /// Check if cache is available for a specific URL
  static Future<bool> isCacheAvailable(String url) async {
    final cache = await _loadCache();
    return cache.containsKey(url);
  }

  /// Get cached file paths for a specific URL
  static Future<List<String>> getCachedFilePaths(String url) async {
    final cache = await _loadCache();
    return cache[url] ?? [];
  }

  /// Delete cached files for a specific URL and update the cache file
  static Future<void> deleteCachedFiles(String url) async {
    final cache = await _loadCache();

    if (cache.containsKey(url)) {
      // Delete cached files
      for (final filePath in cache[url]!) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      // Remove the URL from the cache
      cache.remove(url);
      // Update the cache file
      await _updateCache(cache);
    }
  }
}
