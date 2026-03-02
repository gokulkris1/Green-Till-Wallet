import 'dart:io';


class SignupModel{
  File? profilePhoto ;
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? confirmpassword;
  String? country;
  String? countrycode;
  String? countryAbbreviate;
  String? mobileNumber;
  String? currency;
  bool? termsandconditions;

  SignupModel(
      {this.profilePhoto,
        this.firstName,
        this.lastName,
        this.email,
        this.password,
        this.confirmpassword,
        this.country,
        this.countrycode,
        this.mobileNumber,
        this.currency,
        this.termsandconditions,
      this.countryAbbreviate});
}
