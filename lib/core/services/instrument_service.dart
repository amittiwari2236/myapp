
import 'package:just_audio/just_audio.dart';

class InstrumentService {
  final Map<String, AudioPlayer> _players = {};
  
  // Base frequencies guaranteed to create perfect 10-second integer cycles
  final Map<String, double> _baseFreqs = {
    'tanpura': 100.0,
    'sarangi': 200.0,
    'root': 100.0,
    'sacral': 200.0,
    'solar_plexus': 300.0,
    'heart': 400.0,
    'throat': 500.0,
    'third_eye': 600.0,
    'crown': 700.0,
  };

  final Map<String, String> _assetPaths = {
    'tanpura': 'assets/audio/tanpura_real.wav',
    'sarangi': 'assets/audio/sarangi_real.wav',
    'root': 'assets/audio/root_chakra.wav',
    'sacral': 'assets/audio/sacral_chakra.wav',
    'solar_plexus': 'assets/audio/solar_plexus_chakra.wav',
    'heart': 'assets/audio/heart_chakra.wav',
    'throat': 'assets/audio/throat_chakra.wav',
    'third_eye': 'assets/audio/third_eye_chakra.wav',
    'crown': 'assets/audio/crown_chakra.wav',
  };

  Future<void> init() async {
    for (String key in _assetPaths.keys) {
      _players[key] = AudioPlayer();
      await _players[key]!.setAsset(_assetPaths[key]!);
      await _players[key]!.setLoopMode(LoopMode.one);
    }
  }

  Future<void> playInstrument(String id) async {
    await _players[id]?.play();
  }

  Future<void> pauseInstrument(String id) async {
    await _players[id]?.pause();
  }

  Future<void> setInstrumentTuning(String id, double targetFrequency) async {
    if (!_baseFreqs.containsKey(id) || !_players.containsKey(id)) return;
    
    // just_audio web doesn't support independent setPitch.
    // However, setSpeed uses playbackRate which changes BOTH pitch and speed.
    // For an infinite perfectly looping drone, changing speed shifts the pitch smoothly.
    double pitchRatio = targetFrequency / _baseFreqs[id]!;
    pitchRatio = pitchRatio.clamp(0.1, 4.0);
    
    await _players[id]?.setSpeed(pitchRatio);
  }

  Future<void> setInstrumentVolume(String id, double volume) async {
    await _players[id]?.setVolume(volume);
  }

  Future<void> dispose() async {
    for (var player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}

final instrumentService = InstrumentService();
