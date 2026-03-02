// To parse this JSON data, do
//
//     final redeemPointsResponse = redeemPointsResponseFromJson(jsonString);

import 'dart:convert';

RedeemPointsResponse redeemPointsResponseFromJson(String str) => RedeemPointsResponse.fromJson(json.decode(str));

String redeemPointsResponseToJson(RedeemPointsResponse data) => json.encode(data?.toJson());

class RedeemPointsResponse {
  RedeemPointsResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  Data? data;
  String? message;
  int? apiStatusCode;

  factory RedeemPointsResponse.fromJson(Map<String, dynamic> json) => RedeemPointsResponse(
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
