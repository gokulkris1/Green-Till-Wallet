// To parse this JSON data, do
//
//     final editProfileResponse = editProfileResponseFromJson(jsonString);

import 'dart:convert';

EditProfileResponse editProfileResponseFromJson(String str) => EditProfileResponse.fromJson(json.decode(str));

String editProfileResponseToJson(EditProfileResponse data) => json.encode(data?.toJson());

class EditProfileResponse {
  EditProfileResponse({
    this.data,
    this.message,
    this.status,
    this.apiStatusCode
  });

  Data? data;
  String? message;
  int? status;
  int? apiStatusCode;

  factory EditProfileResponse.fromJson(Map<String, dynamic> json) => EditProfileResponse(
    data: Data.fromJson(json["data"]),
    message: json["message"],
    status: json["status"],
      apiStatusCode: 200

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
    this.phoneNumber,
    this.email,
    this.countryCode,
    this.country,
    this.currency,
    this.socialMediaId,
    this.registerType,
    this.phoneVerified,
    this.notification,
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
  bool? phoneVerified;
  bool? notification;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userId: json["userId"],
    deviceTokenId: json["deviceTokenId"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    userType: json["userType"],
    profileImage: json["profileImage"],
    phoneNumber: json["phoneNumber"],
    email: json["email"],
    countryCode: json["countryCode"],
    country: json["country"],
    currency: json["currency"],
    socialMediaId: json["socialMediaId"],
    registerType: json["registerType"],
    phoneVerified: json["phoneVerified"],
    notification: json["notification"],
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
    "phoneVerified": phoneVerified,
    "notification": notification,
  };
}
