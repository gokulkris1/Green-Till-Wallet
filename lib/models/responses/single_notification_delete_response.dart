// To parse this JSON data, do
//
//     final singleNotificationDeleteResponse = singleNotificationDeleteResponseFromJson(jsonString);

import 'dart:convert';

SingleNotificationDeleteResponse singleNotificationDeleteResponseFromJson(String str) => SingleNotificationDeleteResponse.fromJson(json.decode(str));

String singleNotificationDeleteResponseToJson(SingleNotificationDeleteResponse data) => json.encode(data?.toJson());

class SingleNotificationDeleteResponse {
  SingleNotificationDeleteResponse({
     this.status,
     this.data,
     this.message,
    this.apiStatusCode
  });

  int? status;
  Data? data;
  String? message;
  int? apiStatusCode;

  factory SingleNotificationDeleteResponse.fromJson(Map<String, dynamic> json) => SingleNotificationDeleteResponse(
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
