import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_provider.dart';
import 'package:intl/intl.dart';

class AnalyticsMainScreen extends ConsumerWidget {
  const AnalyticsMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analyticsState = ref.watch(analyticsProvider);
    
    // Formatting durations
    String formatDuration(int seconds) {
      final m = seconds ~/ 60;
      final s = seconds % 60;
      return '$m:${s.toString().padLeft(2, '0')}';
    }
    
    final lastSession = analyticsState.history.isNotEmpty ? analyticsState.history.first : null;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
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
              // Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    )
                  ]
                ),
                child: Column(
                  children: [
                    const Text('Great Session! 🙏', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('You stayed consistent and in tune.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCol(formatDuration(lastSession?.durationSeconds ?? 0), 'Last Duration'),
                        _buildStatCol('${lastSession?.averageFrequency.toStringAsFixed(1) ?? "0"} Hz', 'Avg. Frequency'),
                        _buildStatCol('${lastSession?.accuracyPercentage.toStringAsFixed(0) ?? "0"}%', 'Stability'),
                      ],
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Chart Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Frequency Stability', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Very Stable', style: TextStyle(color: Colors.green, fontSize: 12)),
                  )
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Chart
              SizedBox(
                height: 150,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                    titlesData: const FlTitlesData(
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 25.5,
                    minY: 500,
                    maxY: 550,
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 528),
                          FlSpot(5, 529),
                          FlSpot(10, 527),
                          FlSpot(15, 528),
                          FlSpot(20, 528.5),
                          FlSpot(25.5, 528),
                        ],
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.green.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Pitch Accuracy
              const Text('Avg. Pitch Accuracy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: analyticsState.averageGlobalAccuracy / 100.0,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('${analyticsState.averageGlobalAccuracy.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Bottom Stats
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard('Total Sessions', '${analyticsState.totalSessions}', theme),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard('Total Chants', '${analyticsState.totalChantCount} sec', theme),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Text('Recent Sessions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              if (analyticsState.history.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(child: Text('No sessions recorded yet.', style: TextStyle(color: Colors.grey))),
                )
              else
                ...analyticsState.history.take(5).map((session) {
                  return Column(
                    children: [
                      _buildListRow(
                        DateFormat('MMM dd, hh:mm a').format(session.startTime),
                        '${session.accuracyPercentage.toStringAsFixed(1)}%',
                        '${session.averageFrequency.toStringAsFixed(1)} Hz | ${formatDuration(session.durationSeconds)}',
                      ),
                      const Divider(),
                    ],
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildListRow(String label, String value, String subValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(subValue, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}
