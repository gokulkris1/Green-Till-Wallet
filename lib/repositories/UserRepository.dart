import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:greentill/models/responses/add_storecard_response.dart';
import 'package:greentill/models/responses/all_notification_delete_response.dart';
import 'package:greentill/models/responses/change_password_response.dart';
import 'package:greentill/models/responses/delete_account_response.dart';
import 'package:greentill/models/responses/delete_receipt_response.dart';
import 'package:greentill/models/responses/delete_storecard_response.dart';
import 'package:greentill/models/responses/earn_point_response.dart';
import 'package:greentill/models/responses/get_notificationcount_response.dart';
import 'package:greentill/models/responses/get_productlist_response.dart';
import 'package:greentill/models/responses/get_shoppinglist_response.dart';
import 'package:greentill/models/responses/get_vouchercard_response.dart';
import 'package:greentill/models/responses/getnotificationlist_response.dart';
import 'package:greentill/models/responses/getstaticpage_response.dart';
import 'package:greentill/models/responses/getsurveylist_response.dart';
import 'package:greentill/models/responses/home_page_response.dart';
import 'package:greentill/models/responses/listredeemedproduct.dart';
import 'package:greentill/models/responses/redeem_voucher_response.dart';
import 'package:greentill/models/responses/single_notification_delete_response.dart';
import 'package:greentill/models/responses/stamp_voucher_response_model.dart';
import 'package:greentill/models/responses/total_points_response.dart';
import 'package:greentill/models/responses/edit_receipt_response.dart';
import 'package:greentill/models/responses/edit_storecard_response.dart';
import 'package:greentill/models/responses/editprofile_response.dart';
import 'package:greentill/models/responses/feedback_response.dart';
import 'package:greentill/models/responses/forgot_password_response.dart';
import 'package:greentill/models/responses/get_category_list_response.dart';
import 'package:greentill/models/responses/get_coupons_list_response.dart';
import 'package:greentill/models/responses/getreceiptlist_response.dart';
import 'package:greentill/models/responses/login_response.dart';
import 'package:greentill/models/responses/logout_response.dart';
import 'package:greentill/models/responses/signup_response.dart';
import 'package:greentill/models/responses/store_card_response.dart';
import 'package:greentill/models/responses/store_list_response.dart';
import 'package:greentill/models/responses/upload_response.dart';
import 'package:greentill/models/responses/uploadgalleryornative_response.dart';
import 'package:greentill/models/signup_model.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

import '../models/responses/get_profile_response.dart';
import '../models/responses/get_redeemvoucherList.dart';
import '../models/responses/redeem_stamp_voucher_response.dart';

class UserRepository {
  SharedPrefHelper prefs = SharedPrefHelper.instance;

  //dev
  String baseUrl = "https://greentill-api.apps.openxcell.dev";
  String baseUrlHttps = "greentill-api.apps.openxcell.dev";

  // local
  //  String baseUrl = "https://d451-2401-4900-1f3f-8d8a-8c8c-fc33-839b-a0d7.ngrok-free.app";
  //  String baseUrlHttps = "192.168.2.153:8451";

  // Live
  //  String baseUrl = "https://api.greentill.co";
  //  String baseUrlHttps = "api.greentill.co";

  UserRepository();

  static UserRepository getInstance() {
    return UserRepository();
  }

  String _normalizeBackendMessage(dynamic message,
      {String fallback = "Something went wrong!"}) {
    final raw = (message ?? "").toString().trim();
    if (raw.isEmpty || raw == "null") {
      return fallback;
    }

    final lower = raw.toLowerCase();
    if ((lower.contains("authenticationfailedexception") ||
            lower.contains("javax.mail") ||
            lower.contains("authentication unsuccessful")) &&
        (lower.contains("535") ||
            lower.contains("mail") ||
            lower.contains("smtp"))) {
      return "Email service is temporarily unavailable. Please try again later.";
    }

    if (lower.contains("socketexception") ||
        lower.contains("failed host lookup") ||
        lower.contains("connection closed")) {
      return "No Internet connection";
    }

    if (raw.length > 260) {
      return "${raw.substring(0, 257)}...";
    }
    return raw;
  }

  String _extractMessage(dynamic body,
      {String fallback = "Something went wrong!"}) {
    if (body is Map<String, dynamic>) {
      return _normalizeBackendMessage(body["message"], fallback: fallback);
    }
    if (body is Map) {
      return _normalizeBackendMessage(body["message"], fallback: fallback);
    }
    return _normalizeBackendMessage(body, fallback: fallback);
  }

  Future<bool> isLoggedIn() async {
    return prefs.getBool(SharedPrefHelper.IS_LOGGED_IN_BOOL) ?? false;
  }

  Future<LoginResponse> enableDemoLogin() async {
    final demoPayload = <String, dynamic>{
      "status": 1,
      "message": "Demo login enabled",
      "data": {
        "userId": 999999,
        "deviceTokenId": null,
        "firstName": "Demo",
        "lastName": "User",
        "userType": "USER",
        "profileImage": null,
        "accessToken": "demo-access-token",
        "phoneNumber": "",
        "email": "demo@greentill.app",
        "countryCode": "+353",
        "country": "Ireland",
        "currency": "EUR",
        "socialMediaId": null,
        "registerType": "DEMO",
        "phoneVerified": true,
        "notification": true,
        "countryAbbreviate": "IE",
        "customerId": "",
        "customerIdQrImage": ""
      }
    };

    prefs.putBool(SharedPrefHelper.IS_LOGGED_IN_BOOL, true);
    prefs.putString(SharedPrefHelper.ACCESS_TOKEN_STRING, "demo-access-token");
    prefs.putString(SharedPrefHelper.USER_ID, "999999");
    prefs.putString(SharedPrefHelper.USER_DATA, jsonEncode(demoPayload));

    return LoginResponse.fromJson(demoPayload);
  }

