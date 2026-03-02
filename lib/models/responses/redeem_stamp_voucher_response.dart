// To parse this JSON data, do
//
//     final redeemStampVoucherResponse = redeemStampVoucherResponseFromMap(jsonString);

import 'dart:convert';

RedeemStampVoucherResponse redeemStampVoucherResponseFromMap(String str) => RedeemStampVoucherResponse.fromJson(json.decode(str));

String redeemStampVoucherResponseToMap(RedeemStampVoucherResponse data) => json.encode(data.toMap());

class RedeemStampVoucherResponse {
  int? status;
  Data? data;
  String? message;

  RedeemStampVoucherResponse({
     this.status,
     this.data,
     this.message,
  });

  factory RedeemStampVoucherResponse.fromJson(Map<String, dynamic> json) =>
      RedeemStampVoucherResponse(
        status: json["status"],
        data: json["data"] == null ? null : Data.fromMap(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "data": data?.toMap(),
        "message": message,
      };
}

class Data {
  Data();

  factory Data.fromMap(Map<String, dynamic> json) => Data(
  );

  Map<String, dynamic> toMap() => {
  };
}
