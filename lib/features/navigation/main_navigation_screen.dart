import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

import '../tuner/screens/tuner_main_screen.dart';
import '../chakra/screens/chakra_main_screen.dart';
import '../meditation/screens/meditation_main_screen.dart';
import '../analytics/screens/analytics_main_screen.dart';
import '../library/screens/library_main_screen.dart';

// State provider for Bottom Nav
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final screens = [
      const TunerMainScreen(),
      const ChakraMainScreen(),
      const LibraryMainScreen(),
      const MeditationMainScreen(), // Meditation Studio / Sessions
    ];

    return Scaffold(
      body: PopScope(
        canPop: currentIndex == 0,
        onPopInvoked: (didPop) {
          if (didPop) return;
          ref.read(bottomNavIndexProvider.notifier).state = 0;
        },
        child: IndexedStack(
          index: currentIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFCF9F2),
          border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          currentIndex: currentIndex,
          onTap: (index) => ref.read(bottomNavIndexProvider.notifier).state = index,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey.shade500,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.candlestick_chart_outlined),
              ),
              label: 'Tuner',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.all_inclusive),
              ),
              label: 'Chakra',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.my_library_books_outlined),
              ),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.settings_suggest_outlined),
              ),
              label: 'Sessions',
            ),
          ],
        ),
      ),
    );
  }
}
