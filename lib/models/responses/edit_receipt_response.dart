// To parse this JSON data, do
//
//     final editReceiptResponse = editReceiptResponseFromJson(jsonString);

import 'dart:convert';

EditReceiptResponse editReceiptResponseFromJson(String str) => EditReceiptResponse.fromJson(json.decode(str));

String editReceiptResponseToJson(EditReceiptResponse data) => json.encode(data?.toJson());

class EditReceiptResponse {
  EditReceiptResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  Data? data;
  dynamic message;
  int? apiStatusCode;

  factory EditReceiptResponse.fromJson(Map<String, dynamic> json) => EditReceiptResponse(
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
