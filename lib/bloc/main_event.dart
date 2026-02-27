part of 'main_bloc.dart';

@immutable
abstract class MainEvent {
  const MainEvent();
}

class AppLaunched extends MainEvent {
  const AppLaunched();
}

class NavigateToLogin extends MainEvent {
  const NavigateToLogin();
}

class NavigateToSignUp extends MainEvent {
  const NavigateToSignUp();
}

class CompleteAuthentication extends MainEvent {
  const CompleteAuthentication();
}

class SetLoading extends MainEvent {
  const SetLoading(this.enabled);

  final bool enabled;
}
