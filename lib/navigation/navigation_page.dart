import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/screens/changepassword/change_password_screen.dart';
import 'package:greentill/ui/screens/billing/billing_screen.dart';
import 'package:greentill/ui/screens/contactus/contact_us_screen.dart';
import 'package:greentill/ui/screens/coupons/couponsScreen.dart';
import 'package:greentill/ui/screens/editProfile/editprofilescreen.dart';
import 'package:greentill/ui/screens/emailverification/emailverificationscreen.dart';
import 'package:greentill/ui/screens/faq/faq_screen.dart';
import 'package:greentill/ui/screens/forgotpassword/forgot_password_screen.dart';
import 'package:greentill/ui/screens/forgotpassword/password_recover_screen.dart';
import 'package:greentill/ui/screens/homepage/home_screen.dart';
import 'package:greentill/ui/screens/information/info_screen.dart';
import 'package:greentill/ui/screens/login/login_screen.dart';
import 'package:greentill/ui/screens/notification/notification_screen.dart';
import 'package:greentill/ui/screens/privacy_policy/privacy_policy.dart';
import 'package:greentill/ui/screens/qrscan/qr_code_screen.dart';
import 'package:greentill/ui/screens/receipt/edit_receipt_screen.dart';
import 'package:greentill/ui/screens/receipt/feedback_receipt_screen.dart';
import 'package:greentill/ui/screens/receipt/receipt_detail_screen.dart';
import 'package:greentill/ui/screens/receipt/receipt_screen.dart';
import 'package:greentill/ui/screens/resetpassword/reset_password_screen.dart';
import 'package:greentill/ui/screens/rewards/redeem_voucher_detail_screen.dart';
import 'package:greentill/ui/screens/rewards/rewards_screen.dart';
import 'package:greentill/ui/screens/auditreport/audit_report_screen.dart';
import 'package:greentill/ui/screens/shopping_list/shopping_listing_screen.dart';
import 'package:greentill/ui/screens/sidemenu/side_menu.dart';
import 'package:greentill/ui/screens/signup/signup_screen.dart';
import 'package:greentill/ui/screens/signup/terms_and_conditions_signup.dart';
import 'package:greentill/ui/screens/splash_screen/splash_screen.dart';
import 'package:greentill/ui/screens/storecards/cardAddedScreen.dart';
import 'package:greentill/ui/screens/storecards/cardDeletedScreen.dart';
import 'package:greentill/ui/screens/storecards/storecardscreen.dart';
import 'package:greentill/ui/screens/surveys/survey_screen.dart';
import 'package:greentill/ui/screens/taxsummary/tax_summary_screen.dart';
import 'package:greentill/ui/screens/termsandconditions/terms_and_conditions.dart';
import 'package:greentill/utils/shared_pref_helper.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  late MainBloc bloc;

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration(milliseconds: 2000)).then((value) => FirebaseMessagingService().init());
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
          } else if (state == MainStates.SignUp) {
            return SignUpScreen();
          } else if (state == MainStates.Login) {
            return LoginScreen();
          } else if (state == MainStates.EmailVerification) {
            return EmailVerificationScreen();
          } else if (state == MainStates.ForgotPassword) {
            return ForgotPasswordScreen();
          } else if (state == MainStates.TermsandConditionsSignupEvent) {
            return TermsAndConditionsSignupScreen();
          } else if (state == MainStates.PasswordRecover) {
            return PasswordRecoverScreen();
          } else if (state == MainStates.ResetPassword) {
            return ResetPasswordScreen();
          } else if (state == MainStates.HomeScreenEvent) {
            return HomeScreen();
          } else if (state == MainStates.TermsAndConditionsEvent) {
            return TermsAndConditionsScreen();
          } else if (state == MainStates.PrivacyPolicy) {
            return PrivacyPolicyScreen();
          } else if (state == MainStates.ContactUS) {
            return ContactUSScreen();
          } else if (state == MainStates.SideMenu) {
            return SideMenuScreen();
          } else if (state == MainStates.EditProfile) {
            return EditProfileScreen();
          } else if (state == MainStates.ReceiptEvent) {
            return ReceiptScreen();
          } else if (state == MainStates.CouponsEvent) {
            return CouponsScreen();
          } else if (state == MainStates.ReceiptDetailEvent) {
            return ReceiptDetailScreen();
          } else if (state == MainStates.EditReceiptEvent) {
            return EditReceiptScreen();
          } else if (state == MainStates.QrCodeEvent) {
            return QrCodeScreen();
          } else if (state == MainStates.CardDeletedEvent) {
            return CardDeletedScreen();
          } else if (state == MainStates.CardAddedEvent) {
            return CardAddedScreen();
          } else if (state == MainStates.StoreCardEvent) {
            return StoreCardScreen();
          } else if (state == MainStates.RewardScreenEvent) {
            return RewardsScreen();
          } else if (state == MainStates.RedeemVoucherDetailEvent) {
            return RedeemVoucherDetailScreen();
          } else if (state == MainStates.InformationEvent) {
            return InfoScreen();
          } else if (state == MainStates.FeedbackEvent) {
            return FeedbackReceiptScreen();
          } else if (state == MainStates.ShoppingLinkEvent) {
            return ShoppingListingScreen();
          } else if (state == MainStates.SurveyEvent) {
            return SurveyScreen();
          } else if (state == MainStates.NotificationEvent) {
            return NotificationScreen();
          } else if (state == MainStates.FaqEvent) {
            return FaqScreen();
          } else if (state == MainStates.ChangePasswordEvent) {
            return ChangePasswordScreen();
          } else if (state == MainStates.TaxSummaryEvent) {
            return TaxSummaryScreen();
          } else if (state == MainStates.AuditReportsEvent) {
            return AuditReportScreen();
          } else if (state == MainStates.BillingEvent) {
            return BillingScreen();
          } else if (state == MainStates.LoggedLoading) {
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
                title: Text("Please login"),
                content: Text("Login to proceed further."),
                actions: <Widget>[
                  TextButton(
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
                    child: Text("Login"),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        }),
      ),
      onWillPop: () async {
        bool isLoggedIn = SharedPrefHelper.instance
            .getBool(SharedPrefHelper.IS_LOGGED_IN_BOOL);
        if (isLoggedIn) {
        } else {}

        if (bloc.state == MainStates.HomeScreenEvent ||
            bloc.state == MainStates.Login) {
          return true;
        }
        if (bloc.state == MainStates.SignUp ||
            bloc.state == MainStates.ForgotPassword) {
          bloc.add(Login());
          return false;
        }
        if (bloc.state == MainStates.ReceiptEvent) {
          return true;
        }
        if (bloc.state == MainStates.FeedbackEvent) {
          return true;
        }
        if (bloc.state == MainStates.ReceiptDetailEvent) {
          return true;
        } else {
          (bloc.userData?.country ?? "").isNotEmpty
              ? bloc.add(HomeScreenEvent())
              : bloc.add(EditProfile());
          return false;
        }
        return false;
      },
    );
  }
}
//
// onWillPop: (){
// bloc.add(HomeScreenEvent());
// },
