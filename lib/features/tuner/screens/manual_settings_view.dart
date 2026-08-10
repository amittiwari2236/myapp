
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tuner_provider.dart';

class ManualSettingsView extends ConsumerWidget {
  const ManualSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tunerState = ref.watch(tunerProvider);
    final theme = Theme.of(context);

    // List of predefined frequencies
    final presets = [396.0, 417.0, 432.0, 440.0, 528.0, 639.0, 741.0, 852.0, 963.0];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Frequency Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Frequency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${tunerState.targetFrequency.toStringAsFixed(1)} Hz', style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  ref.read(tunerProvider.notifier).updateTargetFrequency((tunerState.targetFrequency - 1).clamp(20, 2000));
                },
              ),
              Expanded(
                child: Slider(
                  value: tunerState.targetFrequency.clamp(20.0, 2000.0),
                  min: 20,
                  max: 2000,
                  onChanged: (val) {
                    ref.read(tunerProvider.notifier).updateTargetFrequency(val);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  ref.read(tunerProvider.notifier).updateTargetFrequency((tunerState.targetFrequency + 1).clamp(20, 2000));
                },
              ),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('20 Hz', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('2000 Hz', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Quick Presets
          const Text('Quick Presets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: presets.map((freq) {
              final isSelected = (tunerState.targetFrequency - freq).abs() < 0.5;
              return GestureDetector(
                onTap: () {
                  ref.read(tunerProvider.notifier).updateTargetFrequency(freq);
                },
                child: _buildPresetChip('${freq.toInt()} Hz', isSelected, theme),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Pitch & Scale (Mock UI for now, but fully interactive slider for Pitch Shift)
          const Text('Pitch & Scale', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          _buildDropdownRow(
            'Root Note',
            tunerState.selectedScale,
            scaleFrequencies.keys.toList(),
            (val) {
              if (val != null) {
                ref.read(tunerProvider.notifier).updateScale(val);
              }
            },
          ),
          const SizedBox(height: 12),
          _buildDropdownRow('Scale', 'Natural Minor', ['Natural Minor', 'Major', 'Harmonic Minor'], (val) {}),
          const SizedBox(height: 12),
          _buildDropdownRow('Octave', '4 (Middle)', ['3', '4 (Middle)', '5'], (val) {}),
          
          const SizedBox(height: 24),
          const Text('Pitch Shift', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: 0, 
                  min: -24,
                  max: 24,
                  onChanged: (val) {},
                ),
              ),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('-24', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('0', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('+24', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, bool isSelected, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? theme.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? theme.primaryColor : Colors.grey.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildDropdownRow(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.keyboard_arrow_down, size: 16),
              ),
              isDense: true,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 14),
              onChanged: onChanged,
              items: options.map<DropdownMenuItem<String>>((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val),
                );
              }).toList(),
            ),
          ),
        )
      ],
    );
  }
}
