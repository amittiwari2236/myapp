import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppPermissions {
  static Future<void> requestInitialPermissions() async {
    if (kIsWeb) {
      return; // Skip permission requests on Web to prevent UnsupportedError crashes
    }
    // Request microphone for tuner and voice analysis
    var micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      await Permission.microphone.request();
    }

    // Request storage for saving sessions and audio
    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }

    // Request notifications for session reminders
    var notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      await Permission.notification.request();
    }
  }
}
