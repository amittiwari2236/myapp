import 'dart:math' as math;
import 'package:flutter/material.dart';

class CustomTunerGauge extends StatelessWidget {
  final double currentFrequency;
  final double targetFrequency;

  const CustomTunerGauge({
    super.key,
    required this.currentFrequency,
    required this.targetFrequency,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate deviation (simplified for visual representation)
    bool hasPitch = currentFrequency > 0;
    double deviation = hasPitch ? (currentFrequency - targetFrequency) : 0.0;
    
    // Normalize deviation to an angle between -pi/2 and pi/2
    // Let's say a max deviation of 20Hz maps to 90 degrees (pi/2)
    double maxDeviation = 20.0;
    double normalizedDeviation = (deviation / maxDeviation).clamp(-1.0, 1.0);
    double needleAngle = normalizedDeviation * (math.pi / 2);

    return SizedBox(
      width: double.infinity,
      height: 280, // Height is roughly half of width to accommodate the semi-circle + extra padding
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(
            size: const Size(double.infinity, 250),
            painter: _GaugePainter(),
          ),
          CustomPaint(
            size: const Size(double.infinity, 250),
            painter: _NeedlePainter(needleAngle),
          ),
          // Center Text Content
          Positioned(
            bottom: 10, // Adjust vertically
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ॐ',
                  style: TextStyle(
                    fontSize: 48,
                    color: Color(0xFF2E3A2F), // Dark greenish black
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${targetFrequency.toInt()} Hz',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E3A2F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'A4 = 432 Hz',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Target Frequency',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Side texts (396 Hz and 528 Hz)
          Positioned(
            left: 40,
            bottom: 70,
            child: Column(
              children: [
                const Text('396', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Hz', style: TextStyle(color: Color(0xFF666666), fontSize: 12)),
              ],
            ),
          ),
          Positioned(
            right: 40,
            bottom: 70,
            child: Column(
              children: [
                const Text('528', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Hz', style: TextStyle(color: Color(0xFF666666), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2.2;
    
    // Draw the ticks
    int totalTicks = 51; // odd number so there is a center tick
    double sweepAngle = math.pi;
    double startAngle = math.pi;

    for (int i = 0; i < totalTicks; i++) {
      double fraction = i / (totalTicks - 1);
      double angle = startAngle + fraction * sweepAngle;
      
      // Calculate tick length (center tick and every 5th tick is longer)
      bool isMajor = i % 10 == 0;
      bool isMedium = i % 5 == 0 && !isMajor;
      
      double tickLength = isMajor ? 16.0 : (isMedium ? 12.0 : 8.0);
      double innerRadius = radius - tickLength;
      
      Offset p1 = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      Offset p2 = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );

      // Exact color mapping from screenshot:
      // Left side is orange, middle is grey, right side is green
      Color tickColor;
      if (fraction <= 0.2) {
        tickColor = const Color(0xFFE86F1C);
      } else if (fraction >= 0.8) {
        tickColor = const Color(0xFF4CAF50);
      } else {
        tickColor = const Color(0xFFDDDDDD);
      }

      final tickPaint = Paint()
        ..color = tickColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isMajor ? 3 : 2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NeedlePainter extends CustomPainter {
  final double angle; // 0 is straight up (-pi/2 in canvas coordinates relative to center)

  _NeedlePainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final needleLength = size.width / 2.2 - 25; // Stop before ticks

    double drawAngle = -math.pi / 2 + angle;
    Offset tip = Offset(
      center.dx + needleLength * math.cos(drawAngle),
      center.dy + needleLength * math.sin(drawAngle),
    );
    
    // In screenshot, needle has a grey base line with an orange tip/dot
    final basePaint = Paint()
      ..color = const Color(0xFFB0B0B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
      
    // The line comes from center
    canvas.drawLine(center, tip, basePaint);

    // Orange dot on the needle
    final dotPaint = Paint()
      ..color = const Color(0xFFE86F1C)
      ..style = PaintingStyle.fill;
    
    Offset dotPos = Offset(
      center.dx + (needleLength * 0.6) * math.cos(drawAngle),
      center.dy + (needleLength * 0.6) * math.sin(drawAngle),
    );
    canvas.drawCircle(dotPos, 4, dotPaint);

    // Center pivot point
    final pivotPaint = Paint()
      ..color = const Color(0xFF2E3A2F)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, pivotPaint);
    
    // Top dot near tip
    final tipDotPaint = Paint()
      ..color = const Color(0xFF2E3A2F)
      ..style = PaintingStyle.fill;
    
    Offset tipDotPos = Offset(
      center.dx + (needleLength + 5) * math.cos(drawAngle),
      center.dy + (needleLength + 5) * math.sin(drawAngle),
    );
    canvas.drawCircle(tipDotPos, 4, tipDotPaint);
  }

  @override
  bool shouldRepaint(covariant _NeedlePainter oldDelegate) {
    return oldDelegate.angle != angle;
  }
}
