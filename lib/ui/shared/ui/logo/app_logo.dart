import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 250});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(size * 0.28), // Modern, very rounded
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.7),
            width: 4,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          'assets/app_logo.jpg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
