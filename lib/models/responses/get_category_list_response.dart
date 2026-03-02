// To parse this JSON data, do
//
//     final getCategoryListResponse = getCategoryListResponseFromJson(jsonString);

import 'dart:convert';

GetCategoryListResponse getCategoryListResponseFromJson(String str) =>
    GetCategoryListResponse.fromJson(json.decode(str));

String getCategoryListResponseToJson(GetCategoryListResponse data) =>
    json.encode(data?.toJson());

class GetCategoryListResponse {
  GetCategoryListResponse(
      {this.status, this.data, this.message, this.apiStatusCode});

  int? status;
  List<Datum>? data;
  String? message;
  int? apiStatusCode;

  factory GetCategoryListResponse.fromJson(Map<String, dynamic> json) =>
      GetCategoryListResponse(
        status: json["status"],
        data: List<Datum>.from((json["data"]?.map((x) => Datum.fromJson(x)) ?? [])),
        message: json["message"],
        apiStatusCode: 200,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from((data?.map((x) => x?.toJson()) ?? [])),
        "message": message,
      };
}

class Datum {
  Datum({
    this.createdAt,
    this.updatedAt,
    this.categoryId,
    this.categoryName,
  });

  DateTime? createdAt;
  DateTime? updatedAt;
  int? categoryId;
  String? categoryName;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        categoryId: json["categoryId"],
        categoryName: json["categoryName"],
      );

  Map<String, dynamic> toJson() => {
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "categoryId": categoryId,
        "categoryName": categoryName,
      };
}
