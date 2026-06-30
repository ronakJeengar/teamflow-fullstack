import 'package:flutter/foundation.dart';

class DiagnosticsService {
  static final DateTime _startupStart = DateTime.now();
  static Duration? startupDuration;

  static void markStartupComplete() {
    if (startupDuration == null) {
      startupDuration = DateTime.now().difference(_startupStart);
      debugPrint('[Diagnostics] Mobile App Startup took: ${startupDuration!.inMilliseconds}ms');
    }
  }
}
