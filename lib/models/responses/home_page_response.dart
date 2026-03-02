// To parse this JSON data, do
//
//     final homePageResponse = homePageResponseFromJson(jsonString);

import 'dart:convert';

HomePageResponse homePageResponseFromJson(String str) => HomePageResponse.fromJson(json.decode(str));

String homePageResponseToJson(HomePageResponse data) => json.encode(data?.toJson());

class HomePageResponse {
  HomePageResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  Data? data;
  String? message;
  int? apiStatusCode;

  factory HomePageResponse.fromJson(Map<String, dynamic> json) => HomePageResponse(
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
    this.shoppingList,
    this.receiptList,
    this.couponList,
    this.redeemList,
    this.totalPoints,
    this.storeCardList,
    this.earnedPoints,
    this.sliderList,
    this.surveyList
  });

  List<ShoppingList>? shoppingList;
  List<ReceiptList>? receiptList;
  List<CouponList>? couponList;
  List<RedeemList>? redeemList;
  List<SliderList>? sliderList;
  List<SurveyList>? surveyList;
  double? totalPoints;
  int? earnedPoints;
  List<StoreCardList>? storeCardList;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    shoppingList: List<ShoppingList>.from((json["shoppingList"]?.map((x) => ShoppingList.fromJson(x)) ?? [])),
    receiptList: List<ReceiptList>.from((json["receiptList"]?.map((x) => ReceiptList.fromJson(x)) ?? [])),
    sliderList: json["sliderList"] == null ? [] : List<SliderList>.from((json["sliderList"]?.map((x) => SliderList.fromJson(x)) ?? [])),
    surveyList: json["surveyList"] == null ? [] : List<SurveyList>.from((json["surveyList"]?.map((x) => SurveyList.fromJson(x)) ?? [])),
    couponList: List<CouponList>.from((json["couponList"]?.map((x) => CouponList.fromJson(x)) ?? [])),
    redeemList: List<RedeemList>.from((json["redeemList"]?.map((x) => RedeemList.fromJson(x)) ?? [])),
    totalPoints: json["totalPoints"].toDouble() ?? 0.0,
    earnedPoints: json["earnedPoints"] ?? 0,
    storeCardList: List<StoreCardList>.from((json["storeCardList"]?.map((x) => StoreCardList.fromJson(x)) ?? [])),
  );

  Map<String, dynamic> toJson() => {
    "shoppingList": List<dynamic>.from((shoppingList?.map((x) => x?.toJson()) ?? [])),
    "receiptList": List<dynamic>.from((receiptList?.map((x) => x?.toJson()) ?? [])),
    "sliderList": List<dynamic>.from((sliderList?.map((x) => x?.toJson()) ?? [])),
    "couponList": List<dynamic>.from((couponList?.map((x) => x?.toJson()) ?? [])),
    "redeemList": List<dynamic>.from((redeemList?.map((x) => x?.toJson()) ?? [])),
    "surveyList": List<dynamic>.from((surveyList?.map((x) => x?.toJson()) ?? [])),
    "totalPoints": totalPoints,
    "earnedPoints": earnedPoints,
    "storeCardList": List<dynamic>.from((storeCardList?.map((x) => x?.toJson()) ?? [])),
  };
}

class SurveyList {
  SurveyList({
    this.surveyId,
    this.title,
    this.surveyImage,
    this.surveyLink,
    this.description,
  });

  int? surveyId;
  String? title;
  String? surveyImage;
  String? surveyLink;
  String? description;

  factory SurveyList.fromJson(Map<String, dynamic> json) => SurveyList(
    surveyId: json["surveyId"],
    title: json["title"] ?? "",
    surveyImage: json["surveyImage"] ?? "",
    surveyLink: json["surveyLink"] ?? "",
    description: json["description"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "surveyId": surveyId,
    "title": title,
    "surveyImage": surveyImage,
    "surveyLink": surveyLink,
    "description": description,
  };
}


class SliderList {
  SliderList({
    this.sliderId,
    this.sliderImage,
    this.sliderLink
  });

  int? sliderId;
  String? sliderImage;
  String? sliderLink;

  factory SliderList.fromJson(Map<String, dynamic> json) => SliderList(
    sliderId: json["sliderId"],
    sliderImage: json["sliderImage"] ?? "",
    sliderLink: json["sliderLink"] ?? "",

  );

