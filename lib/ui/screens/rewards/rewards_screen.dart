import 'package:cached_network_image/cached_network_image.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/models/responses/dummy_response_model.dart';
import 'package:greentill/models/responses/earn_point_response.dart';
import 'package:greentill/models/responses/get_productlist_response.dart';
import 'package:greentill/models/responses/listredeemedproduct.dart';
import 'package:greentill/models/responses/stamp_voucher_response_model.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/ui/screens/information/info_screen.dart';
import 'package:greentill/ui/screens/qrscan/qr_code_screen.dart';
import 'package:greentill/ui/screens/rewards/redeem_voucher_detail_screen.dart';
import 'package:greentill/ui/screens/rewards/redeemed_product_webview.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../utils/strings.dart';

class RewardsScreen extends BaseStatefulWidget {
  final bool isViewAll;

  const RewardsScreen({super.key, this.isViewAll = false});

  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends BaseState<RewardsScreen> with BasicScreen {
  bool _isVisible = true;
  int earnedpoints = 0;
  double totalpoints = 0.0;
  bool isLoadingLocal = true;
  bool isFirst = true;
  String currency = "";
  String userid = prefs.getString(SharedPrefHelper.USER_ID) ?? "0";
  List<PointList> pointList = [];
  List<DummyModelResponse> dummyData = [
    DummyModelResponse(
      storeLogo: '',
      reward: '50% off on next order',
      storeName: '',
      storeNumber: '',
      isClaimed: true,
    ),
    DummyModelResponse(
      storeLogo: '',
      reward: 'one free coffee',
      storeName: '',
      storeNumber: '',
      isClaimed: false,
    ),
  ];

  // List<Datumvoucherlist> voucherCardlist = [];
  List<ProductList> productCardlist = [];
  List<DatumRedeemedProductList> redeemedVoucherlist = [];
  List<ListElement> loyaltyRewardlist = [];
  final DateFormat formattercustom = DateFormat('M/yy');
  bool isVoucherLoading = true;
  bool isWalletLoading = true;
  bool isLoyaltyLoading = true;
  int totalUserPoint = 0;

  @override
  void didUpdateWidget(covariant RewardsScreen oldWidget) {
    // getreceiptlist();
    // getEarnedpoints();
    getCurrency();
    getEarnpoints();
    // getVoucherCardList();
    getRedeemedVoucherList();
    getProductCardList();
    getLoyaltyRewardRedeemedVoucherList();
    // getNotificationCount();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget buildBody(BuildContext context) {
    print("viewallvalue");
    print(widget.isViewAll);
    if (isFirst) {
      isFirst = false;
      getCurrency();
      getEarnpoints();
      // getVoucherCardList();
      getRedeemedVoucherList();
      getProductCardList();
      getLoyaltyRewardRedeemedVoucherList();
    }
    if (isLoadingLocal == true) {
      return loader();
    } else {
      return DefaultTabController(
        length: 4,
        initialIndex: 1,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: colorstorecardbackground,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(deviceHeight * 0.22),
            child: Container(
              height: deviceHeight * 0.22,
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
                padding: const EdgeInsets.only(
                    left: HORIZONTAL_PADDING,
                    right: HORIZONTAL_PADDING,
                    top: VERTICAL_PADDING,
                    bottom: 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          child: Image.asset(
                            IC_BACK_ARROW_TWO_COLOR,
                            height: 24,
                            width: 24,
                            fit: BoxFit.fill,
                          ),
                          onTap: () {
                            // Navigator.pop(context);
                            return bloc.add(HomeScreenEvent());
                          },
                        ),
                        SizedBox(
                          width: deviceWidth * 0.025,
                        ),
                        appBarHeader(
                          redeem,
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
                                  print("navigation points");
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return InfoScreen();
                                  }));
                                },
                                child: Image.asset(
                                  IC_MESSAGE_QUESTION,
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
                    SizedBox(height: deviceHeight * 0.02),
                    CoinsAvailableWidget("$totalpoints",
                        points: earnedpoints.toString(), currency: currency),
                    SizedBox(height: deviceHeight * 0.02),
                    Expanded(
                      child: TabBar(
                        labelPadding: EdgeInsets.zero,
                        unselectedLabelStyle: TextStyle(
                          color: colorAccentLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Avenir",
                        ),
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Avenir",
                            fontSize: 14),
                        indicatorColor: colortheme,
                        tabs: [
                          Tab(text: earnedPoints),
                          Tab(text: redeem),
                          Tab(text: wallet),
                          Tab(
                            text: loyaltyReward,
                          )
                        ],
                        indicatorPadding: EdgeInsets.all(0),
                        indicatorSize: TabBarIndicatorSize.label,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Container(
              width: deviceWidth,
              height: deviceHeight,
              child: Stack(
                children: [
                  TabBarView(children: [
                    //Earned points
                    RefreshIndicator(
                      onRefresh: () {
                        getCurrency();
                        getEarnpoints();
                        // getVoucherCardList();
                        getProductCardList();
                        return getRedeemedVoucherList();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: VERTICAL_PADDING * 2),
                        child: ListView.separated(
                          padding: EdgeInsets.only(bottom: deviceHeight * 0.1),
                          itemCount: pointList.length ?? 0,
                          itemBuilder: (ctx, index) {
                            return earnedPointsCard(
                                "${pointList[index].count ?? 0}",
                                "${pointList[index].point ?? 0}",
                                true,
                                type: pointList[index].type ?? "",
                                logo: index == 0
                                    ? IC_SCAN_STORE
                                    : index == 1
                                        ? IC_UPLOAD_STORE
                                        : IC_LOYAL_STORE);
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(height: deviceHeight * 0.025);
                          },
                        ),
                      ),
                    ),

                    //Redeem points

                    RefreshIndicator(
                      onRefresh: () {
                        getCurrency();
                        getEarnpoints();
                        // getVoucherCardList();
                        getProductCardList();

                        return getRedeemedVoucherList();
                      },
                      child: isVoucherLoading
                          ? loader()
                          : productCardlist.length <= 0 ||
                                  productCardlist.isEmpty
                              ? Center(
                                  child: getSmallText("No voucher available!",
                                      bold: true,
                                      isCenter: true,
                                      fontSize: BUTTON_FONT_SIZE,
                                      color: colorBlack,
                                      weight: FontWeight.w500),
                                )
                              : Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: VERTICAL_PADDING * 2),
                                  child: ListView.separated(
                                    padding: EdgeInsets.only(
                                        bottom: deviceHeight * 0.1),
                                    itemCount: productCardlist.length,
                                    itemBuilder: (ctx, index) {
                                      String currencySymbol =
                                          (productCardlist[index]
                                                      .currencyCode ??
                                                  "")
                                                  .isNotEmpty
                                              ? getCurrencySymbol(
                                                  productCardlist[index]
                                                          .currencyCode ??
                                                      "")
                                              : "";
                                      return GestureDetector(
                                        onTap: () {
                                          // bloc.add(RedeemVoucherDetailEvent());
                                          // voucherCardlist[index].redeemed == true
                                          //     ? null
                                          //     :
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return RedeemVoucherDetailScreen(
                                              amount: productCardlist[index]
                                                      .amount ??
                                                  0.0,
                                              userpoints: totalUserPoint ?? 0,
                                              totalvoucherpoints:
                                                  productCardlist[index]
                                                          .points ??
                                                      0,
                                              // link:
                                              //     voucherCardlist[index]?.link ??
                                              //         "",
                                              icon: productCardlist[index]
                                                      .image ??
                                                  "",
                                              vouchername:
                                                  productCardlist[index]
                                                          .name ??
                                                      "",
                                              description:
                                                  productCardlist[index]
                                                          .description ??
                                                      "",
                                              redeemId: productCardlist[index]
                                                      .productId ??
                                                  0,
                                              currency: currencySymbol ?? "",
                                            );
                                          }));
                                        },
                                        child: redeemVoucherCard(
                                          context,
                                          amount:
                                              productCardlist[index].amount ??
                                                  0.0,
                                          userpoints: totalUserPoint ?? 0,
                                          totalvoucherpoints:
                                              productCardlist[index].points ??
                                                  0,
                                          // link: voucherCardlist[index]?.link ?? "",
                                          icon: productCardlist[index].image ??
                                              "",
                                          vouchername:
                                              productCardlist[index].name ??
                                                  "",
                                          // isRedeemed: voucherCardlist[index]?.redeemed,
                                          currency: currencySymbol ?? "",
                                          redeemId:
                                              productCardlist[index].productId,
                                        ),

                                        // redeemVoucherCard(
                                        //   context,
                                        //   amount: voucherCardlist[index]?.amount ?? 0.0,
                                        //   userpoints:
                                        //       voucherCardlist[index]?.userTotalPoints ??
                                        //           0,
                                        //   totalvoucherpoints:
                                        //       voucherCardlist[index]?.points ?? 0,
                                        //   link: voucherCardlist[index]?.link ?? "",
                                        //   icon: voucherCardlist[index]?.voucherImage ??
                                        //       "",
                                        //   vouchername:
                                        //       voucherCardlist[index]?.storeName ?? "",
                                        //   // isRedeemed: voucherCardlist[index]?.redeemed,
                                        //   currency: currency ?? "",
                                        //   redeemId:
                                        //       voucherCardlist[index]?.redeemId ?? 0,
                                        // ),
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return SizedBox(
                                          height: deviceHeight * 0.03);
                                    },
                                  ),
                                ),
                    ),

                    //wallet

                    RefreshIndicator(
                      onRefresh: () {
                        getCurrency();
                        getEarnpoints();
                        // getVoucherCardList();
                        getProductCardList();
                        return getRedeemedVoucherList();
                      },
                      child: isWalletLoading
                          ? loader()
                          : redeemedVoucherlist.length <= 0 ||
                                  redeemedVoucherlist.isEmpty
                              ? Center(
                                  child: getSmallText("No voucher available!",
                                      bold: true,
                                      isCenter: true,
                                      fontSize: BUTTON_FONT_SIZE,
                                      color: colorBlack,
                                      weight: FontWeight.w500),
                                )
                              : Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: VERTICAL_PADDING * 2),
                                  child: ListView.separated(
                                    padding: EdgeInsets.only(
                                        bottom: deviceHeight * 0.1),
                                    itemCount: redeemedVoucherlist.length,
                                    itemBuilder: (ctx, index) {
                                      String currencySymbol =
                                          (redeemedVoucherlist[index]
                                                      .currencyCode ??
                                                  "")
                                                  .isNotEmpty
                                              ? getCurrencySymbol(
                                                  redeemedVoucherlist[index]
                                                          .currencyCode ??
                                                      "")
                                              : "";
                                      return voucherCard(context,
                                          storename: redeemedVoucherlist[index]
                                                  .name ??
                                              "",
                                          logo: redeemedVoucherlist[index]
                                                  .image ??
                                              "",
                                          // creditCardNumber:
                                          //     redeemedVoucherlist[index]?.voucherCode ??
                                          //         "",
                                          amount: (redeemedVoucherlist[index]
                                                      .amount ??
                                                  0)
                                              .toStringAsFixed(2),
                                          link: redeemedVoucherlist[index]
                                                  .link ??
                                              "",
                                          // date: createdatdate,
                                          currency: currencySymbol ?? "");
                                      // return customCreditCard(context, ,IC_ADIDAS,
                                      //     redeemedVoucherlist[index]?.voucherCode ?? "", '522', redeemedVoucherlist[index]?.amount.toStringAsFixed(2), createdatdate);
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return SizedBox(
                                          height: deviceHeight * 0.03);
                                    },
                                  ),
                                ),
                    ),

                    //Loyalty Reward
                    RefreshIndicator(
                      onRefresh: () async {
                        // getCurrency();
                        // getEarnpoints();
                        // // getVoucherCardList();
                        // getProductCardList();

                        return getLoyaltyRewardRedeemedVoucherList();
                      },
                      child: isLoyaltyLoading
                          ? loader()
                          : loyaltyRewardlist.length == 0
                              ? Center(
                                  child: Text('No Loyalty Reward Available'),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.all(20),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: loyaltyRewardlist.length,
                                  itemBuilder: (context, index) {
                                    return gridItem(
                                        context,
                                        index,
                                        loyaltyRewardlist[index].storeName ?? '',
                                        loyaltyRewardlist[index].stampImage ?? '',
                                        loyaltyRewardlist[index]
                                            .loyaltyStampVoucherId ?? 0,
                                        loyaltyRewardlist[index].storesId ?? 0,
                                        loyaltyRewardlist[index].voucherCode ?? 'No Voucher Code Available',
                                        loyaltyRewardlist[index].userId ?? 0,
                                        isClaimed: loyaltyRewardlist[index]
                                            .rewardClaimed ?? false);
                                  },
                                ),
                    ),
                  ]),
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
                                    child:
                                        customFlotingButton("Home", IC_HOME)),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return QrCodeScreen();
                                      }));
                                    },
                                    child: customFlotingButton(
                                        "Scan QR", IC_GREYQR)),
                                GestureDetector(
                                    onTap: () {
                                      // bloc.add(HomeScreenEvent());
                                      showUserQr(context,
                                          customerID: bloc.userData?.customerId
                                                  ?.toString() ??
                                              "",
                                          userQr: bloc.userData
                                                  ?.customerIdQrImage ??
                                              "",
                                          email: bloc.userData?.email ?? "");
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
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget redeemVoucherCard(BuildContext context,
      {double? amount,
      int? userpoints,
      double? totalvoucherpoints,
      String? icon,
      // String link,
      String? vouchername,
      // bool isRedeemed = false,
      String? currency,
      int? redeemId}) {
    final double safeAmount = amount ?? 0;
    final int safeUserPoints = userpoints ?? 0;
    final double safeTotalVoucherPoints = totalvoucherpoints ?? 0;
    print(totalpoints);
    print(userpoints);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
      // color: isRedeemed ? colorWhite.withOpacity(0.7) : colorWhite,
      color: colorWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        height: deviceHeight * 0.35,
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                width: deviceWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                ),
                child: CachedNetworkImage(
                  imageUrl: icon ?? "",
                  errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        //color: colorBackgroundButton,
                        // image: DecorationImage(
                        //     image: AssetImage(IC_PROFILE), fit: BoxFit.scaleDown),
                      ),
                      child: Icon(
                        Icons.error,
                        size: 32,
                        color: colortheme,
                      )
                      // getTitle("Something went wrong!",isCenter: true,fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE),
                      ),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(
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
                    width: deviceWidth,
                    decoration: BoxDecoration(
                      //color: colorBackgroundButton,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.fill),
                    ),
                  ),
                ),
                // child: Image.asset(
                //   IC_REDEEM_VOUCHER,
                //   fit: BoxFit.fill,
                // ),
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
                      width: deviceWidth * 0.65,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: getTitle(vouchername ?? "",
                                    lines: 1,
                                    color: colorBlack,
                                    weight: FontWeight.w500,
                                    fontSize: CAPTION_TEXT_FONT_SIZE),
                              ),
                              SizedBox(
                                width: deviceWidth * 0.02,
                              ),
                              getTitle("${currency ?? ""}",
                                  //"$currency 500",
                                  color: colortheme,
                                  lines: 1,
                                  fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                                  weight: FontWeight.w900,
                                  isCenter: true),
                              Flexible(
                                child: getTitle(
                                    safeAmount.toStringAsFixed(2),
                                    //"$currency 500",
                                    color: colortheme,
                                    lines: 1,
                                    fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                                    weight: FontWeight.w900,
                                    isCenter: true),
                              ),
                            ],
                          ),
                          // Spacer(),
                          // isRedeemed ? Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   crossAxisAlignment: CrossAxisAlignment.center,
                          //   children: [
                          //     getTitle(
                          //       "Redeemed",
                          //       bold: true,
                          //       isCenter: true,
                          //       weight: FontWeight.w800,
                          //       fontSize: BUTTON_FONT_SIZE,
                          //       color: colortheme,
                          //     ),
                          //   ],
                          // ):
                          Row(
                            children: [
                              getTitle(
                                "You have",
                                bold: false,
                                weight: FontWeight.w500,
                                fontSize: SUBTITLE_FONT_SIZE,
                                color: colorgreytext,
                              ),
                              Flexible(
                                child: getTitle(
                                  (safeUserPoints >= safeTotalVoucherPoints)
                                      ? " $safeTotalVoucherPoints"
                                      : " $safeUserPoints",
                                  bold: true,
                                  weight: FontWeight.w800,
                                  fontSize: BUTTON_FONT_SIZE,
                                  color: colorBlack,
                                ),
                              ),
                              Flexible(
                                child: getTitle(
                                  "/" "$safeTotalVoucherPoints" " points",
                                  bold: false,
                                  weight: FontWeight.w500,
                                  fontSize: SUBTITLE_FONT_SIZE,
                                  color: colorgreytext,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    //isRedeemed ? SizedBox():
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Image.asset(
                        //   IC_ELLIPSE,
                        //   height: 35,
                        //   width: 35,
                        // ),
                        safeUserPoints >= safeTotalVoucherPoints
                            ? CircularPercentIndicator(
                                radius: 16.0,
                                lineWidth: 2.0,
                                percent: 1.0,
                                backgroundWidth: 16,
                                progressColor: colortheme,
                                fillColor: colorpaymentbackground,
                                backgroundColor: colorpaymentbackground,
                                center: Icon(
                                  Icons.check,
                                  color: colortheme,
                                ))
                            : CircularPercentIndicator(
                                radius: 16.0,
                                lineWidth: 2.0,
                                percent: safeTotalVoucherPoints == 0
                                    ? 0.0
                                    : (safeUserPoints / safeTotalVoucherPoints)
                                        .clamp(0.0, 1.0),
                                backgroundWidth: 16,
                                progressColor: colortheme,
                                fillColor: colorpaymentbackground,
                                backgroundColor: colorpaymentbackground,
                                // center: new Icon(Icons.rotate_right)
                              ),
                        SizedBox(
                          height: 5,
                        ),
                        Flexible(
                          child: Row(
                            children: [
                              getTitle(
                                  (safeUserPoints >= safeTotalVoucherPoints)
                                      ? "$safeTotalVoucherPoints points"
                                      : "${safeTotalVoucherPoints - safeUserPoints} needed",
                                  fontSize: LARGER_DIVIDER_THICKNESS,
                                  weight: FontWeight.w600,
                                  color: colorgreytext),
                              // getTitle(" needed",
                              //     fontSize: LARGER_DIVIDER_THICKNESS,
                              //     weight: FontWeight.w500,
                              //     color: colorgreytext)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // isRedeemed
            //     ? Expanded(
            //         flex: 1,
            //         child: Container(
            //             color: colorfeedbackreceiptt,
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               children: [
            //                 getTitle(
            //                   "Redeemed",
            //                   isCenter: true,
            //                   weight: FontWeight.w500,
            //                   fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
            //                   color: colortheme,
            //                 ),
            //               ],
            //             )))
            //     : SizedBox(),
            ((safeUserPoints >= safeTotalVoucherPoints))
                ? Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(left: HORIZONTAL_PADDING),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () {
                            print("print");
                            if (safeUserPoints >= safeTotalVoucherPoints) {
                              changeLoadStatus();
                              bloc.userRepository
                                  .redeemProduct(
                                      // userid: int.parse(userid),
                                      redeemid: redeemId ?? 0)
                                  .then((value) {
                                changeLoadStatus();
                                if (value.status == 1) {
                                  print("redeem voucher successful");
                                  if (mounted)
                                    showMessage(value.message ?? "", () {
                                      setState(() {
                                        isShowMessage = false;
                                        isWalletLoading = true;
                                        isVoucherLoading = true;
                                        // Navigator.of(context)
                                        //     .popUntil(ModalRoute.withName("/"));
                                        bloc.add(RewardScreenEvent());
                                        getEarnpoints();
                                        // getVoucherCardList();
                                        getRedeemedVoucherList();
                                        getProductCardList();
                                      });
                                    });
                                } else if (value.apiStatusCode == 401) {
                                  showMessage(value.message ?? "", () {
                                    setState(() {
                                      Navigator.pop(context);
                                      isShowMessage = false;
                                      logoutaccount();
                                      return bloc.add(Login());
                                    });
                                  });
                                } else {
                                  print("redeem voucher failed ");
                                  print(value.message);
                                  if (mounted)
                                    showMessage(value.message ?? "", () {
                                      setState(() {
                                        // bloc.add(WelcomeIn());
                                        // Navigator.pop(context);
                                        isShowMessage = false;
                                        isWalletLoading = true;
                                        isVoucherLoading = true;
                                        bloc.add(RewardScreenEvent());
                                        getEarnpoints();
                                        // getVoucherCardList();
                                        getRedeemedVoucherList();
                                        getProductCardList();
                                        // Navigator.of(context)
                                        //     .popUntil(ModalRoute.withName("/"));
                                        // bloc.add(HomeScreenEvent());
                                      });
                                    });
                                }
                              });
                            }
                          },
                          child: Container(
                              width: deviceWidth * 0.3,
                              padding: EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.transparent),
                                color: colortheme,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  getTitle("Redeem",
                                      color: colorWhite,
                                      fontSize: BUTTON_FONT_SIZE,
                                      bold: true,
                                      isCenter: true,
                                      weight: FontWeight.w700),
                                  // Spacer(),
                                  SizedBox(
                                    width: deviceWidth * 0.02,
                                  ),
                                  Icon(
                                    Icons.arrow_forward_outlined,
                                    color: colorWhite,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: deviceWidth * 0.01,
                                  ),
                                ],
                              )),
                        ),
                      ),
                    ))
                : SizedBox(),
            ((safeUserPoints >= safeTotalVoucherPoints))
                ? SizedBox(
                    height: deviceHeight * 0.015,
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget voucherCard(BuildContext context,
      {String? logo,
      String? creditCardNumber,
      String? cvv,
      String? amount,
      String? date,
      String? currency,
      String? link,
      String? storename}) {
    return GestureDetector(
      onTap: () {
        if ((link ?? "").isNotEmpty) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return RedeemedProductWebview(
              link: link ?? "",
              title: storename ?? "",
            );
          }));
        } else {
          showMessage('Something went wrong!', () {
            setState(() {
              isShowMessage = false;
            });
          });
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
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
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: logo ?? "",
                    errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          //color: colorBackgroundButton,
                          // image: DecorationImage(
                          //     image: AssetImage(IC_PROFILE), fit: BoxFit.scaleDown),
                        ),
                        child: Center(
                            child: Icon(
                          Icons.error,
                          color: colortheme,
                          size: 32,
                        ))
                        // getTitle("Something went wrong!",isCenter: true,fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE),
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
                      width: deviceWidth,
                      decoration: BoxDecoration(
                        //color: colorBackgroundButton,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.fill),
                      ),
                    ),
                  ),
                  // child: Image.asset(
                  //   IC_REDEEM_VOUCHER,
                  //   fit: BoxFit.fill,
                  // ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: VERTICAL_PADDING,
                      horizontal: HORIZONTAL_PADDING),
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
                            Row(
                              children: [
                                Flexible(
                                  child: getTitle(storename ?? "",
                                      lines: 1,
                                      color: colorBlack,
                                      weight: FontWeight.w500,
                                      fontSize: CAPTION_TEXT_FONT_SIZE),
                                ),
                                SizedBox(
                                  width: deviceWidth * 0.02,
                                ),
                                getTitle("${currency ?? ""}",
                                    //"$currency 500",
                                    color: colortheme,
                                    lines: 1,
                                    fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                                    weight: FontWeight.w900,
                                    isCenter: true),
                                Flexible(
                                  child: getTitle(amount ?? "",
                                      //"$currency 500",
                                      color: colortheme,
                                      lines: 1,
                                      fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                                      weight: FontWeight.w900,
                                      isCenter: true),
                                ),
                              ],
                            ),
                            // Spacer(),
                            // isRedeemed ? Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   crossAxisAlignment: CrossAxisAlignment.center,
                            //   children: [
                            //     getTitle(
                            //       "Redeemed",
                            //       bold: true,
                            //       isCenter: true,
                            //       weight: FontWeight.w800,
                            //       fontSize: BUTTON_FONT_SIZE,
                            //       color: colortheme,
                            //     ),
                            //   ],
                            // ):
                            // Row(
                            //   children: [
                            //     Flexible(
                            //       child: SelectableText(
                            //         creditCardNumber ?? "",
                            //         style: TextStyle(
                            //           fontWeight: FontWeight.w500,
                            //           fontSize: BUTTON_FONT_SIZE,
                            //           color: colorBlack,
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // )
                          ],
                        ),
                      ),
                      //isRedeemed ? SizedBox():
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     getSmallText(
                      //       expiryDate,
                      //       color: colorBlack,
                      //       weight: FontWeight.w400,
                      //       fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                      //     ),
                      //     // getSmallText(
                      //     //   date,
                      //     //   color: colorBlack,
                      //     //   weight: FontWeight.w400,
                      //     //   fontSize: BUTTON_FONT_SIZE,
                      //     // ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getEarnpoints() async {
    bloc.userRepository
        .getearnpoints(userid: int.parse(userid))
        .then((value) {
      if (value.status == 1) {
        //youtubeVideosResponse = value;
        if (mounted)
          setState(() {
            isLoadingLocal = false;
            earnedpoints = value.data?.earnedPoints ?? 0;
            totalpoints = value.data?.totalPoints ?? 0.0;
            pointList = value.data?.pointList ?? [];
            print("earnpoints" + earnedpoints.toString());
            print(pointList);
          });
        // if (mounted)
        //   setState(() {
        //     isLoadingLocal = false;
        //   });
      } else if (value.apiStatusCode == 401) {
        showMessage(value.message ?? "", () {
          if (mounted)
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
          if (mounted)
            setState(() {
              isShowMessage = false;
              isLoadingLocal = false;
            });
        });
      }
    });
    }

  // getVoucherCardList() async {
  //   if (userid != null) {
  //     bloc.userRepository
  //         .getvouchercard(userid: int.parse(userid))
  //         .then((value) {
  //       if (value.status == 1) {
  //         setState(() {
  //           isLoadingLocal = false;
  //           isVoucherLoading = false;
  //           voucherCardlist = value.data ?? [];
  //           print("vouchercardlist");
  //           print(voucherCardlist);
  //         });
  //         // if (mounted)
  //         //   setState(() {
  //         //     isLoadingLocal = false;
  //         //   });
  //       } else if (value.apiStatusCode == 401) {
  //         showMessage(value.message ?? "", () {
  //           setState(() {
  //             isShowMessage = false;
  //             isVoucherLoading = false;
  //             logoutaccount();
  //             isLoadingLocal = false;
  //             return bloc.add(Login());
  //           });
  //         });
  //       } else {
  //         print(value.message);
  //         showMessage(value.message ?? "", () {
  //           setState(() {

  //             isShowMessage = false;
  //             isLoadingLocal = false;
  //             isVoucherLoading = false;
  //           });
  //         });
  //       }
  //     });
  //   }
  // }

  getRedeemedVoucherList() async {
    print('REDEEM');
    bloc.userRepository.getredeemedproductist().then((value) {
      if (value.status == 1) {
        if (mounted)
          setState(() {
            isLoadingLocal = false;
            isWalletLoading = false;
            redeemedVoucherlist = value.data ?? [];
            print("redeemedvoucher");
            print(redeemedVoucherlist);
          });
        // if (mounted)
        //   setState(() {
        //     isLoadingLocal = false;
        //   });
      } else if (value.apiStatusCode == 401) {
        showMessage(value.message ?? "", () {
          if (mounted)
            setState(() {
              isShowMessage = false;
              isWalletLoading = false;
              logoutaccount();
              isLoadingLocal = false;
              return bloc.add(Login());
            });
        });
      } else {
        print(value.message);
        showMessage(value.message ?? "", () {
          if (mounted)
            setState(() {
              isShowMessage = false;
              isLoadingLocal = false;
              isWalletLoading = false;
            });
        });
      }
    });
    }

  ///Loyalty Reward Function
  getLoyaltyRewardRedeemedVoucherList() async {
    bloc.userRepository.getStampVoucherList().then((value) {
      print('STATUS VALUER ${value.status}');
      if (value.status == 1) {
        if (mounted)
          setState(() {
            isLoadingLocal = false;
            isWalletLoading = false;
            isLoyaltyLoading = false;
            loyaltyRewardlist = value.data?.list ?? [];
          });
        print("Loyalty Reward");
        print(loyaltyRewardlist);
        // if (mounted)
        //   setState(() {
        //     isLoadingLocal = false;
        //   });
      } else if (value.apiStatusCode == 401) {
        showMessage(value.message ?? "", () {
          if (mounted)
            setState(() {
              isShowMessage = false;
              isWalletLoading = false;
              logoutaccount();
              isLoadingLocal = false;
              isLoyaltyLoading = false;
              return bloc.add(Login());
            });
        });
      } else {
        print(value.message);
        showMessage(value.message ?? "", () {
          if (mounted)
            setState(() {
              isShowMessage = false;
              isLoadingLocal = false;
              isWalletLoading = false;
              isLoyaltyLoading = false;
            });
        });
      }
    });
    }

  getCurrency() {
    currency = (bloc.userData?.currency ?? "").isNotEmpty
        ? getCurrencySymbol(bloc.userData?.currency ?? "")
        : "\€";
  }

  getProductCardList() async {
    bloc.userRepository.getproductlist().then((value) {
      if (value.status == 1) {
        setState(() {
          isLoadingLocal = false;
          isVoucherLoading = false;
          productCardlist = value.data?.productList ?? [];
          totalUserPoint = value.data?.userTotalPoints ?? 0;
          print("productCardlist");
          print(productCardlist);
        });
        // if (mounted)
        //   setState(() {
        //     isLoadingLocal = false;
        //   });
      } else if (value.apiStatusCode == 401) {
        showMessage(value.message ?? "", () {
          setState(() {
            isShowMessage = false;
            isVoucherLoading = false;
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
            isVoucherLoading = false;
          });
        });
      }
    });
    }

  gridItem(
    BuildContext context,
    int index,
    String storeName,
    String storeLogo,
    int loyaltyStampVoucherId,
    int storesId,
    String voucherCode,
    int userId, {
    bool isstorelogoavailable = true,
    bool isClaimed = true,
  }) {
    return isClaimed == true
        ? Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black)),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 8.0),
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
                                height: deviceHeight * 0.05,
                                width: deviceWidth * 0.10,
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
                                          errorWidget: (context, url, error) =>
                                              Container(
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
                                                child: getSmallText(
                                                    getInitials(storeName),
                                                    weight: FontWeight.w500,
                                                    align: TextAlign.center,
                                                    color: colorBlack,
                                                    fontSize:
                                                        BODY1_TEXT_FONT_SIZE)),
                                          ),
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              Center(
                                                  child: SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: CircularProgressIndicator(
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
                                              color: colorWhite,
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              image: DecorationImage(
                                                  alignment: Alignment.center,
                                                  image: imageProvider,
                                                  fit: BoxFit.scaleDown),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: getSmallText(storeLogo,
                                            weight: FontWeight.w500,
                                            align: TextAlign.center,
                                            color: colorBlack,
                                            fontSize: BODY1_TEXT_FONT_SIZE),
                                      ),
                              ),

                              // SizedBox(width: deviceWidth * 0.010),
                              Text(
                                storeName,
                                style: TextStyle(fontSize: 9),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              )
                              // getSmallText(storeName ?? "",
                              //     weight: FontWeight.w500,
                              //     align: TextAlign.center,
                              //     fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                              //     color: colorBlack,
                              //     bold: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    getCommonDivider(),
                    SizedBox(
                      height: 25,
                    ),
                  ],
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          width: 150,
                          height: 50,
                          color: Colors.grey,
                          child: Center(
                              child: Text(
                            'Claimed',
                            style: TextStyle(color: Colors.white),
                          ))),
                    ],
                  ),
                )
              ],
            ),
          )
        : FlipCard(
            front: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 6.0, right: 6.0, top: 6.0),
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
                                height: deviceHeight * 0.05,
                                width: deviceWidth * 0.10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: colorbordercoupons),
                                  // color: Colors.black,
                                  // image: widget.isCoupons
                                  //     ? DecorationImage(image: AssetImage(widget.logo))
                                  //     : null
                                ),
                                child: isstorelogoavailable
                                    ? Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: CachedNetworkImage(
                                          imageUrl: storeLogo ?? "",
                                          errorWidget: (context, url, error) =>
                                              Container(
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
                                                child: getSmallText(
                                                    getInitials(storeName),
                                                    weight: FontWeight.w500,
                                                    align: TextAlign.center,
                                                    color: colorBlack,
                                                    fontSize:
                                                        BODY1_TEXT_FONT_SIZE)),
                                          ),
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              Center(
                                                  child: SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress))),
                                          // placeholder: (context, url) => Container(
                                          //   decoration: BoxDecoration(
                                          //     color: colorBackgroundButton,
                                          //     borderRadius: BorderRadius.circular(18),
                                          //     image: DecorationImage(
                                          //         image: AssetImage(IC_PROFILE_IMAGE),
                                          //         fit: BoxFit.cover) ,
                                          //   ),
                                          // ),
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              color: colorWhite,
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              image: DecorationImage(
                                                  alignment: Alignment.center,
                                                  image: imageProvider,
                                                  fit: BoxFit.scaleDown),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: getSmallText(storeLogo,
                                            weight: FontWeight.w500,
                                            align: TextAlign.center,
                                            color: colorBlack,
                                            fontSize: BODY1_TEXT_FONT_SIZE),
                                      ),
                              ),

                              // SizedBox(width: deviceWidth * 0.010),
                              Text(
                                storeName,
                                style: TextStyle(fontSize: 9),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              )
                              // getSmallText(storeName ?? "",
                              //     weight: FontW eight.w500,
                              //     align: TextAlign.center,
                              //     fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                              //     color: colorBlack,
                              //     bold: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    getCommonDivider(),
                    SizedBox(
                      height: 25,
                    ),
                    GestureDetector(
                      onTap: () {
                        print("print");
                        print('DATA FOR SUBMIT ${loyaltyStampVoucherId},${storesId},${userId},${voucherCode}');
                        changeLoadStatus();
                        bloc.userRepository
                            .redeemStamp(
                                // userid: int.parse(userid),
                                loyaltyStampVoucherId,
                                storesId,
                                userId,
                                voucherCode)
                            .then((value) {
                          changeLoadStatus();
                          if (value.status == 1) {
                            print("redeem voucher successful");
                            if (mounted)
                              showMessage(value.message ?? "", () {
                                setState(() {
                                  isShowMessage = false;
                                  isWalletLoading = true;
                                  isVoucherLoading = true;
                                  // Navigator.of(context)
                                  //     .popUntil(ModalRoute.withName("/"));
                                  bloc.add(RewardScreenEvent());
                                  getEarnpoints();
                                  // getVoucherCardList();
                                  getRedeemedVoucherList();
                                  getProductCardList();
                                  getLoyaltyRewardRedeemedVoucherList();
                                });
                              });
                          } else if (value.status == 401) {
                            showMessage(value.message ?? "", () {
                              setState(() {
                                Navigator.pop(context);
                                isShowMessage = false;
                                logoutaccount();
                                return bloc.add(Login());
                              });
                            });
                          } else {
                            print("redeem voucher failed ");
                            print(value.message);
                            if (mounted)
                              showMessage(value.message ?? "", () {
                                setState(() {
                                  // bloc.add(WelcomeIn());
                                  // Navigator.pop(context);
                                  isShowMessage = false;
                                  isWalletLoading = true;
                                  isVoucherLoading = true;
                                  bloc.add(RewardScreenEvent());
                                  getEarnpoints();
                                  // getVoucherCardList();
                                  getRedeemedVoucherList();
                                  getProductCardList();
                                  getLoyaltyRewardRedeemedVoucherList();
                                  // Navigator.of(context)
                                  //     .popUntil(ModalRoute.withName("/"));
                                  // bloc.add(HomeScreenEvent());
                                });
                              });
                          }
                        });
                                            },
                      child: Container(
                          width: deviceWidth * 0.3,
                          padding: EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.transparent),
                            color: colortheme,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              getTitle("Redeem",
                                  color: colorWhite,
                                  fontSize: BUTTON_FONT_SIZE,
                                  bold: true,
                                  isCenter: true,
                                  weight: FontWeight.w700),
                              // Spacer(),
                              SizedBox(
                                width: deviceWidth * 0.02,
                              ),
                              Icon(
                                Icons.arrow_forward_outlined,
                                color: colorWhite,
                                size: 20,
                              ),
                              SizedBox(
                                width: deviceWidth * 0.01,
                              ),
                            ],
                          )),
                    )
                  ],
                )),
            back: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(child: Text(voucherCode)),
              ),
            ));
  }
}
