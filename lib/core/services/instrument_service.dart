
import 'package:just_audio/just_audio.dart';

class InstrumentService {
  
  final Map<String, double> _baseFreqs = {
    'male_tanpura': 130.81,
    'female_tanpura': 261.63,
    'shruti_box': 130.81,
    'surpeti': 261.63,
    'swarmandal': 261.63,
    'harmonium': 130.81,
    'bansuri': 261.63,
    'veena': 130.81,
    'sitar': 130.81,
    'santoor': 261.63,
    'sarangi': 130.81,
    'rudra_veena': 65.41,
    'esraj': 130.81,
    'om_drone': 130.81,
    'singing_bowl': 261.63,
    'tibetan_bowl': 130.81,
    'temple_bell': 523.25,
    'soft_bell': 523.25,
    'shankha': 261.63,
    'mantra_drone': 130.81,
    'ambient_drone': 130.81,
  };

  final Map<String, String> _assetPaths = {
    'male_tanpura': 'assets/audio/tanpura_real.wav',
    'female_tanpura': 'assets/audio/tanpura_real.wav',
    'shruti_box': 'assets/audio/tanpura.wav',
    'surpeti': 'assets/audio/tanpura.wav',
    'swarmandal': 'assets/audio/tanpura_real.wav',
    'harmonium': 'assets/audio/sarangi_real.wav',
    'bansuri': 'assets/audio/sarangi_real.wav',
    'veena': 'assets/audio/sarangi_real.wav',
    'sitar': 'assets/audio/tanpura_real.wav',
    'santoor': 'assets/audio/tanpura.wav',
    'sarangi': 'assets/audio/sarangi_real.wav',
    'rudra_veena': 'assets/audio/tanpura_real.wav',
    'esraj': 'assets/audio/sarangi_real.wav',
    'om_drone': 'assets/audio/om.wav',
    'singing_bowl': 'assets/audio/bowl.wav',
    'tibetan_bowl': 'assets/audio/bowl.wav',
    'temple_bell': 'assets/audio/bowl.wav',
    'soft_bell': 'assets/audio/bowl.wav',
    'shankha': 'assets/audio/om.wav',
    'mantra_drone': 'assets/audio/om.wav',
    'ambient_drone': 'assets/audio/root_chakra.wav',
  };

  final Map<String, String> instrumentNames = {
    'male_tanpura': 'Male Tanpura',
    'female_tanpura': 'Female Tanpura',
    'shruti_box': 'Shruti Box',
    'surpeti': 'Surpeti',
    'swarmandal': 'Swarmandal',
    'harmonium': 'Harmonium',
    'bansuri': 'Bansuri / Flute',
    'veena': 'Veena',
    'sitar': 'Sitar',
    'santoor': 'Santoor',
    'sarangi': 'Sarangi',
    'rudra_veena': 'Rudra Veena',
    'esraj': 'Esraj',
    'om_drone': 'Om Drone',
    'singing_bowl': 'Singing Bowl',
    'tibetan_bowl': 'Tibetan Bowl',
    'temple_bell': 'Temple Bell',
    'soft_bell': 'Soft Meditation Bell',
    'shankha': 'Shankha / Conch',
    'mantra_drone': 'Mantra Drone',
    'ambient_drone': 'Ambient Meditation Drone',
  };

  final AudioPlayer _player = AudioPlayer();
  String? _currentId;
  
  Future<void> init() async {
    await _player.setLoopMode(LoopMode.one);
  }

  Future<void> playInstrument(String id) async {
    if (_currentId != id) {
      await _player.setAsset(_assetPaths[id]!);
      _currentId = id;
    }
    await _player.play();
  }

  Future<void> pauseInstrument(String id) async {
    if (_currentId == id) {
      await _player.pause();
    }
  }

  Future<void> setInstrumentTuning(String id, double targetFrequency) async {
    if (!_baseFreqs.containsKey(id)) return;
    
    // just_audio setSpeed controls playbackRate, changing both pitch and speed.
    double pitchRatio = targetFrequency / _baseFreqs[id]!;
    pitchRatio = pitchRatio.clamp(0.1, 4.0);
    
    if (_currentId == id) {
      await _player.setSpeed(pitchRatio);
    }
  }

  Future<void> setInstrumentVolume(String id, double volume) async {
    if (_currentId == id) {
      await _player.setVolume(volume);
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

final instrumentService = InstrumentService();
