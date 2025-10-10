import 'package:flutter/material.dart';
import '../widgets/silk_background.dart';

/// Example screen showing different SilkBackground configurations
/// Use this to experiment with different silk effects
class SilkBackgroundDemo extends StatelessWidget {
  const SilkBackgroundDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Silk Background Examples'),
        backgroundColor: Colors.black87,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          _buildExample(
            context,
            'Default',
            const SilkBackground(),
          ),
          _buildExample(
            context,
            'Purple Silk',
            const SilkBackground(
              color: Color(0xFF7B7481),
              speed: 5.0,
              scale: 1.0,
            ),
          ),
          _buildExample(
            context,
            'Green Silk',
            const SilkBackground(
              color: Color(0xFF386641),
              speed: 3.0,
              scale: 1.5,
            ),
          ),
          _buildExample(
            context,
            'Blue Silk',
            const SilkBackground(
              color: Color(0xFF264653),
              speed: 7.0,
              scale: 0.8,
            ),
          ),
          _buildExample(
            context,
            'Rose Gold',
            const SilkBackground(
              color: Color(0xFFB76E79),
              speed: 4.0,
              noiseIntensity: 2.0,
            ),
          ),
          _buildExample(
            context,
            'Dark Silk',
            const SilkBackground(
              color: Color(0xFF1A1A1A),
              speed: 6.0,
              scale: 2.0,
              noiseIntensity: 3.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExample(BuildContext context, String title, Widget background) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: background,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
