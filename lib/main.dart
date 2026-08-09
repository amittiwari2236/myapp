import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: MantraTunerApp(),
    ),
  );
}

class MantraTunerApp extends ConsumerWidget {
  const MantraTunerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine theme mode (can be managed via Riverpod if settings allow)
    return MaterialApp(
      title: 'Mantra Tuner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Default to light, can be dynamic
      home: const SplashScreen(),
    );
  }
}
