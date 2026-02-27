import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/screens/home/home_screen.dart';
import 'package:greentill/ui/screens/login/login_screen.dart';
import 'package:greentill/ui/screens/signup/signup_screen.dart';
import 'package:greentill/ui/screens/splash_screen/splash_screen.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MainBloc>().add(const AppLaunched());
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: BlocBuilder<MainBloc, MainState>(
          builder: (context, state) {
            switch (state) {
              case MainState.splash:
                return const SplashScreen();
              case MainState.onboarding:
                return const SignUpScreen();
              case MainState.login:
                return const LoginScreen();
              case MainState.loading:
                return const Center(child: CircularProgressIndicator());
              case MainState.home:
                return const HomeScreen();
              case MainState.error:
                return const Center(
                  child: Text("Something went wrong. Please restart the app."),
                );
            }
          },
        ),
      ),
    );
  }
}
