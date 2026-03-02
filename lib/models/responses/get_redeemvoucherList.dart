// To parse this JSON data, do
//
//     final getRedeemedVouchersListResponse = getRedeemedVouchersListResponseFromJson(jsonString);

import 'dart:convert';

GetRedeemedVouchersListResponse getRedeemedVouchersListResponseFromJson(String str) => GetRedeemedVouchersListResponse.fromJson(json.decode(str));

String getRedeemedVouchersListResponseToJson(GetRedeemedVouchersListResponse data) => json.encode(data?.toJson());

class GetRedeemedVouchersListResponse {
  GetRedeemedVouchersListResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  List<DatumRedeemedVoucher>? data;
  String? message;
  int? apiStatusCode;

  factory GetRedeemedVouchersListResponse.fromJson(Map<String, dynamic> json) => GetRedeemedVouchersListResponse(
    status: json["status"],
    data: List<DatumRedeemedVoucher>.from((json["data"]?.map((x) => DatumRedeemedVoucher.fromJson(x)) ?? [])),
    message: json["message"],
      apiStatusCode: 200

  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from((data?.map((x) => x?.toJson()) ?? [])),
    "message": message,
  };
}

class DatumRedeemedVoucher {
  DatumRedeemedVoucher({
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
  DateTime? expireDate;

  factory DatumRedeemedVoucher.fromJson(Map<String, dynamic> json) => DatumRedeemedVoucher(
    redeemId: json["redeemId"],
    storeName: json["storeName"],
    voucherImage: json["voucherImage"],
    points: json["points"],
    userTotalPoints: json["userTotalPoints"] ?? 0,
    amount: json["amount"] ?? 0.0,
    link: json["link"],
    description: json["description"],
    voucherCode: json["voucherCode"] ?? "",
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
    "expireDate": expireDate?.toIso8601String(),
  };
}




