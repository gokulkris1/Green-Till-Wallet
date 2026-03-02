// To parse this JSON data, do
//
//     final stampVoucherResponseModel = stampVoucherResponseModelFromMap(jsonString);

import 'dart:convert';

StampVoucherResponseModel stampVoucherResponseModelFromMap(String str) => StampVoucherResponseModel.fromJson(json.decode(str));

String stampVoucherResponseModelToMap(StampVoucherResponseModel data) => json.encode(data.toMap());

class StampVoucherResponseModel {
  int? status;
  Data? data;
  String? message;
  int? apiStatusCode;


  StampVoucherResponseModel({
     this.status,
     this.data,
     this.message,
    this.apiStatusCode
  });

  factory StampVoucherResponseModel.fromJson(Map<String, dynamic> json) =>
      StampVoucherResponseModel(
          status: json["status"],
          data: json["data"] == null ? null : Data.fromMap(json["data"]),
          message: json["message"],
          apiStatusCode: 200);

  Map<String, dynamic> toMap() => {
        "status": status,
        "data": data?.toMap(),
        "message": message,
      };
}

class Data {
  List<ListElement>? list;
  int? totalRecords;

  Data({
     this.list,
     this.totalRecords,
  });

  factory Data.fromMap(Map<String, dynamic> json) => Data(
    list: List<ListElement>.from((json["list"]?.map((x) => ListElement.fromMap(x)) ?? [])),
    totalRecords: json["totalRecords"],
  );

  Map<String, dynamic> toMap() => {
    "list": List<dynamic>.from((list?.map((x) => x.toMap()) ?? [])),
    "totalRecords": totalRecords,
  };
}

class ListElement {
  int? loyaltyStampVoucherId;
  int? userId;
  int? storesId;
  String? storeName;
  String? stampImage;
  bool? rewardClaimed;
  String? voucherCode;

  ListElement({
     this.loyaltyStampVoucherId,
     this.userId,
     this.storesId,
     this.storeName,
     this.stampImage,
     this.rewardClaimed,
    this.voucherCode
  });

  factory ListElement.fromMap(Map<String, dynamic> json) => ListElement(
    loyaltyStampVoucherId: json["loyaltyStampVoucherId"],
    userId: json["userId"],
    storesId: json["storesId"],
    storeName: json["storeName"],
    stampImage: json["stampImage"],
    rewardClaimed: json["rewardClaimed"],
    voucherCode: json["voucherCode"]
  );

  Map<String, dynamic> toMap() => {
    "loyaltyStampVoucherId": loyaltyStampVoucherId,
    "userId": userId,
    "storesId": storesId,
    "storeName": storeName,
    "stampImage": stampImage,
    "rewardClaimed": rewardClaimed,
    "voucherCode": voucherCode
  };
}
