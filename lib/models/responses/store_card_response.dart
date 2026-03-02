// To parse this JSON data, do
//
//     final storeCardListResponse = storeCardListResponseFromJson(jsonString);

import 'dart:convert';

StoreCardListResponse storeCardListResponseFromJson(String str) => StoreCardListResponse.fromJson(json.decode(str));

String storeCardListResponseToJson(StoreCardListResponse data) => json.encode(data?.toJson());

class StoreCardListResponse {
  StoreCardListResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  List<DatumStoreCardList>? data;
  String? message;
  int? apiStatusCode;

  factory StoreCardListResponse.fromJson(Map<String, dynamic> json) => StoreCardListResponse(
    status: json["status"],
    data: List<DatumStoreCardList>.from((json["data"]?.map((x) => DatumStoreCardList.fromJson(x)) ?? [])),
    message: json["message"],
    apiStatusCode: 200,

  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from((data?.map((x) => x?.toJson()) ?? [])),
    "message": message,
  };
}

class DatumStoreCardList {
  DatumStoreCardList({
    this.storeCardId,
    this.userId,
    this.storeId,
    this.storeName,
    this.storeDescription,
    this.storeLogo,
    this.storeNumber,
    this.barcodeImage,
    this.currentStamps,
    this.loyaltyVoucherGenerated,
    this.requiredStampsForReward,
    this.stampImage,
    this.storeLoyaltyPartner,
    this.totalStampsCount
  });

  int? storeCardId;
  int? userId;
  dynamic storeId;
  String? storeName;
  String? storeDescription;
  String? storeNumber;
  String? barcodeImage;
  String? storeLogo;
  int? requiredStampsForReward;
  double? currentStamps;
  double? totalStampsCount;
  String? stampImage;
  bool? storeLoyaltyPartner;
  bool? loyaltyVoucherGenerated;

  factory DatumStoreCardList.fromJson(Map<String, dynamic> json) => DatumStoreCardList(
    storeCardId: json["storeCardId"],
    userId: json["userId"],
    storeId: json["storeId"] ?? "",
    storeName: json["storeName"] == null ? null : json["storeName"],
    storeDescription: json["storeDescription"] == null ? null : json["storeDescription"],
    storeNumber: json["storeNumber"] == null ? null : json["storeNumber"],
    barcodeImage: json["barcodeImage"],
    storeLogo: json["storeLogo"] == null ? null : json["storeLogo"],
    currentStamps: json["currentStamps"] == null ? null : json["currentStamps"],
    loyaltyVoucherGenerated: json["loyaltyVoucherGenerated"] == null ? null : json["loyaltyVoucherGenerated"],
    requiredStampsForReward: json["requiredStampsForReward"] == null ? null : json["requiredStampsForReward"],
    stampImage: json["stampImage"] == null ? null : json["stampImage"],
    storeLoyaltyPartner: json["storeLoyaltyPartner"] == null ? null : json["storeLoyaltyPartner"],
    totalStampsCount: json["totalStampsCount"] == null ? null : json["totalStampsCount"],
  );

  Map<String, dynamic> toJson() => {
    "storeCardId": storeCardId,
    "userId": userId,
    "storeId": storeId,
    "storeName": storeName,
    "storeDescription": storeDescription,
    "storeNumber": storeNumber,
    "storeLogo": storeLogo,
    "barcodeImage": barcodeImage,
    "currentStamps": currentStamps,
    "loyaltyVoucherGenerated": loyaltyVoucherGenerated,
    "requiredStampsForReward": requiredStampsForReward,
    "stampImage": stampImage,
    "storeLoyaltyPartner": storeLoyaltyPartner,
    "totalStampsCount": totalStampsCount,
  };
}