  //done
  Future<LoginResponse> login(
      {String email = "",
      String password = "",
      String fcmtoken = "",
      String devicetype = "",
      String registertype = "",
      String firstname = "",
      String socialMediaId = ""}) async {
    print("fcmtoken");
    print(fcmtoken);
    try {
      return await http.Client()
          .post(
            Uri.parse("$baseUrl/api/user/login"),
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode(
              {
                "email": email,
                "password": password,
                "fcmToken": fcmtoken,
                "deviceToken": "123456",
                "deviceType": devicetype,
                "loginType": "USER",
                "userType": "USER",
                "registerType": registertype,
                "socialMediaId": socialMediaId,
                "firstName": firstname,
              },
            ),
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        print("$baseUrl/api/user/login");
        print(value.body);
        // print("email = " + email);
        // print("password = " + password);
        // print("fcmtoken = " + fcmtoken);

        try {
          if (value.statusCode == 200) {
            var map = json.decode(value.body);
            print(map);
            if (map["status"] == 0) {
              return LoginResponse(
                  data: null,
                  message: map["message"] ?? "Something went wrong!",
                  status: 0);
            } else {
              LoginResponse data = LoginResponse.fromJson(map);
              prefs.putBool(SharedPrefHelper.IS_LOGGED_IN_BOOL, true);
              final accessToken = data.data?.accessToken ?? "";
              final userId = data.data?.userId?.toString() ?? "";
              prefs.putString(
                  SharedPrefHelper.ACCESS_TOKEN_STRING, accessToken);
              prefs.putString(SharedPrefHelper.USER_ID, userId);
              prefs.putString(SharedPrefHelper.USER_DATA, value.body);

              // }
              return data;
            }
          } else {
            var map = json.decode(value.body);
            return LoginResponse(
                data: null,
                message: map["message"] ?? "Something went wrong!",
                status: 0);
          }
        } catch (e) {
          return LoginResponse(data: null, message: e.toString(), status: 0);
        }
      });
    } on SocketException {
      return LoginResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return LoginResponse(data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<GetReceiptListResponse> getreceiptList(int userid,
      {String startdate = "",
      String enddate = "",
      String timezone = "",
      String direction = "",
      String query = "",
      String tagType = ""}) async {
    print("tagType");
    print(tagType);
    print('startdate ${startdate}');
    print(enddate);
    print(direction);
    print(query);
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      final sortDirection = direction.isEmpty ? "DESC" : direction;
      final resolvedTimezone =
          timezone.isEmpty ? DateTime.now().timeZoneName.toString() : timezone;

      return await http.Client()
          .post(Uri.parse("$baseUrl/api/user/receiptList"),
              headers: {
                "access-token": accesstoken,
                "Content-Type": "application/json",
              },
              body: jsonEncode({
                "endDate": enddate,
                "query": query,
                "sortBy": {"direction": sortDirection, "property": "createdAt"},
                "startDate": startdate,
                "tagType": tagType,
                "timeZone": resolvedTimezone,
                "userId": userid
              }))
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        print("$baseUrl/api/user/receiptList");
        print("HEADERS RECEIPT LIST ${value.headers}");
        print("REQUEST RECEIPT LIST ${value.request?.headers}");
        // print(value.body);
        print('HEADERS ${value.headers['start']}');

        try {
          if (value.statusCode == 200) {
            var map = json.decode(utf8.decode(value.bodyBytes));
            print(map);
            log(map.toString());

            if (map["status"] == 0) {
              return GetReceiptListResponse(
                  data: null, message: map["message"], status: 0);
            } else if (map["status"] == 401) {
              return GetReceiptListResponse(
                  data: null, message: map["message"], status: 401);
            } else {
              GetReceiptListResponse data =
                  GetReceiptListResponse.fromJson(map);

              return data;
            }
          } else {
            var map = json.decode(utf8.decode(value.bodyBytes));
            return GetReceiptListResponse(
                data: null,
                message: map["message"] ?? "Something went wrong!",
                status: 0,
                apiStatusCode: value.statusCode);
          }
        } catch (e) {
          return GetReceiptListResponse(
              data: null, message: e.toString(), status: 0);
        }
      });
    } on SocketException {
      return GetReceiptListResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return GetReceiptListResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  LoginResponse getUserData() {
    String data = prefs.getString(SharedPrefHelper.USER_DATA);
    var map = json.decode(data);
    LoginResponse model = LoginResponse.fromJson(map);
    return model;
  }
  //done

  Future<EditReceiptResponse> editReceiptInfo(int userid, int receiptid,
      {String amount = "",
      String currency = "",
      // String description,
      List warrantycards = const [],
      String purchaseDate = "",
      String storeLocation = "",
      String storeName = "",
      String timeZone = "",
      String tagType = "",
      int storesId = 0}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    print("tokenvalue = " + accesstoken);
    // List<http.MultipartFile> newList = [];
    //
    // for (var img in warrantycards) {
    //   if (img != "") {
    //     var multipartFile = await http.MultipartFile.fromPath(
    //       'Photos',
    //       File(img).path,
    //       filename: img.split('/').last,
    //     );
    //     newList.add(multipartFile);
    //   }
    // }
    var cards = [];
    print("warrantycards.length");
    print(warrantycards.length);

    for (int i = 0; i < warrantycards.length; i++) {
      var file = warrantycards[i];
      cards.add(await MultipartFile.fromFile(file.path,
          filename: file.path.split('/').last,
          contentType: MediaType('file', 'multipart/form-data')));
      print("cardsfor");
      print(cards);
    }
    print("cards");
    print(cards);
    print(warrantycards);
    print(warrantycards.length);
    print(purchaseDate);
    print("purchaseDate121");
    print("amount");
    print(amount);
    print(tagType);
    print(storesId);
    print(storeName);
    print(amount.length);

    var dio = Dio();

    dio.options.headers["Content-Type"] = "multipart/form-data";
    dio.options.headers["access-token"] = accesstoken;
    dio.options.validateStatus = (status) => true;

    FormData formData = FormData.fromMap({
      "userId": userid,
      "receiptId": receiptid,
      if (amount.isNotEmpty) "amount": double.parse(amount),
      "currency": currency,
      // if (description != null) "description": description,
      if (purchaseDate.isNotEmpty) "purchaseDate": purchaseDate,
      "files": cards,
      "storeLocation": storeLocation,
      "storeName": storeName,
      "timeZone": timeZone,
      "tagType": tagType,
      "storesId": storesId,
    });
    print(formData);
    print("formData");

    try {
      return await dio
          .put(
            "$baseUrl/api/user/receipt?receiptId=$receiptid&userId=$userid",
            data: formData,
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        print("statuscode" + value.statusCode.toString());

        try {
          if (value.statusCode == 200) {
            // var map = json.decode(value.data);
            print(value.data);
            if (value.data["status"] == 0) {
              return EditReceiptResponse(
                  data: null, message: value.data["message"], status: 0);
            } else if (value.data["status"] == 401) {
              return EditReceiptResponse(
                  data: null, message: value.data["message"], status: 401);
            } else {
              EditReceiptResponse data =
                  EditReceiptResponse.fromJson(value.data);

              return data;
            }
          } else {
            var map = json.decode(value.data);
            return EditReceiptResponse(
                data: null,
                message: map["message"] ?? "Something went wrong!",
                status: 0,
                apiStatusCode: value.statusCode);
          }
        } catch (e) {
          return EditReceiptResponse(
              data: null, message: e.toString(), status: 0);
        }
      });
    } on SocketException {
      return EditReceiptResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return EditReceiptResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<SignupResponse> signup(SignupModel signupModel) async {
    print("signup=");
    print(signupModel.country);

    var dio = Dio();

    final Map<String, dynamic> formMap = {
      "firstName": signupModel.firstName,
      "lastName": signupModel.lastName,
      "email": signupModel.email,
      "password": signupModel.password,
      "confirmPassword": signupModel.confirmpassword,
      "country": signupModel.country,
      "countryCode": signupModel.countrycode,
      "currency": signupModel.currency,
      "termsAndCondition": signupModel.termsandconditions,
      "phoneNumber": signupModel.mobileNumber,
      "countryAbbreviate": signupModel.countryAbbreviate,
      "facebookId": null,
      "googleId": null,
    };

    final profilePhoto = signupModel.profilePhoto;
    if (profilePhoto != null) {
      final fileName = profilePhoto.path.split('/').last;
      formMap["file"] = await MultipartFile.fromFile(profilePhoto.path,
          filename: fileName, contentType: MediaType('image', 'jpg'));
    }

    FormData formData = FormData.fromMap(formMap);
    print(formData);
    print(signupModel.confirmpassword);
    print(signupModel.password);
    print("formData");

    try {
      return await dio
          .post(
            "$baseUrl/api/user/signUp",
            options: Options(
              headers: {
                HttpHeaders.contentTypeHeader: "application/json",
                // HttpHeaders.authorizationHeader: accesstoken,
              },
              validateStatus: (status) => true,
            ),
            data: formData,
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        print("statuscode" + value.statusCode.toString());
        try {
          if (value.statusCode == 200) {
            print(value);
            if (value.data["status"] == 0) {
              return SignupResponse(
                  data: null, message: _extractMessage(value.data), status: 0);
            } else {
              //prefs.putBool(SharedPrefHelper.IS_ACCOUNT_CREATED_BOOL, true);
              prefs.putString(SharedPrefHelper.USER_DATA, value.toString());
              // print("shared data =");
              // print(prefs.getString(SharedPrefHelper.USER_DATA));
              return SignupResponse.fromJson(value.data);
            }
          } else {
            return SignupResponse(
                data: null, message: _extractMessage(value.data), status: 0);
          }
        } catch (e) {
          return SignupResponse(
              data: null,
              message: _normalizeBackendMessage(e.toString()),
              status: 0);
        }
      });
    } on SocketException {
      return SignupResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return SignupResponse(data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<ForgotPasswordResponse> forgotpassword(String email) async {
    try {
      return await http.Client()
          .post(
            Uri.parse("$baseUrl/api/user/forgotPassword?email=$email"),
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode(
              {
                "email": email,
              },
            ),
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        print("$baseUrl/api/user/forgotPassword");
        // print(value.body);
        print("username = " + email.toString());
        print("username = " + value.toString());

        try {
          if (value.statusCode == 200) {
            var map = json.decode(value.body);
            print("map");
            print(map);
            if (map["status"] == 0) {
              return ForgotPasswordResponse(
                  data: null, message: _extractMessage(map), status: 0);
            } else {
              ForgotPasswordResponse data =
                  ForgotPasswordResponse.fromJson(map);

              // }
              return data;
            }
          } else {
            var map = json.decode(value.body);
            return ForgotPasswordResponse(
                data: null, message: _extractMessage(map), status: 0);
          }
        } catch (e) {
          return ForgotPasswordResponse(
              data: null,
              message: _normalizeBackendMessage(e.toString()),
              status: 0);
        }
      });
    } on SocketException {
      return ForgotPasswordResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return ForgotPasswordResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<UploadReceiptResponse> uploadreceipt(String receiptlink, int userid,
      {String receipttype = "QR_SCANNED"}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    print("tokenvalue = " + accesstoken);
    print("receiptName = " + receiptlink);
    print("userId = " + userid.toString());

    try {
      return await http.Client()
          .post(
            Uri.parse("$baseUrl/api/user/uploadReceipt"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
            body: jsonEncode(
              {
                "receiptName": receiptlink,
                "userId": userid,
                "receiptFromType": receipttype
              },
            ),
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        print("$baseUrl/api/user/uploadReceipt");

        try {
          if (value.statusCode == 200) {
            // var map = json.decode(value.body);
            var map = json.decode(utf8.decode(value.bodyBytes));
            if (map["status"] == 0) {
              return UploadReceiptResponse(
                  data: null, message: map["message"], status: 0);
            } else if (map["status"] == 401) {
              return UploadReceiptResponse(
                  data: null, message: map["message"], status: 401);
            } else {
              UploadReceiptResponse data = UploadReceiptResponse.fromJson(map);

              return data;
            }
          } else {
            var map = json.decode(value.body);
            return UploadReceiptResponse(
                data: null,
                message: map["message"] ?? "Something went wrong!",
                status: 0,
                apiStatusCode: value.statusCode);
          }
        } catch (e) {
          return UploadReceiptResponse(
              data: null, message: e.toString(), status: 0);
        }
      });
    } on SocketException {
      return UploadReceiptResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return UploadReceiptResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //Logout API
  //done
  Future<LogoutResponse> logout() async {
    String accesstoken = prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING);
    try {
      return await http.Client()
          .get(
            Uri.parse("$baseUrl/api/user/logout"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
            // body: jsonEncode(
            //   {
            //     "fcmToken": "dghyjkd",
            //
            //   },
            // ),
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
            print("$baseUrl/api/user/logout");
            print(value.body);

            try {
              if (value.statusCode == 200) {
                var map = json.decode(value.body);
                print(map);
                if (map["status"] == 0) {
                  return LogoutResponse(
                      data: null, message: map["message"], status: 0);
                } else if (map["status"] == 401) {
                  return LogoutResponse(
                      data: null, message: map["message"], status: 401);
                } else {
                  LogoutResponse data = LogoutResponse.fromJson(map);

                  return data;
                }
              } else {
                var map = json.decode(value.body);
                print("mapdata" + map.toString());
                return LogoutResponse(
                    data: null,
                    message: map["message"] ?? "Something went wrong!",
                    status: 0,
                    apiStatusCode: value.statusCode);
              }
            } catch (e) {
              return LogoutResponse(
                  data: null, message: e.toString(), status: 0);
            }
          });
    } on SocketException {
      return LogoutResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return LogoutResponse(data: null, message: "Request time out", status: 0);
    }
  }

  // Future<FilterReceiptResponse> filterReceipt(
  //    int userid,String startdate, String enddate,String timezone, String direction ) async {
  //   String accesstoken = prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING);
  //   print("tokenvalue = " + accesstoken);
  //
  //   try {
  //     return await http.Client()
  //         .post(
  //       Uri.parse("$baseUrl/api/user/receiptFilter"),
  //       headers: {
  //         "access-token": accesstoken,
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode(
  //           {
  //             "userId": userid,
  //             "startDate": startdate,
  //             "endDate": enddate,
  //             "timeZone": "Asia/Kolkata",
  //             "sortBy": {
  //               "direction": direction
  //             }
  //           }
  //       ),
  //     )
  //         .timeout(const Duration(seconds: 60))
  //         .then((value) async {
  //       print("$baseUrl/api/user/receiptFilter");
  //
  //       try {
  //         if (value.statusCode == 200) {
  //           var map = json.decode(value.body);
  //           print(map);
  //           if (map["status"] == 0) {
  //             return FilterReceiptResponse(
  //                 data: null, message: map["message"], status: 0);
  //           }else if (map["status"] == 401) {
  //             return FilterReceiptResponse(
  //                 data: null, message: map["message"], status: 401);
  //           } else {
  //             FilterReceiptResponse data = FilterReceiptResponse.fromJson(map);
  //
  //             return data;
  //           }
  //         }
  //         else {
  //           var map = json.decode(value.body);
  //           return FilterReceiptResponse(
  //               data: null, message: map["message"] ?? "Something went wrong!", status: 0,apiStatusCode: value.statusCode);
  //         }
  //       } catch (e) {
  //         return FilterReceiptResponse(
  //             data: null, message: e.toString(), status: 0);
  //       }
  //     });
  //   } on SocketException {
  //     return FilterReceiptResponse(
  //         data: null, message: "No Internet connection", status: 0);
  //   } on TimeoutException {
  //     return FilterReceiptResponse(
  //         data: null, message: "Request time out", status: 0);
  //   }
  // }

  // Future<EditProfileResponse> editProfile({
  //   int userid,
  //   String country,
  //   String countrycode,
  //   String currency,
  //   String firstname,
  //   String lastname,
  //   String phonenumber,
  //   File profilePhoto,
  // }) async {
  //   String accesstoken = prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING);
  //   print("tokenvalue = " + accesstoken);
  //   String fileName = profilePhoto != null
  //       ? profilePhoto.path.split('/').last
  //       : null;
  //   try {
  //     return await http.Client()
  //         .put(
  //           Uri.parse(
  //               "$baseUrl/api/user/profileedit?country=$country&countryCode=$countrycode&currency=$currency&firstName=$firstname&lastName=$lastname&phoneNumber=$phonenumber&userId=$userid"),
  //           headers: {
  //             "access-token": accesstoken,
  //             "Content-Type": "application/json",
  //           },
  //           // body: jsonEncode({
  //           //   "userId": userid,
  //           //   "receiptId": receiptid,
  //           //   if (amount != null) "amount": double.parse(amount),
  //           //   if (currency != null) "currency": currency,
  //           //   if (description != null) "description": description,
  //           //   if (purchaseDate != null) "purchaseDate": purchaseDate,
  //           //   if (warrantycards != null) "files": warrantycards,
  //           //   if (storeLocation != null) "storeLocation": storeLocation,
  //           //   if (storeName != null) "storeName": storeName,
  //           //   if (timeZone != null) "timeZone": timeZone,
  //           // }),
  //         )
  //         .timeout(const Duration(seconds: 60))
  //         .then((value) async {
  //           print(
  //               "$baseUrl/api/user/profileedit?country=$country&countryCode=$countrycode&currency=$currency&firstName=$firstname&lastName=$lastname&phoneNumber=$phonenumber&userId=$userid");
  //
  //           try {
  //             if (value.statusCode == 200) {
  //               var map = json.decode(value.body);
  //               print(map);
  //               if (map["status"] == 0) {
  //                 return EditProfileResponse(
  //                     data: null, message: map["message"], status: 0);
  //               } else if (map["status"] == 401) {
  //                 return EditProfileResponse(
  //                     data: null, message: map["message"], status: 401);
  //               } else {
  //                 EditProfileResponse data = EditProfileResponse.fromJson(map);
  //                 prefs.putString(SharedPrefHelper.USER_DATA, value.toString());
  //                 print("shared data =");
  //                 print(prefs.getString(SharedPrefHelper.USER_DATA));
  //                 return data;
  //               }
  //             } else {
  //               var map = json.decode(value.body);
  //               return EditProfileResponse(
  //                   data: null,
  //                   message: map["message"] ?? "Something went wrong!",
  //                   status: 0,
  //                   apiStatusCode: value.statusCode);
  //             }
  //           } catch (e) {
  //             return EditProfileResponse(
  //                 data: null, message: e.toString(), status: 0);
  //           }
  //         });
  //   } on SocketException {
  //     return EditProfileResponse(
  //         data: null, message: "No Internet connection", status: 0);
  //   } on TimeoutException {
  //     return EditProfileResponse(
  //         data: null, message: "Request time out", status: 0);
  //   }
  // }
  //done
  Future<EditProfileResponse> editProfile({
    int userid = 0,
    String country = "",
    String countrycode = "",
    String currency = "",
    String firstname = "",
    String lastname = "",
    String phonenumber = "",
    File? profilePhoto,
    String countryAbbreviate = "",
  }) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    print("tokenvalue = " + accesstoken);
    var dio = Dio();
    dio.options.headers["Content-Type"] = "application/json";
    dio.options.headers["access-token"] = accesstoken;
    dio.options.validateStatus = (status) => true;

    //               "$baseUrl/api/user/profileedit?country=$country&countryCode=$countrycode&currency=$currency&firstName=$firstname&lastName=$lastname&phoneNumber=$phonenumber&userId=$userid"),

    final Map<String, dynamic> formMap = {
      // "userid" :userid,
      //
      // if (country != null) "country": country,
      // if (countrycode != null) "countryCode": countrycode,
      // if (currency != null) "currency": currency,
      // if (firstname != null) "firstName": firstname,
      // if (lastname != null) "lastName": lastname,
      // if (phonenumber != null) "phoneNumber": phonenumber,
    };
    if (profilePhoto != null) {
      final fileName = profilePhoto.path.split('/').last;
      formMap["file"] = await MultipartFile.fromFile(profilePhoto.path,
          filename: fileName, contentType: MediaType('image', 'jpg'));
    }

    FormData formData = FormData.fromMap(formMap);

    print(profilePhoto);
    print(formData.fields);
    print("formData");

    try {
      return await dio
          .put(
            // "$baseUrl/api/user/profileedit",
            "$baseUrl/api/user/profileedit?country=$country&countryCode=$countrycode&currency=$currency&firstName=$firstname&lastName=$lastname&phoneNumber=$phonenumber&userId=$userid&countryAbbreviate=$countryAbbreviate",
            // options: Options(headers: {
            //   HttpHeaders.contentTypeHeader: "application/json",
            //   HttpHeaders.authorizationHeader: accesstoken,
            // }),
            data: formData,
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        print("$baseUrl/api/user/profileedit");
        print(value.statusCode);

        try {
          if (value.statusCode == 200) {
            print(value);
            // var map = json.decode(value.body);
            print(value.data);
            if (value.data["status"] == 0) {
              return EditProfileResponse(
                  data: null, message: value.data["message"], status: 0);
            } else if (value.data["status"] == 401) {
              return EditProfileResponse(
                  data: null, message: value.data["message"], status: 401);
            } else {
              EditProfileResponse data =
                  EditProfileResponse.fromJson(value.data);
              prefs.putString(SharedPrefHelper.USER_DATA, value.toString());
              print("shared data =");
              print(prefs.getString(SharedPrefHelper.USER_DATA));
              return data;
            }
          } else {
            return EditProfileResponse(
                data: null,
                message: value.data["message"] ?? "Something went wrong!",
                status: 0,
                apiStatusCode: value.statusCode);
          }
        } catch (e) {
          return EditProfileResponse(
              data: null, message: e.toString(), status: 0);
        }
      });
    } on SocketException {
      return EditProfileResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return EditProfileResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  // Future<LogoutResponse> logout() async {
  //   String accesstoken = prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING);
  //   try {
  //     return await http.Client()
  //         .get(
  //       Uri.parse("$baseUrl/api/user/logout"),
  //       headers: {
  //         "access-token": accesstoken,
  //         "Content-Type": "application/json",
  //       },
  //       // body: jsonEncode(
  //       //   {
  //       //     "fcmToken": "dghyjkd",
  //       //
  //       //   },
  //       // ),
  //     )
  //         .timeout(const Duration(seconds: 60))
  //         .then((value) async {
  //       print("$baseUrl/api/user/logout");
  //       print(value.body);
  //
  //       try {
  //         if (value.statusCode == 200) {
  //           var map = json.decode(value.body);
  //           print(map);
  //           if (map["status"] == 0) {
  //             return LogoutResponse(
  //                 data: null, message: map["message"], status: 0);
  //           } else if (map["status"] == 401) {
  //             return LogoutResponse(
  //                 data: null, message: map["message"], status: 401);
  //           } else {
  //             LogoutResponse data = LogoutResponse.fromJson(map);
  //
  //             return data;
  //           }
  //         } else {
  //           var map = json.decode(value.body);
  //           print("mapdata" + map.toString());
  //           return LogoutResponse(
  //               data: null,
  //               message: map["message"] ?? "Something went wrong!",
  //               status: 0,
  //               apiStatusCode: value.statusCode);
  //         }
  //       } catch (e) {
  //         return LogoutResponse(
  //             data: null, message: e.toString(), status: 0);
  //       }
  //     });
  //   } on SocketException {
  //     return LogoutResponse(
  //         data: null, message: "No Internet connection", status: 0);
  //   } on TimeoutException {
  //     return LogoutResponse(data: null, message: "Request time out", status: 0);
  //   }
  // }
  //done
  Future<GetProfileResponse> getprofile({int userid = 0}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      return await http.Client()
          .get(
            Uri.parse("$baseUrl/api/user/viewProfile?userId=$userid"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
            print("$baseUrl/api/user/viewProfile?userId=$userid");
            print(value.body);
            //
            try {
              if (value.statusCode == 200) {
                var map = json.decode(value.body);
                print(map);
                if (map["status"] == 0) {
                  return GetProfileResponse(
                      data: null, message: map["message"], status: 0);
                } else if (map["status"] == 401) {
                  return GetProfileResponse(
                      data: null, message: map["message"], status: 401);
                } else {
                  GetProfileResponse data = GetProfileResponse.fromJson(map);
                  prefs.putString(SharedPrefHelper.USER_DATA, value.body);
                  print("api success");
                  print(prefs.getString(SharedPrefHelper.USER_DATA));

                  return data;
                }
              } else {
                var map = json.decode(value.body);
                print("mapdata" + map.toString());
                return GetProfileResponse(
                    data: null,
                    message: map["message"] ?? "Something went wrong!",
                    status: 0,
                    apiStatusCode: value.statusCode);
              }
            } catch (e) {
              return GetProfileResponse(
                  data: null, message: e.toString(), status: 0);
            }
          });
    } on SocketException {
      return GetProfileResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return GetProfileResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<GetCategoryListResponse> getCategoryList() async {
    String accesstoken = prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING);
    try {
      return await http.Client()
          .post(
            Uri.parse("$baseUrl/api/user/category/list"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
            print("$baseUrl/api/user/category/list");
            // print(value.body);

            try {
              if (value.statusCode == 200) {
                var map = json.decode(value.body);
                print(map);
                if (map["status"] == 0) {
                  return GetCategoryListResponse(
                      data: null, message: map["message"], status: 0);
                } else if (map["status"] == 401) {
                  return GetCategoryListResponse(
                      data: null, message: map["message"], status: 401);
                } else {
                  GetCategoryListResponse data =
                      GetCategoryListResponse.fromJson(map);

                  return data;
                }
              } else {
                var map = json.decode(value.body);
                return GetCategoryListResponse(
                    data: null,
                    message: map["message"] ?? "Something went wrong!",
                    status: 0,
                    apiStatusCode: value.statusCode);
              }
            } catch (e) {
              return GetCategoryListResponse(
                  data: null, message: e.toString(), status: 0);
            }
          });
    } on SocketException {
      return GetCategoryListResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return GetCategoryListResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<GetCouponsListResponse> getCouponsList(
      {String sortby = "",
      List categoryid = const [],
      String query = ""}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      return await http.Client()
          .post(
            Uri.parse("$baseUrl/api/user/coupon/list"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
            body: jsonEncode(
              {"sortByType": sortby, "categoryId": categoryid, "search": query},
            ),
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        print("$baseUrl/api/user/coupon/list");
        // print(value.body);

        try {
          if (value.statusCode == 200) {
            var map = json.decode(value.body);
            print(map);
            log(map.toString());
            if (map["status"] == 0) {
              return GetCouponsListResponse(
                  data: null, message: map["message"], status: 0);
            } else if (map["status"] == 401) {
              return GetCouponsListResponse(
                  data: null, message: map["message"], status: 401);
            } else {
              GetCouponsListResponse data =
                  GetCouponsListResponse.fromJson(map);

              return data;
            }
          } else {
            var map = json.decode(value.body);
            return GetCouponsListResponse(
                data: null,
                message: map["message"] ?? "Something went wrong!",
                status: 0,
                apiStatusCode: value.statusCode);
          }
        } catch (e) {
          return GetCouponsListResponse(
              data: null, message: e.toString(), status: 0);
        }
      });
    } on SocketException {
      return GetCouponsListResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return GetCouponsListResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<DeleteAccountResponse> deleteaccount({int userid = 0}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      return await http.Client()
          .delete(
            Uri.parse("$baseUrl/api/user/$userid"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
            // body: jsonEncode(
            //   {
            //     "id": userid,
            //     // "categoryId": categoryid,
            //   },
            // ),
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
            print("$baseUrl/api/user/$userid");
            // print(value.body);

            try {
              if (value.statusCode == 200) {
                var map = json.decode(value.body);
                print(map);
                if (map["status"] == 0) {
                  return DeleteAccountResponse(
                      data: null, message: map["message"], status: 0);
                } else if (map["status"] == 401) {
                  return DeleteAccountResponse(
                      data: null, message: map["message"], status: 401);
                } else {
                  DeleteAccountResponse data =
                      DeleteAccountResponse.fromJson(map);

                  return data;
                }
              } else {
                var map = json.decode(value.body);
                return DeleteAccountResponse(
                    data: null,
                    message: map["message"] ?? "Something went wrong!",
                    status: 0,
                    apiStatusCode: value.statusCode);
              }
            } catch (e) {
              return DeleteAccountResponse(
                  data: null, message: e.toString(), status: 0);
            }
          });
    } on SocketException {
      return DeleteAccountResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return DeleteAccountResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<UploadGalleryOrNativeResponse> uploadgalleryornative(
      {int userid = 0,
      File? profilePhoto,
      String receipttype = "GALLERY"}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    print("tokenvalue = " + accesstoken);
    var dio = Dio();
    dio.options.headers["Content-Type"] = "application/json";
    dio.options.headers["access-token"] = accesstoken;
    dio.options.validateStatus = (status) => true;
    //               "$baseUrl/api/user/profileedit?country=$country&countryCode=$countrycode&currency=$currency&firstName=$firstname&lastName=$lastname&phoneNumber=$phonenumber&userId=$userid"),

    final Map<String, dynamic> formMap = {
      "receiptFromType": receipttype,
    };
    if (profilePhoto != null) {
      final fileName = profilePhoto.path.split('/').last;
      formMap["file"] = await MultipartFile.fromFile(profilePhoto.path,
          filename: fileName, contentType: MediaType('image', 'jpg'));
    }
    FormData formData = FormData.fromMap(formMap);

    print(profilePhoto);
    print(formData.fields);
    print("formData");

    try {
      return await dio
          .post(
            "$baseUrl/api/user/receipt/ocr?userId=$userid",
            // options: Options(headers: {
            //   HttpHeaders.contentTypeHeader: "application/json",
            //   HttpHeaders.authorizationHeader: accesstoken,
            // }),
            data: formData,
          )
          .timeout(const Duration(seconds: 120))
          .then((value) async {
        print("$baseUrl/api/user/receipt/ocr?userId=$userid");
        print(value.statusCode);

        try {
          if (value.statusCode == 200) {
            print(value);
            // var map = json.decode(value.body);
            print(value.data);
            if (value.data["status"] == 0) {
              return UploadGalleryOrNativeResponse(
                  data: null, message: value.data["message"], status: 0);
            } else if (value.data["status"] == 401) {
              return UploadGalleryOrNativeResponse(
                  data: null, message: value.data["message"], status: 401);
            } else {
              UploadGalleryOrNativeResponse data =
                  UploadGalleryOrNativeResponse.fromJson(value.data);
              return data;
            }
          } else {
            return UploadGalleryOrNativeResponse(
                data: null,
                message: value.data["message"] ?? "Something went wrong!",
                status: 0,
                apiStatusCode: value.statusCode);
          }
        } catch (e) {
          return UploadGalleryOrNativeResponse(
              data: null, message: e.toString(), status: 0);
        }
      });
    } on SocketException {
      return UploadGalleryOrNativeResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return UploadGalleryOrNativeResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<StoreCardListResponse> getStoreCardListing(int userid,
      {String query = ""}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      print("searchquery");
      print(query);
      return await http.Client()
          .post(
            Uri.parse("$baseUrl/api/user/storeCard/list?" +
                ("search=${query}") +
                "&userId=$userid"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
            body: jsonEncode(
              {"search": query},
            ),
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        print("$baseUrl/api/user/storeCard/list?userId=$userid");
        // print(value.body);

        try {
          if (value.statusCode == 200) {
            var map = json.decode(value.body);
            log("Responce $map");
            if (map["status"] == 0) {
              return StoreCardListResponse(
                  data: null, message: map["message"], status: 0);
            } else if (map["status"] == 401) {
              return StoreCardListResponse(
                  data: null, message: map["message"], status: 401);
            } else {
              StoreCardListResponse data = StoreCardListResponse.fromJson(map);

              return data;
            }
          } else {
            var map = json.decode(value.body);
            return StoreCardListResponse(
                data: null,
                message: map["message"] ?? "Something went wrong!",
                status: 0,
                apiStatusCode: value.statusCode);
          }
        } catch (e) {
          return StoreCardListResponse(
              data: null, message: e.toString(), status: 0);
        }
      });
    } on SocketException {
      return StoreCardListResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return StoreCardListResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<DeleteStoreCardResponse> deletestorecard({int storecardid = 0}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      return await http.Client()
          .delete(
            Uri.parse(
                "$baseUrl/api/user/storeCard/delete?storeCardId=$storecardid"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
            // body: jsonEncode(
            //   {
            //     "id": userid,
            //     // "categoryId": categoryid,
            //   },
            // ),
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
            print(
                "$baseUrl/api/user/storeCard/delete?storeCardId=$storecardid");
            // print(value.body);

            try {
              if (value.statusCode == 200) {
                var map = json.decode(value.body);
                print(map);
                if (map["status"] == 0) {
                  return DeleteStoreCardResponse(
                      data: null, message: map["message"], status: 0);
                } else if (map["status"] == 401) {
                  return DeleteStoreCardResponse(
                      data: null, message: map["message"], status: 401);
                } else {
                  DeleteStoreCardResponse data =
                      DeleteStoreCardResponse.fromJson(map);

                  return data;
                }
              } else {
                var map = json.decode(value.body);
                return DeleteStoreCardResponse(
                    data: null,
                    message: map["message"] ?? "Something went wrong!",
                    status: 0,
                    apiStatusCode: value.statusCode);
              }
            } catch (e) {
              return DeleteStoreCardResponse(
                  data: null, message: e.toString(), status: 0);
            }
          });
    } on SocketException {
      return DeleteStoreCardResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return DeleteStoreCardResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<AddStoreCardResponse> addstorecard(
      String storeName, String storeNumber, int userid,
      {int storeId = 0}) async {
    print("storename" + "$storeName" + "$storeNumber" + "$storeId");
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      // String updatedurl = "$baseUrl/api/user/storeCard/add?storeName=$storeName&storeNumber=$storeNumber&userId=$userid" +storeId.toString() != null ?"&storeId="$storeId :;
      return await http.Client()
          .post(
            // Uri.parse("$baseUrl/api/user/storeCard/add?storeName=$storeName&storeNumber=$storeNumber&userId=$userid&storeId=$storeId"),
            Uri.parse(
                "$baseUrl/api/user/storeCard/add?storeName=$storeName&storeNumber=$storeNumber&userId=$userid" +
                    ("&storeId=${storeId}")),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
            body: jsonEncode(
              {
                "storeId": storeId,
                "storeName": storeName,
                "storeNumber": storeNumber,
                "userId": userid,
              },
            ),
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        print("$baseUrl/api/user/storeCard/add");
        // print(value.body);

        try {
          if (value.statusCode == 200) {
            var map = json.decode(value.body);
            print(map);
            if (map["status"] == 0) {
              return AddStoreCardResponse(
                  data: null, message: map["message"], status: 0);
            } else if (map["status"] == 401) {
              return AddStoreCardResponse(
                  data: null, message: map["message"], status: 401);
            } else {
              AddStoreCardResponse data = AddStoreCardResponse.fromJson(map);

              return data;
            }
          } else {
            var map = json.decode(value.body);
            return AddStoreCardResponse(
                data: null,
                message: map["message"] ?? "Something went wrong!",
                status: 0,
                apiStatusCode: value.statusCode);
          }
        } catch (e) {
          return AddStoreCardResponse(
              data: null, message: e.toString(), status: 0);
        }
      });
    } on SocketException {
      return AddStoreCardResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return AddStoreCardResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<StoreListResponse> getstorelist({String searchQuery = ""}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      return await http.Client()
          .post(
              Uri.parse(
                  "$baseUrl/api/user/storeCard/store/storeList?search=$searchQuery"),
              headers: {
                "access-token": accesstoken,
                "Content-Type": "application/json",
              },
              body: jsonEncode({
                "search": searchQuery,
              }))
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        print("$baseUrl/api/user/storeCard/store/storeList");
        // print(value.body);

        try {
          if (value.statusCode == 200) {
            var map = json.decode(utf8.decode(value.bodyBytes));
            print(map);
            if (map["status"] == 0) {
              return StoreListResponse(
                  data: null, message: map["message"], status: 0);
            } else if (map["status"] == 401) {
              return StoreListResponse(
                  data: null, message: map["message"], status: 401);
            } else {
              StoreListResponse data = StoreListResponse.fromJson(map);

              return data;
            }
          } else {
            var map = json.decode(utf8.decode(value.bodyBytes));
            return StoreListResponse(
                data: null,
                message: map["message"] ?? "Something went wrong!",
                status: 0,
                apiStatusCode: value.statusCode);
          }
        } catch (e) {
          return StoreListResponse(
              data: null, message: e.toString(), status: 0);
        }
      });
    } on SocketException {
      return StoreListResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return StoreListResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<EditStoreCardResponse> editstorecard(
      String storeName, String storeNumber, int storeCardId,
      {int? storeId}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    final storeIdParam = storeId != null ? "&storeId=$storeId" : "";
    try {
      return await http.Client()
          .put(
            // Uri.parse("$baseUrl/api/user/storeCard/add?storeName=$storeName&storeNumber=$storeNumber&userId=$userid&storeId=$storeId"),
            Uri.parse(
                "$baseUrl/api/user/storeCard/edit?storeName=$storeName&storeNumber=$storeNumber&storeCardId=$storeCardId$storeIdParam"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
            body: jsonEncode(
              {
                "storeId": storeId,
                "storeName": storeName,
                "storeNumber": storeNumber,
                "storeCardId": storeCardId,
              },
            ),
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        print(
            "$baseUrl/api/user/storeCard/edit?storeName=$storeName&storeNumber=$storeNumber&storeCardId=$storeCardId" +
                ("&storeId=${storeId}"));
        // print(value.body);

        try {
          if (value.statusCode == 200) {
            var map = json.decode(value.body);
            print(map);
            if (map["status"] == 0) {
              return EditStoreCardResponse(
                  data: null, message: map["message"], status: 0);
            } else if (map["status"] == 401) {
              return EditStoreCardResponse(
                  data: null, message: map["message"], status: 401);
            } else {
              EditStoreCardResponse data = EditStoreCardResponse.fromJson(map);

              return data;
            }
          } else {
            var map = json.decode(value.body);
            return EditStoreCardResponse(
                data: null,
                message: map["message"] ?? "Something went wrong!",
                status: 0,
                apiStatusCode: value.statusCode);
          }
        } catch (e) {
          return EditStoreCardResponse(
              data: null, message: e.toString(), status: 0);
        }
      });
    } on SocketException {
      return EditStoreCardResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return EditStoreCardResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<DeleteReceiptResponse> deletereceipts(List<int> receiptids) async {
    String accesstoken = prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING);
    try {
      return await http.Client()
          .post(
            Uri.parse("$baseUrl/api/user/deleteReceipt"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
            body: jsonEncode(receiptids),
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        print("deleteresponseapi");
        print(value.request);
        print(receiptids);
        print("$baseUrl/api/user/deleteReceipt");
        // print(value.body);

        try {
          if (value.statusCode == 200) {
            var map = json.decode(value.body);
            print(map);
            if (map["status"] == 0) {
              return DeleteReceiptResponse(
                  data: null, message: map["message"], status: 0);
            } else if (map["status"] == 401) {
              return DeleteReceiptResponse(
                  data: null, message: map["message"], status: 401);
            } else {
              DeleteReceiptResponse data = DeleteReceiptResponse.fromJson(map);

              return data;
            }
          } else {
            var map = json.decode(value.body);
            return DeleteReceiptResponse(
                data: null,
                message: map["message"] ?? "Something went wrong!",
                status: 0,
                apiStatusCode: value.statusCode);
          }
        } catch (e) {
          return DeleteReceiptResponse(
              data: null, message: e.toString(), status: 0);
        }
      });
    } on SocketException {
      return DeleteReceiptResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return DeleteReceiptResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //not used
  Future<TotalPointsResponse> gettotalpoints({int userid = 0}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      return await http.Client()
          .get(
            Uri.parse("$baseUrl/api/user/totalPoints?userId=$userid"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
            print("$baseUrl/api/user/totalPoints?userId=$userid");
            print(value.body);
            //
            try {
              if (value.statusCode == 200) {
                var map = json.decode(value.body);
                print(map);
                if (map["status"] == 0) {
                  return TotalPointsResponse(
                      data: null, message: map["message"], status: 0);
                } else if (map["status"] == 401) {
                  return TotalPointsResponse(
                      data: null, message: map["message"], status: 401);
                } else {
                  TotalPointsResponse data = TotalPointsResponse.fromJson(map);

                  return data;
                }
              } else {
                var map = json.decode(value.body);
                return TotalPointsResponse(
                    data: null,
                    message: map["message"] ?? "Something went wrong!",
                    status: 0,
                    apiStatusCode: value.statusCode);
              }
            } catch (e) {
              return TotalPointsResponse(
                  data: null, message: e.toString(), status: 0);
            }
          });
    } on SocketException {
      return TotalPointsResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return TotalPointsResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

// done
  Future<FeedbackResponse> sendfeedback(
      {String feedback = "",
      String feedbackfrom = "",
      String rating = "",
      int receiptid = 0,
      int userid = 0}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      return await http.Client()
          .post(
            Uri.parse("$baseUrl/api/user/feedback"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "comment": feedback,
              "feedbackFrom": "USER_APP",
              "rating": rating,
              "receiptId": receiptid,
              "userId": userid,
            }),
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        print("sendfeedbackapi");
        print(feedback);
        print(receiptid);
        print(userid);
        print(value.request);
        print("$baseUrl/api/user/feedback");

        try {
          if (value.statusCode == 200) {
            var map = json.decode(value.body);
            print(map);
            if (map["status"] == 0) {
              return FeedbackResponse(
                  data: null, message: map["message"], status: 0);
            } else if (map["status"] == 401) {
              return FeedbackResponse(
                  data: null, message: map["message"], status: 401);
            } else {
              FeedbackResponse data = FeedbackResponse.fromJson(map);

              return data;
            }
          } else {
            var map = json.decode(value.body);
            return FeedbackResponse(
                data: null,
                message: map["message"] ?? "Something went wrong!",
                status: 0,
                apiStatusCode: value.statusCode);
          }
        } catch (e) {
          return FeedbackResponse(data: null, message: e.toString(), status: 0);
        }
      });
    } on SocketException {
      return FeedbackResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return FeedbackResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

//done
  Future<EarnPointsResponse> getearnpoints({int userid = 0}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      return await http.Client()
          .get(
            Uri.parse(
                "$baseUrl/api/user/earnedPoints/getPoints?userId=$userid"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
            print("$baseUrl/user/earnedPoints/getPoints?userId=$userid");
            print(value.body);
            //
            try {
              if (value.statusCode == 200) {
                var map = json.decode(value.body);
                print(map);
                if (map["status"] == 0) {
                  return EarnPointsResponse(
                      data: null, message: map["message"], status: 0);
                } else if (map["status"] == 401) {
                  return EarnPointsResponse(
                      data: null, message: map["message"], status: 401);
                } else {
                  EarnPointsResponse data = EarnPointsResponse.fromJson(map);

                  return data;
                }
              } else {
                var map = json.decode(value.body);
                return EarnPointsResponse(
                    data: null,
                    message: map["message"] ?? "Something went wrong!",
                    status: 0,
                    apiStatusCode: value.statusCode);
              }
            } catch (e) {
              return EarnPointsResponse(
                  data: null, message: e.toString(), status: 0);
            }
          });
    } on SocketException {
      return EarnPointsResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return EarnPointsResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //not used
  Future<GetVoucherCardResponse> getvouchercard(
      {int userid = 0, String query = ""}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      return await http.Client()
          .get(
            Uri.parse(
                "$baseUrl/api/user/earnedPoints/voucherCards?userId=$userid"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
            print("$baseUrl/api/user/earnedPoints/voucherCards?userId=$userid");
            print(value.body);
            //
            try {
              if (value.statusCode == 200) {
                var map = json.decode(value.body);
                print(map);
                if (map["status"] == 0) {
                  return GetVoucherCardResponse(
                      data: null, message: map["message"], status: 0);
                } else if (map["status"] == 401) {
                  return GetVoucherCardResponse(
                      data: null, message: map["message"], status: 401);
                } else {
                  GetVoucherCardResponse data =
                      GetVoucherCardResponse.fromJson(map);

                  return data;
                }
              } else {
                var map = json.decode(value.body);
                return GetVoucherCardResponse(
                    data: null,
                    message: map["message"] ?? "Something went wrong!",
                    status: 0,
                    apiStatusCode: value.statusCode);
              }
            } catch (e) {
              return GetVoucherCardResponse(
                  data: null, message: e.toString(), status: 0);
            }
          });
    } on SocketException {
      return GetVoucherCardResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return GetVoucherCardResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  // Future<RedeemPointsResponse> redeempoints({int userid, int redeemid}) async {
  //   String accesstoken = prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING);
  //   try {
  //     return await http.Client()
  //         .post(
  //       Uri.parse("$baseUrl/api/user/earnedPoints/redeemPoints"),
  //       headers: {
  //         "access-token": accesstoken,
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode(
  //         {
  //           if (userid != null) "userId" :userid,
  //           if (redeemid != null) "redeemId" :redeemid
  //         },
  //       ),
  //     )
  //         .timeout(const Duration(seconds: 60))
  //         .then((value) async {
  //       print("$baseUrl/api/user/earnedPoints/redeemPoints");
  //       // print(value.body);
  //
  //       try {
  //         if (value.statusCode == 200) {
  //           var map = json.decode(value.body);
  //           print(map);
  //           if (map["status"] == 0) {
  //             return RedeemPointsResponse(
  //                 data: null, message: map["message"], status: 0);
  //           } else if (map["status"] == 401) {
  //             return RedeemPointsResponse(
  //                 data: null, message: map["message"], status: 401);
  //           } else {
  //             RedeemPointsResponse data = RedeemPointsResponse.fromJson(map);
  //
  //             return data;
  //           }
  //         } else {
  //           var map = json.decode(value.body);
  //           return RedeemPointsResponse(
  //               data: null,
  //               message: map["message"] ?? "Something went wrong!",
  //               status: 0,
  //               apiStatusCode: value.statusCode);
  //         }
  //       } catch (e) {
  //         return RedeemPointsResponse(
  //             data: null, message: e.toString(), status: 0);
  //       }
  //     });
  //   } on SocketException {
  //     return RedeemPointsResponse(
  //         data: null, message: "No Internet connection", status: 0);
  //   } on TimeoutException {
  //     return RedeemPointsResponse(data: null, message: "Request time out", status: 0);
  //   }
  // }

  //done
  Future<RedeemVoucherProductResponse> redeemProduct({int redeemid = 0}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      return await http.Client()
          .post(
            Uri.parse("$baseUrl/api/user/redeemProduct?productId=$redeemid"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
            body: jsonEncode(
              {
                // if (userid != null) "userId" :userid,
                "productId": redeemid
              },
            ),
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        print("$baseUrl/api/user/redeemProduct?productId=$redeemid");
        // print(value.body);

        try {
          if (value.statusCode == 200) {
            var map = json.decode(value.body);
            print(map);
            if (map["status"] == 0) {
              return RedeemVoucherProductResponse(
                  data: null, message: map["message"], status: 0);
            } else if (map["status"] == 401) {
              return RedeemVoucherProductResponse(
                  data: null, message: map["message"], status: 401);
            } else {
              RedeemVoucherProductResponse data =
                  RedeemVoucherProductResponse.fromJson(map);

              return data;
            }
          } else {
            var map = json.decode(value.body);
            return RedeemVoucherProductResponse(
                data: null,
                message: map["message"] ?? "Something went wrong!",
                status: 0,
                apiStatusCode: value.statusCode);
          }
        } catch (e) {
          return RedeemVoucherProductResponse(
              data: null, message: e.toString(), status: 0);
        }
      });
    } on SocketException {
      return RedeemVoucherProductResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return RedeemVoucherProductResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  // not used
  Future<GetRedeemedVouchersListResponse> getredeemvoucherlist(
      {int userid = 0}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      return await http.Client()
          .get(
            Uri.parse(
                "$baseUrl/api/user/earnedPoints/redeemedVouchers?userId=$userid"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
            print(
                "$baseUrl/api/user/earnedPoints/redeemedVouchers?userId=$userid");
            print(value.body);
            //
            try {
              if (value.statusCode == 200) {
                var map = json.decode(value.body);
                print(map);
                if (map["status"] == 0) {
                  return GetRedeemedVouchersListResponse(
                      data: null, message: map["message"], status: 0);
                } else if (map["status"] == 401) {
                  return GetRedeemedVouchersListResponse(
                      data: null, message: map["message"], status: 401);
                } else {
                  GetRedeemedVouchersListResponse data =
                      GetRedeemedVouchersListResponse.fromJson(map);

                  return data;
                }
              } else {
                var map = json.decode(value.body);
                return GetRedeemedVouchersListResponse(
                    data: null,
                    message: map["message"] ?? "Something went wrong!",
                    status: 0,
                    apiStatusCode: value.statusCode);
              }
            } catch (e) {
              return GetRedeemedVouchersListResponse(
                  data: null, message: e.toString(), status: 0);
            }
          });
    } on SocketException {
      return GetRedeemedVouchersListResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return GetRedeemedVouchersListResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<GetShoppingListResponse> getShoppingListing(
      {String query = ""}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      print("searchquery");
      print(query);
      return await http.Client()
          .get(
            Uri.parse("$baseUrl/api/user/shoppingList?" + ("search=${query}")),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
            print("$baseUrl/api/user/shoppingList");
            // print(value.body);

            try {
              if (value.statusCode == 200) {
                var map = json.decode(value.body);
                print(map);
                if (map["status"] == 0) {
                  return GetShoppingListResponse(
                      data: null, message: map["message"], status: 0);
                } else if (map["status"] == 401) {
                  return GetShoppingListResponse(
                      data: null, message: map["message"], status: 401);
                } else {
                  GetShoppingListResponse data =
                      GetShoppingListResponse.fromJson(map);

                  return data;
                }
              } else {
                var map = json.decode(value.body);
                return GetShoppingListResponse(
                    data: null,
                    message: map["message"] ?? "Something went wrong!",
                    status: 0,
                    apiStatusCode: value.statusCode);
              }
            } catch (e) {
              return GetShoppingListResponse(
                  data: null, message: e.toString(), status: 0);
            }
          });
    } on SocketException {
      return GetShoppingListResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return GetShoppingListResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

//done
  Future<HomePageResponse> getHomePageList({int userid = 0}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      return await http.Client()
          .get(
            Uri.parse("$baseUrl/api/user/homePage?userId=$userid"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
            print('HEADERS ${value.headers}');
            print('REQUEST ${value}');
            print("$baseUrl/api/user/homePage?userId=$userid");
            log(value.body);
            //
            try {
              if (value.statusCode == 200) {
                var map = json.decode(value.body);
                print(map);
                if (map["status"] == 0) {
                  return HomePageResponse(
                      data: null, message: map["message"], status: 0);
                } else if (map["status"] == 401) {
                  return HomePageResponse(
                      data: null, message: map["message"], status: 401);
                } else {
                  HomePageResponse data = HomePageResponse.fromJson(map);

                  return data;
                }
              } else {
                var map = json.decode(value.body);
                return HomePageResponse(
                    data: null,
                    message: map["message"] ?? "Something went wrong!",
                    status: 0,
                    apiStatusCode: value.statusCode);
              }
            } catch (e) {
              return HomePageResponse(
                  data: null, message: e.toString(), status: 0);
            }
          });
    } on SocketException {
      return HomePageResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return HomePageResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<GetStaticPageResponse> getstaticpage({String type = ""}) async {
    // String accesstoken = prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING);
    try {
      return await http.Client()
          .get(
            Uri.parse(
                "$baseUrl/api/staticPage/user/getStaticPage?pageType=$type"),
            // headers: {
            //   "access-token": accesstoken,
            //   "Content-Type": "application/json",
            // },
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        print("$baseUrl/api/staticPage/user/getStaticPage?pageType=$type");
        print(value.body);
        //
        try {
          if (value.statusCode == 200) {
            var map = json.decode(value.body);
            print(map);
            if (map["status"] == 0) {
              return GetStaticPageResponse(
                  data: null, message: map["message"], status: 0);
            } else if (map["status"] == 401) {
              return GetStaticPageResponse(
                  data: null, message: map["message"], status: 401);
            } else {
              GetStaticPageResponse data = GetStaticPageResponse.fromJson(map);

              return data;
            }
          } else {
            var map = json.decode(value.body);
            print("mapdata" + map.toString());
            return GetStaticPageResponse(
                data: null,
                message: map["message"] ?? "Something went wrong!",
                status: 0,
                apiStatusCode: value.statusCode);
          }
        } catch (e) {
          return GetStaticPageResponse(
              data: null, message: e.toString(), status: 0);
        }
      });
    } on SocketException {
      return GetStaticPageResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return GetStaticPageResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<GetSurveyListResponse> getSurveyList() async {
    String accesstoken = prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING);
    try {
      return await http.Client()
          .post(
            Uri.parse("$baseUrl/api/user/surveyList"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
            print("$baseUrl/api/user/surveyList");
            // print(value.body);

            try {
              if (value.statusCode == 200) {
                var map = json.decode(value.body);
                print(map);
                if (map["status"] == 0) {
                  return GetSurveyListResponse(
                      data: null, message: map["message"], status: 0);
                } else if (map["status"] == 401) {
                  return GetSurveyListResponse(
                      data: null, message: map["message"], status: 401);
                } else {
                  GetSurveyListResponse data =
                      GetSurveyListResponse.fromJson(map);

                  return data;
                }
              } else {
                var map = json.decode(value.body);
                return GetSurveyListResponse(
                    data: null,
                    message: map["message"] ?? "Something went wrong!",
                    status: 0,
                    apiStatusCode: value.statusCode);
              }
            } catch (e) {
              return GetSurveyListResponse(
                  data: null, message: e.toString(), status: 0);
            }
          });
    } on SocketException {
      return GetSurveyListResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return GetSurveyListResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

//done
  Future<GetNotificationListResponse> getNotificationList() async {
    String accesstoken = prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING);
    try {
      return await http.Client()
          .get(
            Uri.parse("$baseUrl/api/user/listNotification"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
            print("$baseUrl/api/user/listNotification");
            // print(value.body);

            try {
              if (value.statusCode == 200) {
                var map = json.decode(value.body);
                print(map);
                if (map["status"] == 0) {
                  return GetNotificationListResponse(
                      data: null, message: map["message"], status: 0);
                } else if (map["status"] == 401) {
                  return GetNotificationListResponse(
                      data: null, message: map["message"], status: 401);
                } else {
                  GetNotificationListResponse data =
                      GetNotificationListResponse.fromJson(map);

                  return data;
                }
              } else {
                var map = json.decode(value.body);
                return GetNotificationListResponse(
                    data: null,
                    message: map["message"] ?? "Something went wrong!",
                    status: 0,
                    apiStatusCode: value.statusCode);
              }
            } catch (e) {
              return GetNotificationListResponse(
                  data: null, message: e.toString(), status: 0);
            }
          });
    } on SocketException {
      return GetNotificationListResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return GetNotificationListResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

//done
  Future<GetNotificationCountResponse> getNotificationCount() async {
    String accesstoken = prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING);
    try {
      return await http.Client()
          .get(
            Uri.parse("$baseUrl/api/user/notificationCount"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
            print("$baseUrl/api/user/notificationCount");
            print("access token" + accesstoken);

            try {
              if (value.statusCode == 200) {
                var map = json.decode(value.body);
                print(map);
                if (map["status"] == 0) {
                  return GetNotificationCountResponse(
                      data: null, message: map["message"], status: 0);
                } else if (map["status"] == 401) {
                  return GetNotificationCountResponse(
                      data: null, message: map["message"], status: 401);
                } else {
                  GetNotificationCountResponse data =
                      GetNotificationCountResponse.fromJson(map);

                  return data;
                }
              } else {
                var map = json.decode(value.body);
                return GetNotificationCountResponse(
                    data: null,
                    message: map["message"] ?? "Something went wrong!",
                    status: 0,
                    apiStatusCode: value.statusCode);
              }
            } catch (e) {
              return GetNotificationCountResponse(
                  data: null, message: e.toString(), status: 0);
            }
          });
    } on SocketException {
      return GetNotificationCountResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return GetNotificationCountResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<GetListProductResponse> getproductlist({String query = ""}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      return await http.Client()
          .post(
            Uri.parse("$baseUrl/api/user/listProducts"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
            print("$baseUrl/api/user/listProducts");
            print(value.body);
            //
            try {
              if (value.statusCode == 200) {
                var map = json.decode(value.body);
                print(map);
                if (map["status"] == 0) {
                  return GetListProductResponse(
                      data: null, message: map["message"], status: 0);
                } else if (map["status"] == 401) {
                  return GetListProductResponse(
                      data: null, message: map["message"], status: 401);
                } else {
                  GetListProductResponse data =
                      GetListProductResponse.fromJson(map);

                  return data;
                }
              } else {
                var map = json.decode(value.body);
                return GetListProductResponse(
                    data: null,
                    message: map["message"] ?? "Something went wrong!",
                    status: 0,
                    apiStatusCode: value.statusCode);
              }
            } catch (e) {
              return GetListProductResponse(
                  data: null, message: e.toString(), status: 0);
            }
          });
    } on SocketException {
      return GetListProductResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return GetListProductResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<ListRedeemedProductResponse> getredeemedproductist() async {
    String accesstoken = prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING);
    try {
      return await http.Client()
          .post(
            Uri.parse("$baseUrl/api/user/listRedeemedProduct"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
            print("$baseUrl/api/user/listRedeemedProduct");
            print(value.body);
            //
            try {
              if (value.statusCode == 200) {
                var map = json.decode(value.body);
                print(map);
                if (map["status"] == 0) {
                  return ListRedeemedProductResponse(
                      data: null, message: map["message"], status: 0);
                } else if (map["status"] == 401) {
                  return ListRedeemedProductResponse(
                      data: null, message: map["message"], status: 401);
                } else {
                  ListRedeemedProductResponse data =
                      ListRedeemedProductResponse.fromJson(map);

                  return data;
                }
              } else {
                var map = json.decode(value.body);
                return ListRedeemedProductResponse(
                    data: null,
                    message: map["message"] ?? "Something went wrong!",
                    status: 0,
                    apiStatusCode: value.statusCode);
              }
            } catch (e) {
              return ListRedeemedProductResponse(
                  data: null, message: e.toString(), status: 0);
            }
          });
    } on SocketException {
      return ListRedeemedProductResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return ListRedeemedProductResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  //done
  Future<ChangePasswordResponse> changepassword(
      String oldPassword, String newPassword) async {
    String accesstoken = prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING);
    try {
      return await http.Client()
          .put(
            Uri.parse("$baseUrl/api/user/changePassword"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
            body: jsonEncode(
              {
                "oldPassword": oldPassword,
                "newPassword": newPassword,
              },
            ),
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        print("$baseUrl/api/user/changePassword");
        // print(value.body);

        try {
          if (value.statusCode == 200) {
            var map = json.decode(value.body);
            print(map);
            if (map["status"] == 0) {
              return ChangePasswordResponse(
                  data: null, message: map["message"], status: 0);
            } else if (map["status"] == 401) {
              return ChangePasswordResponse(
                  data: null, message: map["message"], status: 401);
            } else {
              ChangePasswordResponse data =
                  ChangePasswordResponse.fromJson(map);

              return data;
            }
          } else {
            var map = json.decode(value.body);
            return ChangePasswordResponse(
                data: null,
                message: map["message"] ?? "Something went wrong!",
                status: 0,
                apiStatusCode: value.statusCode);
          }
        } catch (e) {
          return ChangePasswordResponse(
              data: null, message: e.toString(), status: 0);
        }
      });
    } on SocketException {
      return ChangePasswordResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return ChangePasswordResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

//done
  Future<SingleNotificationDeleteResponse> singledeletenotification(
      {int userid = 0, int sentNotificationId = 0}) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      return await http.Client()
          .get(
            Uri.parse(
                "$baseUrl/api/user/clearNotification?sentNotificationId=$sentNotificationId&userId=$userid"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
            print(
                "$baseUrl/api/user/clearNotification?sentNotificationId=$sentNotificationId&userId=$userid");
            print(value.body);
            //
            try {
              if (value.statusCode == 200) {
                var map = json.decode(value.body);
                print(map);
                if (map["status"] == 0) {
                  return SingleNotificationDeleteResponse(
                      data: null, message: map["message"], status: 0);
                } else if (map["status"] == 401) {
                  return SingleNotificationDeleteResponse(
                      data: null, message: map["message"], status: 401);
                } else {
                  SingleNotificationDeleteResponse data =
                      SingleNotificationDeleteResponse.fromJson(map);

                  return data;
                }
              } else {
                var map = json.decode(value.body);
                return SingleNotificationDeleteResponse(
                    data: null,
                    message: map["message"] ?? "Something went wrong!",
                    status: 0,
                    apiStatusCode: value.statusCode);
              }
            } catch (e) {
              return SingleNotificationDeleteResponse(
                  data: null, message: e.toString(), status: 0);
            }
          });
    } on SocketException {
      return SingleNotificationDeleteResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return SingleNotificationDeleteResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

//done
  Future<AllNotificationDeleteResponse> deleteallnotifications({
    int userid = 0,
  }) async {
    String accesstoken =
        prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING) ?? "";
    try {
      return await http.Client()
          .get(
            Uri.parse("$baseUrl/api/user/clearAllNotification?userId=$userid"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
            print("$baseUrl/api/user/clearAllNotification?userId=$userid");
            print(value.body);
            //
            try {
              if (value.statusCode == 200) {
                var map = json.decode(value.body);
                print(map);
                if (map["status"] == 0) {
                  return AllNotificationDeleteResponse(
                      data: null, message: map["message"], status: 0);
                } else if (map["status"] == 401) {
                  return AllNotificationDeleteResponse(
                      data: null, message: map["message"], status: 401);
                } else {
                  AllNotificationDeleteResponse data =
                      AllNotificationDeleteResponse.fromJson(map);

                  return data;
                }
              } else {
                var map = json.decode(value.body);
                return AllNotificationDeleteResponse(
                    data: null,
                    message: map["message"] ?? "Something went wrong!",
                    status: 0,
                    apiStatusCode: value.statusCode);
              }
            } catch (e) {
              return AllNotificationDeleteResponse(
                  data: null, message: e.toString(), status: 0);
            }
          });
    } on SocketException {
      return AllNotificationDeleteResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return AllNotificationDeleteResponse(
          data: null, message: "Request time out", status: 0);
    }
  }

  ///StampVoucherList
  Future<StampVoucherResponseModel> getStampVoucherList() async {
    String accesstoken = prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING);
    try {
      return await http.Client()
          .post(
            Uri.parse("$baseUrl/api/user/stampVoucher/list"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "page": {"limit": 20, "pageId": 1},
              "search": "",
              "sortBy": {
                "direction": "ASC",
                "property": "loyaltyStampVoucherId"
              }
            }),
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        print('IM HERE');
        //
        try {
          print('MAPING ${value.body}');
          if (value.statusCode == 200) {
            var map = json.decode(value.body);

            if (map["status"] == 0) {
              return StampVoucherResponseModel(
                  data: null, message: map["message"], status: 0);
            } else if (map["status"] == 401) {
              return StampVoucherResponseModel(
                  data: null, message: map["message"], status: 401);
            } else {
              StampVoucherResponseModel data =
                  StampVoucherResponseModel.fromJson(map);

              return data;
            }
          } else {
            var map = json.decode(value.body);
            return StampVoucherResponseModel(
                data: null,
                message: map["message"] ?? "Something went wrong!",
                status: 0,
                apiStatusCode: value.statusCode);
          }
        } catch (e) {
          return StampVoucherResponseModel(
              data: null, message: e.toString(), status: 0);
        }
      });
    } on SocketException {
      return StampVoucherResponseModel(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return StampVoucherResponseModel(
          data: null, message: "Request time out", status: 0);
    }
  }

  ///Redeem Stamp
  Future<RedeemStampVoucherResponse> redeemStamp(int loyaltyStampVoucherId,
      int storeId, int userId, String voucherCode) async {
    String accesstoken = prefs.getString(SharedPrefHelper.ACCESS_TOKEN_STRING);
    try {
      return await http.Client()
          .post(
            Uri.parse("$baseUrl/api/user/stampVoucher/claimReward/"),
            headers: {
              "access-token": accesstoken,
              "Content-Type": "application/json",
            },
            body: jsonEncode(
              {
                "loyaltyStampVoucherId": loyaltyStampVoucherId,
                "storesId": storeId,
                "userId": userId,
                "voucherCode": voucherCode
              },
            ),
          )
          .timeout(const Duration(seconds: 60))
          .then((value) async {
        // print(value.body);

        try {
          if (value.statusCode == 200) {
            var map = json.decode(value.body);
            print(map);
            if (map["status"] == 0) {
              return RedeemStampVoucherResponse(
                  data: null, message: map["message"], status: 0);
            } else if (map["status"] == 401) {
              return RedeemStampVoucherResponse(
                  data: null, message: map["message"], status: 401);
            } else {
              RedeemStampVoucherResponse data =
                  RedeemStampVoucherResponse.fromJson(map);

              return data;
            }
          } else {
            var map = json.decode(value.body);
            return RedeemStampVoucherResponse(
              data: null,
              message: map["message"] ?? "Something went wrong!",
              status: 0,
            );
          }
        } catch (e) {
          return RedeemStampVoucherResponse(
              data: null, message: e.toString(), status: 0);
        }
      });
    } on SocketException {
      return RedeemStampVoucherResponse(
          data: null, message: "No Internet connection", status: 0);
    } on TimeoutException {
      return RedeemStampVoucherResponse(
          data: null, message: "Request time out", status: 0);
    }
  }
}
