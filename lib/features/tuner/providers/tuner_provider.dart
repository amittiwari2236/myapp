
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/synth_service.dart';
import '../../../core/services/pitch_detection_service.dart';
import 'instrument_provider.dart';

const Map<String, double> scaleFrequencies = {
  'C': 261.63,
  'C#': 277.18,
  'D': 293.66,
  'D#': 311.13,
  'E': 329.63,
  'F': 349.23,
  'F#': 369.99,
  'G': 392.00,
  'G#': 415.30,
  'A': 440.00,
  'A#': 466.16,
  'B': 493.88,
};

class TunerState {
  final double targetFrequency;
  final double detectedFrequency;
  final bool isPlaying;
  final bool isMicOn;
  final String selectedScale;

  TunerState({
    required this.targetFrequency,
    required this.detectedFrequency,
    required this.isPlaying,
    required this.isMicOn,
    required this.selectedScale,
  });

  TunerState copyWith({
    double? targetFrequency,
    double? detectedFrequency,
    bool? isPlaying,
    bool? isMicOn,
    String? selectedScale,
  }) {
    return TunerState(
      targetFrequency: targetFrequency ?? this.targetFrequency,
      detectedFrequency: detectedFrequency ?? this.detectedFrequency,
      isPlaying: isPlaying ?? this.isPlaying,
      isMicOn: isMicOn ?? this.isMicOn,
      selectedScale: selectedScale ?? this.selectedScale,
    );
  }
}

class TunerNotifier extends StateNotifier<TunerState> {
  final Ref ref;

  TunerNotifier(this.ref) : super(TunerState(
    targetFrequency: 440.0, 
    detectedFrequency: -1.0,
    isPlaying: false,
    isMicOn: false,
    selectedScale: 'A',
  )) {
    pitchDetectionService.init();
    pitchDetectionService.onPitchDetected = (pitch) {
      state = state.copyWith(detectedFrequency: pitch);
    };
    pitchDetectionService.onRecordingStateChanged = (isRecording) {
      state = state.copyWith(isMicOn: isRecording);
    };
  }

  void updateTargetFrequency(double freq) {
    // If the manual freq is changed, optionally untie it from the scale if it doesn't match perfectly,
    // but for simplicity we just update the freq directly and find the closest scale just in case, or leave scale as is.
    String newScale = state.selectedScale;
    scaleFrequencies.forEach((scale, f) {
      if ((f - freq).abs() < 0.5) {
        newScale = scale;
      }
    });
    
    state = state.copyWith(targetFrequency: freq, selectedScale: newScale);
    synthService.setInstrumentTuning('pure_tone', freq);
    ref.read(instrumentProvider.notifier).syncTuningFromTuner(freq);
  }

  void updateScale(String scale) {
    if (scaleFrequencies.containsKey(scale)) {
      double newFreq = scaleFrequencies[scale]!;
      state = state.copyWith(selectedScale: scale, targetFrequency: newFreq);
      synthService.setInstrumentTuning('pure_tone', newFreq);
      ref.read(instrumentProvider.notifier).syncTuningFromTuner(newFreq);
    }
  }

  void togglePlayback() {
    if (state.isPlaying) {
      synthService.pauseInstrument('pure_tone');
    } else {
      synthService.setInstrumentTuning('pure_tone', state.targetFrequency);
      synthService.playInstrument('pure_tone');
    }
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  Future<void> toggleMic() async {
    if (state.isMicOn) {
      await pitchDetectionService.stop();
    } else {
      await pitchDetectionService.start();
    }
  }

  void stop() {
    if (state.isPlaying) {
      synthService.pauseInstrument('pure_tone');
      state = state.copyWith(isPlaying: false);
    }
  }

  @override
  void dispose() {
    pitchDetectionService.stop();
    super.dispose();
  }
}

final tunerProvider = StateNotifierProvider<TunerNotifier, TunerState>((ref) {
  return TunerNotifier(ref);
});
