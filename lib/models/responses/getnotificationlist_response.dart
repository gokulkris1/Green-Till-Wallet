// To parse this JSON data, do
//
//     final getNotificationListResponse = getNotificationListResponseFromJson(jsonString);

import 'dart:convert';

GetNotificationListResponse getNotificationListResponseFromJson(String str) => GetNotificationListResponse.fromJson(json.decode(str));

String getNotificationListResponseToJson(GetNotificationListResponse data) => json.encode(data?.toJson());

class GetNotificationListResponse {
  GetNotificationListResponse({
    this.status,
    this.data,
    this.message,
    this.apiStatusCode
  });

  int? status;
  Data? data;
  String? message;
  int? apiStatusCode;

  factory GetNotificationListResponse.fromJson(Map<String, dynamic> json) => GetNotificationListResponse(
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
    this.notificationCount,
    this.notificationList,
  });

  int? notificationCount;
  List<NotificationList>? notificationList;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    notificationCount: json["NotificationCount"],
    notificationList: json["NotificationList"] == null ? [] : List<NotificationList>.from((json["NotificationList"]?.map((x) => NotificationList.fromJson(x)) ?? [])),
  );

  Map<String, dynamic> toJson() => {
    "NotificationCount": notificationCount,
    "NotificationList": List<dynamic>.from((notificationList?.map((x) => x?.toJson()) ?? [])),
  };
}

class NotificationList {
  NotificationList({
    this.createdAt,
    this.updatedAt,
    this.sentNotificationId,
    this.title,
    this.description,
    this.image,
    this.notificationType,
  });

  DateTime? createdAt;
  DateTime? updatedAt;
  int? sentNotificationId;
  String? title;
  String? description;
  String? image;
  NotificationType? notificationType;

  factory NotificationList.fromJson(Map<String, dynamic> json) => NotificationList(
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    sentNotificationId: json["sentNotificationId"],
    title: json["title"] ?? "",
    description: json["description"] ?? "",
    image: json["image"] ?? "",
    notificationType: notificationTypeValues.map[json["notificationType"]],
  );

  Map<String, dynamic> toJson() => {
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "sentNotificationId": sentNotificationId,
    "title": title,
    "description": description,
    "image": image,
    "notificationType": notificationTypeValues.reverse[notificationType],
  };
}

enum Description { NEW_SURVEY_HAS_BEEN_ADDED, THIS_IS_A_PICTURE_OF_MOUNTAINS, NEW_COUPONS_HAS_BEEN_ADDED, NEW_REWARDS_HAS_BEEN_ADDED, NEW_SHOPPING_LINKS_HAS_BEEN_ADDED,YOU_CAN_NOW_CLAIM_EXCITING_REWARDS_FROM_REDEEM_SECTION }

final descriptionValues = EnumValues({
  "New coupons has been added": Description.NEW_COUPONS_HAS_BEEN_ADDED,
  "New rewards has been added": Description.NEW_REWARDS_HAS_BEEN_ADDED,
  "New shopping links has been added": Description.NEW_SHOPPING_LINKS_HAS_BEEN_ADDED,
  "New survey has been added": Description.NEW_SURVEY_HAS_BEEN_ADDED,
  "This is a picture of mountains": Description.THIS_IS_A_PICTURE_OF_MOUNTAINS,
  "You can now claim exciting rewards from redeem section!": Description.YOU_CAN_NOW_CLAIM_EXCITING_REWARDS_FROM_REDEEM_SECTION
});

enum NotificationType { NEW_SURVEY, CUSTOM_NOTIFICATION, NEW_COUPONS, NEW_REWARD, NEW_SHOPPING_LINK,CLAIM_REWARD }

final notificationTypeValues = EnumValues({
  "CLAIM_REWARD": NotificationType.CLAIM_REWARD,
  "CUSTOM_NOTIFICATION": NotificationType.CUSTOM_NOTIFICATION,
  "NEW_COUPONS": NotificationType.NEW_COUPONS,
  "NEW_REWARD": NotificationType.NEW_REWARD,
  "NEW_SHOPPING_LINK": NotificationType.NEW_SHOPPING_LINK,
  "NEW_SURVEY": NotificationType.NEW_SURVEY
});

enum Title { SURVEY, NATURE, COUPONS, REWARDS, SHOPPING_LINKS,ELIGIBLE_TO_CLAIM_REWARDS }

final titleValues = EnumValues({
  "Coupons": Title.COUPONS,
  "Eligible to claim rewards": Title.ELIGIBLE_TO_CLAIM_REWARDS,
  "Nature": Title.NATURE,
  "Rewards": Title.REWARDS,
  "Shopping Links": Title.SHOPPING_LINKS,
  "Survey": Title.SURVEY
});

class EnumValues<T> {
  final Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap ??= map.map((k, v) => MapEntry(v, k));
    return reverseMap!;
  }
}
