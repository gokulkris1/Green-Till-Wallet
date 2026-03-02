import 'dart:io';

import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:greentill/utils/strings.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/ui/res/dimen_resources.dart';

import 'package:greentill/utils/validations.dart';
import 'package:greentill/utils/image_upload_bottomsheet.dart';
import '../signup/signup_screen.dart';
import 'package:currency_picker/currency_picker.dart';

class EditProfileScreen extends BaseStatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends BaseState<EditProfileScreen>
    with BasicScreen, InputValidationMixin {
  String userid = prefs.getString(SharedPrefHelper.USER_ID) ?? "0";

  final TextEditingController _firstname = TextEditingController();
  final TextEditingController _lastname = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _mobilenumber = TextEditingController();
  bool _value = false;
  final countryPicker = const FlCountryCodePicker();
  CountryCode? countryCode;
  Currency? selectedCurrency;
  File? selectedImageFile;
  Image _profileImage = Image.asset(IC_SELECT_PROFILE);
  final formGlobalKey = GlobalKey<FormState>();
  bool isFirst = true;
  bool isLoadingLocal = true;
  final countryTextController = TextEditingController();
  final currencyTextController = TextEditingController();
  String? countryCodeExisting;
  String? countryFlagExisting;

  Future getCountryCode() async {
    // print("bloc.userData.country=");
    // print(bloc.userData.country);
    countryTextController.text = bloc.userData?.country ?? "";
    currencyTextController.text = bloc.userData?.currency ?? "";
    print(bloc.userData?.countryAbbreviate ?? "");
    print("countrycode" + (bloc.userData?.countryAbbreviate ?? ""));
    final value = CountryCode.fromCode(bloc.userData?.countryAbbreviate ?? "");
    print("newcoutrycode");
    print(value?.dialCode ?? "");
    countryCodeExisting = value?.dialCode;
    countryFlagExisting = value?.code;

    setState(() {
      isLoadingLocal = false;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget buildBody(BuildContext context) {
    if (isFirst) {
      isFirst = false;
      print("blocdata");
      // getprofile();
      // print(bloc.userData?.toJson());
      _firstname.text = (bloc.userData?.firstName ?? "").toString();
      _lastname.text = bloc.userData?.lastName ?? "";
      _email.text = bloc.userData?.email ?? "";
      _mobilenumber.text = bloc.userData?.phoneNumber ?? "";
      //RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(bloc.userData.countryCode)
      if ((bloc.userData?.countryAbbreviate ?? "").isNotEmpty)
        {
          getCountryCode();
        }else{
        setState(() {
          isLoadingLocal = false;
        });
      }

      _profileImage = bloc.userData?.profileImage == null
          ? Image.asset(IC_SELECT_PROFILE)
          : Image.network(
              bloc.userData?.profileImage ?? "",
              fit: BoxFit.fill,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                final expected = loadingProgress.expectedTotalBytes;
                return Center(
                  child: CircularProgressIndicator(
                    value: expected != null
                        ? loadingProgress.cumulativeBytesLoaded / expected
                        : null,
                  ),
                );
              },
            );
    }
    return isLoadingLocal
        ? loader()
        : Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: colorWhite,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(deviceHeight * 0.07),
              child: Container(
                height: deviceHeight * 0.07,
                width: deviceWidth,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15)),
                  color: Colors.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 30.0,
                        offset: Offset(0.0, 0.05))
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: HORIZONTAL_PADDING,
                      vertical: VERTICAL_PADDING),
                  child: Row(
                    children: [
                      GestureDetector(
                        child: Image.asset(
                          IC_BACK_ARROW_TWO_COLOR,
                          height: 24,
                          width: 24,
                          fit: BoxFit.fill,
                        ),
                        onTap: () {
                          return bloc.add(SideMenu());
                        },
                      ),
                      SizedBox(
                        width: deviceWidth * 0.025,
                      ),
                      Expanded(
                        child: appBarHeader(
                          editProfile,
                          fontSize: BUTTON_FONT_SIZE,
                          bold: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // appBar: AppBar(
            //   shape: const RoundedRectangleBorder(
            //     borderRadius: BorderRadius.vertical(
            //       bottom: Radius.circular(15),
            //     ),
            //   ),
            //   shadowColor: Colors.grey.withOpacity(0.2),
            //   elevation: 2,
            //   backgroundColor: colorWhite,
            //   title: appBarHeader(
            //     editProfile,
            //     bold: false,
            //   ),
            //   centerTitle: true,
            //   leading: GestureDetector(
            //     child: Image.asset(IC_BACK_ARROW_TWO_COLOR),
            //     onTap: () {
            //       return bloc.add(SideMenu());
            //
            //     },
            //   ),
            // ),
            body: SafeArea(
              child: Form(
                key: formGlobalKey,
                child: Container(
                  height: deviceHeight,
                  width: deviceWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: HORIZONTAL_PADDING,
                        vertical: VERTICAL_PADDING),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 30,
                          ), 
                          Center(
                            child: InkWell(
                              onTap: () {
                                onProfileImageClicked();
                              },
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    backgroundImage: _profileImage.image ??
                                        AssetImage(IC_SELECT_PROFILE),
                                    // backgroundImage: AssetImage(IC_RECEIPT),
                                    radius: 55,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 2),
                                    child: Image.asset(
                                      IC_CAMERA,
                                      height: deviceHeight * 0.045,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: deviceHeight * 0.1,
                          ),
                          SizedBox(
                            width: deviceWidth * 0.8,
                            child: getCommonTextFormField(
                                context: context,
                                controller: _firstname,
                                hintText: Firstname,
                                validator: (text) {
                                  if ((text?.trim() ?? "").isEmpty) {
                                    return "Please enter first name";
                                  } else {
                                    return null;
                                  }
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
                                  if ((text?.trim() ?? "").isEmpty) {
                                    return "Please enter last name";
                                  } else {
                                    return null;
                                  }
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
                              readOnly: true,
                              hintText: Email,
                              validator: (email) {
                                if (isEmailValid(email?.trim() ?? ""))
                                  return null;
                                else
                                  return 'Please Enter a valid email address';
                              },
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
                              validator: (text) {
                                if ((text?.trim() ?? "").isEmpty) {
                                  return "Please select country";
                                } else {
                                  print("Selected country is=" + (text ?? ""));
                                  return null;
                                }
                              },
                              onTap: () async {
                                if (bloc.userData?.country == null ||
                                    bloc.userData?.country == "") {
                                  final code = await countryPicker.showPicker(
                                    context: context,
                                    pickerMaxHeight: deviceHeight * 0.8,
                                    // scrollToDeviceLocale: true,
                                  );
                                  if (code != null) {
                                    setState(() => countryCode = code);
                                    countryTextController.text = code.name;
                                  }
                                }else{
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
                              validator: (text) {
                                final trimmed = text?.trim() ?? "";
                                if (trimmed.isEmpty) {
                                  return "Please enter mobile number";
                                } else if (trimmed.length < 7){
                                  return "Mobile number should be at least of 7 digits";
                                } else if (trimmed.length > 15){
                                  return "Mobile number should be less than 15 digits";
                                }
                                else {
                                  return null;
                                }
                              },
                              hintText: Mobilenumber,
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
                              readOnly: true,
                              controller: currencyTextController,
                              validator: (text) {
                                if ((text?.trim() ?? "").isEmpty) {
                                  return "Please select currency";
                                } else {
                                  print("Selected currency is=" + (text ?? ""));
                                  return null;
                                }
                              },
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
                          getButton(Save, () async{
                            print("countryCodeExisting=");
                            // print(countryCode.code.trim().toString());
                            // print(countryCodeExisting);
                            if (selectedImageFile != null) {
                              selectedImageFile =
                                  await convertHEIC2PNG(selectedImageFile!.path);
                            }
                            if (formGlobalKey.currentState?.validate() ??
                                false) {
                              changeLoadStatus();
                              bloc.userRepository
                                  .editProfile(
                                userid: int.parse(userid),
                                country: countryTextController.text
                                    .trim()
                                    .toString(),
                                countrycode:
                                    (countryCode?.dialCode ?? countryCodeExisting ?? "").trim(),
                                phonenumber: _mobilenumber.text.trim(),
                                currency: currencyTextController.text.trim(),
                                firstname: _firstname.text.trim(),
                                lastname: _lastname.text.trim(),
                                profilePhoto: selectedImageFile,
                                countryAbbreviate:
                                    (countryCode?.code ??
                                            bloc.userData?.countryAbbreviate ??
                                            "")
                                        .trim(),

                              )
                                  .then((value) {
                                changeLoadStatus();
                                if (value.status == 1) {
                                  print("edit profile successful");
                                  // bloc.userRepository
                                  //     .getprofile(
                                  //   userid: int.parse(userid),
                                  // )
                                  //     .then((value) {
                                  //   if (value.status == 1) {
                                  //     return bloc.add(HomeScreenEvent());
                                  //     // showMessage(value.message ?? "", () {
                                  //     //   setState(() {
                                  //     //     isShowMessage = false;
                                  //     //     bloc.add(Home
                                  //     //   });
                                  //     // });
                                  //   } else if (value.status == 401) {
                                  //     print(value.message);
                                  //     showMessage(value.message ?? "", () {
                                  //       setState(() {
                                  //         isShowMessage = false;
                                  //         logoutaccount();
                                  //         return bloc.add(Login());
                                  //       });
                                  //     });
                                  //   } else {
                                  //     showMessage(value.message ?? "", () {
                                  //       setState(() {
                                  //         isShowMessage = false;
                                  //       });
                                  //     });
                                  //   }
                                  // });
                                  // bloc.init();
                                  return bloc.add(HomeScreenEvent());
                                  // showMessage(value.message ?? "", () {
                                  //   setState(() {
                                  //     bloc.add(HomeScreenEvent());
                                  //     isShowMessage = false;
                                  //   });
                                  // });
                                } else if (value.apiStatusCode == 401) {
                                  showMessage(value.message ?? "", () {
                                    setState(() {
                                      isShowMessage = false;
                                      logoutaccount();
                                      return bloc.add(Login());
                                    });
                                  });
                                } else {
                                  print("edit profile failed ");
                                  print(value.message);
                                  showMessage(value.message ?? "", () {
                                    setState(() {
                                      // bloc.add(WelcomeIn());
                                      isShowMessage = false;
                                    });
                                  });
                                }
                              });
                              // return bloc.add(HomeScreenEvent());
                            }
                          },
                              width: deviceWidth * 0.8,
                              fontsize: BUTTON_FONT_SIZE),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );
  }

  getprofile() async {
    await bloc.userRepository
        .getprofile(userid: int.parse(userid))
        .then((value) {
      if (value.status == 1) {
        bloc.init();
        // if (mounted)
        //   setState(() {
        //     isLoadingLocal = false;
        //   });
      } else if (value.apiStatusCode == 401) {
        print(value.message);
        showMessage(value.message ?? "", () {
          setState(() {
            isShowMessage = false;
            logoutaccount();
            isLoadingLocal = false;
            return bloc.add(Login());
          });
        });
      } else {
        print("value.status");
        print(value.status);
        showMessage(value.message ?? "", () {
          if(mounted)
            setState(() {
              isShowMessage = false;
              isLoadingLocal = false;
              //getprofile();
            });
        });
      }
    });
  }

}
