import 'dart:io';
import 'package:flutter/material.dart';

class LogService {
  static final _logFile = File('/storage/emulated/0/Download/mod_debug_log.txt');
  static bool _isCleaning = false;
  static final List<String> _queuedLogs = [];

  static Future<void> log(String message) async {
    final now = DateTime.now().toIso8601String();
    final logLine = '[$now] $message\n';
    debugPrint(logLine);

    if (_isCleaning) {
      _queuedLogs.add(logLine);
      return;
    }

    try {
      await _logFile.writeAsString(logLine, mode: FileMode.append);
    } catch (e) {
      debugPrint('Log write error: $e');
    }
  }

  static Future<void> clearLog() async {
    _isCleaning = true;

    try {
      if (await _logFile.exists()) {
        await _logFile.writeAsString(''); // очищення
        debugPrint('[LogService] Log cleared.');
      }
    } catch (e) {
      debugPrint('[LogService] Failed to clear log: $e');
    } finally {
      _isCleaning = false;
      // записати все, що накопичилось під час очищення
      if (_queuedLogs.isNotEmpty) {
        try {
          await _logFile.writeAsString(_queuedLogs.join(), mode: FileMode.append);
        } catch (e) {
          debugPrint('Log flush error: $e');
        }
        _queuedLogs.clear();
      }
      // ✅ Сигнальний рядок
      try {
        await _logFile.writeAsString('[LogService] ✅ LOG CLEAR COMPLETE\n', mode: FileMode.append);
      } catch (e) {
        debugPrint('Log signal error: $e');
      }
    }
  }

  static Future<void> clearIfTooBig() async {
    final length = await _logFile.length();
    if (length > 5 * 1024 * 1024) {
      await clearLog();
      debugPrint('[LogService] Log auto-cleared (too big)');
    }
  }
}
