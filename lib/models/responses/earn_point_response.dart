// To parse this JSON data, do
//
//     final earnPointsResponse = earnPointsResponseFromJson(jsonString);

import 'dart:convert';

EarnPointsResponse earnPointsResponseFromJson(String str) => EarnPointsResponse.fromJson(json.decode(str));

String earnPointsResponseToJson(EarnPointsResponse data) => json.encode(data?.toJson());

class EarnPointsResponse {
  EarnPointsResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  Data? data;
  String? message;
  int? apiStatusCode;

  factory EarnPointsResponse.fromJson(Map<String, dynamic> json) => EarnPointsResponse(
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
    this.pointList,
    this.totalPoints,
    this.earnedPoints,
  });

  List<PointList>? pointList;
  double? totalPoints;
  int? earnedPoints;


  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pointList: List<PointList>.from((json["pointList"]?.map((x) => PointList.fromJson(x)) ?? [])),
    totalPoints: json["totalPoints"].toDouble() ?? 0.0,
    earnedPoints: json["earnedPoints"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "pointList": List<dynamic>.from((pointList?.map((x) => x?.toJson()) ?? [])),
    "totalPoints": totalPoints,
    "earnedPoints": earnedPoints,
  };
}

class PointList {
  PointList({
    this.count,
    this.type,
    this.point,
  });

  int? count;
  String? type;
  int? point;

  factory PointList.fromJson(Map<String, dynamic> json) => PointList(
    count: json["count"] ?? 0,
    type: json["type"] ?? "",
    point: json["point"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "type": type,
    "point": point,
  };
}
