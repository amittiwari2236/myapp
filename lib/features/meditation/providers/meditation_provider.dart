import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tuner/providers/tuner_provider.dart';
import '../../../core/services/pitch_detection_service.dart';
import '../../analytics/providers/analytics_provider.dart';

class SessionStats {
  final DateTime startTime;
  final int durationSeconds;
  final double averageFrequency;
  final double accuracyPercentage;
  final int chantCount;

  SessionStats({
    required this.startTime,
    required this.durationSeconds,
    required this.averageFrequency,
    required this.accuracyPercentage,
    required this.chantCount,
  });
}

class MeditationState {
  final bool isActive;
  final int elapsedSeconds;
  final int totalDurationSeconds;
  final List<double> frequencySamples;
  final int chantFrames;
  final SessionStats? lastSession;

  MeditationState({
    this.isActive = false,
    this.elapsedSeconds = 0,
    this.totalDurationSeconds = 600, // 10 minutes default
    this.frequencySamples = const [],
    this.chantFrames = 0,
    this.lastSession,
  });

  MeditationState copyWith({
    bool? isActive,
    int? elapsedSeconds,
    int? totalDurationSeconds,
    List<double>? frequencySamples,
    int? chantFrames,
    SessionStats? lastSession,
  }) {
    return MeditationState(
      isActive: isActive ?? this.isActive,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      frequencySamples: frequencySamples ?? this.frequencySamples,
      chantFrames: chantFrames ?? this.chantFrames,
      lastSession: lastSession ?? this.lastSession,
    );
  }
}

class MeditationNotifier extends StateNotifier<MeditationState> {
  final Ref ref;
  Timer? _timer;
  DateTime? _startTime;

  MeditationNotifier(this.ref) : super(MeditationState());

  void setDuration(int seconds) {
    state = state.copyWith(totalDurationSeconds: seconds);
  }

  void startMeditation() {
    if (state.isActive) return;

    _startTime = DateTime.now();
    state = state.copyWith(
      isActive: true,
      elapsedSeconds: 0,
      frequencySamples: [],
      chantFrames: 0,
    );

    // Make sure mic is on for pitch detection tracking
    pitchDetectionService.start();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.elapsedSeconds >= state.totalDurationSeconds) {
        stopMeditation();
        return;
      }
      
      // Collect metric: 
      // We read the current detected frequency from tuner state
      final currentPitch = ref.read(tunerProvider).detectedFrequency;
      
      final updatedSamples = List<double>.from(state.frequencySamples);
      int newChantFrames = state.chantFrames;
      
      if (currentPitch > 0) {
        updatedSamples.add(currentPitch);
        newChantFrames++;
      }

      state = state.copyWith(
        elapsedSeconds: state.elapsedSeconds + 1,
        frequencySamples: updatedSamples,
        chantFrames: newChantFrames,
      );
    });
  }

  void stopMeditation() {
    if (!state.isActive) return;

    _timer?.cancel();
    
    // Finalize session
    double avgFreq = 0.0;
    double accuracy = 0.0;
    if (state.frequencySamples.isNotEmpty) {
      avgFreq = state.frequencySamples.reduce((a, b) => a + b) / state.frequencySamples.length;
      final targetFreq = ref.read(tunerProvider).targetFrequency;
      // Simple accuracy: 100% minus the average percentage deviation
      double avgDeviation = state.frequencySamples.map((f) => (f - targetFreq).abs() / targetFreq).reduce((a, b) => a + b) / state.frequencySamples.length;
      accuracy = (1.0 - avgDeviation) * 100;
      accuracy = accuracy.clamp(0.0, 100.0);
    }

    final stats = SessionStats(
      startTime: _startTime ?? DateTime.now(),
      durationSeconds: state.elapsedSeconds,
      averageFrequency: avgFreq,
      accuracyPercentage: accuracy,
      chantCount: state.chantFrames, // Each frame is ~1 second of active voice
    );
    
    ref.read(analyticsProvider.notifier).saveSession(stats);

    state = state.copyWith(
      isActive: false,
      lastSession: stats,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final meditationProvider = StateNotifierProvider<MeditationNotifier, MeditationState>((ref) {
  return MeditationNotifier(ref);
});
