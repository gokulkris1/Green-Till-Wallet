// To parse this JSON data, do
//
//     final allNotificationDeleteResponse = allNotificationDeleteResponseFromJson(jsonString);

import 'dart:convert';

AllNotificationDeleteResponse allNotificationDeleteResponseFromJson(String str) => AllNotificationDeleteResponse.fromJson(json.decode(str));

String allNotificationDeleteResponseToJson(AllNotificationDeleteResponse data) => json.encode(data?.toJson());

class AllNotificationDeleteResponse {
  AllNotificationDeleteResponse({
     this.status,
     this.data,
     this.message,
    this.apiStatusCode
  });

  int? status;
  Data? data;
  String? message;
  int? apiStatusCode;

  factory AllNotificationDeleteResponse.fromJson(Map<String, dynamic> json) => AllNotificationDeleteResponse(
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
