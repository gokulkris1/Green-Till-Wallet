// import 'package:country_code_picker/country_code_picker.dart';
import 'dart:io';

import 'package:currency_picker/currency_picker.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/models/signup_model.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/ui/screens/signup/terms_and_conditions_signup.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/image_upload_bottomsheet.dart';
import 'package:greentill/utils/strings.dart';
import 'package:greentill/utils/validations.dart';

class SignUpScreen extends BaseStatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends BaseState<SignUpScreen>
    with BasicScreen, InputValidationMixin {
  final TextEditingController _firstname = TextEditingController();
  final TextEditingController _lastname = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmpassword = TextEditingController();
  final TextEditingController _mobilenumber = TextEditingController();
  bool _value = false;
  final countryPicker = const FlCountryCodePicker();
  CountryCode? countryCode;
  File? selectedImageFile;
  Image _profileImage = Image.asset(IC_SELECT_PROFILE);
  final formGlobalKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _obscureTextconfirm = true;
  Currency? selectedCurrency;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final countryTextController = TextEditingController();
  final currencyTextController = TextEditingController();

  @override
  void dispose() {
    countryTextController.dispose();
    currencyTextController.dispose();
    _firstname.dispose();
    _lastname.dispose();
    _email.dispose();
    _confirmpassword.dispose();
    _password.dispose();
    _mobilenumber.dispose();

    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorWhite,
      appBar: AppBar(
        backgroundColor: colorWhite,
        elevation: 0,
        // title: appBarHeader(forgotPassword,bold: true,weight: FontWeight.w800),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_outlined, color: Colors.black),
          onPressed: () => bloc.add(Login()),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: formGlobalKey,
          child: Container(
            height: deviceHeight,
            width: deviceWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: HORIZONTAL_PADDING, vertical: VERTICAL_PADDING),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                    SizedBox(
                      width: deviceWidth * 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          getSmallText(SignupHeading,
                              bold: true,
                              fontSize: TITLE_TEXT_FONT_SIZE,
                              weight: FontWeight.w400,
                              color: colorBlack),
                          getTitle(
                            Signup,
                            bold: true,
                            fontSize: TITLE_TEXT_FONT_SIZE,
                            weight: FontWeight.w800,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    getSmallText(Signupcontent,
                        weight: FontWeight.w400,
                        align: TextAlign.center,
                        fontSize: SUBTITLE_FONT_SIZE),
                    const SizedBox(
                      height: 30,
                    ),
                    // Container(
                    //     child: Image.asset(
                    //       _profileImage,
                    //       height: deviceHeight * 0.12,
                    //       width: deviceWidth * 0.25,
                    //       fit: BoxFit.fill,
                    //     )),
                    Center(
                      child: InkWell(
                        onTap: () {
                          onProfileImageClicked();
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: _profileImage.image,
                          radius: 55,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    getSmallText(profilePicture,
                        weight: FontWeight.w400,
                        align: TextAlign.center,
                        fontSize: SUBTITLE_FONT_SIZE),
                    const SizedBox(
                      height: 25,
                    ),

                    SizedBox(
                      width: deviceWidth * 0.8,
                      child: getCommonTextFormField(
                          context: context,
                          controller: _firstname,
                          hintText: Firstname,
                          validator: (text) {
                            final value = text?.trim() ?? "";
                            if (value.isEmpty) {
                              return "Please enter first name";
                            }
                            return null;
                          }),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: deviceWidth * 0.8,
                      child: getCommonTextFormField(
                          context: context,
                          controller: _lastname,
                          hintText: Lastname,
                          validator: (text) {
                            final value = text?.trim() ?? "";
                            if (value.isEmpty) {
                              return "Please enter last name";
                            }
                            return null;
                          }),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: deviceWidth * 0.8,
                      child: getCommonTextFormField(
                        context: context,
                        controller: _email,
                        hintText: Email,
                        validator: (email) {
                          final value = email?.trim() ?? "";
                          if (isEmailValid(value)) {
                            return null;
                          }
                          return 'Please enter a valid email address';
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: deviceWidth * 0.8,
                      child: getCommonTextFormField(
                        context: context,
                        controller: _password,
                        hintText: Password,
                        obscureText: _obscureText,
                        validator: (password) {
                          final value = password?.trim() ?? "";
                          if (isPasswordValid(value)) {
                            return null;
                          }
                          return 'Please enter a valid password';
                        },
                        suffixIcon: InkWell(
                            onTap: () {
                              _toggle();
                            },
                            child: _obscureText == true
                                ? Image.asset(IC_PASSWORD_HIDE)
                                : Image.asset(IC_PASSWORD_SHOW)),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: deviceWidth * 0.8,
                      child: getCommonTextFormField(
                        context: context,
                        controller: _confirmpassword,
                        obscureText: _obscureTextconfirm,
                        hintText: Confirmpassword,
                        validator: (password) {
                          final value = password?.trim() ?? "";
                          if (value == _password.text.trim()) {
                            return null;
                          }
                          return 'Password does not match';
                        },
                        suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                _obscureTextconfirm = !_obscureTextconfirm;
                              });
                            },
                            child: _obscureTextconfirm == true
                                ? Image.asset(IC_PASSWORD_HIDE)
                                : Image.asset(IC_PASSWORD_SHOW)),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: deviceWidth * 0.8,
                      child: getCountryTextFormField(
                        controller: countryTextController,
                        readOnly: true,
                        onTap: () async {
                          final code = await countryPicker.showPicker(
                            context: context,
                            pickerMaxHeight: deviceHeight * 0.8,
                            // scrollToDeviceLocale: true,
                          );
                          if (code != null) {
                            setState(() => countryCode = code);
                            countryTextController.text = code.name;
                            print("phonecode" + code.dialCode.toString());
                          }
                        },
                        validator: (text) {
                          final value = text?.trim() ?? "";
                          if (value.isEmpty) {
                            return "Please select country";
                          }
                          print("Selected country is=" + value);
                          return null;
                        },
                        prefixIcon: ClipOval(
                          clipper: MyClipper(),
                          child: Transform.scale(
                            child: countryCode?.flagImage() ?? const SizedBox.shrink(),
                            // scale: 0.5,
                            scaleX: 0.5,
                            // scaleY: 0.5,
                            alignment: Alignment.center,
                            // origin: Offset(0,0),
                          ),
                        ),
                        suffixIcon: Image.asset(
                          IC_ARROW_DOWN,
                          width: 20,
                          height: 20,
                        ),
                        context: context,
                        hintText: countryCode?.name ?? Selectcountry,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: deviceWidth * 0.8,
                      child: getCommonTextFormField(
                        context: context,
                        controller: _mobilenumber,
                        hintText: Mobilenumber,
                        validator: (text) {
                          final value = text?.trim() ?? "";
                          if (value.isEmpty) {
                            return "Please enter mobile number";
                          } else if (value.length < 7) {
                            return "Mobile number should be at least of 7 digits";
                          } else if (value.length > 15) {
                            return "Mobile number should be less than 15 digits";
                          }
                          else {
                            return null;
                          }
                        },
                        prefixIcon: ClipOval(
                          clipper: MyClipper(),
                          child: Transform.scale(
                            child: countryCode?.flagImage() ?? const SizedBox.shrink(),
                            // scale: 0.5,
                            scaleX: 0.5,
                            // scaleY: 0.5,
                            alignment: Alignment.center,

                            // origin: Offset(0,0),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: deviceWidth * 0.8,
                      child: getCurrencyTextFormField(
                        controller: currencyTextController,
                        validator: (text) {
                          final value = text?.trim() ?? "";
                          if (value.isEmpty) {
                            return "Please select currency";
                          } else {
                            print("Selected currency is=" + value);
                            return null;
                          }
                        },
                        readOnly: true,
                        onTap: () {
                          showCurrencyPicker(
                            context: context,
                            showFlag: true,
                            showCurrencyName: true,
                            showCurrencyCode: true,
                            onSelect: (Currency currency) {
                              selectedCurrency = currency;
                              setState(() =>
                                  currencyTextController.text = currency.code);
                              // "${selectedCurrency.symbol}  ${selectedCurrency.name}");
                              ;
                                                        },
                          );
                        },
                        suffixIcon: Image.asset(
                          IC_ARROW_DOWN,
                          width: 20,
                          height: 20,
                        ),
                        context: context,
                        hintText:
                            "${selectedCurrency?.symbol ?? ""}  ${selectedCurrency?.code ?? ""}",
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: deviceWidth * 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 1,
                          ),
                          Center(
                              child: InkWell(
                            onTap: () {
                              setState(() {
                                _value = !_value;
                              });
                            },
                            child: Container(
                              height: 22,
                              width: 22,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: colortheme),
                              child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: _value
                                    ? const Icon(
                                        Icons.check,
                                        size: 16.0,
                                        color: Colors.white,
                                      )
                                    : Container(
                                        height: 22,
                                        width: 22,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: colorBackgroundInput),
                                      ),
                              ),
                            ),
                          )),
                          SizedBox(
                            width: 12,
                          ),
                          Row(
                            children: [
                              getSmallText(
                                AgreeToThe,
                                color: colorAccentLight,
                                fontSize: FORGET_PASSWORD_TEXT_FONT_SIZE,
                                weight: FontWeight.w400,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context){
                                    return TermsAndConditionsSignupScreen();
                                  }));
                                  // return bloc.add(TermsandConditionsSignupEvent());
                                },
                                child: getTitle(
                                  TermsAndConditions,
                                  color: colorBlack,
                                  weight: FontWeight.w800,
                                  fontSize: SUBTITLE_FONT_SIZE,
                                  bold: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    getButton(Signup, () async {
                      if ((formGlobalKey.currentState?.validate() ?? false) && _value) {
                        if (selectedImageFile != null) {
                          selectedImageFile =
                              await convertHEIC2PNG(selectedImageFile!.path);
                        }
                        changeLoadStatus();
                        bloc.userRepository
                            .signup(SignupModel(
                                profilePhoto: selectedImageFile,
                                firstName: _firstname.text.trim(),
                                lastName: _lastname.text.trim(),
                                email: _email.text.trim(),
                                password: _password.text.trim(),
                                confirmpassword: _confirmpassword.text.trim(),
                                countrycode:
                                    (countryCode?.dialCode ?? "").trim(),
                                country: countryTextController.text
                                    .trim()
                                    .toString(),
                                mobileNumber: _mobilenumber.text.trim(),
                                currency: currencyTextController.text.trim(),
                                termsandconditions: _value,
                            countryAbbreviate:
                                (countryCode?.code ?? "").trim()
                        ))
                            .then((value) {
                          changeLoadStatus();
                          if (value.status == 1) {
                            print("sign up successful");
                            showMessage(value.message ?? "", () {
                              setState(() {
                                bloc.add(EmailVerification());
                                isShowMessage = false;
                              });
                            });
                          } else {
                            print("sign up failed");
                            print(value.message);
                            showMessage(value.message ?? "", () {
                              setState(() {
                                // bloc.add(WelcomeIn());
                                isShowMessage = false;
                              });
                            });
                          }
                        });

                        //return bloc.add(EmailVerification());
                        } else if ((formGlobalKey.currentState?.validate() ?? false) && !_value) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: getSmallText(
                              "Please agree to the terms and conditions"),
                        ));
                      }
                    }, width: deviceWidth * 0.8, fontsize: BUTTON_FONT_SIZE),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: deviceWidth * 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          getSmallText(
                            alreadyHaveAccount,
                            color: colorAccentLight,
                            fontSize: FORGET_PASSWORD_TEXT_FONT_SIZE,
                            weight: FontWeight.w400,
                          ),
                          GestureDetector(
                              onTap: () {
                                return bloc.add(Login());
                              },
                              child: getTitle(
                                Signin,
                                weight: FontWeight.w800,
                                color: colorBlack,
                                fontSize: SUBTITLE_FONT_SIZE,
                                bold: true,
                              )),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onProfileImageClicked() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return Container(
          color: Colors.white,
          child: ImageUploadOptionsBottomSheet(onImageSelected: (image) {
            setState(() {
              selectedImageFile = image;
              _profileImage = Image.file(image);
            });
          }),
        );
      },
      isDismissible: true,
      elevation: 2,
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromCircle(center: Offset(23.5, 23.5), radius: 9);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }
}
