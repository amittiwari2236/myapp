import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tuner_provider.dart';
import '../providers/mixer_provider.dart';
import '../providers/instrument_provider.dart';
import '../widgets/custom_tuner_gauge.dart';

class TunerView extends ConsumerWidget {
  const TunerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tunerState = ref.watch(tunerProvider);
    final instrumentState = ref.watch(instrumentProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mic Indicator
            GestureDetector(
              onTap: () {
                ref.read(tunerProvider.notifier).toggleMic();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: tunerState.isMicOn ? const Color(0xFFF0F6F0) : const Color(0xFFF6F0F0), 
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tunerState.isMicOn ? const Color(0xFFE2EBE2) : const Color(0xFFEBE2E2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tunerState.isMicOn ? Icons.mic : Icons.mic_off, 
                      color: tunerState.isMicOn ? const Color(0xFF3C7D4A) : const Color(0xFF7D3C3C), 
                      size: 16
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tunerState.isMicOn ? 'Mic: ON' : 'Mic: OFF',
                      style: TextStyle(
                        color: tunerState.isMicOn ? const Color(0xFF3C7D4A) : const Color(0xFF7D3C3C),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Circular Gauge
            Center(
              child: CustomTunerGauge(
                currentFrequency: tunerState.detectedFrequency,
                targetFrequency: tunerState.targetFrequency,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tuning Status
            Builder(
              builder: (context) {
                bool hasPitch = tunerState.detectedFrequency > 0;
                double deviation = hasPitch ? (tunerState.detectedFrequency - tunerState.targetFrequency) : 0.0;
                String statusText = !tunerState.isMicOn 
                    ? 'Turn on mic to tune' 
                    : (!hasPitch ? 'Sing a tone...' : (deviation.abs() < 1.5 ? 'You are in tune! 🎉' : (deviation > 0 ? 'Too High ↑' : 'Too Low ↓')));
                
                return Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F1E6), // Soft warm tone
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          statusText,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E3A2F),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hasPitch ? 'Deviation: ${deviation > 0 ? '+' : ''}${deviation.toStringAsFixed(1)} Hz' : 'Deviation: -- Hz',
                          style: const TextStyle(
                            color: Color(0xFF555555),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),
            
            const SizedBox(height: 40),
            
            // Bottom Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Instrument Selector Button
                Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFDF9F2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(instrumentState.selectedInstrument == SelectedInstrument.tanpura ? Icons.music_note : Icons.straighten),
                        onPressed: () {
                          ref.read(instrumentProvider.notifier).switchSelectedInstrument();
                        },
                        color: const Color(0xFF4A4A4A),
                        iconSize: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(instrumentState.selectedInstrument == SelectedInstrument.tanpura ? 'Tanpura' : 'Sarangi', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF2E3A2F))),
                    const SizedBox(height: 4),
                    const Text('Select', style: TextStyle(color: Color(0xFF888888), fontSize: 11)),
                  ],
                ),
                
                // Play/Pause Button
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE86F1C),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      ref.read(instrumentProvider.notifier).toggleSelectedInstrumentPlayback();
                    },
                    icon: Icon(
                      (instrumentState.selectedInstrument == SelectedInstrument.tanpura ? instrumentState.tanpuraIsPlaying : instrumentState.sarangiIsPlaying) ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    iconSize: 36,
                  ),
                ),
                
                // Calibration Button
                Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFDF9F2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: () {},
                        color: const Color(0xFF4A4A4A),
                        iconSize: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Calibration', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF2E3A2F))),
                    const SizedBox(height: 4),
                    const Text('440 Hz', style: TextStyle(color: Color(0xFF888888), fontSize: 11)),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 48),
            
            // Adaptive Resonance Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDF9F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.graphic_eq, color: Color(0xFF2E3A2F), size: 36), // Approximate icon
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adaptive Resonance',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3A2F),
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Real-time pitch guidance.\nStay in tune with the\ntarget frequency.',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
