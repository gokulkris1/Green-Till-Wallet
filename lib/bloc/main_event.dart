part of 'main_bloc.dart';

@immutable
abstract class MainEvent {}

// this displays error message
class ShowError extends MainEvent {}

// to show splash screen
class SplashIn extends MainEvent {
  SplashIn();
}

class Logindata extends MainEvent {
  final Data? data;

  Logindata(this.data);
}

class Login extends MainEvent {
  Login();
}

class SignUp extends MainEvent {
  SignUp();
}

class EmailVerification extends MainEvent {
  EmailVerification();
}

class ForgotPassword extends MainEvent {
  ForgotPassword();
}

class TermsandConditionsSignupEvent extends MainEvent {
  TermsandConditionsSignupEvent();
}

class PasswordRecover extends MainEvent {
  PasswordRecover();
}

class ResetPassword extends MainEvent {
  ResetPassword();
}

class HomeScreenEvent extends MainEvent {
  HomeScreenEvent();
}

class TermsAndConditionsEvent extends MainEvent {
  TermsAndConditionsEvent();
}

class PrivacyPolicy extends MainEvent {
  PrivacyPolicy();
}

class ContactUS extends MainEvent {
  ContactUS();
}

class SideMenu extends MainEvent {
  SideMenu();
}

class EditProfile extends MainEvent {
  EditProfile();
}

class ReceiptEvent extends MainEvent {
  ReceiptEvent();
}

class CouponsEvent extends MainEvent {
  CouponsEvent();
}

class ReceiptDetailEvent extends MainEvent {
  ReceiptDetailEvent();
}

class EditReceiptEvent extends MainEvent {
  EditReceiptEvent();
}

class QrCodeEvent extends MainEvent {
  QrCodeEvent();
}

class CardDeletedEvent extends MainEvent {
  CardDeletedEvent();
}

class CardAddedEvent extends MainEvent {
  CardAddedEvent();
}

class StoreCardEvent extends MainEvent {
  StoreCardEvent();
}

class RewardScreenEvent extends MainEvent {
  // final bool isViewAll;
  // final BuildContext context;
  RewardScreenEvent();
}

class RedeemVoucherDetailEvent extends MainEvent {
  RedeemVoucherDetailEvent();
}

class InformationEvent extends MainEvent {
  InformationEvent();
}

class FeedbackEvent extends MainEvent {
  FeedbackEvent();
}

class ShoppingLinkEvent extends MainEvent {
  ShoppingLinkEvent();
}

class SurveyEvent extends MainEvent {
  SurveyEvent();
}

class NotificationEvent extends MainEvent {
  NotificationEvent();
}

class FaqEvent extends MainEvent {
  FaqEvent();
}

class ChangePasswordEvent extends MainEvent {
  ChangePasswordEvent();
}

class TaxSummaryEvent extends MainEvent {
  TaxSummaryEvent();
}

class AuditReportsEvent extends MainEvent {
  AuditReportsEvent();
}

class BillingEvent extends MainEvent {
  BillingEvent();
}

class SendFeedbackDataEvent extends MainEvent {
  final int? receiptid;
  final int? userid;
  final String? message;
  final String? imagefrom;
  final BuildContext? context;

  SendFeedbackDataEvent(
      {this.receiptid,
      this.userid,
      this.message,
      this.imagefrom,
      this.context});
}

class LoyaltyRewardEvent extends MainEvent {
  LoyaltyRewardEvent();
}
