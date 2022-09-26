import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations extends ChangeNotifier {
  Locale locale;
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Map<String, String> _localizedStrings;

  changeLanguage(Locale selectedLocale) async {
    this.locale = selectedLocale;
    await this.load();
  }

  Future<bool> load() async {
    print(locale.languageCode);
    String jsonString =
        await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key];
  }

  //following are the keys that added in json file
  String get test => translate("test");

  String get Welcome_back => translate("Welcome_back");

  String get Sign_in_to_your_account => translate("Sign_in_to_your_account");

  String get Craete_your_account => translate("Craete_your_account");

  String get First_Name => translate("First_Name");

  String get Last_Name => translate("Last_Name");

  String get Confirm_Password => translate("Confirm_Password");

  String get Signing_Text => translate("Signing_Text");

  String get And => translate("And");

  String get Privacy_Policy => translate("Privacy_Policy");

  String get Term_of_use => translate("Term_of_use");

  String get Password => translate("Password");

  String get Enter_Password => translate("Enter_Password");

  String get Re_Enter_Password => translate("Re_Enter_Password");

  String get Email => translate("Email");

  String get Username => translate("Username");

  String get Enter_Email => translate("Enter_Email_Here");

  String get Enter_First_Name => translate("Enter_First_Name");

  String get Enter_Last_Name => translate("Enter_Last_Name");

  String get Forgot_Password => translate("Forgot_Password");

  String get Login => translate("Login");

  String get Dont_have_an_account => translate("Dont_have_an_account");

  String get Sign_Up => translate("Sign_Up");

  String get Done => translate("Done");

  String get Forgot_Password_Text => translate("Forgot_Password_Text");

  String get SHOP_BY_CATEGORY => translate("SHOP_BY_CATEGORY");

  String get Search_Text => translate("Search_Text");

  String get Category => translate("Category");

  String get Designer => translate("Designer");

  String get Size => translate("Size");

  String get Condition => translate("Condition");

  String get Price => translate("Price");

  String get Color => translate("Color");

  String get New_Arrivals => translate("New_Arrivals");

  String get Filter => translate("Filter");

  String get Clear_All => translate("Clear_All");

  String get Cancel => translate("Cancel");

  String get Apply => translate("Apply");

  String get Reset => translate("Reset");
  String get Welcome => translate("Welcome to Green Till");
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    AppLocalizations localizations = new AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => true;
}
