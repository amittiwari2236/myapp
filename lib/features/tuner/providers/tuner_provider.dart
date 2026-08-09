import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/synth_service.dart';
import '../../../core/services/pitch_detection_service.dart';
import 'instrument_provider.dart';

class TunerState {
  final double targetFrequency;
  final double detectedFrequency;
  final bool isPlaying;
  final bool isMicOn;

  TunerState({
    required this.targetFrequency,
    required this.detectedFrequency,
    required this.isPlaying,
    required this.isMicOn,
  });

  TunerState copyWith({
    double? targetFrequency,
    double? detectedFrequency,
    bool? isPlaying,
    bool? isMicOn,
  }) {
    return TunerState(
      targetFrequency: targetFrequency ?? this.targetFrequency,
      detectedFrequency: detectedFrequency ?? this.detectedFrequency,
      isPlaying: isPlaying ?? this.isPlaying,
      isMicOn: isMicOn ?? this.isMicOn,
    );
  }
}

class TunerNotifier extends StateNotifier<TunerState> {
  final Ref ref;

  TunerNotifier(this.ref) : super(TunerState(
    targetFrequency: 432.0, 
    detectedFrequency: -1.0, // -1 means no pitch detected
    isPlaying: false,
    isMicOn: false,
  )) {
    // Initialize pitch detection listener
    pitchDetectionService.init();
    pitchDetectionService.onPitchDetected = (pitch) {
      // Smoothing could be applied here if needed
      state = state.copyWith(detectedFrequency: pitch);
    };
    pitchDetectionService.onRecordingStateChanged = (isRecording) {
      state = state.copyWith(isMicOn: isRecording);
    };
  }

  void updateTargetFrequency(double freq) {
    state = state.copyWith(targetFrequency: freq);
    synthService.setInstrumentTuning('pure_tone', freq);
    ref.read(instrumentProvider.notifier).syncTuningFromTuner(freq);
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
