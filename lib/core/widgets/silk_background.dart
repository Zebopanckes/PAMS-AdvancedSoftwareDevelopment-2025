// Author: Alec Brothwood (23076824) - Project Manager
// Author: Ashley Shoniwa (24021297) - Frontend Developer
// File: silk_background.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A silk-like animated background widget inspired by shader effects
/// This creates a flowing, fabric-like pattern with customizable properties
class SilkBackground extends StatefulWidget {
  /// Animation speed multiplier (default: 5.0)
  final double speed;
  
  /// Pattern scale multiplier (default: 1.0)
  final double scale;
  
  /// Primary color of the silk effect (default: #7B7481)
  final Color color;
  
  /// Noise intensity for grain effect (default: 1.5)
  final double noiseIntensity;
  
  /// Rotation angle in radians (default: 0.0)
  final double rotation;

  const SilkBackground({
    super.key,
    this.speed = 3.0,
    this.scale = 1.0,
    this.color = const Color.fromARGB(255, 52, 170, 80),
    this.noiseIntensity = 0.5,
    this.rotation = 0.0,
  });

  @override
  State<SilkBackground> createState() => _SilkBackgroundState();
}

class _SilkBackgroundState extends State<SilkBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _time = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(() {
      setState(() {
        _time += 0.1 * (1 / 60) * widget.speed;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SilkPainter(
        time: _time,
        speed: widget.speed,
        scale: widget.scale,
        color: widget.color,
        noiseIntensity: widget.noiseIntensity,
        rotation: widget.rotation,
      ),
      child: Container(),
    );
  }
}

class _SilkPainter extends CustomPainter {
  final double time;
  final double speed;
  final double scale;
  final Color color;
  final double noiseIntensity;
  final double rotation;

  _SilkPainter({
    required this.time,
    required this.speed,
    required this.scale,
    required this.color,
    required this.noiseIntensity,
    required this.rotation,
  });

  /// Simple noise function based on sine and position
  double _noise(double x, double y) {
    const double g = math.e;
    final double rx = g * math.sin(g * x);
    final double ry = g * math.sin(g * y);
    return (rx * ry * (1.0 + x)) % 1.0;
  }

  /// Rotate UV coordinates
  Offset _rotateUv(Offset uv, double angle) {
    final double c = math.cos(angle);
    final double s = math.sin(angle);
    return Offset(
      c * uv.dx - s * uv.dy,
      s * uv.dx + c * uv.dy,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Create a grid of points to sample the pattern
    const int gridSize = 100;
    final double stepX = size.width / gridSize;
    final double stepY = size.height / gridSize;

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        // Calculate UV coordinates (0 to 1)
        final double u = i / gridSize;
        final double v = j / gridSize;

        // Apply rotation
        final Offset rotatedUv = _rotateUv(Offset(u, v) * scale, rotation);

        // Calculate texture coordinates
        double texX = rotatedUv.dx * scale;
        double texY = rotatedUv.dy * scale;

        // Time offset for animation
        final double tOffset = speed * time;

        // Add wave distortion
        texY += 0.03 * math.sin(8.0 * texX - tOffset);

        // Create silk-like pattern using multiple sine waves
        final double pattern = 0.6 +
            0.4 *
                math.sin(5.0 *
                    (texX +
                        texY +
                        math.cos(3.0 * texX + 5.0 * texY) +
                        0.02 * tOffset) +
                    math.sin(20.0 * (texX + texY - 0.1 * tOffset)));

        // Add noise for grain effect
        final double noise = _noise(i.toDouble(), j.toDouble());
        final double noiseEffect = noise / 15.0 * noiseIntensity;

        // Calculate final color
        final double r = ((color.r * 255.0).round() & 0xff) / 255.0 * pattern - noiseEffect;
        final double g = ((color.g * 255.0).round() & 0xff) / 255.0 * pattern - noiseEffect;
        final double b = ((color.b * 255.0).round() & 0xff) / 255.0 * pattern - noiseEffect;

        paint.color = Color.fromRGBO(
          (r.clamp(0.0, 1.0) * 255).toInt(),
          (g.clamp(0.0, 1.0) * 255).toInt(),
          (b.clamp(0.0, 1.0) * 255).toInt(),
          1.0,
        );

        // Draw a small rectangle for this grid point
        canvas.drawRect(
          Rect.fromLTWH(i * stepX, j * stepY, stepX + 1, stepY + 1),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SilkPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.speed != speed ||
        oldDelegate.scale != scale ||
        oldDelegate.color != color ||
        oldDelegate.noiseIntensity != noiseIntensity ||
        oldDelegate.rotation != rotation;
  }
}
