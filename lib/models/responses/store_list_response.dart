// To parse this JSON data, do
//
//     final storeListResponse = storeListResponseFromJson(jsonString);

import 'dart:convert';

StoreListResponse storeListResponseFromJson(String str) => StoreListResponse.fromJson(json.decode(str));

String storeListResponseToJson(StoreListResponse data) => json.encode(data?.toJson());

class StoreListResponse {
  StoreListResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  List<DatumStoreList>? data;
  String? message;
  int? apiStatusCode;

  factory StoreListResponse.fromJson(Map<String, dynamic> json) => StoreListResponse(
    status: json["status"],
    data: List<DatumStoreList>.from((json["data"]?.map((x) => DatumStoreList.fromJson(x)) ?? [])),
    message: json["message"],
      apiStatusCode: 200

  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from((data?.map((x) => x?.toJson()) ?? [])),
    "message": message,
  };
}

class DatumStoreList {
  DatumStoreList({
    this.storeId,
    this.storeName,
    this.storeLogo,
    this.facebookLink,
    this.googleLink,
    this.twitterLink,
    this.playstoreLink,
    this.appstoreLink,
    this.active,
  });

  int? storeId;
  String? storeName;
  String? storeLogo;
  String? facebookLink;
  String? googleLink;
  String? twitterLink;
  String? playstoreLink;
  String? appstoreLink;
  bool? active;

  factory DatumStoreList.fromJson(Map<String, dynamic> json) => DatumStoreList(
    storeId: json["storeId"],
    storeName: json["storeName"] ?? "",
    storeLogo: json["storeLogo"] ?? "",
    facebookLink: json["facebookLink"] ?? "",
    googleLink: json["googleLink"] ?? "",
    twitterLink: json["twitterLink"] ?? "",
    playstoreLink: json["playstoreLink"] ?? "",
    appstoreLink: json["appstoreLink"] ?? "",
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "storeId": storeId,
    "storeName": storeName,
    "storeLogo": storeLogo,
    "facebookLink": facebookLink,
    "googleLink": googleLink,
    "twitterLink": twitterLink,
    "playstoreLink": playstoreLink,
    "appstoreLink": appstoreLink,
    "active": active,
  };
}
