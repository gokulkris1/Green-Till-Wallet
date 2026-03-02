import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:greentill/utils/strings.dart';
import 'package:greentill/utils/validations.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple_sign_in;

class LoginScreen extends BaseStatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseState<LoginScreen>
    with BasicScreen, InputValidationMixin {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscureText = true;
  bool _isSigningIn = false;

  FirebaseAuth? auth;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      auth = FirebaseAuth.instance;
    }
  }

  Future<void> startAppleLogin(BuildContext context) async {
    if (kIsWeb) {
      showMessage("Apple sign-in isn't available on web preview.", () {
        setState(() {
          isShowMessage = false;
        });
      });
      return;
    }
    debugPrint("clickonapple");
    var authData;
    try {
      if (!await apple_sign_in.TheAppleSignIn.isAvailable()) {
        debugPrint("Apple sign in not available");
        showMessage('Unable to login', () {
          setState(() {
            isShowMessage = false;
          });
        });
        // setState(() {
        //   _isLoadingApple = false;
        // });
        // showErrorAlert(context: context, message: "Apple sign in unavailable");
        return; //Break from the program
      }
      final apple_sign_in.AuthorizationResult result =
          await apple_sign_in.TheAppleSignIn.performRequests([
        apple_sign_in.AppleIdRequest(requestedScopes: [
          apple_sign_in.Scope.email,
          apple_sign_in.Scope.fullName
        ])
      ]);
      debugPrint("applepopupopenup");
      if (result.status == apple_sign_in.AuthorizationStatus.cancelled) {
        debugPrint(result.status.name);
        return;
      }

      if (result.error != null) {
        debugPrint("result.error" + result.error.toString());
        showMessage('Unable to login', () {
          setState(() {
            isShowMessage = false;
          });
        });
        return;
      }

      final authCode = result.credential?.authorizationCode;
      final identityToken = result.credential?.identityToken;
      if (authCode == null || identityToken == null) {
        showMessage("Unable to login", () {
          setState(() {
            isShowMessage = false;
          });
        });
        return;
      }
      final AuthCredential credential = OAuthProvider('apple.com').credential(
          accessToken: String.fromCharCodes(authCode),
          idToken: String.fromCharCodes(identityToken));

      await auth?.signInWithCredential(credential).then((authResult) async {
        setState(() {
          authData = authResult;
        });

        if (authData != null) {
          if (SharedPrefHelper.instance
              .getString(SharedPrefHelper.FIREBASE_TOKEN)
              .isEmpty) {
            if (kIsWeb) {
              SharedPrefHelper.instance
                  .putString(SharedPrefHelper.FIREBASE_TOKEN, "");
              return;
            }
            FirebaseMessaging.instance.getToken().then((value) async {
              SharedPrefHelper.instance
                  .putString(SharedPrefHelper.FIREBASE_TOKEN, value ?? "");
              if (SharedPrefHelper.instance
                  .getString(SharedPrefHelper.FIREBASE_TOKEN)
                  .isEmpty) {
                await showMessage("Login failed please try again later", () {
                  setState(() {
                    isShowMessage = false;
                  });
                });
              } else {
                changeLoadStatus();
                bloc.userRepository
                    .login(
                        email: authResult.user?.email ?? "",
                        fcmtoken: SharedPrefHelper.instance
                                .getString(SharedPrefHelper.FIREBASE_TOKEN) ??
                            "",
                        devicetype: kIsWeb
                            ? "web"
                            : (Platform.isIOS ? "ios" : "android"),
                        registertype: "Apple",
                        socialMediaId: authResult.user?.uid ?? "",
                        firstname: authResult.user?.displayName ?? "")
                    .then((value) {
                  changeLoadStatus();
                  if (value.status == 1) {
                    print("user logged in");
                    // showMessage(value.message ?? "", () {
                    // setState(() {
                    // isShowMessage = false;
                    bloc.add(HomeScreenEvent());
                    // });
                    // });
                  } else {
                    print(value.message);
                    showMessage(value.message ?? "", () {
                      setState(() {
                        isShowMessage = false;
                      });
                    });
                  }
                });
              }
            });
          } else {
            changeLoadStatus();
            bloc.userRepository
                .login(
                    email: authResult.user?.email ?? "",
                    fcmtoken: SharedPrefHelper.instance
                            .getString(SharedPrefHelper.FIREBASE_TOKEN) ??
                        "",
                    devicetype:
                        kIsWeb ? "web" : (Platform.isIOS ? "ios" : "android"),
                    registertype: "Apple",
                    socialMediaId: authResult.user?.uid ?? "",
                    firstname: authResult.user?.displayName ?? "")
                .then((value) {
              changeLoadStatus();
              if (value.status == 1) {
                print("user logged in");
                // showMessage(value.message ?? "", () {
                // setState(() {
                // isShowMessage = false;
                bloc.add(HomeScreenEvent());
                // });
                // });
              } else {
                print(value.message);
                showMessage(value.message ?? "", () {
                  setState(() {
                    isShowMessage = false;
                  });
                });
              }
            });
          }
          // Navigator.pushReplacement(
          //     context, MaterialPageRoute(builder: (context) => SignUpScreen()));

          // Navigator.pushReplacement(
          //     context, MaterialPageRoute(builder: (context) => SignUpScreen()));
        } else {
          print("logindata null");
          showMessage('Unable to login auth data null', () {
            setState(() {
              isShowMessage = false;
            });
          });
        }
        // if (await userExists(authData.user.email)) {
        //   _saveUserDataToSharedPreferences();
        //   SharedPreferencesMethods.saveUserLoggedInSharedPreference(true);
        //   Navigator.pushReplacement(context,
        //       MaterialPageRoute(builder: (context) => SelectInterestsPage(0)));
        //   // _loginWithApple();
        // } else {
        //   Navigator.of(context)
        //       .push(MaterialPageRoute(
        //       builder: (context) => SetUpAccountWithApple(
        //         uid: authData.user.uid,
        //         appleEmailId: authData.user.email,
        //       )))
        //       .then((value) {
        //     setState(() {
        //       _isLoadingApple = false;
        //     });
        //   });
        // }
      });
    } catch (error) {
      showMessage('Unable to login' + error.toString(), () {
        setState(() {
          isShowMessage = false;
        });
      });
      // setState(() {
      //   _isLoadingApple = false;
      // });
      // print(error);
      // ErrorHandler()
      //     .showErrorDialog(context, 'Unable to login', error.toString());
      // showErrorAlert(context: context, message: error.toString());
      return null;
    }
  }

  // Future<void> signupapple(BuildContext context) async {
  //   final credential = await SignInWithApple.getAppleIDCredential(
  //     scopes: [
  //       AppleIDAuthorizationScopes.email,
  //       AppleIDAuthorizationScopes.fullName,
  //     ],
  //     // webAuthenticationOptions: WebAuthenticationOptions(
  //     //   // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
  //     //   clientId:
  //     //   'de.lunaone.flutter.signinwithappleexample.service',
  //     //
  //     //   redirectUri:
  //     //   // For web your redirect URI needs to be the host of the "current page",
  //     //   // while for Android you will be using the API server that redirects back into your app via a deep link
  //     //   kIsWeb
  //     //       ? Uri.parse('https://${window.location.host}/')
  //     //       : Uri.parse(
  //     //     'https://flutter-sign-in-with-apple-example.glitch.me/callbacks/sign_in_with_apple',
  //     //   ),
  //     // ),
  //     // TODO: Remove these if you have no need for them
  //     nonce: 'example-nonce',
  //     state: 'example-state',
  //   );
  //
  //   print(credential);
  //
  //   // This is the endpoint that will convert an authorization code obtained
  //   // via Sign in with Apple into a session in your system
  //   final signInWithAppleEndpoint = Uri(
  //     scheme: 'https',
  //     host: 'flutter-sign-in-with-apple-example.glitch.me',
  //     path: '/sign_in_with_apple',
  //     queryParameters: <String, String>{
  //       'code': credential.authorizationCode,
  //       if (credential.givenName != null)
  //         'firstName': credential.givenName,
  //       if (credential.familyName != null)
  //         'lastName': credential.familyName,
  //       'useBundleId':
  //       !kIsWeb && (Platform.isIOS || Platform.isMacOS)
  //           ? 'true'
  //           : 'false',
  //       if (credential.state != null) 'state': credential.state,
  //     },
  //   );
  //   final session = await http.Client().post(
  //     signInWithAppleEndpoint,
  //   );
  //   print(session);
  // }

  Future<void> signup(BuildContext context) async {
    if (kIsWeb) {
      showMessage("Google sign-in isn't available on web preview.", () {
        setState(() {
          isShowMessage = false;
        });
      });
      return;
    }
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount == null) {
      return;
    }
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
    );

    // Getting users credential
    UserCredential result = await auth!.signInWithCredential(authCredential);
    final User? user = result.user;
    if (user == null) {
      showMessage("Login failed please try again later", () {
        setState(() {
          isShowMessage = false;
        });
      });
      return;
    }
    print("udid:");
    print(user.uid);
    // print("userdetails"+user.uid);
    // print("userdetails"+user.email);
    // print("userdetails"+user.displayName);
    if (SharedPrefHelper.instance
        .getString(SharedPrefHelper.FIREBASE_TOKEN)
        .isEmpty) {
      if (kIsWeb) {
        SharedPrefHelper.instance
            .putString(SharedPrefHelper.FIREBASE_TOKEN, "");
        return;
      }
      FirebaseMessaging.instance.getToken().then((value) async {
        SharedPrefHelper.instance
            .putString(SharedPrefHelper.FIREBASE_TOKEN, value ?? "");
        if (SharedPrefHelper.instance
            .getString(SharedPrefHelper.FIREBASE_TOKEN)
            .isEmpty) {
          await showMessage("Login failed please try again later", () {
            setState(() {
              isShowMessage = false;
            });
          });
        } else {
          changeLoadStatus();
          print("udid:");
          print(user.uid);
          bloc.userRepository
              .login(
                  email: user.email ?? "",
                  fcmtoken: SharedPrefHelper.instance
                          .getString(SharedPrefHelper.FIREBASE_TOKEN) ??
                      "",
                  devicetype:
                      kIsWeb ? "web" : (Platform.isIOS ? "ios" : "android"),
                  registertype: "Google",
                  socialMediaId: user.uid,
                  firstname: user.displayName ?? "")
              .then((value) {
            changeLoadStatus();
            if (value.status == 1) {
              print("user logged in");
              // showMessage(value.message ?? "", () {
              // setState(() {
              // isShowMessage = false;
              // value.data.country == null || value.data.country == ""?bloc.add(EditProfile()):
              bloc.add(HomeScreenEvent());
              // });
              // });
            } else {
              print(value.message);
              showMessage(value.message ?? "", () async {
                await googleSignIn.disconnect();

                setState(() {
                  isShowMessage = false;
                });
              });
            }
          });
        }
      });
    } else {
      print("udid:");
      print(user.uid);
      changeLoadStatus();
      bloc.userRepository
          .login(
              email: user.email ?? "",
              fcmtoken: SharedPrefHelper.instance
                      .getString(SharedPrefHelper.FIREBASE_TOKEN) ??
                  "",
              devicetype: kIsWeb ? "web" : (Platform.isIOS ? "ios" : "android"),
              registertype: "Google",
              socialMediaId: user.uid,
              firstname: user.displayName ?? "")
          .then((value) {
        changeLoadStatus();
        if (value.status == 1) {
          print("user logged in");
          // showMessage(value.message ?? "", () {
          // setState(() {
          // isShowMessage = false;
          // bloc.add(HomeScreenEvent());
          // value.data.country == null || value.data.country == ""?bloc.add(EditProfile()):
          bloc.add(HomeScreenEvent());
          // });
          // });
        } else {
          print(value.message);
          showMessage(value.message ?? "", () async {
            await googleSignIn.disconnect();
            setState(() {
              isShowMessage = false;
            });
          });
        }
      });
    }
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => SignUpScreen()));
    // if result not null we simply call the MaterialpageRoute,
    // for go to the HomePage screen
  }

  String _deviceType() {
    if (kIsWeb) {
      return "web";
    }
    return Platform.isIOS ? "ios" : "android";
  }

  Future<String> _resolveFcmToken() async {
    String token =
        SharedPrefHelper.instance.getString(SharedPrefHelper.FIREBASE_TOKEN);
    if (token.isNotEmpty || kIsWeb) {
      return token;
    }
    try {
      token = await FirebaseMessaging.instance.getToken() ?? "";
    } catch (_) {
      token = "";
    }
    SharedPrefHelper.instance.putString(SharedPrefHelper.FIREBASE_TOKEN, token);
    return token;
  }

  Future<void> _handleEmailSignIn() async {
    if (_isSigningIn) {
      return;
    }
    if (mounted) {
      setState(() {
        _isSigningIn = true;
      });
    }
    final fcmToken = await _resolveFcmToken();
    changeLoadStatus();
    try {
      final value = await bloc.userRepository.login(
        email: _email.text.trim(),
        password: _password.text.trim(),
        fcmtoken: fcmToken,
        devicetype: _deviceType(),
        registertype: "Normal",
      );
      if (!mounted) {
        return;
      }
      if (value.status == 1) {
        bloc.add(HomeScreenEvent());
      } else {
        showMessage(value.message ?? "", () {
          if (mounted) {
            setState(() {
              isShowMessage = false;
            });
          }
        });
      }
    } finally {
      changeLoadStatus();
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final formGlobalKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorWhite,
      body: GestureDetector(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: formGlobalKey,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: HORIZONTAL_PADDING,
                      vertical: VERTICAL_PADDING),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                child: Image.asset(
                              IC_GREENTILL_IMAGE,
                              height: deviceHeight * 0.15,
                              width: deviceWidth * 0.35,
                            )),
                            const SizedBox(
                              height: 15,
                            ),
                            getTitle(WelcomeLogin,
                                bold: true,
                                fontSize: TITLE_TEXT_FONT_SIZE,
                                weight: FontWeight.w800),
                            const SizedBox(
                              height: 20,
                            ),
                            getSmallText(LoginContent,
                                weight: FontWeight.w400,
                                align: TextAlign.center,
                                fontSize: SUBTITLE_FONT_SIZE),
                            const SizedBox(
                              height: 30,
                            ),
                            SizedBox(
                              width: deviceWidth * 0.8,
                              child: getCommonTextFormField(
                                context: context,
                                controller: _email,
                                hintText: Email,
                                validator: (email) {
                                  if (isEmailValid(email?.trim() ?? ""))
                                    return null;
                                  else
                                    return 'Please enter a valid email address';
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: deviceWidth * 0.8,
                              child: getCommonTextFormField(
                                context: context,
                                controller: _password,
                                obscureText: _obscureText,
                                validator: (password) {
                                  if (isPasswordValid(password?.trim() ?? ""))
                                    return null;
                                  else
                                    return 'Please enter a valid password';
                                },
                                suffixIcon: InkWell(
                                    onTap: () {
                                      _toggle();
                                    },
                                    child: _obscureText == true
                                        ? Image.asset(IC_PASSWORD_HIDE)
                                        : Image.asset(IC_PASSWORD_SHOW)),
                                hintText: Password,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                                width: deviceWidth * 0.8,
                                child: GestureDetector(
                                    onTap: () {
                                      return bloc.add(ForgotPassword());
                                    },
                                    child: getSmallText(ForgetPasswordcontent,
                                        weight: FontWeight.w400,
                                        fontSize: SUBTITLE_FONT_SIZE,
                                        align: TextAlign.end))),
                            const SizedBox(
                              height: 20,
                            ),
                            getButton(_isSigningIn ? "Signing in..." : Signin,
                                () {
                              if (formGlobalKey.currentState?.validate() ??
                                  false) {
                                _handleEmailSignIn();
                              }
                            },
                                width: deviceWidth * 0.8,
                                fontsize: BUTTON_FONT_SIZE),
                            const SizedBox(
                              height: 25,
                            ),
                            SizedBox(
                                width: deviceWidth * 0.8,
                                child: getSmallText(orloginwith,
                                    weight: FontWeight.w400,
                                    fontSize: SUBTITLE_FONT_SIZE,
                                    align: TextAlign.center)),
                            const SizedBox(
                              height: 25,
                            ),
                            SizedBox(
                              width: deviceWidth * 0.8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (Platform.isIOS)
                                    SocialLoginButton(IC_APPLE, () {
                                      startAppleLogin(context);
                                    }),
                                  if (Platform.isIOS)
                                    const SizedBox(
                                      width: 15,
                                    ),
                                  SocialLoginButton(IC_GOOGLE, () {
                                    signup(context);
                                  })
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Spacer(),
                        Container(
                          margin: EdgeInsets.only(bottom: deviceHeight * 0.002),
                          child: Padding(
                            padding:
                                EdgeInsets.only(bottom: deviceHeight * 0.06),
                            child: SizedBox(
                              width: deviceWidth * 0.8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  getSmallText(
                                    Didnothaveaccount,
                                    color: colorAccentLight,
                                    fontSize: FORGET_PASSWORD_TEXT_FONT_SIZE,
                                    weight: FontWeight.w400,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        return bloc.add(SignUp());
                                      },
                                      child: getTitle(
                                        Signup,
                                        weight: FontWeight.w800,
                                        color: colorBlack,
                                        fontSize: SUBTITLE_FONT_SIZE,
                                        bold: true,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
