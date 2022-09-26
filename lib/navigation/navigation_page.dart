
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/screens/splash_screen/splash_screen.dart';
import 'package:greentill/utils/shared_pref_helper.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({Key key}) : super(key: key);

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  MainBloc bloc;

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration(microseconds: 100)).then((value) => firebaseInit());
  }

  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of<MainBloc>(context);
    bloc.add(SplashIn());
    return WillPopScope(
      child: Scaffold(
        body: BlocBuilder<MainBloc, MainStates>(builder: (context, state) {
          if (state == MainStates.SplashIn) {
            return const SplashScreen();
          }
          // else if (state == MainStates.SignUp) {
          //   return SignUpScreen();
          // }
          else if (state == MainStates.LoggedLoading) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Loading..."),
                    Container(
                        margin: EdgeInsets.all(10),
                        child: CircularProgressIndicator()),
                  ],
                ),
              ),
            );
          } else if (state == MainStates.LoggedLogIn) {
            //token check
            //unauthorized check
            return Scaffold(
              body: AlertDialog(
                title: Text("Please Login"),
                content: Text("Login to proceed further."),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        // bloc.add(Login());
                        // bool isLoggedIn = SharedPrefHelper.instance
                        //     .getBool(SharedPrefHelper.IS_LOGGED_IN_BOOL);
                        // if (isLoggedIn) {
                        //   bloc.add(Home());
                        // } else {
                        //   bloc.add(WelcomeIn());
                        // }
                      },
                      child: Text("Login")),
                ],
              ),

            );
          } else {
            return Container();
          }
        }),
      ),
      // onWillPop: () async {
      //   bool isLoggedIn = SharedPrefHelper.instance
      //       .getBool(SharedPrefHelper.IS_LOGGED_IN_BOOL);
      //   if (isLoggedIn) {
      //   } else {}
      //
      //   if (bloc.state == MainStates.Home ||
      //       bloc.state == MainStates.WelcomeIn) {
      //     return true;
      //   }
      //   if (bloc.state == MainStates.SignUp ||
      //       bloc.state == MainStates.ForgotPassword) {
      //     bloc.add(WelcomeIn());
      //     return false;
      //   } else {
      //     bloc.add(Home());
      //     return false;
      //   }
      //   return false;
      // },
    );
  }
}
