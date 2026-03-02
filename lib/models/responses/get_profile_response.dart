// To parse this JSON data, do
//
//     final getProfileResponse = getProfileResponseFromJson(jsonString);

import 'dart:convert';

GetProfileResponse getProfileResponseFromJson(String str) =>
    GetProfileResponse.fromJson(json.decode(str));

String getProfileResponseToJson(GetProfileResponse data) =>
    json.encode(data?.toJson());

class GetProfileResponse {
  GetProfileResponse(
      {this.message, this.status, this.data, this.apiStatusCode});

  String? message;
  int? status;
  Data? data;
  int? apiStatusCode;

  factory GetProfileResponse.fromJson(Map<String, dynamic> json) =>
      GetProfileResponse(
          message: json["message"],
          status: json["status"],
          data: Data.fromJson(json["data"]),
          apiStatusCode: 200);

  Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
        "data": data?.toJson(),
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
    this.phoneNumber,
    this.email,
    this.countryCode,
    this.country,
    this.currency,
    this.socialMediaId,
    this.registerType,
    this.notification,
    this.phoneVerified,
  });

  int? userId;
  dynamic deviceTokenId;
  String? firstName;
  String? lastName;
  String? userType;
  dynamic profileImage;
  String? phoneNumber;
  String? email;
  String? countryCode;
  String? country;
  String? currency;
  dynamic socialMediaId;
  String? registerType;
  bool? notification;
  bool? phoneVerified;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userId: json["userId"],
        deviceTokenId: json["deviceTokenId"],
        firstName: json["firstName"] ?? "",
        lastName: json["lastName"] ?? "",
        userType: json["userType"],
        profileImage: json["profileImage"],
        phoneNumber: json["phoneNumber"] ?? "",
        email: json["email"] ?? "",
        countryCode: json["countryCode"] ?? "",
        country: json["country"] ?? "",
        currency: json["currency"] ?? "",
        socialMediaId: json["socialMediaId"],
        registerType: json["registerType"],
        notification: json["notification"],
        phoneVerified: json["phoneVerified"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "deviceTokenId": deviceTokenId,
        "firstName": firstName,
        "lastName": lastName,
        "userType": userType,
        "profileImage": profileImage,
        "phoneNumber": phoneNumber,
        "email": email,
        "countryCode": countryCode,
        "country": country,
        "currency": currency,
        "socialMediaId": socialMediaId,
        "registerType": registerType,
        "notification": notification,
        "phoneVerified": phoneVerified,
      };
}
