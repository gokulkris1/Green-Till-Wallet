// To parse this JSON data, do
//
//     final feedbackResponse = feedbackResponseFromJson(jsonString);

import 'dart:convert';

FeedbackResponse feedbackResponseFromJson(String str) => FeedbackResponse.fromJson(json.decode(str));

String feedbackResponseToJson(FeedbackResponse data) => json.encode(data?.toJson());

class FeedbackResponse {
  FeedbackResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  Data? data;
  String? message;
  int? apiStatusCode;

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) => FeedbackResponse(
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
  Data();

  factory Data.fromJson(Map<String, dynamic> json) => Data(
  );

  Map<String, dynamic> toJson() => {
  };
}
