// To parse this JSON data, do
//
//     final getStaticPageResponse = getStaticPageResponseFromJson(jsonString);

import 'dart:convert';

GetStaticPageResponse getStaticPageResponseFromJson(String str) => GetStaticPageResponse.fromJson(json.decode(str));

String getStaticPageResponseToJson(GetStaticPageResponse data) => json.encode(data?.toJson());

class GetStaticPageResponse {
  GetStaticPageResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  Data? data;
  String? message;
  int? apiStatusCode;

  factory GetStaticPageResponse.fromJson(Map<String, dynamic> json) => GetStaticPageResponse(
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
  Data({
    this.pageId,
    this.title,
    this.content,
    this.pageType,
    this.active,
  });

  int? pageId;
  String? title;
  String? content;
  String? pageType;
  bool? active;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pageId: json["pageId"],
    title: json["title"],
    content: json["content"] ?? "",
    pageType: json["pageType"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "pageId": pageId,
    "title": title,
    "content": content,
    "pageType": pageType,
    "active": active,
  };
}
