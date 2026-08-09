import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/instrument_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/instrument_service.dart';

class InstrumentState {
  final String selectedInstrument;
  final bool isPlaying;
  final double tuning; // Hz

  InstrumentState({
    this.selectedInstrument = 'tanpura',
    this.isPlaying = false,
    this.tuning = 432.0,
  });

  InstrumentState copyWith({
    String? selectedInstrument,
    bool? isPlaying,
    double? tuning,
  }) {
    return InstrumentState(
      selectedInstrument: selectedInstrument ?? this.selectedInstrument,
      isPlaying: isPlaying ?? this.isPlaying,
      tuning: tuning ?? this.tuning,
    );
  }
}

class InstrumentNotifier extends StateNotifier<InstrumentState> {
  InstrumentNotifier() : super(InstrumentState());

  void selectInstrument(String id) {
    if (state.selectedInstrument == id) return;
    
    // Stop old instrument if it was playing
    if (state.isPlaying) {
      instrumentService.pauseInstrument(state.selectedInstrument);
    }
    
    state = state.copyWith(selectedInstrument: id);
    
    // Sync the new instrument tuning
    instrumentService.setInstrumentTuning(id, state.tuning);
    
    // Resume playback on new instrument if it was playing
    if (state.isPlaying) {
      instrumentService.playInstrument(id);
    }
  }

  void switchSelectedInstrument() {
    selectInstrument(state.selectedInstrument == 'tanpura' ? 'sarangi' : 'tanpura');
  }

  void togglePlayback() {
    if (state.isPlaying) {
      instrumentService.pauseInstrument(state.selectedInstrument);
    } else {
      instrumentService.playInstrument(state.selectedInstrument);
    }
    state = state.copyWith(isPlaying: !state.isPlaying);
  }
  
  void pause() {
    if (state.isPlaying) {
      instrumentService.pauseInstrument(state.selectedInstrument);
      state = state.copyWith(isPlaying: false);
    }
  }

  void syncTuningFromTuner(double tuning) {
    state = state.copyWith(tuning: tuning);
    instrumentService.setInstrumentTuning(state.selectedInstrument, tuning);
  }
}

final instrumentProvider = StateNotifierProvider<InstrumentNotifier, InstrumentState>((ref) {
  return InstrumentNotifier();
});
