import 'package:flutter/material.dart';
import 'package:greentill/utils/shared_pref_helper.dart';

class UserRepository {
  SharedPrefHelper prefs = SharedPrefHelper.instance;

  //dev
  // String baseUrl = "https://wearehere-api.apps.openxcell.dev";
  // String baseUrlHttps = "wearehere-api.apps.openxcell.dev";

  // local
  //  String baseUrl = "http://192.168.2.153:8451";
  //  String baseUrlHttps = "192.168.2.153:8451";

  // Live
  //  String baseUrl = "http://192.168.2.153:8451";
  //  String baseUrlHttps = "192.168.2.153:8451";

  UserRepository();

  static UserRepository getInstance() {
    return UserRepository();
  }

  Future<bool> isLoggedIn() async {
    return prefs.getBool(SharedPrefHelper.IS_LOGGED_IN_BOOL) ?? false;
  }

  // Future<LoginResponse> login(String email, String password, String fcmtoken) async {
  //   try {
  //     return await http.Client()
  //         .post(
  //       Uri.parse("$baseUrl/app/auth/login"),
  //       headers: {
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode(
  //         {
  //           "email": email,
  //           "password": password,
  //           "fcmToken" : fcmtoken
  //
  //         },
  //       ),
  //     )
  //         .timeout(const Duration(seconds: 60))
  //         .then((value) async {
  //       print("$baseUrl/app/auth/login");
  //       // print(value.body);
  //       print("email = " + email);
  //       print("password = " + password);
  //       print("fcmtoken = " + fcmtoken);
  //
  //       try {
  //         if (value.statusCode == 200) {
  //           var map = json.decode(value.body);
  //           print(map);
  //           if (map["status"] == 0) {
  //             return LoginResponse(
  //                 data: null, message: map["message"], status: 0);
  //           } else {
  //             LoginResponse data = LoginResponse.fromJson(map);
  //             prefs.putBool(SharedPrefHelper.IS_LOGGED_IN_BOOL, true);
  //             prefs.putBool(SharedPrefHelper.IS_ACCOUNT_CREATED_BOOL,
  //                 data.data.isAccountCreated);
  //             prefs.putString(
  //                 SharedPrefHelper.ACCESS_TOKEN_STRING, data.data.token);
  //             prefs.putString(SharedPrefHelper.USER_DATA, value.body);
  //
  //             // }
  //             return data;
  //           }
  //         } else {
  //           return LoginResponse(
  //               data: null, message: value.statusCode.toString(), status: 0);
  //         }
  //       } catch (e) {
  //         return LoginResponse(data: null, message: e.toString(), status: 0);
  //       }
  //     });
  //   } on SocketException {
  //     return LoginResponse(
  //         data: null, message: "No Internet connection", status: 0);
  //   } on TimeoutException {
  //     return LoginResponse(data: null, message: "Request time out", status: 0);
  //   }
  // }
  //
  // LoginResponse getUserData() {
  //   String data = prefs.getString(SharedPrefHelper.USER_DATA);
  //   var map = json.decode(data);
  //   LoginResponse model = LoginResponse.fromJson(map);
  //   return model;
  // }


}