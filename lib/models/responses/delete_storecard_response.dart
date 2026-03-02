// To parse this JSON data, do
//
//     final deleteStoreCardResponse = deleteStoreCardResponseFromJson(jsonString);

import 'dart:convert';

DeleteStoreCardResponse deleteStoreCardResponseFromJson(String str) => DeleteStoreCardResponse.fromJson(json.decode(str));

String deleteStoreCardResponseToJson(DeleteStoreCardResponse data) => json.encode(data?.toJson());

class DeleteStoreCardResponse {
  DeleteStoreCardResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  Data? data;
  String? message;
  int? apiStatusCode;

  factory DeleteStoreCardResponse.fromJson(Map<String, dynamic> json) => DeleteStoreCardResponse(
    status: json["status"],
    data: Data.fromJson(json["data"]),
    message: json["message"],
    apiStatusCode: 200,

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
