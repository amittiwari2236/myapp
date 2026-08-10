import 'package:hive_flutter/hive_flutter.dart';
import 'permissions_handler.dart';
import '../services/audio_service.dart';
import '../services/drone_service.dart';
import '../services/instrument_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppInitializer {
  /// Runs heavy setup tasks in the background without blocking the UI frame
  static Future<void> initializeBackgroundTasks() async {
    try {
      // Initialize local storage
      await Hive.initFlutter();
    } catch (e) {
      print("Error initializing Hive: $e");
    }

    try {
      // Request necessary system permissions
      await AppPermissions.requestInitialPermissions();
    } catch (e) {
      print("Error requesting permissions: $e");
    }
      
    try {
      if (!kIsWeb) { // sound_generator does not support web
        await audioService.init();
      }
    } catch (e) {
      print("Error initializing audioService: $e");
    }
    
    try {
      if (!kIsWeb) {
        await droneService.init();
      }
    } catch (e) {
      print("Error initializing droneService: $e");
    }
    
    try {
      await instrumentService.init();
    } catch (e) {
      print("Error initializing instrumentService: $e");
    }
  }
}
