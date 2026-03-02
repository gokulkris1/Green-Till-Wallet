// To parse this JSON data, do
//
//     final getSurveyListResponse = getSurveyListResponseFromJson(jsonString);

import 'dart:convert';

GetSurveyListResponse getSurveyListResponseFromJson(String str) => GetSurveyListResponse.fromJson(json.decode(str));

String getSurveyListResponseToJson(GetSurveyListResponse data) => json.encode(data?.toJson());

class GetSurveyListResponse {
  GetSurveyListResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  List<DatumSurvey>? data;
  String? message;
  int? apiStatusCode;

  factory GetSurveyListResponse.fromJson(Map<String, dynamic> json) => GetSurveyListResponse(
    status: json["status"],
    data: json["data"] == null ? [] : List<DatumSurvey>.from((json["data"]?.map((x) => DatumSurvey.fromJson(x)) ?? [])),
    message: json["message"],
    apiStatusCode: 200,

  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from((data?.map((x) => x?.toJson()) ?? [])),
    "message": message,
  };
}

class DatumSurvey {
  DatumSurvey({
    this.surveyId,
    this.title,
    this.surveyImage,
    this.surveyLink,
    this.description,
  });

  int? surveyId;
  String? title;
  String? surveyImage;
  String? surveyLink;
  String? description;

  factory DatumSurvey.fromJson(Map<String, dynamic> json) => DatumSurvey(
    surveyId: json["surveyId"],
    title: json["title"] ?? "",
    surveyImage: json["surveyImage"] ?? "",
    surveyLink: json["surveyLink"] ?? "",
    description: json["description"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "surveyId": surveyId,
    "title": title,
    "surveyImage": surveyImage,
    "surveyLink": surveyLink,
    "description": description,
  };
}
