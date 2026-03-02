import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/models/responses/get_category_list_response.dart';
import 'package:greentill/models/responses/get_coupons_list_response.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/ui/screens/coupons/coupons_detail_screen.dart';
import 'package:greentill/ui/screens/qrscan/qr_code_screen.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:greentill/utils/strings.dart';
import 'package:intl/intl.dart';

class CouponsScreen extends BaseStatefulWidget {
  @override
  _CouponsScreenState createState() => _CouponsScreenState();
}

class _CouponsScreenState extends BaseState<CouponsScreen> with BasicScreen {
  bool isSearch = false;
  bool isSelected = false;
  bool isFirst = true;
  bool isLoadingLocal = true;
  bool isCouponsLoading = false;
  List<Datum> categoriesList = [];
  bool isCategorySelected = false;
  List selectedCategoryList = [];
  List<Datumcoupon> couponsList = [];
  String listorder = "NEW_ADDED";
  TextEditingController searchcontroller = TextEditingController();
  String addurl =
      "https://openxcell-development-public.s3.ap-south-1.amazonaws.com/greentill/development/";
  final DateFormat formatter = DateFormat('dd MMM yyyy');
  bool isFiltered = false;
  bool isSearchloading = false;
  final _debouncer = Debouncer(milliseconds: 1000);
  FocusNode? searchFocusNode;

  _onSearchChanged(String value) {
    // if (debounce?.isActive ?? false) debounce.cancel();
    // _debounce = Timer(const Duration(seconds: 1), () {
    if (searchcontroller.text.isEmpty) {
      setState(() {
        isCouponsLoading = true;
      });
      bloc.userRepository
          .getCouponsList(
          sortby: listorder,
          categoryid:
          selectedCategoryList,
          query:
          value.trim().toString())
          .then((value) {
        setState(() {
          isCouponsLoading = false;
        });
        if (value.status == 1) {
          //youtubeVideosResponse = value;
          couponsList = value.data ?? [];

          // if (mounted)
          //   setState(() {
          //     isLoadingLocal = false;
          //     isCouponsLoading = false;
          //   });
        } else if (value.apiStatusCode ==
            401) {
          showMessage(value.message ?? "", () {
            setState(() {
              isShowMessage = false;
              logoutaccount();
              isCouponsLoading = false;
              return bloc.add(Login());
            });
          });
        } else {
          print(value.message);
          showMessage(value.message ?? "", () {
            setState(() {
              isShowMessage = false;
              isCouponsLoading = false;
              bloc.add(CouponsEvent());
              //getCategorieslist();
            });
          });
        }
      });
    } else {
      setState(() {
        isCouponsLoading = true;
      });
      bloc.userRepository
          .getCouponsList(
          sortby: listorder,
          categoryid:
          selectedCategoryList,
          query:
          value.trim().toString())
          .then((value) {
        setState(() {
          isCouponsLoading = false;
        });
        if (value.status == 1) {
          //youtubeVideosResponse = value;
          couponsList = value.data ?? [];

          // if (mounted)
          //   setState(() {
          //     isLoadingLocal = false;
          //     isCouponsLoading = false;
          //   });
        } else if (value.apiStatusCode ==
            401) {
          showMessage(value.message ?? "", () {
            setState(() {
              isShowMessage = false;
              logoutaccount();
              isCouponsLoading = false;
              return bloc.add(Login());
            });
          });
        } else {
          print(value.message);
          showMessage(value.message ?? "", () {
            setState(() {
              isShowMessage = false;
              isCouponsLoading = false;
              bloc.add(CouponsEvent());
              //getCategorieslist();
            });
          });
        }
      });
    }

    // });
  }

