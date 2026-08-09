import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitch_detector_dart/pitch_detector_result.dart';

class PitchDetectionService {
  static final PitchDetectionService _instance = PitchDetectionService._internal();

  factory PitchDetectionService() {
    return _instance;
  }

  PitchDetectionService._internal();

  final _record = AudioRecorder();
  StreamSubscription<Uint8List>? _audioStreamSubscription;
  
  final int sampleRate = 44100;
  final int bufferSize = 2048; // A good balance for pitch detection
  
  late PitchDetector _pitchDetector;
  
  Function(double)? onPitchDetected;
  Function(bool)? onRecordingStateChanged;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  void init() {
    _pitchDetector = PitchDetector(audioSampleRate: sampleRate.toDouble(), bufferSize: bufferSize);
  }

  Future<bool> start() async {
    try {
      if (await _record.hasPermission()) {
        final stream = await _record.startStream(RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: sampleRate,
          numChannels: 1,
        ));

        _isRecording = true;
        onRecordingStateChanged?.call(true);

        List<double> audioBuffer = [];

        _audioStreamSubscription = stream.listen((data) async {
          // Convert Uint8List to Int16List
          final int16List = Int16List.view(data.buffer);
          
          // Convert Int16List to List<double> (-1.0 to 1.0)
          for (var i = 0; i < int16List.length; i++) {
            audioBuffer.add(int16List[i] / 32768.0);
          }

          // Process when we have enough data
          while (audioBuffer.length >= bufferSize) {
            final processBuffer = audioBuffer.sublist(0, bufferSize);
            audioBuffer = audioBuffer.sublist(bufferSize); // Keep the rest
            
            PitchDetectorResult result = await _pitchDetector.getPitchFromFloatBuffer(processBuffer);
            if (result.pitched) {
              onPitchDetected?.call(result.pitch);
            } else {
              // Not pitched / silence
              onPitchDetected?.call(-1.0);
            }
          }
        });
        return true;
      }
    } catch (e) {
      print('Error starting pitch detection: $e');
    }
    return false;
  }

  Future<void> stop() async {
    _isRecording = false;
    onRecordingStateChanged?.call(false);
    await _audioStreamSubscription?.cancel();
    await _record.stop();
  }

  void dispose() {
    stop();
    _record.dispose();
  }
}

final pitchDetectionService = PitchDetectionService();
