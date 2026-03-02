// To parse this JSON data, do
//
//     final uploadReceiptResponse = uploadReceiptResponseFromJson(jsonString);

import 'dart:convert';

UploadReceiptResponse uploadReceiptResponseFromJson(String str) => UploadReceiptResponse.fromJson(json.decode(str));

String uploadReceiptResponseToJson(UploadReceiptResponse data) => json.encode(data?.toJson());

class UploadReceiptResponse {
  UploadReceiptResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  int? data;
  String? message;
  int? apiStatusCode;

  factory UploadReceiptResponse.fromJson(Map<String, dynamic> json) => UploadReceiptResponse(
    status: json["status"],
    data: json["data"],
    message: json["message"],
    apiStatusCode: 200
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data,
    "message": message,

  };
}

