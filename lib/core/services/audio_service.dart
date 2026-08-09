import 'package:sound_generator/sound_generator.dart';
import 'package:sound_generator/waveTypes.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  bool _isInitialized = false;
  bool _isPlaying = false;
  double _currentFrequency = 432.0;

  bool get isPlaying => _isPlaying;

  Future<void> init() async {
    if (_isInitialized) return;
    
    SoundGenerator.init(
      96000,
    );

    SoundGenerator.onIsPlayingChanged.listen((value) {
      _isPlaying = value;
    });

    SoundGenerator.onOneCycleDataHandler.listen((value) {
      // You can use this for oscilloscope visualization
    });

    SoundGenerator.setAutoUpdateOneCycleSample(true);
    // Force update for one sample
    SoundGenerator.refreshOneCycleData();
    
    SoundGenerator.setWaveType(waveTypes.SINUSOIDAL);
    SoundGenerator.setVolume(1.0); // 0.0 to 1.0
    
    _isInitialized = true;
  }

  void playFrequency(double frequency) {
    _currentFrequency = frequency;
    SoundGenerator.setFrequency(_currentFrequency);
    if (!_isPlaying) {
      SoundGenerator.play();
    }
  }

  void updateFrequency(double frequency) {
    _currentFrequency = frequency;
    SoundGenerator.setFrequency(_currentFrequency);
  }

  void play() {
    if (!_isPlaying) {
      SoundGenerator.setFrequency(_currentFrequency);
      SoundGenerator.play();
    }
  }

  void pause() {
    if (_isPlaying) {
      SoundGenerator.stop();
    }
  }

  void setVolume(double volume) {
    SoundGenerator.setVolume(volume);
  }

  void dispose() {
    SoundGenerator.release();
    _isInitialized = false;
  }
}

// Global instance for easy access outside of Riverpod if needed
final audioService = AudioService();
