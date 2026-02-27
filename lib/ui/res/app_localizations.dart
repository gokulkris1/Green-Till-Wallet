import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations extends ChangeNotifier {
  AppLocalizations(this.locale);

  final Locale locale;
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  Map<String, String> _localizedStrings = {};

  Future<bool> load() async {
    final jsonString =
        await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  //following are the keys that added in json file
  String get test => translate("test");

  String get welcomeBack => translate("Welcome_back");

  String get signInToYourAccount => translate("Sign_in_to_your_account");

  String get createYourAccount => translate("Craete_your_account");

  String get firstName => translate("First_Name");

  String get lastName => translate("Last_Name");

  String get confirmPassword => translate("Confirm_Password");

  String get signingText => translate("Signing_Text");

  String get and => translate("And");

  String get privacyPolicy => translate("Privacy_Policy");

  String get termOfUse => translate("Term_of_use");

  String get password => translate("Password");

  String get enterPassword => translate("Enter_Password");

  String get reEnterPassword => translate("Re_Enter_Password");

  String get email => translate("Email");

  String get username => translate("Username");

  String get enterEmail => translate("Enter_Email_Here");

  String get enterFirstName => translate("Enter_First_Name");

  String get enterLastName => translate("Enter_Last_Name");

  String get forgotPassword => translate("Forgot_Password");

  String get login => translate("Login");

  String get dontHaveAccount => translate("Dont_have_an_account");

  String get signUp => translate("Sign_Up");

  String get done => translate("Done");

  String get forgotPasswordText => translate("Forgot_Password_Text");

  String get shopByCategory => translate("SHOP_BY_CATEGORY");

  String get searchText => translate("Search_Text");

  String get category => translate("Category");

  String get designer => translate("Designer");

  String get size => translate("Size");

  String get condition => translate("Condition");

  String get price => translate("Price");

  String get color => translate("Color");

  String get newArrivals => translate("New_Arrivals");

  String get filter => translate("Filter");

  String get clearAll => translate("Clear_All");

  String get cancel => translate("Cancel");

  String get apply => translate("Apply");

  String get reset => translate("Reset");
  String get welcome => translate("Welcome to Green Till");
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
