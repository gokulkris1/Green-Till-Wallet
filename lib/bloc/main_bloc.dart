import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greentill/models/responses/login_response.dart';
import 'package:greentill/repositories/UserRepository.dart';
import 'package:greentill/ui/screens/receipt/feedback_receipt_screen.dart';

part 'main_event.dart';

enum MainStates {
  SplashIn,
  Login,
  SignUp,
  TermsandConditionsSignupEvent,
  EmailVerification,
  ForgotPassword,
  PasswordRecover,
  ResetPassword,
  HomeScreenEvent,
  TermsAndConditionsEvent,
  PrivacyPolicy,
  ContactUS,
  SideMenu,
  EditProfile,
  ReceiptEvent,
  CouponsEvent,
  ReceiptDetailEvent,
  EditReceiptEvent,
  QrCodeEvent,
  CardDeletedEvent,
  CardAddedEvent,
  StoreCardEvent,
  RewardScreenEvent,
  RedeemVoucherDetailEvent,
  InformationEvent,
  FeedbackEvent,
  SendFeedbackDataEvent,
  ShoppingLinkEvent,
  SurveyEvent,
  NotificationEvent,
  FaqEvent,
  ChangePasswordEvent,
  TaxSummaryEvent,
  AuditReportsEvent,
  BillingEvent,
  LoggedLoading,
  LoggedLogIn,
  LoggedERROR,
  LoggedSUCCESS,
  LoyaltyReward
}

class MainBloc extends Bloc<MainEvent, MainStates> {
  final List<String> colors = [
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

  final UserRepository userRepository = UserRepository.getInstance();
  Data? userData;

  MainBloc() : super(MainStates.SplashIn) {
    on<SplashIn>((event, emit) => emit(MainStates.SplashIn));
    on<SignUp>((event, emit) => _emitLoadingAnd(MainStates.SignUp, emit));
    on<Login>((event, emit) => _emitLoadingAnd(MainStates.Login, emit));
    on<Logindata>(_onLoginData);
    on<EmailVerification>(
        (event, emit) => _emitLoadingAnd(MainStates.EmailVerification, emit));
    on<ForgotPassword>(
        (event, emit) => _emitLoadingAnd(MainStates.ForgotPassword, emit));
    on<TermsandConditionsSignupEvent>((event, emit) =>
        _emitLoadingAnd(MainStates.TermsandConditionsSignupEvent, emit));
    on<PasswordRecover>(
        (event, emit) => _emitLoadingAnd(MainStates.PasswordRecover, emit));
    on<ResetPassword>(
        (event, emit) => _emitLoadingAnd(MainStates.ResetPassword, emit));
    on<HomeScreenEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.HomeScreenEvent, emit));
    on<TermsAndConditionsEvent>((event, emit) =>
        _emitLoadingAnd(MainStates.TermsAndConditionsEvent, emit));
    on<PrivacyPolicy>(
        (event, emit) => _emitLoadingAnd(MainStates.PrivacyPolicy, emit));
    on<ContactUS>((event, emit) => _emitLoadingAnd(MainStates.ContactUS, emit));
    on<SideMenu>((event, emit) => _emitLoadingAnd(MainStates.SideMenu, emit));
    on<EditProfile>(
        (event, emit) => _emitLoadingAnd(MainStates.EditProfile, emit));
    on<ReceiptEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.ReceiptEvent, emit));
    on<CouponsEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.CouponsEvent, emit));
    on<ReceiptDetailEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.ReceiptDetailEvent, emit));
    on<EditReceiptEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.EditReceiptEvent, emit));
    on<QrCodeEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.QrCodeEvent, emit));
    on<CardDeletedEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.CardDeletedEvent, emit));
    on<CardAddedEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.CardAddedEvent, emit));
    on<StoreCardEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.StoreCardEvent, emit));
    on<RewardScreenEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.RewardScreenEvent, emit));
    on<RedeemVoucherDetailEvent>((event, emit) =>
        _emitLoadingAnd(MainStates.RedeemVoucherDetailEvent, emit));
    on<InformationEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.InformationEvent, emit));
    on<FeedbackEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.FeedbackEvent, emit));
    on<ShoppingLinkEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.ShoppingLinkEvent, emit));
    on<SurveyEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.SurveyEvent, emit));
    on<NotificationEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.NotificationEvent, emit));
    on<FaqEvent>((event, emit) => _emitLoadingAnd(MainStates.FaqEvent, emit));
    on<ChangePasswordEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.ChangePasswordEvent, emit));
    on<TaxSummaryEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.TaxSummaryEvent, emit));
    on<AuditReportsEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.AuditReportsEvent, emit));
    on<BillingEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.BillingEvent, emit));
    on<SendFeedbackDataEvent>(_onSendFeedbackData);
    on<LoyaltyRewardEvent>(
        (event, emit) => _emitLoadingAnd(MainStates.LoyaltyReward, emit));
  }

  Future<void> init() async {
    add(Login());
    final value = await userRepository.isLoggedIn();
    if (value) {
      final model = userRepository.getUserData();
      add(Logindata(model.data));
    } else {
      add(Login());
    }
  }

  void _emitLoadingAnd(MainStates state, Emitter<MainStates> emit) {
    emit(MainStates.LoggedLoading);
    emit(state);
  }

  void _onLoginData(Logindata event, Emitter<MainStates> emit) {
    userData = event.data;
    if (userData == null) {
      add(Login());
      return;
    }
    if ((userData?.country ?? "").isEmpty) {
      add(EditProfile());
    } else {
      add(HomeScreenEvent());
    }
  }

  void _onSendFeedbackData(
      SendFeedbackDataEvent event, Emitter<MainStates> emit) {
    final context = event.context;
    if (context == null) return;
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => FeedbackReceiptScreen(
                  userid: event.userid ?? 0,
                  receiptid: event.receiptid ?? 0,
                  message: event.message ?? "",
                  imagefrom: event.imagefrom ?? "",
                )))
        .then((value) {});
  }
}
