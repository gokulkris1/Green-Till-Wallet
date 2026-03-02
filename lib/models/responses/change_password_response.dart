// To parse this JSON data, do
//
//     final changePasswordResponse = changePasswordResponseFromJson(jsonString);

import 'dart:convert';

ChangePasswordResponse changePasswordResponseFromJson(String str) => ChangePasswordResponse.fromJson(json.decode(str));

String changePasswordResponseToJson(ChangePasswordResponse data) => json.encode(data?.toJson());

class ChangePasswordResponse {
  ChangePasswordResponse({
     this.status,
     this.data,
     this.message,
    this.apiStatusCode
  });

  int? status;
  Data? data;
  String? message;
  int? apiStatusCode;

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) => ChangePasswordResponse(
    status: json["status"],
    data: Data.fromJson(json["data"]),
    message: json["message"],
      apiStatusCode: 200
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
    "message": message,
  };
}

class Data {
  Data();

  factory Data.fromJson(Map<String, dynamic> json) => Data(
  );

  Map<String, dynamic> toJson() => {
  };
}
