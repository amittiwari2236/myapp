import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/audio_service.dart';
import '../../tuner/providers/tuner_provider.dart';
import '../../tuner/providers/instrument_provider.dart';
import '../../meditation/providers/meditation_provider.dart';

class ChakraData {
  final int index;
  final String name;
  final String sanskritName;
  final double frequency;
  final Color color;
  final String element;
  final String location;
  final String affirmation;
  final String mantra;
  final String instrumentId;

  const ChakraData({
    required this.index,
    required this.name,
    required this.sanskritName,
    required this.frequency,
    required this.color,
    required this.element,
    required this.location,
    required this.affirmation,
    required this.mantra,
    required this.instrumentId,
  });
}

const List<ChakraData> allChakras = [
  ChakraData(
    index: 0,
    name: 'Crown Chakra',
    sanskritName: 'Sahasrara',
    frequency: 963.0,
    color: Color(0xFF8A2BE2),
    element: 'Thought',
    location: 'Top of Head',
    affirmation: 'I understand.',
    mantra: 'OM',
    instrumentId: 'crown',
  ),
  ChakraData(
    index: 1,
    name: 'Third Eye Chakra',
    sanskritName: 'Ajna',
    frequency: 852.0,
    color: Color(0xFF4B0082),
    element: 'Light',
    location: 'Between Eyebrows',
    affirmation: 'I see.',
    mantra: 'SHAM',
    instrumentId: 'third_eye',
  ),
  ChakraData(
    index: 2,
    name: 'Throat Chakra',
    sanskritName: 'Vishuddha',
    frequency: 741.0,
    color: Color(0xFF1E90FF),
    element: 'Sound',
    location: 'Throat',
    affirmation: 'I speak.',
    mantra: 'HAM',
    instrumentId: 'throat',
  ),
  ChakraData(
    index: 3,
    name: 'Heart Chakra',
    sanskritName: 'Anahata',
    frequency: 639.0,
    color: Color(0xFF4CAF50),
    element: 'Air',
    location: 'Center of Chest',
    affirmation: 'I love.',
    mantra: 'YAM',
    instrumentId: 'heart',
  ),
  ChakraData(
    index: 4,
    name: 'Solar Plexus Chakra',
    sanskritName: 'Manipura',
    frequency: 528.0,
    color: Color(0xFFFFC107),
    element: 'Fire',
    location: 'Upper Abdomen',
    affirmation: 'I do.',
    mantra: 'RAM',
    instrumentId: 'solar_plexus',
  ),
  ChakraData(
    index: 5,
    name: 'Sacral Chakra',
    sanskritName: 'Svadhisthana',
    frequency: 417.0,
    color: Color(0xFFFF9800),
    element: 'Water',
    location: 'Lower Abdomen',
    affirmation: 'I feel.',
    mantra: 'VAM',
    instrumentId: 'sacral',
  ),
  ChakraData(
    index: 6,
    name: 'Root Chakra',
    sanskritName: 'Muladhara',
    frequency: 396.0,
    color: Color(0xFFF44336),
    element: 'Earth',
    location: 'Base of Spine',
    affirmation: 'I am.',
    mantra: 'LAM',
    instrumentId: 'root',
  ),
];

class ChakraState {
  final int selectedIndex;
  final bool isPlaying;

  ChakraState({
    required this.selectedIndex,
    required this.isPlaying,
  });

  ChakraData get currentChakra => allChakras[selectedIndex];

  ChakraState copyWith({
    int? selectedIndex,
    bool? isPlaying,
  }) {
    return ChakraState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

class ChakraNotifier extends StateNotifier<ChakraState> {
  final Ref ref;
  
  ChakraNotifier(this.ref) : super(ChakraState(selectedIndex: 3, isPlaying: false));

  void selectChakra(int index) {
    if (state.selectedIndex == index) return;
    
    state = state.copyWith(selectedIndex: index);
    
    // Update global tuner frequency
    ref.read(tunerProvider.notifier).updateTargetFrequency(allChakras[index].frequency);
    
    // Switch the instrument to match this chakra
    ref.read(instrumentProvider.notifier).selectInstrument(allChakras[index].instrumentId);
  }

  void toggleMeditation() {
    final instrumentId = state.currentChakra.instrumentId;
    
    if (state.isPlaying) {
      audioService.pause(); // For generated pure tones if any
      // Stop the instrument
      if (ref.read(instrumentProvider).isPlaying) {
        ref.read(instrumentProvider.notifier).togglePlayback();
      }
      ref.read(meditationProvider.notifier).stopMeditation();
    } else {
      // Ensure target frequency is set to the current chakra
      ref.read(tunerProvider.notifier).updateTargetFrequency(state.currentChakra.frequency);
      
      // Start the instrument automatically
      if (!ref.read(instrumentProvider).isPlaying) {
        ref.read(instrumentProvider.notifier).togglePlayback();
      }
      
      ref.read(meditationProvider.notifier).startMeditation();
    }
    state = state.copyWith(isPlaying: !state.isPlaying);
  }
  
  void stop() {
    if (state.isPlaying) {
      audioService.pause();
      if (ref.read(instrumentProvider).isPlaying) {
        ref.read(instrumentProvider.notifier).pause();
      }
      ref.read(meditationProvider.notifier).stopMeditation();
      state = state.copyWith(isPlaying: false);
    }
  }
}

final chakraProvider = StateNotifierProvider<ChakraNotifier, ChakraState>((ref) {
  return ChakraNotifier(ref);
});
