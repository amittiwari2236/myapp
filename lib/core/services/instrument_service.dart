
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter/foundation.dart';

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
  final YoutubeExplode _yt = YoutubeExplode();
  String? _currentId;
  String? _currentLoadedUrl;
  Map<String, String> _customLinks = {};
  
  Future<void> init() async {
    await _player.setLoopMode(LoopMode.one);
  }

  void updateCustomLinks(Map<String, String> links) {
    _customLinks = links;
  }

  Future<void> playInstrument(String id) async {
    String? customLink = _customLinks[id];
    String targetUrl = (customLink != null && customLink.trim().isNotEmpty) ? customLink.trim() : _assetPaths[id]!;

    if (_currentId != id || _currentLoadedUrl != targetUrl) {
      String? urlToPlay;
      
      if (customLink != null && customLink.trim().isNotEmpty) {
        if (customLink.contains('youtube.com') || customLink.contains('youtu.be')) {
          try {
            var videoId = VideoId(customLink);
            var manifest = await _yt.videos.streamsClient.getManifest(videoId);
            var audioStream = manifest.audioOnly.withHighestBitrate();
            urlToPlay = audioStream.url.toString();
            
            // Attempt to bypass Web CORS for the raw media stream
            if (kIsWeb) {
               urlToPlay = 'https://corsproxy.io/?' + Uri.encodeComponent(urlToPlay);
            }
          } catch(e) {
             print("Error extracting YT link: $e");
             // Never fall back to default if a custom link was provided but failed
             urlToPlay = null; 
          }
        } else {
          urlToPlay = customLink; // direct remote URL
        }
      } else {
        urlToPlay = _assetPaths[id];
      }

      if (urlToPlay != null) {
        if (urlToPlay.startsWith('http')) {
          await _player.setAudioSource(AudioSource.uri(Uri.parse(urlToPlay)));
        } else {
          await _player.setAsset(urlToPlay);
        }
      } else {
        // If extraction failed or URL is null, stop any playing audio.
        await _player.stop();
      }
      
      _currentId = id;
      _currentLoadedUrl = targetUrl;
    }
    
    if (_currentLoadedUrl != null) {
      await _player.play();
    }
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
    _yt.close();
    await _player.dispose();
  }
}

final instrumentService = InstrumentService();
