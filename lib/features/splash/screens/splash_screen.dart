import 'dart:async';
import 'package:flutter/material.dart';
import '../../navigation/main_navigation_screen.dart';
import '../../../core/utils/app_initializer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Kick off background initializations immediately so they don't block UI
    AppInitializer.initializeBackgroundTasks();

    // 2.5 seconds forward (breathe in), 2.5 seconds reverse (breathe out) = 5 seconds total
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    // Start breathing animation
    _controller.forward().then((_) {
      _controller.reverse();
    });

    // Navigate to main app exactly after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainNavigationScreen(),
            transitionDuration: const Duration(milliseconds: 800),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F2),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Determine text based on animation status
            String breathText = _controller.status == AnimationStatus.forward || 
                                _controller.status == AnimationStatus.completed 
                                ? 'Breathe In' 
                                : 'Breathe Out';

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // The Breathing Circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer expanding circle
                    Container(
                      width: 200 * _scaleAnimation.value,
                      height: 200 * _scaleAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE86F1C).withOpacity(0.15 * _opacityAnimation.value),
                      ),
                    ),
                    // Inner logo circle
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFDF9F2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                          )
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'PYSHK',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: Color(0xFF2E3A2F),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 60),
                
                // Breath Text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    breathText,
                    key: ValueKey<String>(breathText),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 4,
                      color: Color(0xFFE86F1C),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
