import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  MainBloc bloc;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: Platform.isAndroid ? 2 : 2), () {
      // bloc.add(Login());
      bloc.init();
      //bloc.add(Login());
      // bloc.add(SignUp);
    });
  }

  Widget build(BuildContext context) {
    bloc = BlocProvider.of<MainBloc>(context);

    return Scaffold(
      backgroundColor: colorWhite,
      body: Center(
        child: Container(
          width: 170,
          height: 140,
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