  Map<String, dynamic> toJson() => {
    "sliderId": sliderId,
    "sliderImage": sliderImage,
    "sliderLink": sliderLink,
  };
}


class CouponList {
  CouponList({
    this.createdAt,
    this.updatedAt,
    this.couponId,
    this.couponCode,
    this.storeName,
    this.storeLogo,
    this.freeText,
    this.fromDate,
    this.toDate,
    this.barcodeImage,
    this.category,
    this.categoryId,
    this.description,
    this.currency,
    this.backgroundImage,
    this.discountType,
    this.couponLink
  });

  DateTime? createdAt;
  DateTime? updatedAt;
  int? couponId;
  String? couponCode;
  String? storeName;
  String? storeLogo;
  String? freeText;
  DateTime? fromDate;
  DateTime? toDate;
  String? barcodeImage;
  Category? category;
  int? categoryId;
  String? description;
  String? backgroundImage;
  String? currency;
  String? discountType;
  String? couponLink;

  factory CouponList.fromJson(Map<String, dynamic> json) => CouponList(
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    couponId: json["couponId"],
    couponCode: json["couponCode"] ?? "",
    storeName: json["storeName"] ?? "",
    storeLogo: json["storeLogo"] ?? "",
    freeText: json["freeText"] ?? "",
    fromDate: json["fromDate"] == null ? null : DateTime.parse(json["fromDate"]),
    toDate: json["toDate"] == null ? null : DateTime.parse(json["toDate"]),
    barcodeImage: json["barcodeImage"] ?? "",
    category: Category.fromJson(json["category"]),
    categoryId: json["categoryId"],
    description: json["description"] ?? "",
    backgroundImage: json["backgroundImage"] ?? "",
    currency: json["currency"] ?? "",
    discountType: json["discountType"] ?? "",
    couponLink: json["couponLink"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "couponId": couponId,
    "couponCode": couponCode,
    "storeName": storeName,
    "storeLogo": storeLogo,
    "freeText": freeText,
    "fromDate": fromDate?.toIso8601String(),
    "toDate": toDate?.toIso8601String(),
    "barcodeImage": barcodeImage,
    "category": category?.toJson(),
    "categoryId": categoryId,
    "description": description,
    "backgroundImage": backgroundImage,
    "currency": currency,
    "discountType": discountType,
    "couponLink": couponLink,

  };
}

class Category {
  Category({
    this.createdAt,
    this.updatedAt,
    this.categoryId,
    this.categoryName,
  });

  DateTime? createdAt;
  DateTime? updatedAt;
  int? categoryId;
  String? categoryName;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    categoryId: json["categoryId"],
    categoryName: json["categoryName"],
  );

