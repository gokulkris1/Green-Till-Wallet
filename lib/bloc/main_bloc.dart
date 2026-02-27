import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import 'package:greentill/utils/shared_pref_helper.dart';

part 'main_event.dart';

enum MainState {
  splash,
  onboarding,
  login,
  loading,
  home,
  error,
}

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc({Duration splashDelay = const Duration(milliseconds: 1500)})
      : _splashDelay = splashDelay,
        super(MainState.splash) {
    on<AppLaunched>(_onAppLaunched);
    on<NavigateToLogin>(_onNavigateToLogin);
    on<NavigateToSignUp>(_onNavigateToSignUp);
    on<CompleteAuthentication>(_onCompleteAuthentication);
    on<SetLoading>(_onSetLoading);
  }

  final Duration _splashDelay;

  Future<void> _onAppLaunched(
    AppLaunched event,
    Emitter<MainState> emit,
  ) async {
    emit(MainState.splash);
    try {
      final isLoggedIn =
          SharedPrefHelper.instance.getBool(SharedPrefHelper.isLoggedInKey);
      await Future<void>.delayed(_splashDelay);
      emit(isLoggedIn ? MainState.home : MainState.onboarding);
    } catch (_) {
      emit(MainState.error);
    }
  }

  Future<void> _onNavigateToLogin(
    NavigateToLogin event,
    Emitter<MainState> emit,
  ) async {
    await SharedPrefHelper.instance
        .putBool(SharedPrefHelper.isLoggedInKey, false);
    emit(MainState.login);
  }

  Future<void> _onNavigateToSignUp(
    NavigateToSignUp event,
    Emitter<MainState> emit,
  ) async {
    await SharedPrefHelper.instance
        .putBool(SharedPrefHelper.isLoggedInKey, false);
    emit(MainState.onboarding);
  }

  Future<void> _onCompleteAuthentication(
    CompleteAuthentication event,
    Emitter<MainState> emit,
  ) async {
    emit(MainState.loading);
    await SharedPrefHelper.instance
        .putBool(SharedPrefHelper.isLoggedInKey, true);
    emit(MainState.home);
  }

  void _onSetLoading(
    SetLoading event,
    Emitter<MainState> emit,
  ) {
    emit(event.enabled ? MainState.loading : MainState.onboarding);
  }
}
