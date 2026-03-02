// To parse this JSON data, do
//
//     final getListProductResponse = getListProductResponseFromJson(jsonString);

import 'dart:convert';

GetListProductResponse getListProductResponseFromJson(String str) => GetListProductResponse.fromJson(json.decode(str));

String getListProductResponseToJson(GetListProductResponse data) => json.encode(data?.toJson());

class GetListProductResponse {
  GetListProductResponse({
     this.status,
     this.message,
     this.data,
     this.apiStatusCode
  });

  int? status;
  String? message;
  Data? data;
  int? apiStatusCode;

  factory GetListProductResponse.fromJson(Map<String, dynamic> json) => GetListProductResponse(
    status: json["status"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
      apiStatusCode: 200

  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  Data({
     this.productList,
     this.totalPoint,
     this.userTotalPoints,
  });

  List<ProductList>? productList;
  double? totalPoint;
  int? userTotalPoints;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    productList: List<ProductList>.from((json["ProductList"]?.map((x) => ProductList.fromJson(x)) ?? [])),
    totalPoint: json["totalPoint"]?.toDouble(),
    userTotalPoints: json["userTotalPoints"],
  );

  Map<String, dynamic> toJson() => {
    "ProductList": List<dynamic>.from((productList?.map((x) => x?.toJson()) ?? [])),
    "totalPoint": totalPoint,
    "userTotalPoints": userTotalPoints,
  };
}

class ProductList {
  ProductList({
     this.productId,
     this.name,
     this.currencyCode,
     this.disclosure,
     this.description,
     this.image,
     this.amount,
     this.points,
  });


  int? productId;
  String? name;
  String? currencyCode;
  String? disclosure;
  String? description;
  String? image;
  double? amount;
  double? points;

  factory ProductList.fromJson(Map<String, dynamic> json) => ProductList(
    productId: json["productId"],
    name: json["name"] ?? "",
    currencyCode: json["currencyCode"] ?? "",
    disclosure: json["disclosure"] ?? "",
    description: json["description"] ?? "",
    image: json["image"] ?? "",
    amount: json["amount"] ?? 0.0,
    points: json["points"] ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "name": name,
    "currencyCode": currencyCode,
    "disclosure": disclosure,
    "description": description,
    "image": image,
    "amount": amount,
    "points": points,
  };
}
