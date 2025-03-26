import 'dart:io';
import 'package:flutter/material.dart';

class LogService {
  static final _logFile = File('/storage/emulated/0/Download/mod_debug_log.txt');

  static Future<void> log(String message) async {
    final now = DateTime.now().toIso8601String();
    final logLine = '[$now] $message\n';
    debugPrint(logLine);
    try {
      await _logFile.writeAsString(logLine, mode: FileMode.append);
    } catch (e) {
      debugPrint('Log write error: $e');
    }
  }
}
