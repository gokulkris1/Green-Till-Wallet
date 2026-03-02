// To parse this JSON data, do
//
//     final getNotificationCountResponse = getNotificationCountResponseFromJson(jsonString);

import 'dart:convert';

GetNotificationCountResponse getNotificationCountResponseFromJson(String str) => GetNotificationCountResponse.fromJson(json.decode(str));

String getNotificationCountResponseToJson(GetNotificationCountResponse data) => json.encode(data?.toJson());

class GetNotificationCountResponse {
  GetNotificationCountResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  int? data;
  String? message;
  int? apiStatusCode;

  factory GetNotificationCountResponse.fromJson(Map<String, dynamic> json) => GetNotificationCountResponse(
    status: json["status"],
    data: json["data"] ?? 0,
    message: json["message"],
    apiStatusCode: 200,
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data,
    "message": message,
  };
}
