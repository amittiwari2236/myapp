import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tuner/providers/tuner_provider.dart';
import '../../navigation/main_navigation_screen.dart';

class LibraryMainScreen extends ConsumerWidget {
  const LibraryMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    final presets = [
      {'name': 'Deep Sleep', 'freq': 432.0, 'desc': 'Calming and grounding'},
      {'name': 'DNA Repair', 'freq': 528.0, 'desc': 'Miracle tone for transformation'},
      {'name': 'Lucid Dreaming', 'freq': 852.0, 'desc': 'Awakening intuition'},
      {'name': 'Anxiety Relief', 'freq': 396.0, 'desc': 'Liberating guilt and fear'},
      {'name': 'Mental Clarity', 'freq': 741.0, 'desc': 'Awakening intuition and solving'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F2),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Library',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Saved Presets',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A2F),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: presets.length,
                itemBuilder: (context, index) {
                  final preset = presets[index];
                  final freq = preset['freq'] as double;
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      title: Text(
                        preset['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2E3A2F)),
                      ),
                      subtitle: Text(
                        preset['desc'] as String,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${freq.toInt()} Hz',
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                        ),
                      ),
                      onTap: () {
                        // Set the tuner to this frequency and switch tab
                        ref.read(tunerProvider.notifier).updateTargetFrequency(freq);
                        if (!ref.read(tunerProvider).isPlaying) {
                          ref.read(tunerProvider.notifier).togglePlayback();
                        }
                        ref.read(bottomNavIndexProvider.notifier).state = 0; // Go to Tuner
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
