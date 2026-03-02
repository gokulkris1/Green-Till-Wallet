// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data?.toJson());

class LoginResponse {
  LoginResponse({
    this.data,
    this.message,
    this.status,
  });

  Data? data;
  String? message;
  int? status;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    data: Data.fromJson(json["data"]),
    message: json["message"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "message": message,
    "status": status,
  };
}

class Data {
  Data({
    this.userId,
    this.deviceTokenId,
    this.firstName,
    this.lastName,
    this.userType,
    this.profileImage,
    this.accessToken,
    this.phoneNumber,
    this.email,
    this.countryCode,
    this.country,
    this.currency,
    this.socialMediaId,
    this.registerType,
    this.phoneVerified,
    this.notification,
    this.countryAbbreviate,
    this.customerId,
    this.customerIdQrImage
  });

  int? userId;
  dynamic deviceTokenId;
  String? firstName;
  dynamic lastName;
  dynamic userType;
  dynamic profileImage;
  String? accessToken;
  dynamic phoneNumber;
  String? email;
  dynamic countryCode;
  dynamic country;
  dynamic currency;
  dynamic customerId;
  dynamic customerIdQrImage;
  String? socialMediaId;
  String? registerType;
  bool? phoneVerified;
  bool? notification;
  String? countryAbbreviate;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userId: json["userId"],
    deviceTokenId: json["deviceTokenId"],
    firstName: json["firstName"] ?? "",
    lastName: json["lastName"] ?? "",
    userType: json["userType"] ,
    profileImage: json["profileImage"],
    accessToken: json["accessToken"],
    phoneNumber: json["phoneNumber"] ?? "",
    email: json["email"] ?? "",
    countryCode: json["countryCode"] ,
    country: json["country"] ?? "",
    currency: json["currency"]  ?? "",
    socialMediaId: json["socialMediaId"],
    registerType: json["registerType"] ,
    phoneVerified: json["phoneVerified"],
    notification: json["notification"],
    countryAbbreviate: json["countryAbbreviate"] ?? "",
    customerId: json["customerId"] ?? "",
    customerIdQrImage: json["customerIdQrImage"] ?? "",

  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "deviceTokenId": deviceTokenId,
    "firstName": firstName,
    "lastName": lastName,
    "userType": userType,
    "profileImage": profileImage,
    "accessToken": accessToken,
    "phoneNumber": phoneNumber,
    "email": email,
    "countryCode": countryCode,
    "country": country,
    "currency": currency,
    "socialMediaId": socialMediaId,
    "registerType": registerType,
    "phoneVerified": phoneVerified,
    "notification": notification,
    "countryAbbreviate": countryAbbreviate,
    "customerId": customerId,
    "customerIdQrImage": customerIdQrImage,

  };
}
