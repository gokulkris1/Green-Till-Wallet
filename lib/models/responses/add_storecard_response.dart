// To parse this JSON data, do
//
//     final addStoreCardResponse = addStoreCardResponseFromJson(jsonString);

import 'dart:convert';

AddStoreCardResponse addStoreCardResponseFromJson(String str) => AddStoreCardResponse.fromJson(json.decode(str));

String addStoreCardResponseToJson(AddStoreCardResponse data) => json.encode(data?.toJson());

class AddStoreCardResponse {
  AddStoreCardResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  Data? data;
  String? message;
  int? apiStatusCode;

  factory AddStoreCardResponse.fromJson(Map<String, dynamic> json) => AddStoreCardResponse(
    status: json["status"],
    data: Data.fromJson(json["data"]),
    message: json["message"],
    apiStatusCode: 200,

  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
    "message": message,
  };
}

class Data {
  Data({
    this.storeCardId,
    this.userId,
    this.storeId,
    this.storeName,
    this.storeNumber,
    this.barcodeImage,
  });

  int? storeCardId;
  int? userId;
  dynamic storeId;
  String? storeName;
  String? storeNumber;
  String? barcodeImage;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    storeCardId: json["storeCardId"] ??'',
    userId: json["userId"] ?? '',
    storeId: json["storeId"] ?? 0,
    storeName: json["storeName"] ?? '',
    storeNumber: json["storeNumber"] ?? '',
    barcodeImage: json["barcodeImage"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "storeCardId": storeCardId,
    "userId": userId,
    "storeId": storeId,
    "storeName": storeName,
    "storeNumber": storeNumber,
    "barcodeImage": barcodeImage,
  };
}