  Map<String, dynamic> toJson() => {
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "categoryId": categoryId,
    "categoryName": categoryName,
  };
}

class ReceiptList {
  ReceiptList({
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
    this.inProgress,
    this.warrantyCards,
    this.tagType,
    this.receiptFromType,
    this.storeLogo,
    this.storesId,
    this.duplicate
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
  bool? duplicate;


  factory ReceiptList.fromJson(Map<String, dynamic> json) => ReceiptList(
    receiptId: json["receiptId"],
    storesId: json["storesId"],
    generatedName: json["generatedName"] ?? "",
    extension: json["extension"] ?? "",
    fileType: json["fileType"] ?? "",
    path: json["path"],
    storeName: json["storeName"] ?? "",
    storeLogo: json["storeLogo"] ?? "",
    updatedAt: DateTime.parse(json["updatedAt"]),
    storeLocation: json["storeLocation"] ?? "",
    purchaseDate: json["purchaseDate"] == null ? null : DateTime.parse(json["purchaseDate"]),
    description: json["description"] ?? "",
    currency: json["currency"] ?? "",
    amount: json["amount"] ?? "",
    inProgress: json["inProgress"] ?? false,
    tagType: json["tagType"] ?? "PERSONAL",
    receiptFromType: json["receiptFromType"] ?? "",
    warrantyCards: List<WarrantyCard>.from((json["warrantyCards"]?.map((x) => WarrantyCard.fromJson(x)) ?? [])),
    duplicate: json["duplicate"] ?? false,

  );

  Map<String, dynamic> toJson() => {
    "receiptId": receiptId,
    "generatedName": generatedName,
    "storesId": storesId,
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
    "tagType": tagType,
    "receiptFromType": receiptFromType,
    "warrantyCards": List<dynamic>.from((warrantyCards?.map((x) => x?.toJson()) ?? [])),
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
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
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

class RedeemList {
  RedeemList({
     this.productId,
     this.name,
     this.currencyCode,
     this.disclosure,
     this.description,
     this.image,
     this.amount,
     this.points,
  });

  int? productId;
  String? name;
  String? currencyCode;
  String? disclosure;
  String? description;
  String? image;
  double? amount;
  double? points;

  factory RedeemList.fromJson(Map<String, dynamic> json) => RedeemList(
    productId: json["productId"],
    name: json["name"],
    currencyCode: json["currencyCode"],
    disclosure: json["disclosure"],
    description: json["description"],
    image: json["image"],
    amount: json["amount"],
    points: json["points"],
  );

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "name": name,
    "currencyCode": currencyCode,
    "disclosure": disclosure,
    "description": description,
    "image": image,
    "amount": amount,
    "points": points,
  };
}

// class RedeemList {
//   RedeemList({
//     this.redeemId,
//     this.storeName,
//     this.voucherImage,
//     this.points,
//     this.userTotalPoints,
//     this.amount,
//     this.link,
//     this.description,
//     this.voucherCode,
//     this.redeemed,
//     this.expireDate,
//   });
//
//   int redeemId;
//   String storeName;
//   String voucherImage;
//   int points;
//   int userTotalPoints;
//   double amount;
//   String link;
//   String description;
//   String voucherCode;
//   bool redeemed;
//   DateTime expireDate;
//
//   factory RedeemList.fromJson(Map<String, dynamic> json) => RedeemList(
//     redeemId: json["redeemId"],
//     storeName: json["storeName"],
//     voucherImage: json["voucherImage"],
//     points: json["points"],
//     userTotalPoints: json["userTotalPoints"],
//     amount: json["amount"],
//     link: json["link"],
//     description: json["description"],
//     voucherCode: json["voucherCode"],
//     redeemed: json["redeemed"],
//     expireDate: DateTime.parse(json["expireDate"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "redeemId": redeemId,
//     "storeName": storeName,
//     "voucherImage": voucherImage,
//     "points": points,
//     "userTotalPoints": userTotalPoints,
//     "amount": amount,
//     "link": link,
//     "description": description,
//     "voucherCode": voucherCode,
//     "redeemed": redeemed,
//     "expireDate": expireDate?.toIso8601String(),
//   };
// }

class ShoppingList {
  ShoppingList({
    this.id,
    this.storeName,
    this.storeLogo,
    this.link,
    this.deleted,
  });

  int? id;
  String? storeName;
  String? storeLogo;
  String? link;
  bool? deleted;

  factory ShoppingList.fromJson(Map<String, dynamic> json) => ShoppingList(
    id: json["id"],
    storeName: json["storeName"] ?? "",
    storeLogo: json["storeLogo"] ?? "",
    link: json["link"] ?? "",
    deleted: json["deleted"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "storeName": storeName,
    "storeLogo": storeLogo,
    "link": link,
    "deleted": deleted,
  };
}

class StoreCardList {
  StoreCardList({
    this.storeCardId,
    this.userId,
    this.storeId,
    this.storeName,
    this.storeLogo,
    this.storeNumber,
    this.barcodeImage,
    this.currentStamps,
    this.loyaltyVoucherGenerated,
    this.requiredStampsForReward,
    this.stampImage,
    this.storeLoyaltyPartner,
    this.totalStampsCount,

  });

  int? storeCardId;
  int? userId;
  dynamic storeId;
  String? storeName;
  String? storeNumber;
  String? barcodeImage;
  String? storeLogo;
  int? requiredStampsForReward;
  double? currentStamps;
  double? totalStampsCount;
  String? stampImage;
  bool? storeLoyaltyPartner;
  bool? loyaltyVoucherGenerated;

  factory StoreCardList.fromJson(Map<String, dynamic> json) => StoreCardList(
    storeCardId: json["storeCardId"],
    userId: json["userId"],
    storeId: json["storeId"] ?? "",
    storeName: json["storeName"] == null ? null : json["storeName"],
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
