// To parse this JSON data, do
//
//     final getCouponsListResponse = getCouponsListResponseFromJson(jsonString);

import 'dart:convert';

GetCouponsListResponse getCouponsListResponseFromJson(String str) => GetCouponsListResponse.fromJson(json.decode(str));

String getCouponsListResponseToJson(GetCouponsListResponse data) => json.encode(data?.toJson());

class GetCouponsListResponse {
  GetCouponsListResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  List<Datumcoupon>? data;
  String? message;
  int? apiStatusCode;
  factory GetCouponsListResponse.fromJson(Map<String, dynamic> json) => GetCouponsListResponse(
    status: json["status"],
    data: List<Datumcoupon>.from((json["data"]?.map((x) => Datumcoupon.fromJson(x)) ?? [])),
    message: json["message"],
    apiStatusCode: 200,
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from((data?.map((x) => x?.toJson()) ?? [])),
    "message": message,
  };
}

class Datumcoupon {
  Datumcoupon({
    this.createdAt,
    this.updatedAt,
    this.couponId,
    this.couponCode,
    this.storeName,
    this.storeLogo,
    this.freeText,
    this.fromDate,
    this.toDate,
    this.barcodeImage,
    this.category,
    this.categoryId,
    this.description,
    this.currency,
    this.backgroundImage,
    this.discountType,
    this.couponLink
  });

  DateTime? createdAt;
  DateTime? updatedAt;
  int? couponId;
  String? couponCode;
  String? storeName;
  String? storeLogo;
  String? freeText;
  DateTime? fromDate;
  DateTime? toDate;
  String? barcodeImage;
  Category? category;
  int? categoryId;
  String? description;
  String? backgroundImage;
  String? currency;
  String? discountType;
  String? couponLink;


  factory Datumcoupon.fromJson(Map<String, dynamic> json) => Datumcoupon(
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    couponId: json["couponId"],
    couponCode: json["couponCode"] ?? "",
    storeName: json["storeName"] ?? "",
    storeLogo: json["storeLogo"] ?? "",
    freeText: json["freeText"] ?? "",
    fromDate: json["fromDate"] == null ? null : DateTime.parse(json["fromDate"]),
    toDate: json["toDate"] == null ? null : DateTime.parse(json["toDate"]),
    barcodeImage: json["barcodeImage"] ?? "",
    category: Category.fromJson(json["category"]),
    categoryId: json["categoryId"],
    description: json["description"] ?? "",
    backgroundImage: json["backgroundImage"] ?? "",
    currency: json["currency"] ?? "",
    discountType: json["discountType"] ?? "",
    couponLink: json["couponLink"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "couponId": couponId,
    "couponCode": couponCode,
    "storeName": storeName,
    "storeLogo": storeLogo,
    "freeText": freeText,
    "fromDate": fromDate?.toIso8601String(),
    "toDate": toDate?.toIso8601String(),
    "barcodeImage": barcodeImage,
    "category": category?.toJson(),
    "categoryId": categoryId,
    "description": description,
    "backgroundImage": backgroundImage,
    "currency": currency,
    "discountType": discountType,
    "couponLink": couponLink,

  };
}

class Category {
  Category({
    this.createdAt,
    this.updatedAt,
    this.categoryId,
    this.categoryName,
  });

  DateTime? createdAt;
  DateTime? updatedAt;
  int? categoryId;
  String? categoryName;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    categoryId: json["categoryId"],
    categoryName: json["categoryName"],
  );

  Map<String, dynamic> toJson() => {
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "categoryId": categoryId,
    "categoryName": categoryName,
  };
}
