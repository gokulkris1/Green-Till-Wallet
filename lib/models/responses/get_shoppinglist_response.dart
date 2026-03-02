// To parse this JSON data, do
//
//     final getShoppingListResponse = getShoppingListResponseFromJson(jsonString);

import 'dart:convert';

GetShoppingListResponse getShoppingListResponseFromJson(String str) => GetShoppingListResponse.fromJson(json.decode(str));

String getShoppingListResponseToJson(GetShoppingListResponse data) => json.encode(data?.toJson());

class GetShoppingListResponse {
  GetShoppingListResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  List<DatumShoppingList>? data;
  String? message;
  int? apiStatusCode;

  factory GetShoppingListResponse.fromJson(Map<String, dynamic> json) => GetShoppingListResponse(
    status: json["status"],
    data: List<DatumShoppingList>.from((json["data"]?.map((x) => DatumShoppingList.fromJson(x)) ?? [])),
    message: json["message"],
    apiStatusCode: 200,

  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from((data?.map((x) => x?.toJson()) ?? [])),
    "message": message,
  };
}

class DatumShoppingList {
  DatumShoppingList({
    this.id,
    this.storeName,
    this.storeLogo,
    this.link,
    this.deleted,
  });

  int? id;
  String? storeName;
  String? storeLogo;
  String? link;
  bool? deleted;

  factory DatumShoppingList.fromJson(Map<String, dynamic> json) => DatumShoppingList(
    id: json["id"],
    storeName: json["storeName"] ?? "",
    storeLogo: json["storeLogo"] ?? "",
    link: json["link"] ?? "",
    deleted: json["deleted"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "storeName": storeName,
    "storeLogo": storeLogo,
    "link": link,
    "deleted": deleted,
  };
}
