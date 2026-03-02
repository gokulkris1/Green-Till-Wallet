import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late MainBloc bloc;

  @override
  void initState() {
    super.initState();
    final delaySeconds = (!kIsWeb && Platform.isAndroid) ? 2 : 2;
    Timer(Duration(seconds: delaySeconds), () {
      // bloc.add(Login());
      bloc.init();
      //bloc.add(Login());
      // bloc.add(SignUp);
    });
  }

  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of<MainBloc>(context);

    return Scaffold(
      backgroundColor: colorWhite,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width*0.57,
          height:MediaQuery.of(context).size.height*0.22,
          child: Container(
            child: Image.asset(
              SPLASH_IMAGE,
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width,
            ),
          ),
        ),
      ),
    );
  }
}
