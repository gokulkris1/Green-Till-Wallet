
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'main_event.dart';

enum MainStates {
  SplashIn,
  SignUp,
  CreateAccount1,
  LoggedLoading,
  LoggedLogIn,
  LoggedERROR,
  LoggedSUCCESS,
}

class MainBloc extends Bloc<MainEvent, MainStates> {
  List colors = [
    "All",
    "Black",
    "Grey",
    "White",
    "Beige",
    "Red",
    "Pink",
    "Purple",
    "Blue",
    "Green",
    "Yellow",
    "Orange",
    "Brown",
    "Gold",
    "Silver",
    "Other"
  ];

  //UserRepository userRepository = UserRepository.getInstance();
  //Data userData;

  init() {
    // userRepository.isLoggedIn().then((value) async {
    //   if (value) {
    //     userRepository.isAccountCreated().then((value) async {
    //       print("account created=");
    //       print(value);
    //       if (value) {
    //         LoginResponse model = userRepository.getUserData();
    //         this.add(Login(model.data));
    //       } else {
    //         this.add(CreateAccount1());
    //       }
    //     });
    //   } else {
    //     this.add(WelcomeIn());
    //   }
    // });
  }

  MainBloc() : super(MainStates.SplashIn);

  @override
  Stream<MainStates> mapEventToState(MainEvent event) async* {
    // sets state based on events
    if (event is SplashIn) {
      yield MainStates.SplashIn;
    } else if (event is SignUp) {
      yield MainStates.LoggedLoading;
      yield MainStates.SignUp;
      // Navigator.of(event.context)
      //     .push(MaterialPageRoute(builder: (context) => SignUpScreen()));
    }
  }
}
