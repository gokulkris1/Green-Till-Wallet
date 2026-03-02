// To parse this JSON data, do
//
//     final filterReceiptResponse = filterReceiptResponseFromJson(jsonString);

import 'dart:convert';

FilterReceiptResponse filterReceiptResponseFromJson(String str) => FilterReceiptResponse.fromJson(json.decode(str));

String filterReceiptResponseToJson(FilterReceiptResponse data) => json.encode(data?.toJson());

class FilterReceiptResponse {
  FilterReceiptResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode

  });

  int? status;
  List<Datum>? data;
  String? message;
  int? apiStatusCode;

  factory FilterReceiptResponse.fromJson(Map<String, dynamic> json) => FilterReceiptResponse(
    status: json["status"],
    data: List<Datum>.from((json["data"]?.map((x) => Datum.fromJson(x)) ?? [])),
    message: json["message"],
      apiStatusCode: 200
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from((data?.map((x) => x?.toJson()) ?? [])),
    "message": message,
  };
}

class Datum {
  Datum({
    this.receiptId,
    this.generatedName,
    this.extension,
    this.fileType,
    this.path,
    this.storeName,
    this.updatedAt,
  });

  int? receiptId;
  String? generatedName;
  String? extension;
  String? fileType;
  String? path;
  String? storeName;
  DateTime? updatedAt;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    receiptId: json["receiptId"],
    generatedName: json["generatedName"] == null ? null : json["generatedName"],
    extension: json["extension"],
    fileType: json["fileType"],
    path: json["path"],
    storeName: json["storeName"] == null ? null : json["storeName"],
    updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "receiptId": receiptId,
    "generatedName": generatedName,
    "extension": extension,
    "fileType": fileType,
    "path": path,
    "storeName": storeName,
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
