import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/drone_service.dart';

class MixerState {
  final double masterVolume;
  final double toneVolume;
  final double droneVolume;
  final double ambientVolume;
  final bool isDronePlaying;

  MixerState({
    this.masterVolume = 1.0,
    this.toneVolume = 1.0,
    this.droneVolume = 0.5,
    this.ambientVolume = 0.5,
    this.isDronePlaying = false,
  });

  MixerState copyWith({
    double? masterVolume,
    double? toneVolume,
    double? droneVolume,
    double? ambientVolume,
    bool? isDronePlaying,
  }) {
    return MixerState(
      masterVolume: masterVolume ?? this.masterVolume,
      toneVolume: toneVolume ?? this.toneVolume,
      droneVolume: droneVolume ?? this.droneVolume,
      ambientVolume: ambientVolume ?? this.ambientVolume,
      isDronePlaying: isDronePlaying ?? this.isDronePlaying,
    );
  }
}

class MixerNotifier extends StateNotifier<MixerState> {
  MixerNotifier() : super(MixerState()) {
    // Initial volume setup
    audioService.setVolume(state.masterVolume * state.toneVolume);
    droneService.setDroneVolume(state.masterVolume * state.droneVolume);
    droneService.setAmbientVolume(state.masterVolume * state.ambientVolume);
  }

  void setMasterVolume(double volume) {
    state = state.copyWith(masterVolume: volume);
    _applyVolumes();
  }

  void setToneVolume(double volume) {
    state = state.copyWith(toneVolume: volume);
    _applyVolumes();
  }

  void setDroneVolume(double volume) {
    state = state.copyWith(droneVolume: volume);
    _applyVolumes();
  }

  void setAmbientVolume(double volume) {
    state = state.copyWith(ambientVolume: volume);
    _applyVolumes();
  }

  void toggleDrone() {
    if (state.isDronePlaying) {
      droneService.pauseDrone();
    } else {
      droneService.playDrone();
    }
    state = state.copyWith(isDronePlaying: !state.isDronePlaying);
  }

  void _applyVolumes() {
    audioService.setVolume(state.masterVolume * state.toneVolume);
    droneService.setDroneVolume(state.masterVolume * state.droneVolume);
    droneService.setAmbientVolume(state.masterVolume * state.ambientVolume);
  }
}

final mixerProvider = StateNotifierProvider<MixerNotifier, MixerState>((ref) {
  return MixerNotifier();
});
