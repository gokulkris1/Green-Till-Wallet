// To parse this JSON data, do
//
//     final getVoucherCardResponse = getVoucherCardResponseFromJson(jsonString);

import 'dart:convert';

GetVoucherCardResponse getVoucherCardResponseFromJson(String str) => GetVoucherCardResponse.fromJson(json.decode(str));

String getVoucherCardResponseToJson(GetVoucherCardResponse data) => json.encode(data?.toJson());

class GetVoucherCardResponse {
  GetVoucherCardResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  List<Datumvoucherlist>? data;
  String? message;
  int? apiStatusCode;

  factory GetVoucherCardResponse.fromJson(Map<String, dynamic> json) => GetVoucherCardResponse(
    status: json["status"],
    data: List<Datumvoucherlist>.from((json["data"]?.map((x) => Datumvoucherlist.fromJson(x)) ?? [])),
    message: json["message"],
      apiStatusCode: 200

  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from((data?.map((x) => x?.toJson()) ?? [])),
    "message": message,
  };
}

class Datumvoucherlist {
  Datumvoucherlist({
    this.redeemId,
    this.storeName,
    this.voucherImage,
    this.points,
    this.userTotalPoints,
    this.amount,
    this.link,
    this.description,
    this.voucherCode,
    this.expireDate,
    this.redeemed
  });

  int? redeemId;
  String? storeName;
  String? voucherImage;
  int? points;
  int? userTotalPoints;
  double? amount;
  String? link;
  String? description;
  String? voucherCode;
  bool? redeemed;
  DateTime? expireDate;

  factory Datumvoucherlist.fromJson(Map<String, dynamic> json) => Datumvoucherlist(
    redeemId: json["redeemId"],
    storeName: json["storeName"] ?? "",
    voucherImage: json["voucherImage"],
    points: json["points"] ,
    userTotalPoints: json["userTotalPoints"] ,
    amount: json["amount"],
    link: json["link"],
    description: json["description"] ?? "",
    voucherCode: json["voucherCode"] ?? "",
    redeemed: json["redeemed"],
    expireDate: json["expireDate"] == null ? null :DateTime.parse(json["expireDate"]),
  );

  Map<String, dynamic> toJson() => {
    "redeemId": redeemId,
    "storeName": storeName,
    "voucherImage": voucherImage,
    "points": points,
    "userTotalPoints": userTotalPoints,
    "amount": amount,
    "link": link,
    "description": description,
    "voucherCode": voucherCode,
    "redeemed": redeemed,
    "expireDate": expireDate,
  };
}
