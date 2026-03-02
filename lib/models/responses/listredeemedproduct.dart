// To parse this JSON data, do
//
//     final listRedeemedProductResponse = listRedeemedProductResponseFromJson(jsonString);

import 'dart:convert';

ListRedeemedProductResponse listRedeemedProductResponseFromJson(String str) => ListRedeemedProductResponse.fromJson(json.decode(str));

String listRedeemedProductResponseToJson(ListRedeemedProductResponse data) => json.encode(data?.toJson());

class ListRedeemedProductResponse {
  ListRedeemedProductResponse({
     this.status,
     this.data,
     this.message,
    this.apiStatusCode
  });

  int? status;
  List<DatumRedeemedProductList>? data;
  String? message;
  int? apiStatusCode;

  factory ListRedeemedProductResponse.fromJson(Map<String, dynamic> json) => ListRedeemedProductResponse(
    status: json["status"],
    data: List<DatumRedeemedProductList>.from((json["data"]?.map((x) => DatumRedeemedProductList.fromJson(x)) ?? [])),
    message: json["message"],
    apiStatusCode: 200


  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from((data?.map((x) => x?.toJson()) ?? [])),
    "message": message,
  };
}

class DatumRedeemedProductList {
  DatumRedeemedProductList({
     this.walletId,
     this.productId,
     this.name,
     this.currencyCode,
     this.disclosure,
     this.description,
     this.image,
     this.amount,
     this.points,
     this.link,
  });

  int? walletId;
  int? productId;
  String? name;
  String? currencyCode;
  String? disclosure;
  String? description;
  String? image;
  double? amount;
  double? points;
  String? link;

  factory DatumRedeemedProductList.fromJson(Map<String, dynamic> json) => DatumRedeemedProductList(
    walletId: json["walletId"],
    productId: json["productId"],
    name: json["name"] ?? "",
    currencyCode: json["currencyCode"] ?? "",
    disclosure: json["disclosure"] ?? "",
    description: json["description"] ?? "",
    image: json["image"] ?? "",
    amount: json["amount"] ?? 0.0,
    points: json["points"] ?? 0.0,
    link: json["link"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "walletId": walletId,
    "productId": productId,
    "name": name,
    "currencyCode": currencyCode,
    "disclosure": disclosure,
    "description": description,
    "image": image,
    "amount": amount,
    "points": points,
    "link": link,
  };
}

// enum CurrencyCode { USD, EUR }
//
// final currencyCodeValues = EnumValues({
//   "EUR": CurrencyCode.EUR,
//   "USD": CurrencyCode.USD
// });
//
// enum Name { OUTBACK_STEAKHOUSE, MANGO_IE, OVERSTOCK_COM }
//
// final nameValues = EnumValues({
//   "MANGO IE": Name.MANGO_IE,
//   "Outback Steakhouse": Name.OUTBACK_STEAKHOUSE,
//   "Overstock.com": Name.OVERSTOCK_COM
// });
//
// class EnumValues<T> {
//   Map<String, T> map;
//   Map<T, String> reverseMap;
//
//   EnumValues(this.map);
//
//   Map<T, String> get reverse {
//     reverseMap = map.map((k, v) => MapEntry(v, k));
//     return reverseMap;
//   }
// }
