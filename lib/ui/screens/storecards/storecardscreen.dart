import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/models/responses/home_page_response.dart';
import 'package:greentill/models/responses/store_card_response.dart';
import 'package:greentill/models/responses/store_list_response.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/ui/screens/loyalty_details/loyalty_details_screen.dart';
import 'package:greentill/ui/screens/qrscan/qr_code_screen.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:greentill/utils/strings.dart';

class StoreCardScreen extends BaseStatefulWidget {
  @override
  _StoreCardScreenState createState() => _StoreCardScreenState();
}

class _StoreCardScreenState extends BaseState<StoreCardScreen>
    with BasicScreen, TickerProviderStateMixin {
  bool _isVisible = true;
  bool isLoadingLocal = true;
  List<DatumStoreCardList> storeCardList = [];
  List<DatumStoreList> storeList = [];
  bool isFirst = true;
  bool isStoreDeleteLoading = false;
  bool isStorecardLoading = false;
  final TextEditingController _storename = TextEditingController();
  final TextEditingController _storecardnumber = TextEditingController();
  final TextEditingController _editstorename = TextEditingController();
  final TextEditingController _editstorecardnumber = TextEditingController();
  final formGlobalKey = GlobalKey<FormState>();
  bool isSearch = false;
  TextEditingController searchcontroller = TextEditingController();
  String userid = prefs.getString(SharedPrefHelper.USER_ID);
  final _debouncer = Debouncer(milliseconds: 1000);
  FocusNode? searchFocusNode;
  String? selectedname;
  String? editselectedname;

  _onSearchChanged(String value) {
    // if (debounce?.isActive ?? false) debounce.cancel();
    // _debounce = Timer(const Duration(seconds: 1), () {
    if (searchcontroller.text.isEmpty) {
      setState(() {
        isStorecardLoading = true;
      });
      bloc.userRepository
          .getStoreCardListing(int.parse(userid), query: value.trim().toString())
          .then((value) {
        setState(() {
          isStorecardLoading = false;
        });
        if (value.status == 1) {
          //youtubeVideosResponse = value;
          storeCardList = value.data ?? [];

          // if (mounted)
          //   setState(() {
          //     isLoadingLocal = false;
          //     isCouponsLoading = false;
          //   });
        } else if (value.apiStatusCode == 401) {
          showMessage(value.message ?? "", () {
            setState(() {
              isShowMessage = false;
              logoutaccount();
              isStorecardLoading = false;
              return bloc.add(Login());
            });
          });
        } else {
          print(value.message);
          showMessage(value.message ?? "", () {
            setState(() {
              isShowMessage = false;
              isStorecardLoading = false;
              bloc.add(StoreCardEvent());
              //getCategorieslist();
            });
          });
        }
      });
    } else {
      setState(() {
        isStorecardLoading = true;
      });
      bloc.userRepository
          .getStoreCardListing(int.parse(userid), query: value.trim().toString())
          .then((value) {
        setState(() {
          isStorecardLoading = false;
        });
        if (value.status == 1) {
          //youtubeVideosResponse = value;
          storeCardList = value.data ?? [];

          // if (mounted)
          //   setState(() {
          //     isLoadingLocal = false;
          //     isCouponsLoading = false;
          //   });
        } else if (value.apiStatusCode == 401) {
          showMessage(value.message ?? "", () {
            setState(() {
              isShowMessage = false;
              logoutaccount();
              isStorecardLoading = false;
              return bloc.add(Login());
            });
          });
        } else {
          print(value.message);
          showMessage(value.message ?? "", () {
            setState(() {
              isShowMessage = false;
              isStorecardLoading = false;
              bloc.add(StoreCardEvent());
              //getCategorieslist();
            });
          });
        }
      });
    }

    // });
  }

  static String _displayStringForOption(DatumStoreList option) =>
      option.storeName ?? "";
  int? selectedStoreId;

  @override
  void initState() {
    searchFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _storecardnumber.dispose();
    _storename.dispose();
    _editstorecardnumber.dispose();
    _editstorename.dispose();
    searchcontroller.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    if (isFirst) {
      isFirst = false;
      getStoreCardlist();
      getStorelist();
    }
    return isLoadingLocal == true
        ? loader()
        : Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: colorstorecardbackground,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(deviceHeight * 0.07),
              child: Container(
                height: deviceHeight * 0.07,
                width: deviceWidth,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
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
                      horizontal: HORIZONTAL_PADDING, vertical: VERTICAL_PADDING),
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
                          if (isSearch) {
                            setState(() {
                              isSearch = false;
                              searchcontroller.clear();
                              getStoreCardlist();
                            });
                          } else {
                            return bloc.add(HomeScreenEvent());
                          }
                          // Navigator.pop(context);

                          // return bloc.add(SideMenu());
                        },
                      ),
                      SizedBox(
                        width: deviceWidth * 0.025,
                      ),
                      appBarHeader(
                        loyaltyCards,
                        fontSize: BUTTON_FONT_SIZE,
                        bold: false,
                      ),
                      Spacer(),
                      Container(
                        width: deviceWidth * 0.21,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSearch = true;
                                  searchFocusNode?.requestFocus();
                                });
                              },
                              child: Image.asset(
                                IC_SEARCH,
                                height: deviceHeight * 0.032,
                                width: deviceWidth * 0.065,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: isStoreDeleteLoading
                  ? loader()
                  : Container(
                      height: deviceHeight,
                      width: deviceWidth,
                      child: Stack(children: [
                        Container(
                            width: deviceWidth,
                            height: deviceHeight,
                            decoration: BoxDecoration(
                              color: colorstorecardbackground,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 10.0,
                                    offset: Offset(0.0, 0.05))
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                isSearch
                                    ? Container(
                                        height: deviceHeight * 0.12,
                                        width: deviceWidth,
                                        decoration: BoxDecoration(
                                          color: colorWhite,
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                                color: Colors.grey.withOpacity(0.2),
                                                blurRadius: 10.0,
                                                offset: Offset(0.0, 0.05))
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: HORIZONTAL_PADDING,
                                          ),
                                          child: Column(
                                            children: [
                                              Spacer(),
                                              Container(
                                                height: deviceHeight * 0.06,
                                                width: deviceWidth,
                                                decoration: BoxDecoration(
                                                  color: colorMyrecieptHomeBackground,
                                                  border: Border.all(color: colorgreyborder),
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(10),
                                                  ),
                                                ),
                                                child: TextField(
                                                  controller: searchcontroller,
                                                  focusNode: searchFocusNode,
                                                  onChanged: (value) {
                                                    _debouncer.run(() {
                                                      _onSearchChanged(
                                                          searchcontroller.text.trim());
                                                    });
                                                    // searchcontroller.text =
                                                    //     value.toString();
                                                    // setState(() {
                                                    //   isStorecardLoading = true;
                                                    // });
                                                    // bloc.userRepository
                                                    //     .getStoreCardListing(
                                                    //     int.parse(userid),query:
                                                    // value.trim().toString())
                                                    //     .then((value) {
                                                    //   setState(() {
                                                    //     isStorecardLoading = false;
                                                    //   });
                                                    //   if (value.status == 1) {
                                                    //     //youtubeVideosResponse = value;
                                                    //     storeCardList = value.data;
                                                    //
                                                    //     // if (mounted)
                                                    //     //   setState(() {
                                                    //     //     isLoadingLocal = false;
                                                    //     //     isCouponsLoading = false;
                                                    //     //   });
                                                    //   } else if (value.apiStatusCode ==
                                                    //       401) {
                                                    //     showMessage(value.message, () {
                                                    //       setState(() {
                                                    //         isShowMessage = false;
                                                    //         logoutaccount();
                                                    //         isStorecardLoading = false;
                                                    //         return bloc.add(Login());
                                                    //       });
                                                    //     });
                                                    //   } else {
                                                    //     print(value.message);
                                                    //     showMessage(value.message, () {
                                                    //       setState(() {
                                                    //         isShowMessage = false;
                                                    //         isStorecardLoading = false;
                                                    //         bloc.add(StoreCardEvent());
                                                    //         //getCategorieslist();
                                                    //       });
                                                    //     });
                                                    //   }
                                                    // });
                                                  },
                                                  decoration: InputDecoration(
                                                    prefixIcon: Image.asset(
                                                      IC_SEARCH,
                                                      height: 10,
                                                      width: 10,
                                                    ),
                                                    suffixIcon: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          isSearch = false;
                                                          searchcontroller.clear();
                                                          getStoreCardlist();
                                                        });
                                                        // getStoreCardlist();
                                                      },
                                                      child: Image.asset(
                                                        IC_CROSS,
                                                        height: 10,
                                                        width: 10,
                                                      ),
                                                    ),
                                                    hintText: "Search",
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                              // SizedBox(
                                              //   height: 12,
                                              // ),
                                              // Container(
                                              //   height: deviceHeight * 0.04,
                                              //   width: deviceWidth,
                                              //   child: ListView.builder(
                                              //       padding: EdgeInsets.zero,
                                              //       scrollDirection: Axis.horizontal,
                                              //       shrinkWrap: true,
                                              //       primary: false,
                                              //       itemCount: 8,
                                              //       itemBuilder: (context, index) {
                                              //         return Padding(
                                              //           padding: const EdgeInsets.only(
                                              //               right: 8.0, left: 6),
                                              //           child: Container(
                                              //             height: deviceHeight * 0.03,
                                              //             decoration: BoxDecoration(
                                              //               color: colorrecentsearch,
                                              //               border: Border.all(
                                              //                   color: colorgreyborder),
                                              //               borderRadius:
                                              //                   BorderRadius.all(
                                              //                 Radius.circular(7),
                                              //               ),
                                              //             ),
                                              //             child: Row(
                                              //               mainAxisAlignment:
                                              //                   MainAxisAlignment.start,
                                              //               children: [
                                              //                 Padding(
                                              //                   padding:
                                              //                       const EdgeInsets
                                              //                               .only(
                                              //                           left: 8,
                                              //                           top: 8,
                                              //                           bottom: 8),
                                              //                   child: getSmallText(
                                              //                       "Most Recent",
                                              //                       weight:
                                              //                           FontWeight.w400,
                                              //                       align: TextAlign
                                              //                           .center,
                                              //                       fontSize:
                                              //                           CAPTION_SMALLER_TEXT_FONT_SIZE),
                                              //                 ),
                                              //                 const SizedBox(
                                              //                   width: 8,
                                              //                 ),
                                              //                 Container(
                                              //                   height: 20,
                                              //                   width: 20,
                                              //                   margin: EdgeInsets.only(
                                              //                       top: 3,
                                              //                       bottom: 3,
                                              //                       right: 5),
                                              //                   decoration:
                                              //                       BoxDecoration(
                                              //                     border: Border.all(
                                              //                         color: colorGrey4,
                                              //                         width: 1),
                                              //                     // color: Colors.blue,
                                              //                     borderRadius:
                                              //                         BorderRadius
                                              //                             .circular(
                                              //                                 30.0),
                                              //                   ),
                                              //                   padding:
                                              //                       const EdgeInsets
                                              //                           .all(5.5),
                                              //                   child: Image.asset(
                                              //                     IC_CROSS,
                                              //                   ),
                                              //                 )
                                              //               ],
                                              //             ),
                                              //           ),
                                              //         );
                                              //       }),
                                              // ),
                                              Spacer()
                                            ],
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                                Expanded(
                                  child: RefreshIndicator(
                                    onRefresh: () {
                                      print("pulltorefresh");
                                      setState(() {
                                        isSearch = false;
                                      });
                                      return getStoreCardlist();
                                    },
                                    child: Container(
                                      child: isStorecardLoading
                                          ? loader()
                                          : storeCardList.length <= 0 ||
                                                  storeCardList.isEmpty
                                              ? Center(
                                                  child: getSmallText("Add your store cards!",
                                                      bold: true,
                                                      isCenter: true,
                                                      fontSize: BUTTON_FONT_SIZE,
                                                      color: colorBlack,
                                                      weight: FontWeight.w500),
                                                )
                                              : Padding(
                                                  padding: EdgeInsets.only(
                                                    right: VERTICAL_PADDING,
                                                    left: VERTICAL_PADDING,
                                                    top: VERTICAL_PADDING * 2,
                                                    bottom: VERTICAL_PADDING * 2,
                                                  ),
                                                  child: Container(
                                                    child: ListView.builder(
                                                        padding: EdgeInsets.only(
                                                            bottom: deviceHeight * 0.12),
                                                        scrollDirection: Axis.vertical,
                                                        physics: AlwaysScrollableScrollPhysics(),
                                                        clipBehavior: Clip.none,
                                                        primary: false,
                                                        itemCount: storeCardList.length ?? 0,
                                                        shrinkWrap: true,
                                                        itemBuilder: (context, index) {
                                                          return GestureDetector(
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(4.0),
                                                                child: storeCard(
                                                                    storeCardList[index].storeLogo,
                                                                    storeCardList[index].storeName,
                                                                    storeCardList[index]
                                                                        .storeDescription) /*StoreCardListGridItem(
                                                                    storeCardList[index]
                                                                                ?.storeLogo ==
                                                                            null
                                                                        ? getInitials(
                                                                                storeCardList[index]
                                                                                    .storeName) ??
                                                                            ""
                                                                        : storeCardList[index]
                                                                            .storeLogo,
                                                                    storeCardList[index]
                                                                            ?.storeName ??
                                                                        "",
                                                                    isstorelogoavailable:
                                                                        storeCardList[index]
                                                                                ?.storeLogo !=
                                                                            null,
                                                                    color: generateRandomColor1(),
                                                                    border: colorWhite)*/
                                                                ,
                                                              ),
                                                              onTap: () {
                                                                if (storeCardList[index]
                                                                        .storeLoyaltyPartner ==
                                                                    true) {
                                                                  Navigator.push(context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) {
                                                                    return LoyaltyDetailsScreen(
                                                                        storeCardList:
                                                                            StoreCardList(
                                                                      storeCardId:
                                                                          storeCardList[index]
                                                                              .storeCardId,
                                                                      userId: storeCardList[index]
                                                                          .userId,
                                                                      storeId: storeCardList[index]
                                                                          .storeId,
                                                                      storeName:
                                                                          storeCardList[index]
                                                                              .storeName,
                                                                      storeLogo:
                                                                          storeCardList[index]
                                                                              .storeLogo,
                                                                      storeNumber:
                                                                          storeCardList[index]
                                                                              .storeNumber,
                                                                      barcodeImage:
                                                                          storeCardList[index]
                                                                              .barcodeImage,
                                                                      currentStamps:
                                                                          storeCardList[index]
                                                                              .currentStamps,
                                                                      loyaltyVoucherGenerated:
                                                                          storeCardList[index]
                                                                              .loyaltyVoucherGenerated,
                                                                      requiredStampsForReward:
                                                                          storeCardList[index]
                                                                              .requiredStampsForReward,
                                                                      stampImage:
                                                                          storeCardList[index]
                                                                              .stampImage,
                                                                      storeLoyaltyPartner:
                                                                          storeCardList[index]
                                                                              .storeLoyaltyPartner,
                                                                      totalStampsCount:
                                                                          storeCardList[index]
                                                                              .totalStampsCount,
                                                                    ));
                                                                  }));
                                                                } else {
                                                                  openCard(context, storeCardList[index].storeCardId ?? 0,
                                                                      storeName: storeCardList[index].storeName ??
                                                                          "",
                                                                      storeLogo: storeCardList[index]
                                                                              .storeLogo,
                                                                      storeId: storeCardList[index].storeId == ""
                                                                          ? null
                                                                          : storeCardList[index]
                                                                              .storeId,
                                                                      storeNumber: storeCardList[index].storeNumber ??
                                                                          "",
                                                                      barcodeImage: storeCardList[index]
                                                                          .barcodeImage,
                                                                      isstorelogoavailable:
                                                                          storeCardList[index].storeLogo !=
                                                                              null,
                                                                      totalStampsCount: storeCardList[index]
                                                                          .requiredStampsForReward,
                                                                      storeLoyaltyPartner:
                                                                          storeCardList[index]
                                                                              .storeLoyaltyPartner,
                                                                      stampImage: storeCardList[index]
                                                                          .stampImage,
                                                                      requiredStampsForReward: storeCardList[index]
                                                                          .requiredStampsForReward,
                                                                      loyaltyVoucherGenerated:
                                                                          storeCardList[index].loyaltyVoucherGenerated,
                                                                      currentStamps: storeCardList[index].currentStamps

                                                                      //
                                                                      );
                                                                }
                                                              });
                                                        }),
                                                  ),
                                                ),
                                    ),
                                  ),
                                )
                              ],
                            )),
                        Positioned.fill(
                            child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  height: deviceHeight * 0.07,
                                  width: deviceWidth * 0.45,
                                  decoration: BoxDecoration(
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 30.0,
                                          offset: Offset(0.0, 0.05))
                                    ],
                                    // border: Border.all(color: colorhomebordercolor),
                                    color: colortheme,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            bloc.add(HomeScreenEvent());
                                          },
                                          child: customFlotingButton("Home", IC_HOME)),
                                      GestureDetector(
                                          onTap: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(builder: (context) {
                                              return QrCodeScreen();
                                            }));
                                          },
                                          child: customFlotingButton("Scan QR", IC_GREYQR)),
                                      GestureDetector(
                                          onTap: () {
                                            // bloc.add(HomeScreenEvent());
                                            showUserQr(
                                              context,
                                              customerID:
                                                  bloc.userData?.customerId?.toString() ?? "",
                                              userQr: bloc.userData?.customerIdQrImage ?? "",
                                              email: bloc.userData?.email ?? "",
                                            );
                                          },
                                          child: customFlotingButton(idCard, IC_ID)),
                                    ],
                                  ),
                                ),
                              )

                              // getButton("Scan QR Code", () {
                              //   Navigator.push(context,
                              //       MaterialPageRoute(builder: (context) {
                              //     return QrCodeScreen();
                              //   }));
                              // }, width: deviceWidth * 0.45, assetImage: IC_SCAN)

                              ),
                        )),
                        Positioned.fill(
                            child: Padding(
                          padding: const EdgeInsets.only(bottom: 16, right: 16),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: GestureDetector(
                              onTap: () {
                                addNewCardSheet(context);
                              },
                              child: Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                    height: deviceHeight * 0.07,
                                    width: deviceWidth * 0.14,
                                    decoration: BoxDecoration(
                                      color: colorGradientFirst,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Image.asset(
                                      IC_ADD,
                                      height: deviceHeight * 0.03,
                                      width: deviceWidth * 0.06,
                                      fit: BoxFit.scaleDown,
                                    )),
                              ),
                            ),
                          ),
                        )),
                      ]),
                    ),
            ),
          );
  }

  void openCard(
    BuildContext context,
    int storecardid, {
    String? storeLogo,
    String? storeName,
    int? storeId,
    String? storeNumber,
    String? barcodeImage,
    int? requiredStampsForReward,
    double? currentStamps,
    int? totalStampsCount,
    String? stampImage,
    bool? storeLoyaltyPartner,
    bool? loyaltyVoucherGenerated,
    bool isstorelogoavailable = false,
  }) {
    final safeStoreLogo = storeLogo ?? "";
    final safeStoreName = storeName ?? "";
    final safeStoreNumber = storeNumber ?? "";
    final safeBarcodeImage = barcodeImage ?? "";
    final safeRequiredStampsForReward = requiredStampsForReward ?? 0;
    final safeCurrentStamps = currentStamps ?? 0;
    final safeTotalStampsCount = totalStampsCount ?? 0;
    final safeStampImage = stampImage ?? "";
    showDialog(
        context: context,
        builder: (ctx) {
          print('DETAILS $safeStampImage');
          return storeLoyaltyPartner == true
              ? FlipCard(
                  front: Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  // Container(
                                  //   height: deviceHeight * 0.06,
                                  //   width: deviceWidth * 0.12,
                                  //   padding: EdgeInsets.all(5),
                                  //   decoration: BoxDecoration(
                                  //     shape: BoxShape.circle,
                                  //     border: Border.all(color: colorbordercoupons),
                                  //     color: colorWhite,
                                  //     image: DecorationImage(
                                  //       image: AssetImage(storeLogo),
                                  //     ),
                                  //   ),
                                  // ),
                                  Container(
                                    height: deviceHeight * 0.07,
                                    width: deviceWidth * 0.13,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: colorbordercoupons),
                                      color: colorWhite,
                                      // image: widget.isCoupons
                                      //     ? DecorationImage(image: AssetImage(widget.logo))
                                      //     : null
                                    ),
                                    child: isstorelogoavailable
                                        ? Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: CachedNetworkImage(
                                              imageUrl: storeLogo ?? "",
                                              errorWidget: (context, url, error) => Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  //borderRadius:
                                                  //BorderRadius.circular(18),
                                                  color: colorWhite,
                                                  // image: DecorationImage(
                                                  //     image: AssetImage(
                                                  //         IC_GREENTILL_IMAGE),
                                                  //     fit: BoxFit.scaleDown),
                                                ),
                                                child: Center(
                                                    child: getSmallText(getInitials(safeStoreName),
                                                        weight: FontWeight.w500,
                                                        align: TextAlign.center,
                                                        color: colorBlack,
                                                        fontSize: BODY1_TEXT_FONT_SIZE)),
                                              ),
                                              progressIndicatorBuilder:
                                                  (context, url, downloadProgress) => Center(
                                                      child: SizedBox(
                                                          height: 20,
                                                          width: 20,
                                                          child: CircularProgressIndicator(
                                                              value: downloadProgress.progress))),
                                              // placeholder: (context, url) => Container(
                                              //   decoration: BoxDecoration(
                                              //     color: colorBackgroundButton,
                                              //     borderRadius: BorderRadius.circular(18),
                                              //     image: DecorationImage(
                                              //         image: AssetImage(IC_PROFILE_IMAGE),
                                              //         fit: BoxFit.cover),
                                              //   ),
                                              // ),
                                              imageBuilder: (context, imageProvider) => Container(
                                                decoration: BoxDecoration(
                                                  color: colorWhite,
                                                  borderRadius: BorderRadius.circular(100),
                                                  image: DecorationImage(
                                                      alignment: Alignment.center,
                                                      image: imageProvider,
                                                      fit: BoxFit.scaleDown),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: getSmallText(safeStoreLogo,
                                                weight: FontWeight.w500,
                                                align: TextAlign.center,
                                                color: colorBlack,
                                                fontSize: BODY1_TEXT_FONT_SIZE),
                                          ),
                                  ),

                                  SizedBox(width: deviceWidth * 0.025),
                                  getSmallText(safeStoreName,
                                      weight: FontWeight.w500,
                                      align: TextAlign.center,
                                      fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                                      color: colorBlack,
                                      bold: true),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  margin: EdgeInsets.only(top: 3, bottom: 3, right: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: colorGrey4, width: 1),
                                    // color: Colors.blue,
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: const EdgeInsets.all(5.5),
                                  child: Image.asset(
                                    IC_CROSS,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        getCommonDivider(),
                        storeLoyaltyPartner == true
                            ? SizedBox(
                                height: 10,
                              )
                            : Padding(
                                padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      child: Image.asset(IC_EDIT_RECEIPT),
                                      onTap: () {
                                        editCardSheet(context, storecardid,
                                            storeNumber: storeNumber,
                                            storeId: storeId,
                                            storeName: storeName);
                                      },
                                    ),
                                    SizedBox(width: deviceWidth * 0.025),
                                    GestureDetector(
                                      child: Image.asset(IC_DELETE_ACCOUNT),
                                      onTap: () {
                                        // Navigator.pop(context);
                                        logoutBottomSheet(context, deleteCard, () {
                                          Navigator.pop(context);
                                        }, () {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          setState(() {
                                            isStoreDeleteLoading = true;
                                          });
                                          bloc.userRepository
                                              .deletestorecard(storecardid: storecardid)
                                              .then((value) {
                                            if (value.status == 1) {
                                              setState(() {
                                                isStoreDeleteLoading = false;
                                              });
                                              getStoreCardlist();
                                              bloc.add(CardDeletedEvent());
                                            } else if (value.apiStatusCode == 401) {
                                              showMessage(value.message ?? "", () {
                                                setState(() {
                                                  isShowMessage = false;
                                                  logoutaccount();
                                                  isStoreDeleteLoading = false;
                                                  return bloc.add(Login());
                                                });
                                              });
                                            } else {
                                              print(value.message);
                                              showMessage(value.message ?? "", () {
                                                setState(() {
                                                  isShowMessage = false;
                                                  isStoreDeleteLoading = false;
                                                  //getCategorieslist();
                                                });
                                              });
                                            }
                                          });
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                        Container(
                          width: deviceWidth * 0.6,
                          height: deviceHeight * 0.15,
                          child: CachedNetworkImage(
                            fit: BoxFit.fill,
                            imageUrl: safeBarcodeImage,
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                //borderRadius:
                                //BorderRadius.circular(18),
                                color: colorWhite,
                                // image: DecorationImage(
                                //     image: AssetImage(
                                //         IC_GREENTILL_IMAGE),
                                //     fit: BoxFit.scaleDown),
                              ),
                            ),
                            progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        value: downloadProgress.progress))),
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                color: colorWhite,
                                // borderRadius: BorderRadius.circular(100),
                                image: DecorationImage(
                                    // alignment: Alignment.center,
                                    image: imageProvider,
                                    fit: BoxFit.fill),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: deviceHeight * 0.02),
                        getTitle(safeStoreNumber,
                            lines: 1,
                            weight: FontWeight.w800,
                            fontSize: SUBTITLE_FONT_SIZE,
                            color: colorbarcodetext),
                        SizedBox(height: deviceHeight * 0.02),
                      ],
                    ),
                  ),
                  back: Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  // Container(
                                  //   height: deviceHeight * 0.06,
                                  //   width: deviceWidth * 0.12,
                                  //   padding: EdgeInsets.all(5),
                                  //   decoration: BoxDecoration(
                                  //     shape: BoxShape.circle,
                                  //     border: Border.all(color: colorbordercoupons),
                                  //     color: colorWhite,
                                  //     image: DecorationImage(
                                  //       image: AssetImage(storeLogo),
                                  //     ),
                                  //   ),
                                  // ),
                                  Container(
                                    height: deviceHeight * 0.07,
                                    width: deviceWidth * 0.13,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: colorbordercoupons),
                                      color: colorWhite,
                                      // image: widget.isCoupons
                                      //     ? DecorationImage(image: AssetImage(widget.logo))
                                      //     : null
                                    ),
                                    child: isstorelogoavailable
                                        ? Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: CachedNetworkImage(
                                              imageUrl: storeLogo ?? "",
                                              errorWidget: (context, url, error) => Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  //borderRadius:
                                                  //BorderRadius.circular(18),
                                                  color: colorWhite,
                                                  // image: DecorationImage(
                                                  //     image: AssetImage(
                                                  //         IC_GREENTILL_IMAGE),
                                                  //     fit: BoxFit.scaleDown),
                                                ),
                                                child: Center(
                                                    child: getSmallText(getInitials(safeStoreName),
                                                        weight: FontWeight.w500,
                                                        align: TextAlign.center,
                                                        color: colorBlack,
                                                        fontSize: BODY1_TEXT_FONT_SIZE)),
                                              ),
                                              progressIndicatorBuilder:
                                                  (context, url, downloadProgress) => Center(
                                                      child: SizedBox(
                                                          height: 20,
                                                          width: 20,
                                                          child: CircularProgressIndicator(
                                                              value: downloadProgress.progress))),
                                              // placeholder: (context, url) => Container(
                                              //   decoration: BoxDecoration(
                                              //     color: colorBackgroundButton,
                                              //     borderRadius: BorderRadius.circular(18),
                                              //     image: DecorationImage(
                                              //         image: AssetImage(IC_PROFILE_IMAGE),
                                              //         fit: BoxFit.cover),
                                              //   ),
                                              // ),
                                              imageBuilder: (context, imageProvider) => Container(
                                                decoration: BoxDecoration(
                                                  color: colorWhite,
                                                  borderRadius: BorderRadius.circular(100),
                                                  image: DecorationImage(
                                                      alignment: Alignment.center,
                                                      image: imageProvider,
                                                      fit: BoxFit.scaleDown),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: getSmallText(safeStoreLogo,
                                                weight: FontWeight.w500,
                                                align: TextAlign.center,
                                                color: colorBlack,
                                                fontSize: BODY1_TEXT_FONT_SIZE),
                                          ),
                                  ),

                                  SizedBox(width: deviceWidth * 0.025),
                                  getSmallText(safeStoreName,
                                      weight: FontWeight.w500,
                                      align: TextAlign.center,
                                      fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                                      color: colorBlack,
                                      bold: true),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  margin: EdgeInsets.only(top: 3, bottom: 3, right: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: colorGrey4, width: 1),
                                    // color: Colors.blue,
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: const EdgeInsets.all(5.5),
                                  child: Image.asset(
                                    IC_CROSS,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        getCommonDivider(),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                      image: NetworkImage(safeStampImage),
                                      fit: BoxFit.fill,
                                      opacity: 0.35)),
                          child: GridView.builder(
                            padding: EdgeInsets.all(20),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 15,
                              crossAxisSpacing: 15,
                            ),
                            itemCount: safeRequiredStampsForReward.round(),
                            itemBuilder: (context, index) {
                              print('BENTELLY $safeRequiredStampsForReward');
                              if (index == safeRequiredStampsForReward.round() - 1) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: colortheme, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: index <= (safeCurrentStamps - 1)
                                        ? Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Image.asset(
                                              IC_CHECKMARK,
                                            ),
                                          )
                                        : Text(
                                            'REWARD',
                                            style: TextStyle(
                                              color: colorBlack,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                );
                              } else if (index <= safeRequiredStampsForReward.round()) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: colortheme, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: index <= (safeCurrentStamps - 1)
                                        ? Stack(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(12),
                                                child: Image.asset(IC_CHECKMARK),
                                              ),
                                              Center(
                                                child: Text(
                                                  '${index + 1}', // Display the current stamp number
                                                  style: TextStyle(
                                                    color: colorBlack,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            '${index + 1}', // Display the current stamp number
                                            style: TextStyle(
                                              color: colorBlack,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                );
                              } else {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: colortheme, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                        '${safeCurrentStamps.round() == 0 ? '' : safeCurrentStamps.round()}'),
                                  ),
                                );
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // Container(
                                //   height: deviceHeight * 0.06,
                                //   width: deviceWidth * 0.12,
                                //   padding: EdgeInsets.all(5),
                                //   decoration: BoxDecoration(
                                //     shape: BoxShape.circle,
                                //     border: Border.all(color: colorbordercoupons),
                                //     color: colorWhite,
                                //     image: DecorationImage(
                                //       image: AssetImage(storeLogo),
                                //     ),
                                //   ),
                                // ),
                                Container(
                                  height: deviceHeight * 0.07,
                                  width: deviceWidth * 0.13,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: colorbordercoupons),
                                    color: colorWhite,
                                    // image: widget.isCoupons
                                    //     ? DecorationImage(image: AssetImage(widget.logo))
                                    //     : null
                                  ),
                                  child: isstorelogoavailable
                                      ? Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: CachedNetworkImage(
                                            imageUrl: storeLogo ?? "",
                                            errorWidget: (context, url, error) => Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                //borderRadius:
                                                //BorderRadius.circular(18),
                                                color: colorWhite,
                                                // image: DecorationImage(
                                                //     image: AssetImage(
                                                //         IC_GREENTILL_IMAGE),
                                                //     fit: BoxFit.scaleDown),
                                              ),
                                              child: Center(
                                                  child: getSmallText(getInitials(safeStoreName),
                                                      weight: FontWeight.w500,
                                                      align: TextAlign.center,
                                                      color: colorBlack,
                                                      fontSize: BODY1_TEXT_FONT_SIZE)),
                                            ),
                                            progressIndicatorBuilder:
                                                (context, url, downloadProgress) => Center(
                                                    child: SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child: CircularProgressIndicator(
                                                            value: downloadProgress.progress))),
                                            // placeholder: (context, url) => Container(
                                            //   decoration: BoxDecoration(
                                            //     color: colorBackgroundButton,
                                            //     borderRadius: BorderRadius.circular(18),
                                            //     image: DecorationImage(
                                            //         image: AssetImage(IC_PROFILE_IMAGE),
                                            //         fit: BoxFit.cover),
                                            //   ),
                                            // ),
                                            imageBuilder: (context, imageProvider) => Container(
                                              decoration: BoxDecoration(
                                                color: colorWhite,
                                                borderRadius: BorderRadius.circular(100),
                                                image: DecorationImage(
                                                    alignment: Alignment.center,
                                                    image: imageProvider,
                                                    fit: BoxFit.scaleDown),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: getSmallText(safeStoreLogo,
                                              weight: FontWeight.w500,
                                              align: TextAlign.center,
                                              color: colorBlack,
                                              fontSize: BODY1_TEXT_FONT_SIZE),
                                        ),
                                ),

                                SizedBox(width: deviceWidth * 0.025),
                                getSmallText(safeStoreName,
                                    weight: FontWeight.w500,
                                    align: TextAlign.center,
                                    fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                                    color: colorBlack,
                                    bold: true),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 20,
                                width: 20,
                                margin: EdgeInsets.only(top: 3, bottom: 3, right: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(color: colorGrey4, width: 1),
                                  // color: Colors.blue,
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: const EdgeInsets.all(5.5),
                                child: Image.asset(
                                  IC_CROSS,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      getCommonDivider(),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              child: Image.asset(IC_EDIT_RECEIPT),
                              onTap: () {
                                editCardSheet(context, storecardid,
                                    storeNumber: storeNumber,
                                    storeId: storeId,
                                    storeName: storeName);
                              },
                            ),
                            SizedBox(width: deviceWidth * 0.025),
                            GestureDetector(
                              child: Image.asset(IC_DELETE_ACCOUNT),
                              onTap: () {
                                // Navigator.pop(context);
                                logoutBottomSheet(context, deleteCard, () {
                                  Navigator.pop(context);
                                }, () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  setState(() {
                                    isStoreDeleteLoading = true;
                                  });
                                  bloc.userRepository
                                      .deletestorecard(storecardid: storecardid)
                                      .then((value) {
                                    if (value.status == 1) {
                                      setState(() {
                                        isStoreDeleteLoading = false;
                                      });
                                      getStoreCardlist();
                                      bloc.add(CardDeletedEvent());
                                    } else if (value.apiStatusCode == 401) {
                                      showMessage(value.message ?? "", () {
                                        setState(() {
                                          isShowMessage = false;
                                          logoutaccount();
                                          isStoreDeleteLoading = false;
                                          return bloc.add(Login());
                                        });
                                      });
                                    } else {
                                      print(value.message);
                                      showMessage(value.message ?? "", () {
                                        setState(() {
                                          isShowMessage = false;
                                          isStoreDeleteLoading = false;
                                          //getCategorieslist();
                                        });
                                      });
                                    }
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: deviceWidth * 0.6,
                        height: deviceHeight * 0.15,
                        child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          imageUrl: barcodeImage ?? "",
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              //borderRadius:
                              //BorderRadius.circular(18),
                              color: colorWhite,
                              // image: DecorationImage(
                              //     image: AssetImage(
                              //         IC_GREENTILL_IMAGE),
                              //     fit: BoxFit.scaleDown),
                            ),
                          ),
                          progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                              child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(value: downloadProgress.progress))),
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              color: colorWhite,
                              // borderRadius: BorderRadius.circular(100),
                              image: DecorationImage(
                                  // alignment: Alignment.center,
                                  image: imageProvider,
                                  fit: BoxFit.fill),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: deviceHeight * 0.02),
                      getTitle(storeNumber ?? "",
                          lines: 1,
                          weight: FontWeight.w800,
                          fontSize: SUBTITLE_FONT_SIZE,
                          color: colorbarcodetext),
                      SizedBox(height: deviceHeight * 0.02),
                    ],
                  ),
                );
        });
  }

  Future<void> addNewCardSheet(BuildContext context) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        isDismissible: true,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        backgroundColor: colorWhite,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setStateNew) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                height: deviceHeight * 0.5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: HORIZONTAL_PADDING * 1.5, vertical: VERTICAL_PADDING * 1.5),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formGlobalKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              getSmallText(addNewCard ?? "",
                                  weight: FontWeight.w500,
                                  bold: true,
                                  fontSize: CAPTION_TEXT_FONT_SIZE,
                                  color: colorBlack),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  margin: EdgeInsets.only(top: 3, bottom: 3, right: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: colorGrey4, width: 1),
                                    // color: Colors.blue,
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: const EdgeInsets.all(5.5),
                                  child: Image.asset(
                                    IC_CROSS,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          getCommonDivider(),
                          SizedBox(
                            height: deviceHeight * 0.03,
                          ),
                          // Container(
                          //   width: deviceWidth * 0.8,
                          //   child: Autocomplete<DatumStoreList>(
                          //     optionsBuilder: (TextEditingValue textEditingValue) {
                          //       return storeList
                          //           .where((DatumStoreList continent) => continent.storeName.toLowerCase()
                          //           .startsWith(textEditingValue.text.toLowerCase())
                          //       )
                          //           .toList();
                          //     },
                          //     displayStringForOption: (DatumStoreList option) => option.storeName,
                          //   )
                          // ),

                          RawAutocomplete(
                            displayStringForOption: _displayStringForOption,
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '' || textEditingValue.text.isEmpty) {
                                print("textisempty");
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _storename.text = "";
                                  if (_storename.text != (selectedname ?? "")) {
                                    selectedStoreId = null;
                                  }
                                  print("updatedstoreid1");
                                  print(selectedStoreId);
                                });

                                // setState(() {
                                //   _storename.text = "";
                                //   if (_storename.text != selectedname) {
                                //     selectedStoreId = null;
                                //   }
                                // });
                                return const Iterable<DatumStoreList>.empty();
                              } else {
                                print("texteditingvalue:-");
                                print(textEditingValue.text);

                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  // setState(() {
                                  _storename.text = textEditingValue.text;
                                  if (_storename.text != (selectedname ?? "")) {
                                    selectedStoreId = null;
                                  }
                                  print("updatedstoreid");
                                  print(selectedStoreId);
                                  // isStoreSelected = false;
                                  // });
                                });

                                // setState(() {
                                //   _storename.text = textEditingValue.text;
                                //   if (_storename.text != selectedname) {
                                //     selectedStoreId = null;
                                //   }
                                // });
                                List<DatumStoreList> matches = <DatumStoreList>[];
                                matches.addAll(storeList);

                                matches.retainWhere((DatumStoreList continent) =>
                                    (continent.storeName ?? "")
                                        .toLowerCase()
                                        .contains(textEditingValue.text.toLowerCase()));
                                print("mathes");
                                print(matches);
                                return matches;
                              }
                            },
                            onSelected: (DatumStoreList selection) {
                              print('You just selected');
                              print(selection.storeName);
                              print(selection.storeId);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                selectedname = selection.storeName ?? "";
                                _storename.text = selection.storeName ?? "";
                                selectedStoreId = selection.storeId;
                              });

                              // setState(() {
                              //   selectedname = selection.storeName;
                              //   _storename.text = selection.storeName;
                              //   selectedStoreId = selection?.storeId;
                              // });
                            },
                            fieldViewBuilder: (BuildContext context,
                                TextEditingController textEditingController,
                                FocusNode focusNode,
                                VoidCallback onFieldSubmitted) {
                              return SizedBox(
                                width: deviceWidth * 0.8,
                                child: getCommonTextFormField(
                                  context: context,
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  hintText: "Store name",
                                  validator: (text) {
                                    final value = text?.trim() ?? "";
                                    if (value.isEmpty) {
                                      return "Please enter store name";
                                    }
                                    return null;
                                  },
                                  onSubmitted: (String value) {},
                                ),
                              );
                            },
                            optionsViewBuilder: (BuildContext context,
                                void Function(DatumStoreList) onSelected,
                                Iterable<DatumStoreList> options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                    child: SizedBox(
                                        height: 52.0 * options.length,
                                        width: deviceWidth * 0.8,
                                        child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: Container(
                                              color: colorWhite,
                                              // height: 100,
                                              child: Column(
                                                children: options.map((opt) {
                                                  return InkWell(
                                                      onTap: () {
                                                        onSelected(opt);
                                                      },
                                                      child: Container(
                                                          padding: EdgeInsets.only(right: 0),
                                                          child: Card(
                                                              child: Container(
                                                            width: double.infinity,
                                                            padding: EdgeInsets.all(10),
                                                            child: Text(opt.storeName ?? ""),
                                                          ))));
                                                }).toList(),
                                              ),
                                            )))),
                              );
                            },
                          ),

                          // SizedBox(
                          //   width: deviceWidth * 0.8,
                          //   child: getCommonTextFormField(
                          //       context: context,
                          //       controller: _storename,
                          //       hintText: storeNameSmall,
                          //       onTextChanged: (value){
                          //
                          //       },
                          //       validator: (text) {
                          //         if (text == null || text.isEmpty) {
                          //           return "Please enter store name";
                          //         } else {
                          //           return null;
                          //         }
                          //       }),
                          // ),
                          SizedBox(
                            height: deviceHeight * 0.03,
                          ),
                          SizedBox(
                            width: deviceWidth * 0.8,
                            child: getCommonTextFormField(
                                context: context,
                                controller: _storecardnumber,
                                hintText: storeCardNumber,
                                validator: (text) {
                                  final value = text?.trim() ?? "";
                                  if (value.isEmpty) {
                                    return "Please enter store card number";
                                  }
                                  // else if (text.length != 12) {
                                  //   return "store number should be of 12 digits";
                                  // }
                                  else {
                                    return null;
                                  }
                                }),
                          ),
                          SizedBox(
                            height: deviceHeight * 0.03,
                          ),
                          getSmallText(or),
                          SizedBox(
                            height: deviceHeight * 0.03,
                          ),
                          UploadReceiptWidget(
                            IC_SCAN_STORE,
                            scanStoreCard,
                            () {
                              scanBarcode();
                            },
                            width: deviceWidth * 0.8,
                          ),
                          SizedBox(
                            height: deviceHeight * 0.03,
                          ),
                          getButton(
                            add,
                            () {
  String userid = prefs.getString(SharedPrefHelper.USER_ID) ?? "0";
                              if (formGlobalKey.currentState?.validate() ?? false) {
                                print("storeidq");
                                print(selectedStoreId);
                                Navigator.pop(context);
                                if (mounted)
                                  setState(() {
                                    isLoadingLocal = true;
                                  });
                                bloc.userRepository
                                    .addstorecard(_storename.text.trim(),
                                        _storecardnumber.text.trim(), int.parse(userid),
                                        storeId: selectedStoreId ?? 0)
                                    .then((value) {
                                  if (value.status == 1) {
                                    getStoreCardlist();
                                    // Navigator.pop(context);
                                    bloc.add(CardAddedEvent());

                                    // if (mounted)
                                    //   setState(() {
                                    //     isLoadingLocal = false;
                                    //   });
                                  } else if (value.apiStatusCode == 401) {
                                    showMessage(value.message ?? "", () {
                                      setState(() {
                                        isShowMessage = false;
                                        isLoadingLocal = false;
                                        logoutaccount();
                                        return bloc.add(Login());
                                      });
                                    });
                                  } else {
                                    print(value.message);
                                    showMessage(value.message ?? "", () {
                                      setState(() {
                                        isShowMessage = false;
                                        isLoadingLocal = false;
                                        //getCategorieslist();
                                      });
                                    });
                                  }
                                });
                              }
                            },
                            width: deviceWidth * 0.8,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  Future<void> editCardSheet(BuildContext context, int storecardid,
      {String? storeName, int? storeId, String? storeNumber}) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        isDismissible: true,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        backgroundColor: colorWhite,
        builder: (BuildContext context) {
          _editstorename.text = storeName ?? "";
          _editstorecardnumber.text = storeNumber ?? "";
          print("storedata");
          print(storeName);
          print(storeNumber);
          print(storeId);
          print(storecardid);
          return StatefulBuilder(builder: (BuildContext context, StateSetter setStateNew) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                height: deviceHeight * 0.5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: HORIZONTAL_PADDING * 1.5, vertical: VERTICAL_PADDING * 1.5),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formGlobalKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              getSmallText(editcard ?? "",
                                  weight: FontWeight.w500,
                                  bold: true,
                                  fontSize: CAPTION_TEXT_FONT_SIZE,
                                  color: colorBlack),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  margin: EdgeInsets.only(top: 3, bottom: 3, right: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: colorGrey4, width: 1),
                                    // color: Colors.blue,
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: const EdgeInsets.all(5.5),
                                  child: Image.asset(
                                    IC_CROSS,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          getCommonDivider(),
                          SizedBox(
                            height: deviceHeight * 0.03,
                          ),
                          RawAutocomplete(
                            displayStringForOption: _displayStringForOption,
                            initialValue: TextEditingValue(text: _editstorename.text ?? ""),
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '' || textEditingValue.text.isEmpty) {
                                print("textisempty");

                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _editstorename.text = "";
                                  if (_editstorename.text != (editselectedname ?? "")) {
                                    storeId = null;
                                  }
                                  print("updatedstoreid1");
                                  print(selectedStoreId);
                                });

                                // setState(() {
                                //   _editstorename.text = "";
                                //   storeId = null;
                                // });
                                return const Iterable<DatumStoreList>.empty();
                              } else {
                                print("texteditingvalue:-");
                                print(textEditingValue.text);
                                // setState(() {
                                //   _editstorename.text = textEditingValue.text;
                                //   storeId = null;
                                // });

                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  // _editstorename.text = "";
                                  _editstorename.text = textEditingValue.text;
                                  if (_editstorename.text != (editselectedname ?? "")) {
                                    storeId = null;
                                  }
                                  print("updatedstoreid1");
                                  print(selectedStoreId);
                                });

                                List<DatumStoreList> matches = <DatumStoreList>[];
                                matches.addAll(storeList);

                                matches.retainWhere((DatumStoreList continent) =>
                                    (continent.storeName ?? "")
                                        .toLowerCase()
                                        .contains(textEditingValue.text.toLowerCase()));
                                print("mathes");
                                print(matches);
                                return matches;
                              }
                            },
                            onSelected: (DatumStoreList selection) {
                              print('You just selected');
                              print(selection.storeName);
                              print(selection.storeId);
                              // setState(() {
                              //   _editstorename.text = selection.storeName;
                              //   storeId = selection?.storeId;
                              // });

                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                editselectedname = selection.storeName ?? "";
                                _editstorename.text = selection.storeName ?? "";
                                storeId = selection.storeId;
                                print("selectedstoreid");
                                print(storeId);
                              });
                            },
                            fieldViewBuilder: (BuildContext context,
                                TextEditingController textEditingController,
                                FocusNode focusNode,
                                VoidCallback onFieldSubmitted) {
                              return SizedBox(
                                width: deviceWidth * 0.8,
                                child: getCommonTextFormField(
                                  context: context,
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  hintText: "Store name",
                                  validator: (text) {
                                    final value = text?.trim() ?? "";
                                    if (value.isEmpty) {
                                      return "Please enter store name";
                                    }
                                    return null;
                                  },
                                  onSubmitted: (String value) {},
                                ),
                              );
                            },
                            optionsViewBuilder: (BuildContext context,
                                void Function(DatumStoreList) onSelected,
                                Iterable<DatumStoreList> options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                    child: SizedBox(
                                        height: 52.0 * options.length,
                                        width: deviceWidth * 0.8,
                                        child: SingleChildScrollView(
                                            child: Container(
                                          color: colorWhite,
                                          // height: 100,
                                          child: Column(
                                            children: options.map((opt) {
                                              return InkWell(
                                                  onTap: () {
                                                    onSelected(opt);
                                                  },
                                                  child: Container(
                                                      padding: EdgeInsets.only(right: 0),
                                                      child: Card(
                                                          child: Container(
                                                        width: double.infinity,
                                                        padding: EdgeInsets.all(10),
                                                        child: Text(opt.storeName ?? ""),
                                                      ))));
                                            }).toList(),
                                          ),
                                        )))),
                              );
                            },
                          ),
                          SizedBox(
                            height: deviceHeight * 0.03,
                          ),
                          SizedBox(
                            width: deviceWidth * 0.8,
                            child: getCommonTextFormField(
                                context: context,
                                controller: _editstorecardnumber,
                                hintText: storeCardNumber,
                                validator: (text) {
                                  final value = text?.trim() ?? "";
                                  if (value.isEmpty) {
                                    return "Please enter store card number";
                                  }
                                  // else if (text.length != 12) {
                                  //   return "store number should be of 12 digits";
                                  // }
                                  else {
                                    return null;
                                  }
                                }),
                          ),
                          SizedBox(
                            height: deviceHeight * 0.03,
                          ),
                          getSmallText(or),
                          SizedBox(
                            height: deviceHeight * 0.03,
                          ),
                          UploadReceiptWidget(
                            IC_SCAN_STORE,
                            scanStoreCard,
                            () {
                              editScanBarcode();
                            },
                            width: deviceWidth * 0.8,
                          ),
                          SizedBox(
                            height: deviceHeight * 0.03,
                          ),
                          getButton(
                            Save,
                            () {
                              String userid = prefs.getString(SharedPrefHelper.USER_ID) ?? "0";
                              if (formGlobalKey.currentState?.validate() ?? false) {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                setState(() {
                                  isLoadingLocal = true;
                                });
                                bloc.userRepository
                                    .editstorecard(_editstorename.text.trim(),
                                        _editstorecardnumber.text.trim(), storecardid,
                                        storeId: storeId ?? 0)
                                    .then((value) {
                                  if (value.status == 1) {
                                    getStoreCardlist();
                                    // Navigator.pop(context);
                                    //bloc.add(CardAddedEvent());

                                    // if (mounted)
                                    //   setState(() {
                                    //     isLoadingLocal = false;
                                    //   });
                                  } else if (value.apiStatusCode == 401) {
                                    showMessage(value.message ?? "", () {
                                      setState(() {
                                        isShowMessage = false;
                                        isLoadingLocal = false;
                                        logoutaccount();
                                        return bloc.add(Login());
                                      });
                                    });
                                  } else {
                                    print(value.message);
                                    showMessage(value.message ?? "", () {
                                      setState(() {
                                        isShowMessage = false;
                                        isLoadingLocal = false;
                                        //getCategorieslist();
                                      });
                                    });
                                  }
                                });
                              }
                            },
                            width: deviceWidth * 0.8,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  Widget storeCard(String? storeImage, String? storeName, String? storeDis) {
    return Card(
      color: colorWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        height: deviceHeight * 0.26,
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                width: deviceWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  imageUrl: storeImage ?? "",
                  errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                          child: Icon(
                        Icons.error,
                        color: colortheme,
                        size: 32,
                      ))),
                  progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                      child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(value: downloadProgress.progress))),
                  imageBuilder: (context, imageProvider) => Container(
                    width: deviceWidth,
                    decoration: BoxDecoration(
                        //color: colorBackgroundButton,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        color: Colors.white,
                        image: DecorationImage(image: imageProvider, fit: BoxFit.fill)),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: VERTICAL_PADDING, horizontal: HORIZONTAL_PADDING),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: deviceWidth * 0.8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          getTitle(storeName ?? "",
                              lines: 1,
                              bold: true,
                              color: colorBlack,
                              weight: FontWeight.w600,
                              fontSize: BUTTON_FONT_SIZE),
                          /*Center(
                            child: getSmallText(
                              remainingText ?? " ",
                              color: colorBlack,
                              weight: FontWeight.w500,
                              fontSize: BUTTON_FONT_SIZE,
                            ),
                          ),*/
                          Center(
                                  child: Text(
                                    storeDis ?? "",
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: colorBlack,
                                        fontWeight: FontWeight.w500,
                                        fontSize: BUTTON_FONT_SIZE,
                                        fontFamily: "Avenir"),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getStoreCardlist() async {
    await bloc.userRepository.getStoreCardListing(int.parse(userid)).then((value) {
      if (value.status == 1) {
        storeCardList = value.data ?? [];
        print("storecardlist =");
        print(value);

        if (mounted)
          setState(() {
            isLoadingLocal = false;
          });
      } else if (value.apiStatusCode == 401) {
        showMessage(value.message ?? "", () {
          setState(() {
            isShowMessage = false;
            isLoadingLocal = false;
            logoutaccount();
            return bloc.add(Login());
          });
        });
      } else {
        print(value.message);
        showMessage(value.message ?? "", () {
          setState(() {
            isShowMessage = false;
            isLoadingLocal = false;
          });
        });
      }
    });
    }

  getStorelist() async {
    bloc.userRepository.getstorelist(searchQuery: _storename.text.trim()).then((value) {
      if (value.status == 1) {
        storeList = value.data ?? [];
        print("storelist =");
        print(value);

        // if (mounted)
        //   setState(() {
        //     isLoadingLocal = false;
        //   });
      } else if (value.apiStatusCode == 401) {
        showMessage(value.message ?? "", () {
          setState(() {
            isShowMessage = false;
            isLoadingLocal = false;
            logoutaccount();
            return bloc.add(Login());
          });
        });
      } else {
        print(value.message);
        showMessage(value.message ?? "", () {
          setState(() {
            isShowMessage = false;
            isLoadingLocal = false;
          });
        });
      }
    });
    }

  Future<void> scanBarcode() async {
    showMessage("Barcode scanner is temporarily unavailable in this build.", () {
      setState(() {
        isShowMessage = false;
      });
    });
  }

  Future<void> editScanBarcode() async {
    showMessage("Barcode scanner is temporarily unavailable in this build.", () {
      setState(() {
        isShowMessage = false;
      });
    });
  }

  Color generateRandomColor1() {
    // Define all colors you want here
    var predefinedColors = [
      colorrandom1,
      colorrandom2,
      colorrandom3,
      colorrandom4,
      colorrandom1,
      colorrandom2,
      colorrandom3,
      colorrandom4,
    ];
    Random random = Random();
    return predefinedColors[random.nextInt(predefinedColors.length)];
  }
}
