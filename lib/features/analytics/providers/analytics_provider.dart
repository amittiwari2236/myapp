import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../meditation/providers/meditation_provider.dart';

// Since we are not using build_runner for simplicity, we will store 
// SessionStats as a Map<String, dynamic> in Hive.

class AnalyticsState {
  final List<SessionStats> history;
  final int totalSessions;
  final int totalDurationSeconds;
  final double averageGlobalAccuracy;
  final double bestAccuracy;
  final int totalChantCount;

  AnalyticsState({
    this.history = const [],
    this.totalSessions = 0,
    this.totalDurationSeconds = 0,
    this.averageGlobalAccuracy = 0.0,
    this.bestAccuracy = 0.0,
    this.totalChantCount = 0,
  });

  AnalyticsState copyWith({
    List<SessionStats>? history,
    int? totalSessions,
    int? totalDurationSeconds,
    double? averageGlobalAccuracy,
    double? bestAccuracy,
    int? totalChantCount,
  }) {
    return AnalyticsState(
      history: history ?? this.history,
      totalSessions: totalSessions ?? this.totalSessions,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      averageGlobalAccuracy: averageGlobalAccuracy ?? this.averageGlobalAccuracy,
      bestAccuracy: bestAccuracy ?? this.bestAccuracy,
      totalChantCount: totalChantCount ?? this.totalChantCount,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  static const String _boxName = 'session_history_box';
  
  AnalyticsNotifier() : super(AnalyticsState()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
    
    List<SessionStats> loadedHistory = [];
    
    for (var key in box.keys) {
      final item = box.get(key);
      if (item != null) {
        loadedHistory.add(SessionStats(
          startTime: DateTime.fromMillisecondsSinceEpoch(item['startTime'] as int),
          durationSeconds: item['durationSeconds'] as int,
          averageFrequency: item['averageFrequency'] as double,
          accuracyPercentage: item['accuracyPercentage'] as double,
          chantCount: item['chantCount'] as int,
        ));
      }
    }
    
    // Sort by most recent first
    loadedHistory.sort((a, b) => b.startTime.compareTo(a.startTime));
    
    _recalculate(loadedHistory);
  }

  Future<void> saveSession(SessionStats session) async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
    
    final sessionMap = {
      'startTime': session.startTime.millisecondsSinceEpoch,
      'durationSeconds': session.durationSeconds,
      'averageFrequency': session.averageFrequency,
      'accuracyPercentage': session.accuracyPercentage,
      'chantCount': session.chantCount,
    };
    
    await box.add(sessionMap);
    
    final updatedHistory = [session, ...state.history];
    // Keep it sorted just in case
    updatedHistory.sort((a, b) => b.startTime.compareTo(a.startTime));
    
    _recalculate(updatedHistory);
  }
  
  Future<void> clearHistory() async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
    await box.clear();
    _recalculate([]);
  }

  void _recalculate(List<SessionStats> updatedHistory) {
    int totalDur = 0;
    double sumAcc = 0.0;
    double bestAcc = 0.0;
    int totalChant = 0;
    
    for (var session in updatedHistory) {
      totalDur += session.durationSeconds;
      sumAcc += session.accuracyPercentage;
      totalChant += session.chantCount;
      if (session.accuracyPercentage > bestAcc) {
        bestAcc = session.accuracyPercentage;
      }
    }
    
    double avgAcc = updatedHistory.isEmpty ? 0.0 : sumAcc / updatedHistory.length;
    
    state = state.copyWith(
      history: updatedHistory,
      totalSessions: updatedHistory.length,
      totalDurationSeconds: totalDur,
      averageGlobalAccuracy: avgAcc,
      bestAccuracy: bestAcc,
      totalChantCount: totalChant,
    );
  }
}

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier();
});
