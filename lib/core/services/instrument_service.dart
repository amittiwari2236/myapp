import 'package:just_audio/just_audio.dart';

class InstrumentService {
  final AudioPlayer _tanpuraPlayer = AudioPlayer();
  final AudioPlayer _sarangiPlayer = AudioPlayer();

  // The base frequencies we synthesized the audio files at.
  // This is crucial for calculating the pitch ratio.
  static const double _tanpuraBaseFreq = 130.81; 
  static const double _sarangiBaseFreq = 261.63; 

  Future<void> init() async {
    // Load the assets and set them to loop infinitely
    await _tanpuraPlayer.setAsset('assets/audio/tanpura_real.wav');
    await _tanpuraPlayer.setLoopMode(LoopMode.one);

    await _sarangiPlayer.setAsset('assets/audio/sarangi_real.wav');
    await _sarangiPlayer.setLoopMode(LoopMode.one);
  }

  Future<void> playTanpura() async {
    await _tanpuraPlayer.play();
  }

  Future<void> pauseTanpura() async {
    await _tanpuraPlayer.pause();
  }

  Future<void> playSarangi() async {
    await _sarangiPlayer.play();
  }

  Future<void> pauseSarangi() async {
    await _sarangiPlayer.pause();
  }

  Future<void> setTanpuraTuning(double targetFrequency) async {
    // just_audio web doesn't support independent setPitch.
    // However, setSpeed uses playbackRate which changes BOTH pitch and speed.
    // For an infinite drone, changing speed is perfectly fine and sounds natural.
    double pitchRatio = targetFrequency / _tanpuraBaseFreq;
    pitchRatio = pitchRatio.clamp(0.1, 4.0);
    
    await _tanpuraPlayer.setSpeed(pitchRatio);
  }

  Future<void> setSarangiTuning(double targetFrequency) async {
    double pitchRatio = targetFrequency / _sarangiBaseFreq;
    pitchRatio = pitchRatio.clamp(0.1, 4.0);
    
    await _sarangiPlayer.setSpeed(pitchRatio);
  }

  // Master volumes if needed
  Future<void> setTanpuraVolume(double volume) async {
    await _tanpuraPlayer.setVolume(volume);
  }

  Future<void> setSarangiVolume(double volume) async {
    await _sarangiPlayer.setVolume(volume);
  }

  Future<void> dispose() async {
    await _tanpuraPlayer.dispose();
    await _sarangiPlayer.dispose();
  }
}

final instrumentService = InstrumentService();
