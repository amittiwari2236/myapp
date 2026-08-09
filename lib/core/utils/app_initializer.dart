import 'package:hive_flutter/hive_flutter.dart';
import 'permissions_handler.dart';
import '../services/audio_service.dart';
import '../services/drone_service.dart';
import '../services/instrument_service.dart';

class AppInitializer {
  /// Runs heavy setup tasks in the background without blocking the UI frame
  static Future<void> initializeBackgroundTasks() async {
    try {
      // Initialize local storage
      await Hive.initFlutter();
      
      // Request necessary system permissions
      // (This might trigger system dialogs, which is fine since the app has already rendered)
      await AppPermissions.requestInitialPermissions();
      
      // Initialize audio generator
      await audioService.init();
      await droneService.init();
      await instrumentService.init();
      
    } catch (e) {
      // Fail gracefully
      print("Error during background initialization: $e");
    }
  }
}
