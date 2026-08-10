import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/instrument_service.dart';
import '../providers/admin_provider.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  // Store local controllers to avoid rebuilding textfields on every stroke
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing state values
    final links = ref.read(adminProvider);
    for (var entry in instrumentService.instrumentNames.entries) {
      _controllers[entry.key] = TextEditingController(text: links[entry.key] ?? '');
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveLink(String id, String value) {
    ref.read(adminProvider.notifier).setCustomLink(id, value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved link for ${instrumentService.instrumentNames[id]}'), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch for updates (e.g. if loaded from prefs later)
    ref.watch(adminProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel: Audio Mapping'),
        backgroundColor: const Color(0xFFFCF9F2),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF9F7F2),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: instrumentService.instrumentNames.length,
        itemBuilder: (context, index) {
          final id = instrumentService.instrumentNames.keys.elementAt(index);
          final name = instrumentService.instrumentNames[id]!;
          final controller = _controllers[id]!;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'Enter direct audio URL or YouTube link',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _saveLink(id, controller.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
