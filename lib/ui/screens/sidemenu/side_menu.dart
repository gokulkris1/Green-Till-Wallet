import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:greentill/utils/strings.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SideMenuScreen extends BaseStatefulWidget {
  const SideMenuScreen({super.key});

  @override
  _SideMenuScreenState createState() => _SideMenuScreenState();
}

class _SideMenuScreenState extends BaseState<SideMenuScreen> with BasicScreen {
  bool _isInAsyncCall = false;
  String userid = prefs.getString(SharedPrefHelper.USER_ID);

  @override
  Widget buildBody(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: gpLight,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(deviceHeight * 0.14),
        child: Container(
            height: deviceHeight * 0.14,
            width: deviceWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              color: gpLight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: HORIZONTAL_PADDING, vertical: VERTICAL_PADDING),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GestureDetector(
                        onTap: () {
                          return bloc.add(HomeScreenEvent());
                        },
                        child: Image.asset(
                          IC_BACK_ARROW_TWO_COLOR,
                          height: 24,
                          width: 24,
                        )),
                  ),
                  InkWell(
                    onTap: () {
                      return bloc.add(EditProfile());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: VERTICAL_PADDING / 2,
                          horizontal: HORIZONTAL_PADDING / 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: bloc.userData?.profileImage != null
                                ? GestureDetector(
                                    child: Container(
                                      height: 52,
                                      width: 52,
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            bloc.userData?.profileImage ?? "",
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            // borderRadius:
                                            // BorderRadius.circular(100),
                                            color: gpLight,
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    IC_GREENTILL_IMAGE),
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
                                            Center(
                                                child: SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                            value:
                                                                downloadProgress
                                                                    .progress))),
                                        // placeholder: (context, url) => Container(
                                        //   decoration: BoxDecoration(
                                        //     color: colorBackgroundButton,
                                        //     borderRadius: BorderRadius.circular(18),
                                        //     image: DecorationImage(
                                        //         image: AssetImage(IC_PROFILE_IMAGE),
                                        //         fit: BoxFit.cover),
                                        //   ),
                                        // ),
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          decoration: BoxDecoration(
                                            color: gpLight,
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      //  return bloc.add(EditProfile(context));
                                    },
                                  )
                                : Container(
                                    height: 36,
                                    width: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: gpBorder),
                                      //borderRadius:
                                      //BorderRadius.circular(18),
                                      color: gpLight,
                                      // image: DecorationImage(
                                      //     image: AssetImage(
                                      //         IC_GREENTILL_IMAGE),
                                      //     fit: BoxFit.cover)
                                    ),
                                    child: Center(
                                        child: getSmallText(
                                            getInitials(
                                                bloc.userData?.firstName ?? ""),
                                            weight: FontWeight.w500,
                                            align: TextAlign.center,
                                            color: gpTextPrimary,
                                            fontSize: BODY1_TEXT_FONT_SIZE)),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 0, left: 12, right: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                getSmallText(welcome,
                                    weight: FontWeight.w400,
                                    align: TextAlign.center,
                                    fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                                    color: gpTextMuted),
                                SizedBox(
                                  height: 4,
                                ),
                                getSmallText(bloc.userData?.firstName ?? "",
                                    weight: FontWeight.w500,
                                    align: TextAlign.center,
                                    fontSize: BUTTON_FONT_SIZE,
                                    color: gpTextPrimary,
                                    bold: true),
                              ],
                            ),
                          ),
                          Spacer(
                            flex: 1,
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: gpTextMuted,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isInAsyncCall,
        child: SafeArea(
          child: Container(
            height: deviceHeight,
            width: deviceWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: HORIZONTAL_PADDING * 1.8,
                  vertical: VERTICAL_PADDING),
              child: Column(
                children: [
                  SizedBox(
                    height: deviceHeight * 0.02,
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: gpBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getSmallText(
                          "MVP focus",
                          color: gpTextSecondary,
                          fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                          weight: FontWeight.w600,
                        ),
                        const SizedBox(height: 4),
                        getSmallText(
                          "Receipt capture, OCR, and organisation",
                          color: gpTextPrimary,
                          fontSize: CAPTION_TEXT_FONT_SIZE,
                          weight: FontWeight.w700,
                          lines: 2,
                        ),
                      ],
                    ),
                  ),
                  SidemenuWidget(IC_RECEIPT, receipt, () {
                    return bloc.add(ReceiptEvent());
                  }),
                  SizedBox(
                    height: deviceHeight * 0.015,
                  ),
                  SidemenuWidget(IC_GRAPH_ICON, taxSummary, () {
                    return bloc.add(TaxSummaryEvent());
                  }),
                  SizedBox(
                    height: deviceHeight * 0.015,
                  ),
                  SidemenuWidget(IC_UPLOAD_ICON, auditReports, () {
                    return bloc.add(AuditReportsEvent());
                  }),
                  SizedBox(
                    height: deviceHeight * 0.015,
                  ),
                  SidemenuWidget(IC_WALLET, billingAndSubscription, () {
                    return bloc.add(BillingEvent());
                  }),
                  SizedBox(
                    height: deviceHeight * 0.015,
                  ),

                  SidemenuWidget(IC_HEADPHONE, contactandSupport, () {
                    return bloc.add(ContactUS());
                  }),
                  SizedBox(
                    height: deviceHeight * 0.015,
                  ),
                  SidemenuWidget(IC_SIM, TermsAndConditions, () {
                    return bloc.add(TermsAndConditionsEvent());
                  }),
                  SizedBox(
                    height: deviceHeight * 0.015,
                  ),
                  SidemenuWidget(IC_PRIVACY_POLICY, privacyPolicy, () {
                    return bloc.add(PrivacyPolicy());
                  }),
                  SizedBox(
                    height: deviceHeight * 0.015,
                  ),
                  SidemenuWidget(IC_FAQ, faq, () {
                    return bloc.add(FaqEvent());
                  }),
                  SizedBox(
                    height: deviceHeight * 0.015,
                  ),
                  SidemenuWidget(IC_LOCK, changePasswordcontent, () {
                    return bloc.add(ChangePasswordEvent());
                  }),
                  SizedBox(
                    height: deviceHeight * 0.015,
                  ),
                  SidemenuWidget(IC_LOGOUT, logout, () {
                    logoutBottomSheet(context, confirmLogout, () {
                      Navigator.pop(context);
                    }, () {
                      Navigator.pop(context);
                      setState(() {
                        _isInAsyncCall = true;
                      });

                      bloc.userRepository.logout().then((value) {
                        print(value.status.toString());
                        if (value.status == 1) {
                          if (mounted)
                            setState(() {
                              _isInAsyncCall = false;
                            });
                          logoutaccount();
                          signOut();
                          return bloc.add(Login());
                        } else if (value.apiStatusCode == 401) {
                          print("value.messagel");
                          showMessage(value.message ?? "", () {
                            setState(() {
                              isShowMessage = false;
                              logoutaccount();
                              signOut();
                              return bloc.add(Login());
                            });
                          });
                        } else {
                          print(value.message);
                          showMessage(value.message ?? "", () {
                            setState(() {
                              isShowMessage = false;
                            });
                          });
                        }
                      });
                    });
                  }),
                  // SizedBox(
                  //   height: deviceHeight * 0.015,
                  // ),
                  // SidemenuWidget(IC_DELETE_ACCOUNT, deleteaccount, () {
                  //   deleteaccountBottomSheet(
                  //       context, confirmDeleteaccount, () {
                  //     Navigator.pop(context);
                  //   }, () {
                  //     Navigator.pop(context);
                  //     setState(() {
                  //       _isInAsyncCall = true;
                  //     });
                  //
                  //     bloc.userRepository
                  //         .deleteaccount(userid: int.parse(userid))
                  //         .then((value) {
                  //       print("deleteaccount" + value.status.toString());
                  //       if (value.status == 1) {
                  //         if (mounted)
                  //           setState(() {
                  //             _isInAsyncCall = false;
                  //           });
                  //         logoutaccount();
                  //         signOut();
                  //         return bloc.add(Login());
                  //       } else if (value.apiStatusCode == 401) {
                  //         print("value.messagel");
                  //         showMessage(value.message ?? "", () {
                  //           setState(() {
                  //             isShowMessage = false;
                  //             logoutaccount();
                  //             signOut();
                  //             return bloc.add(Login());
                  //           });
                  //         });
                  //       } else {
                  //         print(value.message);
                  //         showMessage(value.message ?? "", () {
                  //           setState(() {
                  //             isShowMessage = false;
                  //           });
                  //         });
                  //       }
                  //     });
                  //   });
                  // }),
                  SizedBox(
                    height: deviceHeight * 0.03,
                  ),
                  Container(
                    height: deviceHeight * 0.09,
                    width: deviceWidth,
                    decoration: BoxDecoration(
                        color: gpLight,
                        border: Border.all(color: gpBorder),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          IC_DOLLAR,
                          height: deviceHeight * 0.05,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 0, left: 12, right: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              getSmallText(comingSoon,
                                  weight: FontWeight.w400,
                                  align: TextAlign.center,
                                  fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                                  color: gpGreen),
                              SizedBox(
                                height: 4,
                              ),
                              getSmallText(payments,
                                  weight: FontWeight.w500,
                                  align: TextAlign.center,
                                  fontSize: BUTTON_FONT_SIZE,
                                  color: gpTextPrimary,
                                  bold: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    height: deviceHeight * 0.015,
                  ),
                  SidemenuWidget(IC_DELETE_ACCOUNT, deleteaccount, () {
                    deleteaccountBottomSheet(context, confirmDeleteaccount, () {
                      Navigator.pop(context);
                    }, () {
                      Navigator.pop(context);
                      setState(() {
                        _isInAsyncCall = true;
                      });

                      bloc.userRepository
                          .deleteaccount(userid: int.parse(userid))
                          .then((value) {
                        print("deleteaccount" + value.status.toString());
                        if (value.status == 1) {
                          if (mounted)
                            setState(() {
                              _isInAsyncCall = false;
                            });
                          logoutaccount();
                          signOut();
                          return bloc.add(Login());
                        } else if (value.apiStatusCode == 401) {
                          print("value.messagel");
                          showMessage(value.message ?? "", () {
                            setState(() {
                              isShowMessage = false;
                              logoutaccount();
                              signOut();
                              return bloc.add(Login());
                            });
                          });
                        } else {
                          print(value.message);
                          showMessage(value.message ?? "", () {
                            setState(() {
                              isShowMessage = false;
                            });
                          });
                        }
                      });
                    });
                  }),
                  SizedBox(
                    height: deviceHeight * 0.02,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// Widget logoutBottomSheet(){
//   showModalBottomSheet(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
//       ),
//       backgroundColor: Colors.white,
//       context: context,
//       builder: (context) {
//         return Container(
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
//           ),
//           height: deviceHeight*0.22,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               Spacer(),
//               getSmallText(confirmLogout,fontSize:BUTTON_FONT_SIZE,bold: true,weight: FontWeight.w500,color: colorBlack,isCenter: true,align: TextAlign.center ),
//               Spacer(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   getButton("NO", (){},width: deviceWidth*0.25,color: colorWhite,textColor: colorGradientFirst,height: deviceHeight*0.06),
//                   SizedBox(width: 10,),
//                   getButton("YES", (){},width: deviceWidth*0.25,height: deviceHeight*0.06),
//                 ],
//               ),
//               Spacer()
//
//             ],
//           ),
//         );
//       });
// }
  String getInitials(String bank_account_name) => bank_account_name.isNotEmpty
      ? bank_account_name.trim().split(' ').map((l) => l[0]).take(1).join()
      : '';
}
