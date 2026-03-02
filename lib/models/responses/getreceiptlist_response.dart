// To parse this JSON data, do
//
//     final getReceiptListResponse = getReceiptListResponseFromJson(jsonString);

import 'dart:convert';

DateTime? _tryParseDateTime(dynamic raw) {
  if (raw == null) {
    return null;
  }
  final value = raw.toString().trim();
  if (value.isEmpty || value.toLowerCase() == "null") {
    return null;
  }
  return DateTime.tryParse(value);
}

GetReceiptListResponse getReceiptListResponseFromJson(String str) =>
    GetReceiptListResponse.fromJson(json.decode(str));

String getReceiptListResponseToJson(GetReceiptListResponse data) =>
    json.encode(data.toJson());

class GetReceiptListResponse {
  GetReceiptListResponse(
      {this.status, this.data, this.message, this.apiStatusCode});

  int? status;
  Data? data;
  String? message;
  int? apiStatusCode;

  factory GetReceiptListResponse.fromJson(Map<String, dynamic> json) =>
      GetReceiptListResponse(
        status: json["status"],
        data: json["data"] is Map<String, dynamic>
            ? Data.fromJson(json["data"])
            : Data(receiptList: [], receiptCount: 0),
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
    this.receiptList,
    this.receiptCount,
  });

  List<Datum>? receiptList;
  int? receiptCount;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        receiptList: List<Datum>.from(
            (json["receiptList"]?.map((x) => Datum.fromJson(x)) ?? [])),
        receiptCount: json["receiptCount"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "receiptList":
            List<dynamic>.from((receiptList?.map((x) => x.toJson()) ?? [])),
        "receiptCount": receiptCount,
      };
}

class Datum {
  Datum({
    this.receiptId,
    this.generatedName,
    this.extension,
    this.fileType,
    this.path,
    this.storeName,
    this.updatedAt,
    this.storeLocation,
    this.purchaseDate,
    this.description,
    this.currency,
    this.amount,
    this.warrantyCards,
    this.inProgress,
    this.tagType,
    this.receiptFromType,
    this.storesId,
    this.storeLogo,
    this.latestReceipt,
    this.duplicate,
  });

  int? receiptId;
  int? storesId;
  String? generatedName;
  String? extension;
  String? fileType;
  String? path;
  dynamic storeName;
  String? storeLogo;
  DateTime? updatedAt;
  dynamic storeLocation;
  DateTime? purchaseDate;
  dynamic description;
  dynamic currency;
  dynamic amount;
  bool? inProgress;
  List<WarrantyCard>? warrantyCards;
  String? tagType;
  String? receiptFromType;
  bool? latestReceipt;
  bool? duplicate;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        receiptId: json["receiptId"],
        storesId: json["storesId"],
        generatedName: json["generatedName"] ?? "",
        extension: json["extension"] ?? "",
        fileType: json["fileType"] ?? "",
        path: json["path"],
        storeName: json["storeName"] ?? "",
        storeLogo: json["storeLogo"] ?? "",
        updatedAt: _tryParseDateTime(json["updatedAt"]),
        storeLocation: json["storeLocation"] ?? "",
        purchaseDate: _tryParseDateTime(json["purchaseDate"]),
        description: json["description"] ?? "",
        currency: json["currency"] ?? "",
        amount: json["amount"] ?? "",
        inProgress: json["inProgress"] ?? false,
        latestReceipt: json["latestReceipt"] ?? false,
        tagType: json["tagType"] ?? "PERSONAL",
        receiptFromType: json["receiptFromType"] ?? "",
        warrantyCards: List<WarrantyCard>.from(
            (json["warrantyCards"]?.map((x) => WarrantyCard.fromJson(x)) ??
                [])),
        duplicate: json["duplicate"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "receiptId": receiptId,
        "storesId": storesId,
        "generatedName": generatedName,
        "extension": extension,
        "fileType": fileType,
        "path": path,
        "storeName": storeName,
        "storeLogo": storeLogo,
        "updatedAt": updatedAt?.toIso8601String(),
        "storeLocation": storeLocation,
        "purchaseDate": purchaseDate?.toIso8601String(),
        "description": description,
        "currency": currency,
        "amount": amount,
        "inProgress": inProgress,
        "latestReceipt": latestReceipt,
        "tagType": tagType,
        "receiptFromType": receiptFromType,
        "warrantyCards":
            List<dynamic>.from((warrantyCards?.map((x) => x.toJson()) ?? [])),
        "duplicate": duplicate,
      };
}

class WarrantyCard {
  WarrantyCard({
    this.createdAt,
    this.updatedAt,
    this.warrantyCardId,
    this.warrantyCardName,
    this.extension,
    this.fileType,
    this.path,
  });

  DateTime? createdAt;
  DateTime? updatedAt;
  int? warrantyCardId;
  String? warrantyCardName;
  String? extension;
  String? fileType;
  String? path;

  factory WarrantyCard.fromJson(Map<String, dynamic> json) => WarrantyCard(
        createdAt: _tryParseDateTime(json["createdAt"]),
        updatedAt: _tryParseDateTime(json["updatedAt"]),
        warrantyCardId: json["warrantyCardId"],
        warrantyCardName: json["warrantyCardName"],
        extension: json["extension"],
        fileType: json["fileType"],
        path: json["path"],
      );

  Map<String, dynamic> toJson() => {
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "warrantyCardId": warrantyCardId,
        "warrantyCardName": warrantyCardName,
        "extension": extension,
        "fileType": fileType,
        "path": path,
      };
}
