import 'package:flutter/material.dart';

class SafaiLogoWidget extends StatelessWidget {
  final double height;

  const SafaiLogoWidget({
    super.key,
    this.height = 62,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/safai_logo.png',
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        // Fallback UI in case asset path is not resolved in hot reload or testing
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  's',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8E7535),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF238B42),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.recycling,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'fai',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8E7535),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF238B42), width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '360°',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF238B42),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'CLEAN TODAY, GREENER TOMORROW',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Color(0xFF238B42),
              ),
            ),
          ],
        );
      },
    );
  }
}
