import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Aurora Background Widget
/// 
/// A Flutter implementation of an animated aurora effect background.
/// Translates the WebGL React component to Flutter's CustomPainter.
/// 
/// Usage:
/// ```dart
/// AuroraBackground(
///   colorStops: [Color(0xFF3A29FF), Color(0xFFFF94B4), Color(0xFFFF3232)],
///   blend: 0.5,
///   amplitude: 1.0,
///   speed: 0.5,
/// )
/// ```
class AuroraBackground extends StatefulWidget {
  final List<Color> colorStops;
  final double blend;
  final double amplitude;
  final double speed;
  final Color backgroundColor;

  const AuroraBackground({
    super.key,
    this.colorStops = const [
      Color(0xFF5227FF),
      Color(0xFF7CFF67),
      Color(0xFF5227FF),
    ],
    this.blend = 0.5,
    this.amplitude = 1.0,
    this.speed = 0.5,
    this.backgroundColor = Colors.white,
  });

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: AuroraPainter(
              time: _controller.value * 100 * widget.speed,
              colorStops: widget.colorStops,
              amplitude: widget.amplitude,
              blend: widget.blend,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class AuroraPainter extends CustomPainter {
  final double time;
  final List<Color> colorStops;
  final double amplitude;
  final double blend;

  AuroraPainter({
    required this.time,
    required this.colorStops,
    required this.amplitude,
    required this.blend,
  });

  // Simplex noise implementation for smooth wave generation
  static const List<List<int>> _grad3 = [
    [1, 1, 0], [-1, 1, 0], [1, -1, 0], [-1, -1, 0],
    [1, 0, 1], [-1, 0, 1], [1, 0, -1], [-1, 0, -1],
    [0, 1, 1], [0, -1, 1], [0, 1, -1], [0, -1, -1]
  ];

  double _dot(List<int> g, double x, double y) {
    return g[0] * x + g[1] * y;
  }

  double snoise(double xin, double yin) {
    const double F2 = 0.366025403784439;
    const double G2 = 0.211324865405187;

    double s = (xin + yin) * F2;
    int i = (xin + s).floor();
    int j = (yin + s).floor();

    double t = (i + j) * G2;
    double x0 = xin - (i - t);
    double y0 = yin - (j - t);

    int i1, j1;
    if (x0 > y0) {
      i1 = 1;
      j1 = 0;
    } else {
      i1 = 0;
      j1 = 1;
    }

    double x1 = x0 - i1 + G2;
    double y1 = y0 - j1 + G2;
    double x2 = x0 - 1.0 + 2.0 * G2;
    double y2 = y0 - 1.0 + 2.0 * G2;

    int ii = i & 255;
    int jj = j & 255;
    int gi0 = _perm[ii + _perm[jj]] % 12;
    int gi1 = _perm[ii + i1 + _perm[jj + j1]] % 12;
    int gi2 = _perm[ii + 1 + _perm[jj + 1]] % 12;

    double t0 = 0.5 - x0 * x0 - y0 * y0;
    double n0;
    if (t0 < 0) {
      n0 = 0.0;
    } else {
      t0 *= t0;
      n0 = t0 * t0 * _dot(_grad3[gi0], x0, y0);
    }

    double t1 = 0.5 - x1 * x1 - y1 * y1;
    double n1;
    if (t1 < 0) {
      n1 = 0.0;
    } else {
      t1 *= t1;
      n1 = t1 * t1 * _dot(_grad3[gi1], x1, y1);
    }

    double t2 = 0.5 - x2 * x2 - y2 * y2;
    double n2;
    if (t2 < 0) {
      n2 = 0.0;
    } else {
      t2 *= t2;
      n2 = t2 * t2 * _dot(_grad3[gi2], x2, y2);
    }

    return 70.0 * (n0 + n1 + n2);
  }

  static final List<int> _perm = _generatePermutation();

  static List<int> _generatePermutation() {
    final p = <int>[
      151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225,
      140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148,
      247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32,
      57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175,
      74, 165, 71, 134, 139, 48, 27, 166, 77, 146, 158, 231, 83, 111, 229, 122,
      60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54,
      65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169,
      200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64,
      52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212,
      207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183, 170, 213,
      119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9,
      129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104,
      218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241,
      81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199, 106, 157,
      184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205, 93,
      222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180
    ];
    return [...p, ...p]; // Double it for wrapping
  }

  Color _lerpColor(Color a, Color b, double t) {
    return Color.lerp(a, b, t.clamp(0.0, 1.0))!;
  }

  Color _getColorFromGradient(double factor) {
    if (colorStops.length < 2) return colorStops.first;
    if (colorStops.length == 2) {
      return _lerpColor(colorStops[0], colorStops[1], factor);
    }

    // For 3 colors: positions at 0.0, 0.5, 1.0
    if (factor <= 0.5) {
      return _lerpColor(colorStops[0], colorStops[1], factor * 2.0);
    } else {
      return _lerpColor(colorStops[1], colorStops[2], (factor - 0.5) * 2.0);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Draw multiple smooth wave layers for aurora effect
    const numWaves = 3;
    
    for (int waveIndex = 0; waveIndex < numWaves; waveIndex++) {
      final path = Path();
      final points = <Offset>[];
      
      // Generate smooth wave points
      const resolution = 100; // Number of points across the width
      final offset = waveIndex * 0.3; // Offset each wave slightly
      
      for (int i = 0; i <= resolution; i++) {
        final x = (i / resolution) * width;
        final uvX = i / resolution;
        
        // Calculate wave height using simplex noise with different frequencies per wave
        final noiseValue1 = snoise(
          uvX * 2.0 + time * 0.01 + offset,
          time * 0.025 + waveIndex * 0.5,
        );
        
        final noiseValue2 = snoise(
          uvX * 4.0 + time * 0.015 + offset,
          time * 0.03 + waveIndex * 0.3,
        );
        
        // Combine noise for more interesting waves
        double waveHeight = (noiseValue1 * 0.7 + noiseValue2 * 0.3) * amplitude;
        waveHeight = math.exp(waveHeight * 0.5);
        
        // Position wave in vertical space
        final y = height * (0.3 + waveHeight * 0.4 - waveIndex * 0.15);
        
        points.add(Offset(x, y));
      }
      
      // Build smooth path through points
      if (points.isNotEmpty) {
        path.moveTo(points.first.dx, points.first.dy);
        
        // Use quadratic curves for smooth interpolation
        for (int i = 0; i < points.length - 1; i++) {
          final current = points[i];
          final next = points[i + 1];
          final controlPoint = Offset(
            (current.dx + next.dx) / 2,
            (current.dy + next.dy) / 2,
          );
          path.quadraticBezierTo(
            current.dx,
            current.dy,
            controlPoint.dx,
            controlPoint.dy,
          );
        }
        
        // Complete the path to fill the area
        path.lineTo(width, height);
        path.lineTo(0, height);
        path.close();
        
        // Get color for this wave based on position
        final colorFactor = waveIndex / (numWaves - 1);
        final waveColor = _getColorFromGradient(colorFactor);
        
        // Calculate alpha based on wave index
        final baseAlpha = 0.3 - (waveIndex * 0.08);
        
        // Create gradient paint for smooth color transitions
        final gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            waveColor.withValues(alpha: baseAlpha * blend),
            waveColor.withValues(alpha: baseAlpha * blend * 0.5),
            waveColor.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.5, 1.0],
        );
        
        final paint = Paint()
          ..shader = gradient.createShader(Rect.fromLTWH(0, 0, width, height))
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;
        
        canvas.drawPath(path, paint);
      }
    }
    
    // Add subtle overlay gradient for depth
    final overlayGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorStops[0].withValues(alpha: 0.1),
        Colors.transparent,
        colorStops[2].withValues(alpha: 0.1),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final overlayPaint = Paint()
      ..shader = overlayGradient.createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), overlayPaint);
  }

  @override
  bool shouldRepaint(AuroraPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.blend != blend;
  }
}
