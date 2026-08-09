import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../../../core/services/audio_service.dart';
import '../../tuner/providers/mixer_provider.dart';
import '../../tuner/providers/instrument_provider.dart';
import '../../tuner/providers/tuner_provider.dart';
import '../providers/meditation_provider.dart';

class MeditationMainScreen extends ConsumerStatefulWidget {
  const MeditationMainScreen({super.key});

  @override
  ConsumerState<MeditationMainScreen> createState() => _MeditationMainScreenState();
}

class _MeditationMainScreenState extends ConsumerState<MeditationMainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _breathingController;
  
  double _droneVolume = 0.8;
  double _voiceVolume = 1.0;
  double _ambientVolume = 0.3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 12 seconds total for 4-4-4 breathing (Inhale, Hold, Exhale)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  String _getBreathingPhase(double value) {
    if (value < 0.33) return 'Inhale';
    if (value < 0.66) return 'Hold';
    return 'Exhale';
  }

  int _getBreathingSeconds(double value) {
    if (value < 0.33) return (value * 3 * 4).ceil(); // 0 to 4
    if (value < 0.66) return ((value - 0.33) * 3 * 4).ceil(); // 0 to 4
    return ((value - 0.66) * 3 * 4).ceil(); // 0 to 4
  }

  double _getScale(double value) {
    if (value < 0.33) {
      // Inhale: grow from 1.0 to 1.5
      return 1.0 + (value * 3 * 0.5);
    } else if (value < 0.66) {
      // Hold: stay at 1.5
      return 1.5;
    } else {
      // Exhale: shrink from 1.5 to 1.0
      return 1.5 - ((value - 0.66) * 3 * 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meditationState = ref.watch(meditationProvider);

    ref.listen(meditationProvider.select((state) => state.isActive), (previous, next) {
      if (next) {
        _breathingController.repeat();
      } else {
        _breathingController.stop();
        _breathingController.reset();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation Studio'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breathing Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Breathing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Text('4 - 4 - 4 (Box Breathing)'),
                        SizedBox(width: 8),
                        Icon(Icons.keyboard_arrow_down, size: 16),
                      ],
                    ),
                  )
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Session Timer
              if (meditationState.isActive)
                Center(
                  child: Text(
                    'Session Time: ${meditationState.elapsedSeconds ~/ 60}:${(meditationState.elapsedSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                ),
              if (meditationState.isActive) const SizedBox(height: 16),
              
              // Functional Breathing Animation
              Center(
                child: AnimatedBuilder(
                  animation: _breathingController,
                  builder: (context, child) {
                    final value = _breathingController.value;
                    final scale = _getScale(value);
                    final phase = _getBreathingPhase(value);
                    final sec = _getBreathingSeconds(value);
                    
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.withOpacity(0.1),
                          border: Border.all(color: Colors.green.withOpacity(0.5), width: 3),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(phase, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                              Text('$sec sec', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                ),
              ),
              
              const SizedBox(height: 48), // Extra space because of scale animation
              
              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: theme.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: theme.primaryColor,
                tabs: const [
                  Tab(text: 'Drone'),
                  Tab(text: 'Instruments'),
                  Tab(text: 'Effects'),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Mixer Controls (Drone Tab Content)
              SizedBox(
                height: 500,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDroneMixer(theme),
                    _buildInstrumentsTab(theme),
                    const Center(child: Text('Effects Controls')),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDroneMixer(ThemeData theme) {
    final mixerState = ref.watch(mixerProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tanpura (Oscillator)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Text('Sa - Pa'),
                  SizedBox(width: 8),
                  Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              ),
            )
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Sound selectors
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSoundIcon(Icons.music_note, 'Tanpura', true, theme),
            _buildSoundIcon(Icons.waves, 'Om Drone', false, theme),
            _buildSoundIcon(Icons.ac_unit, 'Tibetan Bowl', false, theme),
            _buildSoundIcon(Icons.notifications_active, 'Temple Bell', false, theme),
          ],
        ),
        
        const SizedBox(height: 24),
        const Text('Volume Mixer', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildVolumeRow('Drone', mixerState.droneVolume, (val) {
          ref.read(mixerProvider.notifier).setDroneVolume(val);
        }),
        _buildVolumeRow('Tone', mixerState.toneVolume, (val) {
          ref.read(mixerProvider.notifier).setToneVolume(val);
        }),
        _buildVolumeRow('Ambient', mixerState.ambientVolume, (val) {
          ref.read(mixerProvider.notifier).setAmbientVolume(val);
        }),
      ],
    );
  }

  Widget _buildSoundIcon(IconData icon, String label, bool isSelected, ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor.withOpacity(0.1) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: isSelected ? theme.primaryColor : Colors.grey.withOpacity(0.3)),
          ),
          child: Icon(icon, color: isSelected ? theme.primaryColor : Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isSelected ? theme.primaryColor : Colors.grey)),
      ],
    );
  }

  Widget _buildVolumeRow(String label, double value, Function(double) onChanged) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: Slider(
            value: value,
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 40, child: Text('${(value * 100).toInt()}%', style: const TextStyle(fontSize: 12, color: Colors.grey))),
      ],
    );
  }

  Widget _buildInstrumentsTab(ThemeData theme) {
    final instrumentState = ref.watch(instrumentProvider);
    final instrumentNotifier = ref.read(instrumentProvider.notifier);
    final tunerState = ref.watch(tunerProvider);
    final tunerNotifier = ref.read(tunerProvider.notifier);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Realistic Instruments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Tanpura Card
            _buildInstrumentCard(
              title: 'Acoustic Tanpura',
              isPlaying: instrumentState.selectedInstrument == 'tanpura' && instrumentState.isPlaying,
              tuning: tunerState.targetFrequency,
              onToggle: () {
                if (instrumentState.selectedInstrument != 'tanpura') {
                  instrumentNotifier.selectInstrument('tanpura');
                  if (!instrumentState.isPlaying) instrumentNotifier.togglePlayback();
                } else {
                  instrumentNotifier.togglePlayback();
                }
              },
              onTuningChanged: (val) => tunerNotifier.updateTargetFrequency(val),
              theme: theme,
            ),
            
            const SizedBox(height: 16),
            
            // Sarangi Card
            _buildInstrumentCard(
              title: 'Bowed Sarangi',
              isPlaying: instrumentState.selectedInstrument == 'sarangi' && instrumentState.isPlaying,
              tuning: tunerState.targetFrequency,
              onToggle: () {
                if (instrumentState.selectedInstrument != 'sarangi') {
                  instrumentNotifier.selectInstrument('sarangi');
                  if (!instrumentState.isPlaying) instrumentNotifier.togglePlayback();
                } else {
                  instrumentNotifier.togglePlayback();
                }
              },
              onTuningChanged: (val) => tunerNotifier.updateTargetFrequency(val),
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstrumentCard({
    required String title,
    required bool isPlaying,
    required double tuning,
    required VoidCallback onToggle,
    required ValueChanged<double> onTuningChanged,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                color: isPlaying ? theme.primaryColor : Colors.grey,
                iconSize: 36,
                onPressed: onToggle,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tuning (Hz)', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('${tuning.toStringAsFixed(1)} Hz', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          Slider(
            value: tuning,
            min: 50.0,
            max: 500.0,
            onChanged: onTuningChanged,
            activeColor: theme.primaryColor,
            inactiveColor: theme.primaryColor.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}

