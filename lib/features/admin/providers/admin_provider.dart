import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../core/services/instrument_service.dart';

final adminProvider = StateNotifierProvider<AdminNotifier, Map<String, String>>((ref) {
  return AdminNotifier();
});

class AdminNotifier extends StateNotifier<Map<String, String>> {
  static const _prefsKey = 'admin_instrument_links';
  SharedPreferences? _prefs;

  AdminNotifier() : super({}) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final data = _prefs?.getString(_prefsKey);
    if (data != null) {
      try {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        state = decoded.map((key, value) => MapEntry(key, value.toString()));
        instrumentService.updateCustomLinks(state);
      } catch (e) {
        print("Error decoding admin links: $e");
      }
    }
  }

  Future<void> setCustomLink(String instrumentId, String url) async {
    final newState = Map<String, String>.from(state);
    if (url.trim().isEmpty) {
      newState.remove(instrumentId);
    } else {
      newState[instrumentId] = url.trim();
    }
    
    state = newState;
    await _prefs?.setString(_prefsKey, jsonEncode(newState));
    
    // Update the instrument service so it uses it immediately
    instrumentService.updateCustomLinks(newState);
  }

  String? getLinkFor(String instrumentId) {
    return state[instrumentId];
  }
}
