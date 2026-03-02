// To parse this JSON data, do
//
//     final uploadGalleryOrNativeResponse = uploadGalleryOrNativeResponseFromJson(jsonString);

import 'dart:convert';

UploadGalleryOrNativeResponse uploadGalleryOrNativeResponseFromJson(String str) => UploadGalleryOrNativeResponse.fromJson(json.decode(str));

String uploadGalleryOrNativeResponseToJson(UploadGalleryOrNativeResponse data) => json.encode(data?.toJson());

class UploadGalleryOrNativeResponse {
  UploadGalleryOrNativeResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  int? data;
  String? message;
  int? apiStatusCode;
  factory UploadGalleryOrNativeResponse.fromJson(Map<String, dynamic> json) => UploadGalleryOrNativeResponse(
    status: json["status"],
    data: json["data"],
    message: json["message"] ?? "",
    apiStatusCode: 200,
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data,
    "message": message,
  };
}

