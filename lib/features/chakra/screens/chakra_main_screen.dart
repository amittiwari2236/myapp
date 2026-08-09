import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../navigation/main_navigation_screen.dart';
import '../providers/chakra_provider.dart';
import '../../meditation/providers/meditation_provider.dart';
import '../../tuner/providers/tuner_provider.dart';

class ChakraMainScreen extends ConsumerWidget {
  const ChakraMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chakraState = ref.watch(chakraProvider);
    final chakraData = chakraState.currentChakra;

    ref.listen(meditationProvider.select((s) => s.lastSession), (previous, next) {
      if (next != null && (previous == null || previous.startTime != next.startTime)) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Meditation Session Complete'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Duration: ${next.durationSeconds ~/ 60}m ${next.durationSeconds % 60}s'),
                const SizedBox(height: 8),
                Text('Avg Frequency: ${next.averageFrequency.toStringAsFixed(1)} Hz'),
                const SizedBox(height: 8),
                Text('Pitch Accuracy: ${next.accuracyPercentage.toStringAsFixed(1)}%'),
                const SizedBox(height: 8),
                Text('Chant Count: ~${next.chantCount} sec of chanting'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F2),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Chakra Mode',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            ref.read(bottomNavIndexProvider.notifier).state = 0;
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black87),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            children: [
              // Silhouette and Chakra Column
              SizedBox(
                height: 360,
                child: Row(
                  children: [
                    // Chakra selection column
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: allChakras.map((chakra) {
                          return GestureDetector(
                            onTap: () {
                              ref.read(chakraProvider.notifier).selectChakra(chakra.index);
                            },
                            child: _buildSideChakraIcon(
                              chakra.color, 
                              chakraState.selectedIndex == chakra.index
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Spacer(),
                    
                    // Meditating Figure with Chakra Points
                    SizedBox(
                      width: 240,
                      height: 360,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background glowing mandala for selected chakra
                          Positioned(
                            top: 25 + (chakraState.selectedIndex * 30.0).clamp(0, 220), // rough estimate for active glow
                            child: Icon(
                              Icons.ac_unit, 
                              size: 70,
                              color: chakraData.color.withOpacity(0.15),
                            ),
                          ),
                          // Meditating Silhouette
                          const Positioned(
                            bottom: 20,
                            child: Icon(
                              Icons.self_improvement,
                              size: 280,
                              color: Color(0xFF8D7966), // Brownish silhouette
                            ),
                          ),
                          // Chakra Points on the body
                          Positioned(top: 25, child: _buildBodyChakraPoint(allChakras[0].color, isCrown: true, isActive: chakraState.selectedIndex == 0)), // Crown
                          Positioned(top: 85, child: _buildBodyChakraPoint(allChakras[1].color, isActive: chakraState.selectedIndex == 1)), // Third Eye
                          Positioned(top: 115, child: _buildBodyChakraPoint(allChakras[2].color, isActive: chakraState.selectedIndex == 2)), // Throat
                          Positioned(top: 145, child: _buildBodyChakraPoint(allChakras[3].color, isActive: chakraState.selectedIndex == 3)), // Heart
                          Positioned(top: 175, child: _buildBodyChakraPoint(allChakras[4].color, isActive: chakraState.selectedIndex == 4)), // Solar Plexus
                          Positioned(top: 205, child: _buildBodyChakraPoint(allChakras[5].color, isActive: chakraState.selectedIndex == 5)), // Sacral
                          Positioned(top: 245, child: _buildBodyChakraPoint(allChakras[6].color, isActive: chakraState.selectedIndex == 6)), // Root
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                chakraData.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: chakraData.color, 
                ),
              ),
              const SizedBox(height: 4),
              Text(
                chakraData.sanskritName,
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Frequency Control
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: chakraData.color.withOpacity(0.15), 
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${ref.watch(tunerProvider).targetFrequency.toStringAsFixed(1)} Hz',
                      style: TextStyle(
                        color: chakraData.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: chakraData.color,
                      inactiveTrackColor: chakraData.color.withOpacity(0.2),
                      thumbColor: chakraData.color,
                      overlayColor: chakraData.color.withOpacity(0.1),
                      trackHeight: 4.0,
                    ),
                    child: Slider(
                      value: ref.watch(tunerProvider).targetFrequency.clamp(50.0, 1000.0),
                      min: 50.0,
                      max: 1000.0,
                      onChanged: (val) {
                        ref.read(tunerProvider.notifier).updateTargetFrequency(val);
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Recommended Mantra Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Recommended Mantra',
                          style: TextStyle(color: Color(0xFF666666), fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          chakraData.mantra,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: Color(0xFF2E3A2F),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.volume_up_outlined, color: Color(0xFF4A4A4A)),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Details Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Color',
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: chakraData.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Element', Text(chakraData.element, style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 14))),
                    const SizedBox(height: 16),
                    _buildDetailRow('Location', Text(chakraData.location, style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 14))),
                    const SizedBox(height: 16),
                    _buildDetailRow('Affirmation', Text('"${chakraData.affirmation}"', style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 14, fontStyle: FontStyle.italic))),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Start/Stop Meditation Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(chakraProvider.notifier).toggleMeditation();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    backgroundColor: chakraState.isPlaying ? Colors.red.shade400 : chakraData.color,
                    elevation: 0,
                  ),
                  child: Text(
                    chakraState.isPlaying ? 'Stop Meditation' : 'Start Meditation',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              
              // Custom Presets Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF4EA),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.star_border, color: Color(0xFF2E3A2F), size: 32),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Custom Presets',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E3A2F),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Save your favorite\nfrequencies, scales and\nmeditation settings.',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSideChakraIcon(Color color, bool isSelected) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Center(
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          ),
          child: Center(
            child: Icon(Icons.flare, color: color, size: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyChakraPoint(Color color, {bool isCrown = false, bool isActive = false}) {
    if (isCrown) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isActive ? 1.0 : 0.4),
              blurRadius: isActive ? 24 : 16,
              spreadRadius: isActive ? 10 : 6,
            )
          ],
        ),
        child: Center(
          child: Icon(Icons.flare, color: color, size: 24),
        ),
      );
    }
    
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isActive ? 1.0 : 0.4),
            blurRadius: isActive ? 12 : 8,
            spreadRadius: isActive ? 4 : 2,
          )
        ],
        border: Border.all(color: Colors.white.withOpacity(0.6), width: isActive ? 2.5 : 1.5),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, Widget content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: content),
      ],
    );
  }
}
