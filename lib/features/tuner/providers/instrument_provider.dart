import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/instrument_service.dart';

enum SelectedInstrument { tanpura, sarangi }

class InstrumentState {
  final SelectedInstrument selectedInstrument;
  final bool tanpuraIsPlaying;
  final double tanpuraTuning; // Hz
  final bool sarangiIsPlaying;
  final double sarangiTuning; // Hz

  InstrumentState({
    this.selectedInstrument = SelectedInstrument.tanpura,
    this.tanpuraIsPlaying = false,
    this.tanpuraTuning = 130.81, // Default C3
    this.sarangiIsPlaying = false,
    this.sarangiTuning = 261.63, // Default C4
  });

  InstrumentState copyWith({
    SelectedInstrument? selectedInstrument,
    bool? tanpuraIsPlaying,
    double? tanpuraTuning,
    bool? sarangiIsPlaying,
    double? sarangiTuning,
  }) {
    return InstrumentState(
      selectedInstrument: selectedInstrument ?? this.selectedInstrument,
      tanpuraIsPlaying: tanpuraIsPlaying ?? this.tanpuraIsPlaying,
      tanpuraTuning: tanpuraTuning ?? this.tanpuraTuning,
      sarangiIsPlaying: sarangiIsPlaying ?? this.sarangiIsPlaying,
      sarangiTuning: sarangiTuning ?? this.sarangiTuning,
    );
  }
}

class InstrumentNotifier extends StateNotifier<InstrumentState> {
  InstrumentNotifier() : super(InstrumentState());

  void switchSelectedInstrument() {
    state = state.copyWith(
      selectedInstrument: state.selectedInstrument == SelectedInstrument.tanpura
          ? SelectedInstrument.sarangi
          : SelectedInstrument.tanpura
    );
  }

  void toggleSelectedInstrumentPlayback() {
    if (state.selectedInstrument == SelectedInstrument.tanpura) {
      toggleTanpura();
    } else {
      toggleSarangi();
    }
  }

  void toggleTanpura() {
    if (state.tanpuraIsPlaying) {
      instrumentService.pauseTanpura();
    } else {
      instrumentService.playTanpura();
    }
    state = state.copyWith(tanpuraIsPlaying: !state.tanpuraIsPlaying);
  }

  void toggleSarangi() {
    if (state.sarangiIsPlaying) {
      instrumentService.pauseSarangi();
    } else {
      instrumentService.playSarangi();
    }
    state = state.copyWith(sarangiIsPlaying: !state.sarangiIsPlaying);
  }

  void setTanpuraTuning(double tuning) {
    state = state.copyWith(tanpuraTuning: tuning);
    instrumentService.setTanpuraTuning(tuning);
  }

  void setSarangiTuning(double tuning) {
    state = state.copyWith(sarangiTuning: tuning);
    instrumentService.setSarangiTuning(tuning);
  }
  void syncTuningFromTuner(double tuning) {
    state = state.copyWith(tanpuraTuning: tuning, sarangiTuning: tuning);
  }
}

final instrumentProvider = StateNotifierProvider<InstrumentNotifier, InstrumentState>((ref) {
  return InstrumentNotifier();
});
