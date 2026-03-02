// To parse this JSON data, do
//
//     final deleteReceiptResponse = deleteReceiptResponseFromJson(jsonString);

import 'dart:convert';

DeleteReceiptResponse deleteReceiptResponseFromJson(String str) => DeleteReceiptResponse.fromJson(json.decode(str));

String deleteReceiptResponseToJson(DeleteReceiptResponse data) => json.encode(data?.toJson());

class DeleteReceiptResponse {
  DeleteReceiptResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  Data? data;
  String? message;
  int? apiStatusCode;

  factory DeleteReceiptResponse.fromJson(Map<String, dynamic> json) => DeleteReceiptResponse(
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
