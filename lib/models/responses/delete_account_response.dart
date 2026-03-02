// To parse this JSON data, do
//
//     final deleteAccountResponse = deleteAccountResponseFromJson(jsonString);

import 'dart:convert';

DeleteAccountResponse deleteAccountResponseFromJson(String str) => DeleteAccountResponse.fromJson(json.decode(str));

String deleteAccountResponseToJson(DeleteAccountResponse data) => json.encode(data?.toJson());

class DeleteAccountResponse {
  DeleteAccountResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  Data? data;
  String? message;
  int? apiStatusCode;

  factory DeleteAccountResponse.fromJson(Map<String, dynamic> json) => DeleteAccountResponse(
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
