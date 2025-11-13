import 'package:flutter/material.dart';

class KenwellAppLogo extends StatelessWidget {
  final double size;
  const KenwellAppLogo({super.key, this.size = 250});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/app_logo.jpg', width: size, height: size);
  }
}
