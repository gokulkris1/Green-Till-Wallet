import 'package:flutter/material.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: colorWhite,
      body: Center(
        child: SizedBox(
          width: size.width * 0.4,
          child: Image.asset(
            SPLASH_IMAGE,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