  @override
  void initState() {
    searchFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    searchcontroller.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    if (isFirst) {
      isFirst = false;
      getCategorieslist();
      getCouponslist();
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
                          if (isSelected || isSearch) {
                            setState(() {
                              isSelected = false;
                              isSearch = false;
                              searchcontroller.clear();
                              getCouponslist();
                            });
                          } else {
                            return bloc.add(HomeScreenEvent());
                          }
                          // return bloc.add(SideMenu());
                        },
                      ),
                      SizedBox(
                        width: deviceWidth * 0.025,
                      ),
                      appBarHeader(
                        isSearch ? search : coupon,
                        fontSize: BUTTON_FONT_SIZE,
                        bold: false,
                      ),
                      Spacer(),
                      Container(
                        width: deviceWidth * 0.21,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            isSearch
                                ? SizedBox()
                                : GestureDetector(
                                    child: Image.asset(
                                      IC_SEARCH,
                                      height: deviceHeight * 0.032,
                                      width: deviceWidth * 0.065,
                                      fit: BoxFit.fitHeight,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        isSearch = true;
                                        searchFocusNode?.requestFocus();
                                      });
                                    },
                                  ),
                            GestureDetector(
                              onTap: () {
                                if (isSearch) {
                                  receiptCoupons(context);
                                }
                              },
                              child: Image.asset(
                                isSearch ? IC_FILTER : IC_MESSAGE_QUESTION,
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
              child: Stack(
                children: [
                  Container(
                    height: deviceHeight,
                    width: deviceWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isSearch
                            ? Container(
                                height: deviceHeight * 0.14,
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
                                          border: Border.all(
                                              color: colorgreyborder),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                        child: TextField(
                                          controller: searchcontroller,
                                          focusNode: searchFocusNode,
                                          onChanged: (value) {
                                            _debouncer.run(() {
                                              _onSearchChanged(searchcontroller.text.trim());
                                            });
                                            // searchcontroller.text =
                                            //     value.toString();
                                            // setState(() {
                                            //   isCouponsLoading = true;
                                            // });
                                            // bloc.userRepository
                                            //     .getCouponsList(
                                            //         sortby: listorder,
                                            //         categoryid:
                                            //             selectedCategoryList,
                                            //         query:
                                            //             value.trim().toString())
                                            //     .then((value) {
                                            //   setState(() {
                                            //     isCouponsLoading = false;
                                            //   });
                                            //   if (value.status == 1) {
                                            //     //youtubeVideosResponse = value;
                                            //     couponsList = value.data ?? [];
                                            //
                                            //     // if (mounted)
                                            //     //   setState(() {
                                            //     //     isLoadingLocal = false;
                                            //     //     isCouponsLoading = false;
                                            //     //   });
                                            //   } else if (value.apiStatusCode ==
                                            //       401) {
                                            //     showMessage(value.message ?? "", () {
                                            //       setState(() {
                                            //         isShowMessage = false;
                                            //         logoutaccount();
                                            //         isCouponsLoading = false;
                                            //         return bloc.add(Login());
                                            //       });
                                            //     });
                                            //   } else {
                                            //     print(value.message);
                                            //     showMessage(value.message ?? "", () {
                                            //       setState(() {
                                            //         isShowMessage = false;
                                            //         isCouponsLoading = false;
                                            //         bloc.add(CouponsEvent());
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
                                                  getCouponslist();
                                                });

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
                                      Spacer(
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                height: deviceHeight * 0.16,
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
                                  padding: EdgeInsets.only(
                                    left: HORIZONTAL_PADDING,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Spacer(
                                        flex: 3,
                                      ),
                                      getSmallText(suggestions,
                                          weight: FontWeight.w500,
                                          align: TextAlign.center,
                                          fontSize: SUBTITLE_FONT_SIZE,
                                          color: colorHomeText,
                                          bold: true),
                                      Spacer(
                                        flex: 2,
                                      ),
                                      Container(
                                        height: deviceHeight * 0.04,
                                        width: deviceWidth,
                                        child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            primary: false,
                                            itemCount: categoriesList.length,
                                            itemBuilder: (context, index) {
                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    isCouponsLoading = true;
                                                    isCategorySelected =
                                                        !isCategorySelected;
                                                    print(
                                                        "Selected Category is=");
                                                    if (selectedCategoryList
                                                        .contains(
                                                            categoriesList[
                                                                    index]
                                                                .categoryId)) {
                                                      selectedCategoryList
                                                          .remove(
                                                              categoriesList[
                                                                      index]
                                                                  .categoryId);
                                                    } else {
                                                      selectedCategoryList.add(
                                                          categoriesList[index]
                                                              .categoryId);
                                                    }
                                                    print(index);
                                                    print("category list=");
                                                    print(selectedCategoryList);
                                                    getCouponslist();
                                                  });
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    right: 14.0,
                                                  ),
                                                  child:
                                                  LatestSuggestionsListHome(
                                                    categoriesList[index]
                                                            .categoryName ??
                                                        "",
                                                    selectedCategoryList
                                                            .contains(
                                                                categoriesList[
                                                                        index]
                                                                    .categoryId)
                                                        ? colortheme
                                                        : colorbackgroundcoupons,
                                                  ),
                                                ),
                                              );
                                            }),
                                      ),
                                      Spacer()
                                    ],
                                  ),
                                ),
                              ),
                        // isSearch
                        //     ? Container(
                        //         width: deviceWidth,
                        //         color: colorMyrecieptHomeBackground,
                        //         child: Padding(
                        //           padding: const EdgeInsets.only(
                        //               right: HORIZONTAL_PADDING * 1.4,
                        //               left: HORIZONTAL_PADDING * 1.4,
                        //               top: VERTICAL_PADDING * 2,
                        //               bottom: VERTICAL_PADDING),
                        //           child: getSmallText(resultsAvailable ?? "",
                        //               weight: FontWeight.w500,
                        //               bold: true,
                        //               fontSize: FORGET_PASSWORD_TEXT_FONT_SIZE,
                        //               color: colorBlack),
                        //         ),
                        //       )
                        //     : Container(
                        //         color: colorMyrecieptHomeBackground,
                        //         height: VERTICAL_PADDING,
                        //       ),
                        Container(
                          color: colorstorecardbackground,
                          height: 8,
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: getCouponslist,
                            child: Container(
                              color: colorstorecardbackground,
                              child: isCouponsLoading
                                  ? loader()
                                  : couponsList.length <= 0 ||
                                          couponsList.isEmpty
                                      ? Center(
                                          child: getSmallText(
                                              "No offers available!",
                                              bold: true,
                                              isCenter: true,
                                              fontSize: BUTTON_FONT_SIZE,
                                              color: colorBlack,
                                              weight: FontWeight.w500),
                                        )
                                      : ListView.builder(
                                          padding: EdgeInsets.zero,
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          physics: AlwaysScrollableScrollPhysics(),
                                          primary: false,
                                          itemCount: couponsList.length,
                                          itemBuilder: (context, index) {
                                            String currencysymbol = (couponsList[index].currency ?? "").isNotEmpty
                                                ? getCurrencySymbol(couponsList[index].currency ?? "")
                                                : "";
                                            String createdatdate = formatter
                                                .format(
                                                    couponsList[index].toDate ??
                                                        DateTime.now())
                                                .toString();
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: HORIZONTAL_PADDING,
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return CouponsDetailsScreen(
                                                      storeName:
                                                          couponsList[index]
                                                              .storeName ?? "",
                                                      discount: couponsList[index]
                                                          .freeText ?? "",
                                                      storelogo:
                                                          couponsList[index]
                                                                  .storeLogo ??
                                                              "",
                                                      barcodeimage: couponsList[
                                                                  index]
                                                              .barcodeImage ??
                                                          "",
                                                      barcodenumber:
                                                          couponsList[index]
                                                                  .couponCode ??
                                                              "",
                                                      fromdate: couponsList[index].fromDate,
                                                      todate: couponsList[index].toDate,
                                                      backgroundimage: couponsList[index]
                                                          .backgroundImage ??
                                                          "",
                                                      description: couponsList[
                                                      index]
                                                          .description ?? "",
                                                      currency: currencysymbol ?? "",
                                                      discounttype: couponsList[index].discountType ?? "",
                                                      couponlink: couponsList[index].couponLink ?? "",
                                                    );
                                                  }));
                                                },
                                                child: CustomItemList(
                                                  isSelected,
                                                  (couponsList[index]
                                                              .storeLogo ??
                                                          "")
                                                      .isEmpty
                                                      ? getInitials(
                                                              couponsList[index]
                                                                      .storeName ??
                                                                  "") ??
                                                          ""
                                                      : couponsList[index]
                                                          .storeLogo ?? "",
                                                  couponsList[index].storeName ??
                                                      "",
                                                  createdatdate,
                                                  (couponsList[index].freeText ?? "") +
                                                      ((couponsList[index].discountType ?? "") == "PERCENTAGE"
                                                          ? "%"
                                                          : (couponsList[index].discountType ?? "") == "AMOUNT"
                                                              ? currencysymbol
                                                              : "")
                                                      ,
                                                  // couponsList[index]?.discountType == "PERCENTAGE"?"Discount":
                                                  // couponsList[index]?.discountType == "AMOUNT"?"Off":""
                                                  "Discount"
                                                  ,

                                                  isCoupons: true,
                                                  isstorelogoavailable:
                                                      (couponsList[index]
                                                                  .storeLogo ??
                                                              "")
                                                          .isEmpty
                                                          ? false
                                                          : true,
                                                  inprogress: false,
                                                  isLatest: false,
                                                  currency: currencysymbol ?? "",
                                                  isDuplicate: false,
                                                ),
                                              ),
                                            );
                                          }),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
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
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                        onTap: () {
                                          bloc.add(HomeScreenEvent());
                                        },
                                        child:
                                        customFlotingButton("Home", IC_HOME)),
                                    GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                                    return QrCodeScreen();
                                                  }));
                                        },
                                        child: customFlotingButton(
                                            "Scan QR", IC_GREYQR)),
                                    GestureDetector(
                                        onTap: () {
                                          // bloc.add(HomeScreenEvent());
                                          showUserQr(
                                              context,
                                              customerID: bloc
                                                      .userData?.customerId
                                                      ?.toString() ??
                                                  "",
                                              userQr:
                                                  bloc.userData?.customerIdQrImage ??
                                                      "",
                                              email: bloc.userData?.email ?? "");
                                        },
                                        child:
                                        customFlotingButton(idCard, IC_ID)),
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
                ],
              ),
            ),
          );
  }

  String getInitials(String bank_account_name) => bank_account_name.isNotEmpty
      ? bank_account_name.trim().split(' ').map((l) => l[0]).take(1).join()
      : '';

  getCategorieslist() async {
    String userid = prefs.getString(SharedPrefHelper.USER_ID);

    bloc.userRepository.getCategoryList().then((value) {
      if (value.status == 1) {
        //youtubeVideosResponse = value;
        categoriesList = value.data ?? [];
        print("categorieslist =");
        print(value);

        if (mounted)
          setState(() {
            isLoadingLocal = false;
          });
      } else if (value.apiStatusCode == 401) {
        showMessage(value.message ?? "", () {
          setState(() {
            isShowMessage = false;
            logoutaccount();
            isLoadingLocal = false;
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

  Future<void> getCouponslist() async {
    print("listvalue" + listorder);
    bloc.userRepository
        .getCouponsList(sortby: listorder, categoryid: selectedCategoryList)
        .then((value) {
      if (value.status == 1) {
        //youtubeVideosResponse = value;
        couponsList = value.data ?? [];

        if (mounted)
          setState(() {
            isLoadingLocal = false;
            isCouponsLoading = false;
          });
      } else if (value.apiStatusCode == 401) {
        showMessage(value.message ?? "", () {
          setState(() {
            isShowMessage = false;
            logoutaccount();
            isLoadingLocal = false;
            isCouponsLoading = false;
            return bloc.add(Login());
          });
        });
      } else {
        print(value.message);
        showMessage(value.message ?? "", () {
          setState(() {
            isShowMessage = false;
            isLoadingLocal = false;
            isCouponsLoading = false;
            //getCategorieslist();
          });
        });
      }
    });
  }

  Future<void> receiptCoupons(BuildContext context) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        backgroundColor: colorWhite,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateNew) {
            return Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              height: deviceHeight * 0.4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: HORIZONTAL_PADDING * 1.5,
                    vertical: VERTICAL_PADDING * 1.5),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          getSmallText(filter ?? "",
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
                              margin:
                                  EdgeInsets.only(top: 3, bottom: 3, right: 5),
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
                        height: deviceHeight * 0.025,
                      ),
                      getSmallText(sortBy ?? "",
                          weight: FontWeight.w500,
                          bold: true,
                          fontSize: SUBTITLE_FONT_SIZE,
                          color: colorHomeText),
                      SizedBox(
                        height: 8,
                      ),

                      Container(
                        // height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomRadioWidget(
                              value: "NEW_ADDED",
                              groupValue: listorder,
                              onChanged: (value) {
                                setStateNew(() {
                                  listorder = value.toString();
                                });
                              },
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            getTitle('New Offers',
                                color: colorgreytext,
                                fontSize: SUBTITLE_FONT_SIZE),
                          ],
                        ),
                      ),
                      Container(
                        // height: 30,
                        child: Row(
                          children: [
                            CustomRadioWidget(
                              value: "EXPIRES_IN_MONTH",
                              groupValue: listorder,
                              onChanged: (value) {
                                setStateNew(() {
                                  listorder = value.toString();
                                });
                              },
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            getTitle('Expires in 30 Days',
                                color: colorgreytext,
                                fontSize: SUBTITLE_FONT_SIZE),
                          ],
                        ),
                      ),
                      Container(
                        // height: 30,
                        child: Row(
                          children: [
                            CustomRadioWidget(
                              value: "EXPIRES_IN_TWO_MONTH",
                              groupValue: listorder,
                              onChanged: (value) {
                                setStateNew(() {
                                  listorder = value.toString();
                                });
                              },
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            getTitle('Expires in 60 Days',
                                color: colorgreytext,
                                fontSize: SUBTITLE_FONT_SIZE),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: deviceHeight * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          getButton("Reset", () {
                            Navigator.pop(context);
                            setState(() {
                              isCouponsLoading = true;
                              selectedCategoryList = [];
                              isSearch = false;
                            });
                            getCouponslist();
                          },
                              width: deviceWidth * 0.35,
                              color: colorWhite,
                              textColor: colorGradientFirst,
                              height: deviceHeight * 0.06),
                          SizedBox(
                            width: 10,
                          ),
                          getButton(applyFilter, () {
                            changeLoadStatus();
                            Navigator.pop(context);
                            print("listvalue" + listorder);
                            bloc.userRepository
                                .getCouponsList(
                                    sortby: listorder,
                                    categoryid: selectedCategoryList)
                                .then((value) {
                              changeLoadStatus();
                              if (value.status == 1) {
                                //youtubeVideosResponse = value;
                                couponsList = value.data ?? [];

                                if (mounted)
                                  setState(() {
                                    isLoadingLocal = false;
                                    isCouponsLoading = false;
                                  });
                              } else if (value.apiStatusCode == 401) {
                                showMessage(value.message ?? "", () {
                                  setState(() {
                                    isShowMessage = false;
                                    logoutaccount();
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
                          },
                              width: deviceWidth * 0.35,
                              height: deviceHeight * 0.06),
                        ],
                      ),

                      // SizedBox(height: deviceHeight*0.1,),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }
}
