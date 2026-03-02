// To parse this JSON data, do
//
//     final editStoreCardResponse = editStoreCardResponseFromJson(jsonString);

import 'dart:convert';

EditStoreCardResponse editStoreCardResponseFromJson(String str) => EditStoreCardResponse.fromJson(json.decode(str));

String editStoreCardResponseToJson(EditStoreCardResponse data) => json.encode(data?.toJson());

class EditStoreCardResponse {
  EditStoreCardResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  Data? data;
  String? message;
  int? apiStatusCode;

  factory EditStoreCardResponse.fromJson(Map<String, dynamic> json) => EditStoreCardResponse(
    status: json["status"],
    data: Data.fromJson(json["data"]),
    message: json["message"],
      apiStatusCode: 200

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
  int? storeId;
  String? storeName;
  String? storeNumber;
  String? barcodeImage;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    storeCardId: json["storeCardId"],
    userId: json["userId"],
    storeId: json["storeId"],
    storeName: json["storeName"],
    storeNumber: json["storeNumber"],
    barcodeImage: json["barcodeImage"],
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
