// To parse this JSON data, do
//
//     final earnPointsResponse = earnPointsResponseFromJson(jsonString);

import 'dart:convert';

TotalPointsResponse totalPointsResponseFromJson(String str) => TotalPointsResponse.fromJson(json.decode(str));

String totalPointsResponseToJson(TotalPointsResponse data) => json.encode(data?.toJson());

class TotalPointsResponse {
  TotalPointsResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  Data? data;
  String? message;
  int? apiStatusCode;

  factory TotalPointsResponse.fromJson(Map<String, dynamic> json) => TotalPointsResponse(
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
  Data({
    this.earnedPoints,
  });

  double? earnedPoints;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    earnedPoints: json["earned points"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "earned points": earnedPoints ?? 0.0,
  };
}
