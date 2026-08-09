import 'package:just_audio/just_audio.dart';

class DroneService {
  static final DroneService _instance = DroneService._internal();

  factory DroneService() {
    return _instance;
  }

  DroneService._internal();

  final AudioPlayer _tanpuraPlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();

  bool _isDronePlaying = false;
  bool get isDronePlaying => _isDronePlaying;

  Future<void> init() async {
    try {
      await _tanpuraPlayer.setAsset('assets/audio/tanpura.wav');
      await _tanpuraPlayer.setLoopMode(LoopMode.one);
      
      await _ambientPlayer.setAsset('assets/audio/om.wav');
      await _ambientPlayer.setLoopMode(LoopMode.one);
    } catch (e) {
      print("Error loading drone assets: $e");
    }
  }

  void playDrone() {
    _tanpuraPlayer.play();
    _isDronePlaying = true;
  }

  void pauseDrone() {
    _tanpuraPlayer.pause();
    _isDronePlaying = false;
  }
  
  void toggleDrone() {
    if (_isDronePlaying) {
      pauseDrone();
    } else {
      playDrone();
    }
  }

  void setDroneVolume(double volume) {
    _tanpuraPlayer.setVolume(volume);
  }

  void setAmbientVolume(double volume) {
    _ambientPlayer.setVolume(volume);
  }

  void updateDronePitch(double targetFrequency, double baseFrequency) {
    // just_audio allows setting speed/pitch
    // If base Tanpura is C3 (130.81 Hz), we can scale it to match the target frequency root note
    // For simplicity, we can use setSpeed which also changes pitch if pitch modification is not separate
    // In just_audio, setSpeed changes speed and pitch together unless we use Android's specific pitch API, 
    // but just_audio 0.10+ supports setPitch.
    try {
      double ratio = targetFrequency / baseFrequency;
      // Clamp ratio to avoid extreme distortion
      if (ratio > 0.5 && ratio < 2.0) {
        _tanpuraPlayer.setPitch(ratio);
      }
    } catch (e) {
      // Ignore if pitch setting is unsupported on platform
    }
  }

  void dispose() {
    _tanpuraPlayer.dispose();
    _ambientPlayer.dispose();
  }
}

final droneService = DroneService();
