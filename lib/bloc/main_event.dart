part of 'main_bloc.dart';


@immutable
abstract class MainEvent {}

// this displays error message
class ShowError extends MainEvent {}

// to show splash screen
class SplashIn extends MainEvent {
  SplashIn();
}

class SignUp extends MainEvent {
  SignUp();
}

class CreateAccount1 extends MainEvent {
  CreateAccount1();
}



