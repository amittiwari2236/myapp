import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tuner_view.dart';
import 'manual_settings_view.dart';

class TunerMainScreen extends ConsumerStatefulWidget {
  const TunerMainScreen({super.key});

  @override
  ConsumerState<TunerMainScreen> createState() => _TunerMainScreenState();
}

class _TunerMainScreenState extends ConsumerState<TunerMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {}, // Open drawer
        ),
        title: const Text(
          'Mantra Tuner',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () {},
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey.shade500,
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 3,
          dividerColor: Colors.transparent, // Remove default grey line
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          tabs: const [
            Tab(text: 'Tuner'),
            Tab(text: 'Manual'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TunerView(),
          ManualSettingsView(),
        ],
      ),
    );
  }
}
