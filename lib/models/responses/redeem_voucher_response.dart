// To parse this JSON data, do
//
//     final RedeemVoucherProductResponse = RedeemVoucherProductResponseFromJson(jsonString);

import 'dart:convert';

RedeemVoucherProductResponse RedeemVoucherProductResponseFromJson(String str) => RedeemVoucherProductResponse.fromJson(json.decode(str));

String RedeemVoucherProductResponseToJson(RedeemVoucherProductResponse data) => json.encode(data?.toJson());

class RedeemVoucherProductResponse {
  RedeemVoucherProductResponse({
     this.message,
     this.status,
     this.data,
    this.apiStatusCode
  });

  String? message;
  int? status;
  Data? data;
  int? apiStatusCode;

  factory RedeemVoucherProductResponse.fromJson(Map<String, dynamic> json) => RedeemVoucherProductResponse(
    message: json["message"],
    status: json["status"],
    data: Data.fromJson(json["data"]),
      apiStatusCode: 200

  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "data": data?.toJson(),
  };
}

class Data {
  Data({
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

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    walletId: json["walletId"],
    productId: json["productId"],
    name: json["name"],
    currencyCode: json["currencyCode"],
    disclosure: json["disclosure"],
    description: json["description"],
    image: json["image"],
    amount: json["amount"],
    points: json["points"],
    link: json["link"],
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
