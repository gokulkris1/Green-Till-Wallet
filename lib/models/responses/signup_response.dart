// To parse this JSON data, do
//
//     final signupResponse = signupResponseFromJson(jsonString);

import 'dart:convert';

SignupResponse signupResponseFromJson(String str) => SignupResponse.fromJson(json.decode(str));

String signupResponseToJson(SignupResponse data) => json.encode(data?.toJson());

class SignupResponse {
  SignupResponse({
    this.status,
    this.data,
    this.message,
  });

  int? status;
  Data? data;
  String? message;

  factory SignupResponse.fromJson(Map<String, dynamic> json) => SignupResponse(
    status: json["status"],
    data: Data.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
    "message": message,
  };
}

class Data {
  Data({
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.confirmPassword,
    this.countryCode,
    this.phoneNumber,
    this.country,
    this.currency,
    this.facebookId,
    this.googleId,
    this.termsAndCondition,
    this.countryAbbreviate
  });

  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? confirmPassword;
  String? countryCode;
  String? phoneNumber;
  String? country;
  String? currency;
  dynamic facebookId;
  dynamic googleId;
  bool? termsAndCondition;
  String? countryAbbreviate;


  factory Data.fromJson(Map<String, dynamic> json) => Data(
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    password: json["password"],
    confirmPassword: json["confirmPassword"],
    countryCode: json["countryCode"],
    phoneNumber: json["phoneNumber"],
    country: json["country"],
    currency: json["currency"],
    facebookId: json["facebookId"],
    googleId: json["googleId"],
    termsAndCondition: json["termsAndCondition"],
    countryAbbreviate: json["countryAbbreviate"],

  );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "password": password,
    "confirmPassword": confirmPassword,
    "countryCode": countryCode,
    "phoneNumber": phoneNumber,
    "country": country,
    "currency": currency,
    "facebookId": facebookId,
    "googleId": googleId,
    "termsAndCondition": termsAndCondition,
    "countryAbbreviate": countryAbbreviate,

  };
}
