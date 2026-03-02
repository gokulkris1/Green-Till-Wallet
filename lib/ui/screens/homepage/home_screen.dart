import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/main.dart';
import 'package:greentill/models/responses/home_page_response.dart';
import 'package:greentill/models/responses/store_card_response.dart';
import 'package:greentill/models/responses/store_list_response.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/ui/screens/coupons/coupons_detail_screen.dart';
import 'package:greentill/ui/screens/loyalty_details/loyalty_details_screen.dart';
import 'package:greentill/ui/screens/qrscan/qr_code_screen.dart';
import 'package:greentill/ui/screens/receipt/receipt_detail_screen.dart';
import 'package:greentill/ui/screens/rewards/redeem_voucher_detail_screen.dart';
import 'package:greentill/ui/screens/shopping_list/shopping_link_webview.dart';
import 'package:greentill/ui/screens/surveys/survey_detail_screen.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/shared_pref_helper.dart';
import 'package:intl/intl.dart';

class HomeScreen extends BaseStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseState<HomeScreen>
    with BasicScreen, WidgetsBindingObserver {
  List<SliderList> bannerList = [];
  late ScrollController _hideButtonController;
  bool _isVisible = true;
  int _selectedIndex = 0;
  bool isLoadingLocal = true;
  List<DatumStoreList> storeList = [];
  List<DatumStoreCardList> storeCardList2 = [];
  bool isFirst = true;
  bool isStoreDeleteLoading = false;
  final TextEditingController _editstorename = TextEditingController();
  final TextEditingController _editstorecardnumber = TextEditingController();
  String? editselectedname;
  // bool isCouponsLoading = true;
  // bool isReceiptLoading = true;
  // bool isStoreLoading = true;
  String userid = prefs.getString(SharedPrefHelper.USER_ID) ?? "0";
  // List<Datumcoupon> couponsList = [];
  // List<Datum> receiptlist = [];
  // List<DatumStoreCardList> storeCardList = [];
  List<CouponList> couponsList = [];
  List<ReceiptList> receiptlist = [];
  List<StoreCardList> storeCardList = [];
  List<ShoppingList> shoppingLinkList = [];
  List<RedeemList> voucherCardlist = [];
  List<SurveyList> surveylist = [];
  int earnedpoints = 0;
  int unreadnotification = 0;
  double totalpoints = 0.0;
  final DateFormat formatter = DateFormat('dd MMM yyyy');
  int activeIndex = 0;
  int? selectedStoreId;
  String currency = "";
  Timer? timer;
  final formGlobalKey = GlobalKey<FormState>();
  static String _displayStringForOption(DatumStoreList option) =>
      option.storeName ?? "";

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _isVisible = true;
    _hideButtonController = new ScrollController();
    _hideButtonController.addListener(() {
      _scrollListner();
    });
    timer = Timer.periodic(Duration(seconds: 5),
        (Timer t) => isNotificationArrives ? getNotificationCountt() : null);
    //FirebaseMessagingService().init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        getNotificationCountt();
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
      case AppLifecycleState.hidden:
        print("app in hidden");
        break;
    }
  }

  void _scrollListner() {
    if (_hideButtonController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isVisible == true) {
        /* only set when the previous state is false
             * Less widget rebuilds
             */
        print("**** ${_isVisible} up"); //Move IO away from setState
        setState(() {
          _isVisible = false;
        });
      }
    } else {
      if (_hideButtonController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (_isVisible == true) {
          /* only set when the previous state is false
               * Less widget rebuilds
               */
          print("**** ${_isVisible} down"); //Move IO away from setState
          setState(() {
            _isVisible = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _hideButtonController.removeListener(() {
      _scrollListner();
    });
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    // getreceiptlist();
    // getEarnedpoints();
    getHomelist();
    getCurrency();
    // getNotificationCount();
    super.didUpdateWidget(oldWidget);
  }

  Widget customCarouselSlider(String images, String link) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING / 4),
      child: Container(
        margin: EdgeInsets.only(top: 8),
        height: MediaQuery.of(context).size.height * 0.18,
        width: MediaQuery.of(context).size.width,
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(10),
        //   image: DecorationImage(
        //     image: images == null
        //         ? const AssetImage(IC_HOME_BANNER)
        //         :  NetworkImage(images),
        //     fit: BoxFit.fill,
        //   ),
        // ),
        child: Stack(
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              // margin: EdgeInsets.only(bottom: 12),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              child: GestureDetector(
                onTap: () async {
                  print("link" + link);
                  if (link != null || link != "") {
                    if (await canLaunchUrl(Uri.parse(link)))
                      await launchUrl(Uri.parse(link));
                    else {
                      print("wrongurl");
                      showMessage('Something went wrong!', () {
                        setState(() {
                          isShowMessage = false;
                        });
                      });
                    }
                    // can't launch url, there is some error
                  } else {
                    print("wrongurl2");
                    showMessage('Something went wrong!', () {
                      setState(() {
                        isShowMessage = false;
                      });
                    });
                  }
                },
                child: CachedNetworkImage(
                  imageUrl: images,
                  errorWidget: (context, url, error) => Center(
                      child: Icon(
                    Icons.error,
                    color: colortheme,
                  )),

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
                    // margin: EdgeInsets.only(top: 8),
                    height: MediaQuery.of(context).size.height * 0.18,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: colorWhite,
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.fill),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    if (isFirst) {
      isFirst = false;
      getprofile();
      // getCouponslist();
      // getreceiptlist();
      // getStoreCardlist();
      // getEarnedpoints();
      getHomelist();
      getNotificationCountt();
    }
    var size = MediaQuery.of(context).size;
    return isLoadingLocal == true
        ? loader()
        :
        // : bloc.userData.country == null || bloc.userData.country == ""?EditProfileScreen():
        Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: gpLight,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(deviceHeight * 0.07),
              child: Container(
                  height: deviceHeight * 0.07,
                  width: deviceWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15)),
                    color: gpLight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: HORIZONTAL_PADDING,
                        vertical: VERTICAL_PADDING),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            return bloc.add(SideMenu());
                            //onProfileImageClicked();
                          },
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Center(
                                child: bloc.userData?.profileImage != null
                                    ? Container(
                                        height: 36,
                                        width: 36,
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              bloc.userData?.profileImage ?? "",
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              //borderRadius:
                                              //BorderRadius.circular(18),
                                              color: gpLight,
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      IC_GREENTILL_IMAGE),
                                                  fit: BoxFit.cover),
                                            ),
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
                                              color: gpLight,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                        ),
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
                                          //     fit: BoxFit.cover),
                                        ),
                                        child: Center(
                                            child: getSmallText(
                                                getInitials(
                                                    bloc.userData?.firstName ??
                                                        ""),
                                                weight: FontWeight.w500,
                                                align: TextAlign.center,
                                                color: gpTextPrimary,
                                                fontSize:
                                                    BODY1_TEXT_FONT_SIZE)),
                                      ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  bottom: 0,
                                ),
                                child: Image.asset(
                                  IC_MORE,
                                  height: 18,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: deviceWidth * 0.3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Image.asset(
                              //   IC_GRAPH_ICON1,
                              //   height: deviceHeight * 0.032,
                              //   width: deviceWidth * 0.065,
                              //   fit: BoxFit.fitHeight,
                              // ),
                              GestureDetector(
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      IC_NOTIFICATION,
                                      height: deviceHeight * 0.032,
                                      width: deviceWidth * 0.065,
                                      fit: BoxFit.fitHeight,
                                    ),
                                    Positioned(
                                        right: 0,
                                        child:
                                            // unreadnotification !=null && unreadnotification != 0 ?
                                            unreadnotification != 0
                                                ? Container(
                                                    padding: EdgeInsets.all(1),
                                                    decoration:
                                                        new BoxDecoration(
                                                      color: gpError,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    constraints: BoxConstraints(
                                                      minWidth: 12,
                                                      minHeight: 12,
                                                    ),
                                                    child: Text(
                                                      '$unreadnotification',
                                                      style: new TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 8,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ))
                                                : SizedBox())
                                    // :SizedBox(),
                                  ],
                                ),
                                onTap: () {
                                  bloc.add(NotificationEvent());
                                },
                              ),
                              // Image.asset(
                              //   IC_MESSAGE,
                              //   height: deviceHeight * 0.032,
                              //   width: deviceWidth * 0.065,
                              //   fit: BoxFit.fitHeight,
                              // ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
            ),
            body: SafeArea(
              child: Container(
                height: deviceHeight,
                width: deviceWidth,
                child: Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification is ScrollEndNotification) {
                          if (_isVisible == false) {
                            setState(() {
                              _isVisible = true;
                            });
                          }
                        }
                        return true;
                      },
                      child: RefreshIndicator(
                        color: gpGreen,
                        onRefresh: () {
                          print("refreshindicator");
                          getprofile();
                          // getCouponslist();
                          // getreceiptlist();
                          // getStoreCardlist();
                          return getHomelist();
                        },
                        child: SingleChildScrollView(
                          controller: _hideButtonController,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: deviceHeight * 0.01,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: HORIZONTAL_PADDING,
                                    vertical: VERTICAL_PADDING),
                                child: CoinsAvailableWidget("$totalpoints",
                                    points: earnedpoints.toString(),
                                    currency: currency),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: HORIZONTAL_PADDING,
                                    top: VERTICAL_PADDING,
                                    bottom: VERTICAL_PADDING),
                                child: HomeScreenTabRow(() {
                                  bloc.add(ReceiptEvent());
                                }, () {
                                  bloc.add(CouponsEvent());
                                }, () {
                                  bloc.add(RewardScreenEvent());
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(builder: (context) {
                                  //     return RewardsScreen();
                                  //   }),
                                  // );
                                }, () {
                                  bloc.add(StoreCardEvent());
                                }, () {
                                  bloc.add(ShoppingLinkEvent());
                                }, () {
                                  bloc.add(SurveyEvent());
                                }),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: HORIZONTAL_PADDING),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              bloc.add(QrCodeEvent());
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border:
                                                    Border.all(color: gpBorder),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  getSmallText("MVP core flow",
                                                      color: gpTextSecondary,
                                                      fontSize:
                                                          CAPTION_SMALLER_TEXT_FONT_SIZE,
                                                      weight: FontWeight.w600,
                                                      lines: 1),
                                                  const SizedBox(height: 4),
                                                  getSmallText(
                                                      "Capture Receipt",
                                                      color: gpTextPrimary,
                                                      fontSize:
                                                          CAPTION_TEXT_FONT_SIZE,
                                                      weight: FontWeight.w700,
                                                      lines: 1),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              bloc.add(ReceiptEvent());
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border:
                                                    Border.all(color: gpBorder),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  getSmallText(
                                                      "Organise expenses",
                                                      color: gpTextSecondary,
                                                      fontSize:
                                                          CAPTION_SMALLER_TEXT_FONT_SIZE,
                                                      weight: FontWeight.w600,
                                                      lines: 1),
                                                  const SizedBox(height: 4),
                                                  getSmallText(
                                                      "Receipt History",
                                                      color: gpTextPrimary,
                                                      fontSize:
                                                          CAPTION_TEXT_FONT_SIZE,
                                                      weight: FontWeight.w700,
                                                      lines: 1),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              bloc.add(AuditReportsEvent());
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border:
                                                    Border.all(color: gpBorder),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  getSmallText(
                                                      "Accounting export",
                                                      color: gpTextSecondary,
                                                      fontSize:
                                                          CAPTION_SMALLER_TEXT_FONT_SIZE,
                                                      weight: FontWeight.w600,
                                                      lines: 1),
                                                  const SizedBox(height: 4),
                                                  getSmallText("Audit Reports",
                                                      color: gpTextPrimary,
                                                      fontSize:
                                                          CAPTION_TEXT_FONT_SIZE,
                                                      weight: FontWeight.w700,
                                                      lines: 1),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              bloc.add(TaxSummaryEvent());
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border:
                                                    Border.all(color: gpBorder),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  getSmallText(
                                                      vatReclaimSummary,
                                                      color: gpTextSecondary,
                                                      fontSize:
                                                          CAPTION_SMALLER_TEXT_FONT_SIZE,
                                                      weight: FontWeight.w600,
                                                      lines: 1),
                                                  const SizedBox(height: 4),
                                                  getSmallText("Tax Summary",
                                                      color: gpTextPrimary,
                                                      fontSize:
                                                          CAPTION_TEXT_FONT_SIZE,
                                                      weight: FontWeight.w700,
                                                      lines: 1),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              bloc.add(BillingEvent());
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border:
                                                    Border.all(color: gpBorder),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  getSmallText("Trial / Pro",
                                                      color: gpTextSecondary,
                                                      fontSize:
                                                          CAPTION_SMALLER_TEXT_FONT_SIZE,
                                                      weight: FontWeight.w600,
                                                      lines: 1),
                                                  const SizedBox(height: 4),
                                                  getSmallText("Billing",
                                                      color: gpTextPrimary,
                                                      fontSize:
                                                          CAPTION_TEXT_FONT_SIZE,
                                                      weight: FontWeight.w700,
                                                      lines: 1),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: HORIZONTAL_PADDING,
                                    vertical: 0),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.18,
                                  width: MediaQuery.of(context).size.width,
                                  child: CarouselSlider(
                                      options: CarouselOptions(
                                        viewportFraction: 1,
                                        initialPage: 0,
                                        enableInfiniteScroll: false,
                                        autoPlayCurve: Curves.fastOutSlowIn,
                                        autoPlayAnimationDuration:
                                            const Duration(milliseconds: 800),
                                        autoPlay: true,
                                        enlargeCenterPage: false,
                                        onPageChanged: (index, reason) {
                                          setState(() {
                                            activeIndex = index;
                                          });
                                        },
                                      ),
                                      items: List.generate(
                                          bannerList.length,
                                          (index) => customCarouselSlider(
                                              bannerList[index].sliderImage ??
                                                  "",
                                              bannerList[index].sliderLink ??
                                                  ""))),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Center(
                                child: Container(
                                  child: AnimatedSmoothIndicator(
                                    effect: WormEffect(
                                      spacing: 5,
                                      dotHeight: 7,
                                      dotWidth: 7,
                                      type: WormType.normal,
                                      strokeWidth: 0.2,
                                      activeDotColor: colorbannerdots,
                                      dotColor: colorgreytext.withOpacity(0.2),
                                    ),
                                    activeIndex: activeIndex,
                                    count: bannerList.length,
                                    // count: bannerList.length,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Card(
                                margin: EdgeInsets.symmetric(
                                  horizontal: HORIZONTAL_PADDING,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: gpBorder, width: 0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                elevation: 1,
                                child: Container(
                                  width: deviceWidth,
                                  decoration: BoxDecoration(
                                      color: gpLight,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 18.0,
                                            offset: Offset(0.0, 0.05))
                                      ],
                                      border: Border.all(color: gpBorder),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: HORIZONTAL_PADDING,
                                        vertical: VERTICAL_PADDING * 2),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            getTitle(
                                              receipt,
                                              weight: FontWeight.w700,
                                              fontSize: SUBTITLE_FONT_SIZE,
                                              color: gpTextPrimary,
                                            ),
                                            Spacer(),
                                            GestureDetector(
                                              onTap: () {
                                                bloc.add(ReceiptEvent());
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color:
                                                      gpGreen.withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          999),
                                                  border: Border.all(
                                                      color: gpGreen
                                                          .withOpacity(0.35)),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.add,
                                                      size: 14,
                                                      color: gpGreen,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    getSmallText(
                                                      "Add receipt",
                                                      fontSize:
                                                          CAPTION_SMALLER_TEXT_FONT_SIZE,
                                                      color: gpGreen,
                                                      weight: FontWeight.w600,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (!receiptlist.isEmpty) ...[
                                              const SizedBox(width: 10),
                                              GestureDetector(
                                                onTap: () {
                                                  bloc.add(ReceiptEvent());
                                                },
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    getSmallText(viewAllcontent,
                                                        weight: FontWeight.w600,
                                                        align: TextAlign.center,
                                                        fontSize:
                                                            CAPTION_SMALLER_TEXT_FONT_SIZE,
                                                        color: gpInfo,
                                                        bold: true),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Image.asset(
                                                      IC_ARROW,
                                                      height: 18,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: receiptlist.length <= 0 ||
                                                  receiptlist.isEmpty
                                              ? Center(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      getSmallText(
                                                          "No receipts yet. Add your first receipt to start organising expenses.",
                                                          bold: true,
                                                          isCenter: true,
                                                          align:
                                                              TextAlign.center,
                                                          lines: 3,
                                                          fontSize:
                                                              BUTTON_FONT_SIZE,
                                                          color:
                                                              gpTextSecondary,
                                                          weight:
                                                              FontWeight.w500),
                                                      const SizedBox(
                                                          height: 12),
                                                      getButton(
                                                        "Add receipt",
                                                        () {
                                                          bloc.add(
                                                              ReceiptEvent());
                                                        },
                                                        width:
                                                            deviceWidth * 0.5,
                                                        height:
                                                            deviceHeight * 0.05,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : GridView.builder(
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 3,
                                                          crossAxisSpacing: 15,
                                                          mainAxisSpacing: 20,
                                                          childAspectRatio:
                                                              1.1),
                                                  itemCount:
                                                      receiptlist.length > 6
                                                          ? 6
                                                          : receiptlist.length,
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (context, index) {
                                                    String createdatdate = formatter
                                                        .format(receiptlist[
                                                                    index]
                                                                .purchaseDate ??
                                                            DateTime.now())
                                                        .toString();
                                                    return GestureDetector(
                                                      onTap: () {
                                                        print("in progress" +
                                                            receiptlist[index]
                                                                .inProgress
                                                                .toString());
                                                        if (receiptlist[index]
                                                                .inProgress ==
                                                            true) {
                                                          return null;
                                                        } else {
                                                          bloc.add(
                                                              ReceiptEvent());
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) {
                                                            return ReceiptDetailScreen(
                                                              url: receiptlist[
                                                                          index]
                                                                      .path ??
                                                                  "",
                                                              receiptid: receiptlist[
                                                                          index]
                                                                      .receiptId ??
                                                                  0,
                                                              receiptName: receiptlist[
                                                                          index]
                                                                      .storeName
                                                                      .toString() ??
                                                                  "",
                                                              description: receiptlist[
                                                                          index]
                                                                      .description
                                                                      .toString() ??
                                                                  "",
                                                              storeLocation: receiptlist[
                                                                          index]
                                                                      .storeLocation
                                                                      .toString() ??
                                                                  "",
                                                              currency: receiptlist[
                                                                          index]
                                                                      .currency
                                                                      .toString() ??
                                                                  "",
                                                              amount: receiptlist[
                                                                          index]
                                                                      .amount
                                                                      .toString() ??
                                                                  "",
                                                              purchaseDate: receiptlist[
                                                                          index]
                                                                      .purchaseDate
                                                                      .toString() ??
                                                                  "",
                                                              warrantycardslist:
                                                                  receiptlist[
                                                                          index]
                                                                      .warrantyCards,
                                                              isHome: true,
                                                              receiptFromType:
                                                                  receiptlist[index]
                                                                          .receiptFromType ??
                                                                      "",
                                                              tagType: receiptlist[
                                                                          index]
                                                                      .tagType ??
                                                                  "",
                                                              storeid: receiptlist[
                                                                          index]
                                                                      .storesId ??
                                                                  null,
                                                            );
                                                          }));
                                                        }
                                                      },
                                                      child: MyreceiptGridItem(
                                                        receiptlist[index]
                                                                .storeLogo ??
                                                            "",
                                                        receiptlist[index]
                                                                .storeName ??
                                                            "",
                                                        createdatdate,
                                                        inprogress: receiptlist[
                                                                    index]
                                                                .inProgress ??
                                                            false,
                                                        isstorelogoavailable:
                                                            (receiptlist[index]
                                                                            .storeLogo ??
                                                                        "")
                                                                    .isEmpty
                                                                ? false
                                                                : true,
                                                        isDuplicate:
                                                            receiptlist[index]
                                                                    .duplicate ??
                                                                false,
                                                        tagType:
                                                            receiptlist[index]
                                                                    .tagType ??
                                                                "",
                                                      ),
                                                    );
                                                  }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Card(
                                margin: EdgeInsets.symmetric(
                                  horizontal: HORIZONTAL_PADDING,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: gpBorder, width: 0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                elevation: 1,
                                child: Container(
                                  width: deviceWidth,
                                  decoration: BoxDecoration(
                                      color: gpLight,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            blurRadius: 30.0,
                                            offset: Offset(0.0, 0.05))
                                      ],
                                      border: Border.all(color: gpBorder),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        right: 0,
                                        top: VERTICAL_PADDING,
                                        bottom: VERTICAL_PADDING,
                                        left: HORIZONTAL_PADDING),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: HORIZONTAL_PADDING),
                                          child: HeaderViewAll(loyaltyCards,
                                              () {
                                            bloc.add(
                                                StoreCardEvent()); // Navigator.push(context,
                                            //     MaterialPageRoute(
                                            //         builder: (context) {
                                            //   return StoreCardScreen();
                                            // }));
                                            // showMessage("Coming Soon!", () {
                                            //   setState(() {
                                            //     isShowMessage = false;
                                            //     //getprofile();
                                            //   });
                                            // });
                                            // bloc.add(StoreC());
                                          },
                                              isEmpty: storeCardList.isEmpty
                                                  ? true
                                                  : false),
                                        ),
                                        Container(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          height: deviceHeight * 0.12,
                                          width: deviceWidth,
                                          child: storeCardList.length <= 0 ||
                                                  storeCardList.isEmpty
                                              ? Center(
                                                  child: getSmallText(
                                                      "Add your store cards!",
                                                      bold: true,
                                                      isCenter: true,
                                                      fontSize:
                                                          BUTTON_FONT_SIZE,
                                                      color: gpTextSecondary,
                                                      weight: FontWeight.w500),
                                                )
                                              : ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  shrinkWrap: true,
                                                  primary: false,
                                                  itemCount:
                                                      storeCardList.length > 6
                                                          ? 6
                                                          : storeCardList
                                                              .length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    print(
                                                        'IS SELECTED ${storeCardList[index].storeLoyaltyPartner}');
                                                    return Padding(
                                                      padding: EdgeInsets.only(
                                                        right: 14.0,
                                                      ),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (storeCardList[
                                                                      index]
                                                                  .storeLoyaltyPartner ==
                                                              true) {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) {
                                                              return LoyaltyDetailsScreen(
                                                                  storeCardList:
                                                                      storeCardList[
                                                                          index]);
                                                            }));
                                                          } else {
                                                            openCard(context, storeCardList[index].storeCardId ?? 0,
                                                                storeName:
                                                                    storeCardList[index].storeName ??
                                                                        "",
                                                                storeLogo:
                                                                    storeCardList[index].storeLogo ??
                                                                        "",
                                                                storeId: storeCardList[index].storeId == ""
                                                                    ? null
                                                                    : storeCardList[index]
                                                                        .storeId,
                                                                storeNumber:
                                                                    storeCardList[index].storeNumber ??
                                                                        "",
                                                                barcodeImage:
                                                                    storeCardList[index]
                                                                        .barcodeImage,
                                                                isstorelogoavailable:
                                                                    (storeCardList[index].storeLogo ?? "")
                                                                        .isNotEmpty,
                                                                totalStampsCount:
                                                                    storeCardList[index].requiredStampsForReward ??
                                                                        0,
                                                                storeLoyaltyPartner:
                                                                    storeCardList[index].storeLoyaltyPartner ??
                                                                        false,
                                                                stampImage:
                                                                    storeCardList[index].stampImage ??
                                                                        "",
                                                                requiredStampsForReward:
                                                                    storeCardList[index].requiredStampsForReward ??
                                                                        0,
                                                                loyaltyVoucherGenerated:
                                                                    storeCardList[index].loyaltyVoucherGenerated ??
                                                                        false,
                                                                currentStamps:
                                                                    storeCardList[index].currentStamps ?? 0

                                                                //
                                                                );
                                                          }
                                                        },
                                                        child:
                                                            StoreCardListHome(
                                                          storeCardList[index]
                                                                  .storeLogo ??
                                                              "",
                                                          storeCardList[index]
                                                                  .storeName ??
                                                              "",
                                                          isstorelogoavailable:
                                                              (storeCardList[index]
                                                                          .storeLogo ??
                                                                      "")
                                                                  .isNotEmpty,
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Card(
                                margin: EdgeInsets.symmetric(
                                  horizontal: HORIZONTAL_PADDING,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: gpBorder, width: 0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                elevation: 1,
                                child: Container(
                                  width: deviceWidth,
                                  decoration: BoxDecoration(
                                      color: gpLight,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            blurRadius: 30.0,
                                            offset: Offset(0.0, 0.05))
                                      ],
                                      border: Border.all(color: gpBorder),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        right: 0,
                                        top: VERTICAL_PADDING,
                                        bottom: VERTICAL_PADDING,
                                        left: HORIZONTAL_PADDING),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: HORIZONTAL_PADDING),
                                          child: HeaderViewAll(myRewards, () {
                                            bloc.add(RewardScreenEvent());
                                            // Navigator.push(context,
                                            //     MaterialPageRoute(
                                            //         builder: (context) {
                                            //   return RewardsScreen();
                                            // }));
                                            // showMessage("Coming Soon!", () {
                                            //   setState(() {
                                            //     isShowMessage = false;
                                            //     //getprofile();
                                            //   });
                                            // });
                                          },
                                              isEmpty: voucherCardlist.isEmpty
                                                  ? true
                                                  : false),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child:
                                              voucherCardlist.length <= 0 ||
                                                      voucherCardlist.isEmpty
                                                  ? Center(
                                                      child: getSmallText(
                                                          "No rewards available!",
                                                          bold: true,
                                                          isCenter: true,
                                                          fontSize:
                                                              BUTTON_FONT_SIZE,
                                                          color: colorBlack,
                                                          weight:
                                                              FontWeight.w500),
                                                    )
                                                  : Container(
                                                      height:
                                                          deviceHeight * 0.12,
                                                      width: deviceWidth,
                                                      child: ListView.builder(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          shrinkWrap: true,
                                                          primary: false,
                                                          itemCount:
                                                              voucherCardlist
                                                                  .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            String
                                                                currencySymbol =
                                                                (voucherCardlist[index].currencyCode ??
                                                                            "")
                                                                        .isNotEmpty
                                                                    ? getCurrencySymbol(
                                                                        voucherCardlist[index].currencyCode ??
                                                                            "")
                                                                    : "";
                                                            return Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                right: 14.0,
                                                              ),
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  // voucherCardlist[index].redeemed == true
                                                                  //     ? null
                                                                  //     :
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder:
                                                                              (context) {
                                                                    return RedeemVoucherDetailScreen(
                                                                      amount:
                                                                          voucherCardlist[index].amount ??
                                                                              0.0,
                                                                      userpoints:
                                                                          earnedpoints ??
                                                                              0,
                                                                      totalvoucherpoints:
                                                                          voucherCardlist[index].points ??
                                                                              0,
                                                                      // link:
                                                                      // voucherCardlist[index]?.link ??
                                                                      //     "",
                                                                      icon: voucherCardlist[index]
                                                                              .image ??
                                                                          "",
                                                                      vouchername:
                                                                          voucherCardlist[index].name ??
                                                                              "",
                                                                      description:
                                                                          voucherCardlist[index].description ??
                                                                              "",
                                                                      redeemId:
                                                                          voucherCardlist[index].productId ??
                                                                              0,
                                                                      currency:
                                                                          currencySymbol ??
                                                                              "",
                                                                    );
                                                                  }));
                                                                },
                                                                child: MyRewardItemList(
                                                                    voucherCardlist[index]
                                                                            .image ??
                                                                        "",
                                                                    voucherCardlist[index]
                                                                            .name ??
                                                                        "", () {
                                                                  // setState(() {
                                                                  //   _selectedIndex = index;
                                                                  //   print("selectedindex" +
                                                                  //       _selectedIndex
                                                                  //           .toString());
                                                                  // });
                                                                  // claimRewardsBottomSheet(
                                                                  //     context,
                                                                  //     rewardsContent,
                                                                  //     () {});
                                                                },
                                                                    _selectedIndex ==
                                                                            index
                                                                        ? true
                                                                        : false),
                                                              ),
                                                            );
                                                          }),
                                                    ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Card(
                                margin: EdgeInsets.symmetric(
                                  horizontal: HORIZONTAL_PADDING,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: colormyreceiptbordercolor,
                                      width: 0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                elevation: 1,
                                child: Container(
                                  width: deviceWidth,
                                  decoration: BoxDecoration(
                                      color: colorWhite,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            blurRadius: 30.0,
                                            offset: Offset(0.0, 0.05))
                                      ],
                                      border: Border.all(
                                          color: colormyreceiptbordercolor),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        right: 0,
                                        top: VERTICAL_PADDING,
                                        bottom: VERTICAL_PADDING,
                                        left: HORIZONTAL_PADDING),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: HORIZONTAL_PADDING),
                                          child: HeaderViewAll(latestCoupon,
                                              () {
                                            bloc.add(CouponsEvent());
                                          },
                                              isEmpty: couponsList.isEmpty
                                                  ? true
                                                  : false),
                                        ),
                                        Container(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          height: deviceHeight * 0.145,
                                          width: deviceWidth,
                                          child:
                                              couponsList.length <= 0 ||
                                                      couponsList.isEmpty
                                                  ? Center(
                                                      child: getSmallText(
                                                          "No offers available!",
                                                          bold: true,
                                                          isCenter: true,
                                                          fontSize:
                                                              BUTTON_FONT_SIZE,
                                                          color: colorBlack,
                                                          weight:
                                                              FontWeight.w500),
                                                    )
                                                  : ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      shrinkWrap: true,
                                                      primary: false,
                                                      itemCount:
                                                          couponsList.length > 6
                                                              ? 6
                                                              : couponsList
                                                                  .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        String currencysymbol = (couponsList[
                                                                            index]
                                                                        .currency ??
                                                                    "")
                                                                .isNotEmpty
                                                            ? getCurrencySymbol(
                                                                couponsList[index]
                                                                        .currency ??
                                                                    "")
                                                            : "";
                                                        return Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            right: 14.0,
                                                          ),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) {
                                                                return CouponsDetailsScreen(
                                                                  storeName:
                                                                      couponsList[index]
                                                                              .storeName ??
                                                                          "",
                                                                  discount:
                                                                      couponsList[index]
                                                                              .freeText ??
                                                                          "",
                                                                  storelogo:
                                                                      couponsList[index]
                                                                              .storeLogo ??
                                                                          "",
                                                                  barcodeimage:
                                                                      couponsList[index]
                                                                              .barcodeImage ??
                                                                          "",
                                                                  barcodenumber:
                                                                      couponsList[index]
                                                                              .couponCode ??
                                                                          "",
                                                                  fromdate: couponsList[
                                                                          index]
                                                                      .fromDate,
                                                                  todate: couponsList[
                                                                          index]
                                                                      .toDate,
                                                                  backgroundimage:
                                                                      couponsList[index]
                                                                              .backgroundImage ??
                                                                          "",
                                                                  description:
                                                                      couponsList[index]
                                                                              .description ??
                                                                          "",
                                                                  currency:
                                                                      currencysymbol ??
                                                                          "",
                                                                  discounttype:
                                                                      couponsList[index]
                                                                              .discountType ??
                                                                          "",
                                                                  couponlink:
                                                                      couponsList[index]
                                                                              .couponLink ??
                                                                          "",
                                                                );
                                                              }));
                                                            },
                                                            child:
                                                                LatestCouponListHome(
                                                              (couponsList[index]
                                                                              .storeLogo ??
                                                                          "")
                                                                      .isEmpty
                                                                  ? getInitials(
                                                                          couponsList[index].storeName ??
                                                                              "") ??
                                                                      ""
                                                                  : (couponsList[
                                                                              index]
                                                                          .storeLogo ??
                                                                      ""),
                                                              couponsList[index]
                                                                      .storeName ??
                                                                  "",
                                                              offerpercent: (couponsList[
                                                                              index]
                                                                          .freeText ??
                                                                      "") +
                                                                  ((couponsList[index].discountType ??
                                                                              "") ==
                                                                          "PERCENTAGE"
                                                                      ? "%"
                                                                      : (couponsList[index].discountType ?? "") ==
                                                                              "AMOUNT"
                                                                          ? currencysymbol
                                                                          : ""),
                                                              isstorelogoavailable:
                                                                  (couponsList[index]
                                                                              .storeLogo ??
                                                                          "")
                                                                      .isNotEmpty,
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Card(
                                margin: EdgeInsets.symmetric(
                                  horizontal: HORIZONTAL_PADDING,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: colormyreceiptbordercolor,
                                      width: 0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                elevation: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: colorWhite,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            blurRadius: 30.0,
                                            offset: Offset(0.0, 0.05))
                                      ],
                                      border: Border.all(
                                          color: colormyreceiptbordercolor),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: HORIZONTAL_PADDING,
                                      vertical: VERTICAL_PADDING),
                                  // decoration: const BoxDecoration(
                                  //     color: colorstorecardbackground,
                                  //     borderRadius:
                                  //         BorderRadius.all(Radius.circular(5))),
                                  child: Column(
                                    children: [
                                      HeaderViewAll(shoppinglinks, () {
                                        bloc.add(ShoppingLinkEvent());
                                      },
                                          isEmpty: shoppingLinkList.isEmpty
                                              ? true
                                              : false),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 12, bottom: 6),
                                        child: shoppingLinkList.length <= 0 ||
                                                shoppingLinkList.isEmpty
                                            ? Center(
                                                child: getSmallText(
                                                    "No shopping link available!",
                                                    bold: true,
                                                    isCenter: true,
                                                    fontSize: BUTTON_FONT_SIZE,
                                                    color: colorBlack,
                                                    weight: FontWeight.w500),
                                              )
                                            : GridView.builder(
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 3,
                                                        crossAxisSpacing: 15,
                                                        mainAxisSpacing: 8,
                                                        childAspectRatio: 1.4),
                                                itemCount:
                                                    shoppingLinkList.length > 6
                                                        ? 6
                                                        : shoppingLinkList
                                                                .length ??
                                                            0,
                                                shrinkWrap: true,
                                                itemBuilder: (context, index) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      if (shoppingLinkList[
                                                                  index]
                                                              .link !=
                                                          "") {
                                                        Navigator.push(context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                          return ShoppingLinkWebview(
                                                            link: shoppingLinkList[
                                                                        index]
                                                                    .link ??
                                                                "",
                                                            title: shoppingLinkList[
                                                                        index]
                                                                    .storeName ??
                                                                "",
                                                          );
                                                        }));
                                                      } else {
                                                        showMessage(
                                                            'Something went wrong!',
                                                            () {
                                                          setState(() {
                                                            isShowMessage =
                                                                false;
                                                          });
                                                        });
                                                      }
                                                    },
                                                    child: MyShoppingLinkGridItem(
                                                        shoppingLinkList[index]
                                                                .storeLogo ??
                                                            "",
                                                        shoppingLinkList[index]
                                                                .storeName ??
                                                            "",
                                                        isSurvey: false),
                                                  );
                                                }),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Card(
                                margin: EdgeInsets.symmetric(
                                  horizontal: HORIZONTAL_PADDING,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: colormyreceiptbordercolor,
                                      width: 0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                elevation: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: colorWhite,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            blurRadius: 30.0,
                                            offset: Offset(0.0, 0.05))
                                      ],
                                      border: Border.all(
                                          color: colormyreceiptbordercolor),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: HORIZONTAL_PADDING,
                                      vertical: VERTICAL_PADDING),
                                  // decoration: const BoxDecoration(
                                  //     color: colorstorecardbackground,
                                  //     borderRadius:
                                  //         BorderRadius.all(Radius.circular(5))),
                                  child: Column(
                                    children: [
                                      HeaderViewAll(Surveysheader, () {
                                        bloc.add(SurveyEvent());
                                      },
                                          isEmpty: surveylist.isEmpty
                                              ? true
                                              : false),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 12, bottom: 6),
                                        child: surveylist.length <= 0 ||
                                                surveylist.isEmpty
                                            ? Center(
                                                child: getSmallText(
                                                    "No survey available!",
                                                    bold: true,
                                                    isCenter: true,
                                                    fontSize: BUTTON_FONT_SIZE,
                                                    color: colorBlack,
                                                    weight: FontWeight.w500),
                                              )
                                            : GridView.builder(
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 3,
                                                        crossAxisSpacing: 15,
                                                        mainAxisSpacing: 8,
                                                        childAspectRatio: 1.4),
                                                itemCount: surveylist.length > 6
                                                    ? 6
                                                    : surveylist.length ?? 0,
                                                shrinkWrap: true,
                                                itemBuilder: (context, index) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      if ((surveylist[index]
                                                                  .surveyLink ??
                                                              "")
                                                          .isNotEmpty) {
                                                        Navigator.push(context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                          return SurveyScreenWebview(
                                                              link: surveylist[
                                                                          index]
                                                                      .surveyLink ??
                                                                  "",
                                                              title: surveylist[
                                                                          index]
                                                                      .title ??
                                                                  "");
                                                        }));
                                                      } else {
                                                        showMessage(
                                                            'Something went wrong!',
                                                            () {
                                                          setState(() {
                                                            isShowMessage =
                                                                false;
                                                          });
                                                        });
                                                      }
                                                    },
                                                    child:
                                                        MyShoppingLinkGridItem(
                                                            IC_SURVEY_GREEN,
                                                            surveylist[index]
                                                                    .title ??
                                                                "",
                                                            isSurvey: true),
                                                  );
                                                }),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: deviceHeight * 0.15,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                        child: Visibility(
                      visible: _isVisible,
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
                                          // bloc.add(HomeScreenEvent());
                                        },
                                        child: customFlotingButton(
                                            "Home", IC_HOME)),
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
                                          showUserQr(context,
                                              customerID: bloc
                                                      .userData?.customerId
                                                      ?.toString() ??
                                                  "",
                                              userQr: bloc.userData
                                                      ?.customerIdQrImage ??
                                                  "",
                                              email:
                                                  bloc.userData?.email ?? "");
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
                      ),
                      replacement: Padding(
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
                              width: deviceWidth * 0.15,
                              decoration: BoxDecoration(
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 30.0,
                                      offset: Offset(0.0, 0.05))
                                ],
                                // border: Border.all(color: colortheme),
                                color: colortheme,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Image.asset(
                                  IC_GREYQR,
                                  height: deviceHeight * 0.04,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ))
                  ],
                ),
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
        print("value.statusprofile");
        print(value.status);
        showMessage(value.message ?? "", () {
          if (mounted)
            setState(() {
              isShowMessage = false;
              isLoadingLocal = false;
              //getprofile();
            });
        });
      }
    });
  }

  // getCouponslist() async {
  //   bloc.userRepository
  //       .getCouponsList(sortby: "NEW_ADDED", categoryid: []).then((value) {
  //     if (value.status == 1) {
  //       //youtubeVideosResponse = value;
  //       couponsList = value.data;
  //
  //       if (mounted)
  //         setState(() {
  //           isCouponsLoading = false;
  //         });
  //     } else if (value.apiStatusCode == 401) {
  //       showMessage(value.message ?? "", () {
  //         setState(() {
  //           isShowMessage = false;
  //           logoutaccount();
  //           isCouponsLoading = false;
  //           return bloc.add(Login());
  //         });
  //       });
  //     } else {
  //       print(value.message);
  //       showMessage(value.message ?? "", () {
  //         setState(() {
  //           isShowMessage = false;
  //           isCouponsLoading = false;
  //         });
  //       });
  //     }
  //   });
  // }

  String getInitials(String bank_account_name) => bank_account_name.isNotEmpty
      ? bank_account_name.trim().split(' ').map((l) => l[0]).take(1).join()
      : '';

  // getreceiptlist() async {
  //   String userid = prefs.getString(SharedPrefHelper.USER_ID);
  //
  //   if (userid != null) {
  //     bloc.userRepository.getreceiptList(int.parse(userid)).then((value) {
  //       if (value.status == 1) {
  //         //youtubeVideosResponse = value;
  //         receiptlist = value.data;
  //         print("receiptlist =");
  //         print(value);
  //
  //         if (mounted)
  //           setState(() {
  //             isReceiptLoading = false;
  //           });
  //       } else if (value.apiStatusCode == 401) {
  //         showMessage(value.message ?? "", () {
  //           setState(() {
  //             isShowMessage = false;
  //             logoutaccount();
  //             isReceiptLoading = false;
  //             return bloc.add(Login());
  //           });
  //         });
  //       } else {
  //         print(value.message);
  //         showMessage(value.message ?? "", () {
  //           setState(() {
  //             isShowMessage = false;
  //             isReceiptLoading = false;
  //           });
  //         });
  //       }
  //     });
  //   }
  // }

  // getEarnedpoints() async {
  //   String userid = prefs.getString(SharedPrefHelper.USER_ID);
  //
  //   if (userid != null) {
  //     bloc.userRepository
  //         .gettotalpoints(userid: int.parse(userid))
  //         .then((value) {
  //       if (value.status == 1) {
  //         //youtubeVideosResponse = value;
  //         if(mounted)
  //         setState(() {
  //           earnedpoints = value.data?.earnedPoints ?? 0.0;
  //           print("valuepoints" + earnedpoints.toString());
  //           isLoadingLocal = false;
  //         });
  //       } else if (value.apiStatusCode == 401) {
  //         showMessage(value.message ?? "", () {
  //           setState(() {
  //             isShowMessage = false;
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
  //           });
  //         });
  //       }
  //     });
  //   }
  // }

  // getStoreCardlist() async {
  //   String userid = prefs.getString(SharedPrefHelper.USER_ID);
  //
  //   if (userid != null) {
  //     bloc.userRepository.getStoreCardListing(int.parse(userid)).then((value) {
  //       if (value.status == 1) {
  //         storeCardList = value.data;
  //         // print("storecardlist =");
  //         // print(value);
  //
  //         if (mounted)
  //           setState(() {
  //             isStoreLoading = false;
  //           });
  //       } else if (value.apiStatusCode == 401) {
  //         showMessage(value.message ?? "", () {
  //           setState(() {
  //             isShowMessage = false;
  //             isStoreLoading = false;
  //             logoutaccount();
  //             return bloc.add(Login());
  //           });
  //         });
  //       } else {
  //         print(value.message);
  //         showMessage(value.message ?? "", () {
  //           setState(() {
  //             isShowMessage = false;
  //             isStoreLoading = false;
  //           });
  //         });
  //       }
  //     });
  //   }
  // }

  getHomelist() async {
    String userid = prefs.getString(SharedPrefHelper.USER_ID);

    bloc.userRepository
        .getHomePageList(userid: int.parse(userid))
        .then((value) {
      if (value.status == 1) {
        print("receiptlist =");
        print(value);

        if (mounted)
          setState(() {
            isLoadingLocal = false;
            receiptlist = value.data?.receiptList ?? [];
            couponsList = value.data?.couponList ?? [];
            storeCardList = value.data?.storeCardList ?? [];
            shoppingLinkList = value.data?.shoppingList ?? [];
            earnedpoints = value.data?.earnedPoints ?? 0;
            totalpoints = value.data?.totalPoints ?? 0.0;
            voucherCardlist = value.data?.redeemList ?? [];
            bannerList = value.data?.sliderList ?? [];
            surveylist = value.data?.surveyList ?? [];
          });
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
        print("value.message");
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

  void openCard(BuildContext context, int storecardid,
      {String? storeLogo,
      String? storeName,
      int? storeId,
      String? storeNumber,
      String? barcodeImage,
      double? currentStamps,
      int? totalStampsCount,
      int? requiredStampsForReward,
      String? stampImage,
      bool? storeLoyaltyPartner,
      bool? loyaltyVoucherGenerated,
      bool isstorelogoavailable = false}) {
    final String safeStoreName = storeName ?? "";
    final String safeStoreLogo = storeLogo ?? "";
    final String safeStampImage = stampImage ?? "";
    final int requiredStamps = requiredStampsForReward ?? 0;
    final int currentStampCount = (currentStamps ?? 0).toInt();
    showDialog(
        context: context,
        builder: (ctx) {
          return storeLoyaltyPartner == true
              ? FlipCard(
                  front: Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12.0, right: 12.0, top: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                      height: deviceHeight * 0.07,
                                      width: deviceWidth * 0.13,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: colorbordercoupons),
                                        color: colorWhite,
                                        // image: widget.isCoupons
                                        //     ? DecorationImage(image: AssetImage(widget.logo))
                                        //     : null
                                      ),
                                      child: isstorelogoavailable
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: CachedNetworkImage(
                                                imageUrl: storeLogo ?? "",
                                                errorWidget:
                                                    (context, url, error) =>
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
                                                          getInitials(
                                                              safeStoreName),
                                                          weight:
                                                              FontWeight.w500,
                                                          align:
                                                              TextAlign.center,
                                                          color: colorBlack,
                                                          fontSize:
                                                              BODY1_TEXT_FONT_SIZE)),
                                                ),
                                                progressIndicatorBuilder: (context,
                                                        url,
                                                        downloadProgress) =>
                                                    Center(
                                                        child: SizedBox(
                                                            height: 20,
                                                            width: 20,
                                                            child: CircularProgressIndicator(
                                                                value: downloadProgress
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
                                                        BorderRadius.circular(
                                                            100),
                                                    image: DecorationImage(
                                                        alignment:
                                                            Alignment.center,
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
                                                  fontSize:
                                                      BODY1_TEXT_FONT_SIZE))),
                                  SizedBox(width: deviceWidth * 0.025),
                                  getSmallText(storeName ?? "",
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
                                  margin: EdgeInsets.only(
                                      top: 3, bottom: 3, right: 5),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: colorGrey4, width: 1),
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
                        SizedBox(height: deviceHeight * 0.01),
                        storeLoyaltyPartner == true
                            ? SizedBox(
                                height: 10,
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                    right: 16.0, bottom: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      child: Image.asset(IC_EDIT_STORE),
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
                                        logoutBottomSheet(context, deleteCard,
                                            () {
                                          Navigator.pop(context);
                                        }, () {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          setState(() {
                                            isStoreDeleteLoading = true;
                                          });
                                          bloc.userRepository
                                              .deletestorecard(
                                                  storecardid: storecardid)
                                              .then((value) {
                                            if (value.status == 1) {
                                              setState(() {
                                                isStoreDeleteLoading = false;
                                              });

                                              bloc.add(CardDeletedEvent());
                                            } else if (value.apiStatusCode ==
                                                401) {
                                              showMessage(value.message ?? "",
                                                  () {
                                                setState(() {
                                                  isShowMessage = false;
                                                  logoutaccount();
                                                  isStoreDeleteLoading = false;
                                                  return bloc.add(Login());
                                                });
                                              });
                                            } else {
                                              print(value.message);
                                              showMessage(value.message ?? "",
                                                  () {
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
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Center(
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
                        getTitle(storeNumber ?? "",
                            lines: 1,
                            weight: FontWeight.w800,
                            fontSize: SUBTITLE_FONT_SIZE,
                            color: colorbarcodetext),
                        SizedBox(height: deviceHeight * 0.02),
                      ],
                    ),
                  ),
                  back: Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12.0, right: 12.0, top: 12.0),
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
                                      border:
                                          Border.all(color: colorbordercoupons),
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
                                              errorWidget:
                                                  (context, url, error) =>
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
                                                        getInitials(
                                                            safeStoreName),
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
                                                              value: downloadProgress
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
                                                      BorderRadius.circular(
                                                          100),
                                                  image: DecorationImage(
                                                      alignment:
                                                          Alignment.center,
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
                                  getSmallText(storeName ?? "",
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
                                  margin: EdgeInsets.only(
                                      top: 3, bottom: 3, right: 5),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: colorGrey4, width: 1),
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 15,
                              crossAxisSpacing: 15,
                            ),
                            itemCount: requiredStamps,
                            itemBuilder: (context, index) {
                              print('BENTELLY $requiredStamps');
                              if (index == requiredStamps - 1) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: colortheme, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: index <= (currentStampCount - 1)
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
                              } else if (index <= requiredStamps) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: colortheme, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: index <= (currentStampCount - 1)
                                        ? Stack(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                child:
                                                    Image.asset(IC_CHECKMARK),
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
                                              )
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
                                    border:
                                        Border.all(color: colortheme, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                        '${currentStampCount == 0 ? '' : currentStampCount}'),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, right: 12.0, top: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                    height: deviceHeight * 0.07,
                                    width: deviceWidth * 0.13,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(color: colorbordercoupons),
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
                                              errorWidget:
                                                  (context, url, error) =>
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
                                                        getInitials(
                                                            safeStoreName),
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
                                                              value: downloadProgress
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
                                                      BorderRadius.circular(
                                                          100),
                                                  image: DecorationImage(
                                                      alignment:
                                                          Alignment.center,
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
                                                fontSize:
                                                    BODY1_TEXT_FONT_SIZE))),
                                SizedBox(width: deviceWidth * 0.025),
                                getSmallText(storeName ?? "",
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
                                margin: EdgeInsets.only(
                                    top: 3, bottom: 3, right: 5),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: colorGrey4, width: 1),
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
                      SizedBox(height: deviceHeight * 0.01),
                      Padding(
                        padding:
                            const EdgeInsets.only(right: 16.0, bottom: 16.0),
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
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Center(
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

  Future<void> editCardSheet(BuildContext context, int storecardid,
      {String? storeName, int? storeId, String? storeNumber}) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        isDismissible: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateNew) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                height: deviceHeight * 0.5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: HORIZONTAL_PADDING * 1.5,
                      vertical: VERTICAL_PADDING * 1.5),
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
                                  margin: EdgeInsets.only(
                                      top: 3, bottom: 3, right: 5),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: colorGrey4, width: 1),
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
                            initialValue: TextEditingValue(
                                text: _editstorename.text ?? ""),
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '' ||
                                  textEditingValue.text.isEmpty) {
                                print("textisempty");

                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _editstorename.text = "";
                                  if (_editstorename.text !=
                                      (editselectedname ?? "")) {
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

                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  // _editstorename.text = "";
                                  _editstorename.text = textEditingValue.text;
                                  if (_editstorename.text !=
                                      (editselectedname ?? "")) {
                                    storeId = null;
                                  }
                                  print("updatedstoreid1");
                                  print(selectedStoreId);
                                });

                                List<DatumStoreList> matches =
                                    <DatumStoreList>[];
                                matches.addAll(storeList);

                                matches.retainWhere(
                                    (DatumStoreList continent) =>
                                        (continent.storeName ?? "")
                                            .toLowerCase()
                                            .contains(textEditingValue.text
                                                .toLowerCase()));
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
                                    if ((text?.trim() ?? "").isEmpty) {
                                      return "Please enter store name";
                                    } else {
                                      return null;
                                    }
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
                                                      padding: EdgeInsets.only(
                                                          right: 0),
                                                      child: Card(
                                                          child: Container(
                                                        width: double.infinity,
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: Text(
                                                            opt.storeName ??
                                                                ""),
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
                                  if ((text?.trim() ?? "").isEmpty) {
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
                              String userid =
                                  prefs.getString(SharedPrefHelper.USER_ID);
                              if (formGlobalKey.currentState?.validate() ??
                                  false) {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                setState(() {
                                  isLoadingLocal = true;
                                });
                                bloc.userRepository
                                    .editstorecard(
                                        _editstorename.text.trim(),
                                        _editstorecardnumber.text.trim(),
                                        storecardid,
                                        storeId: storeId ?? null)
                                    .then((value) {
                                  if (value.status == 1) {
                                    getStoreCardlist();
                                    getHomelist();
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

  getStoreCardlist() async {
    await bloc.userRepository
        .getStoreCardListing(int.parse(userid))
        .then((value) {
      if (value.status == 1) {
        storeCardList2 = value.data ?? [];
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

  Future<void> editScanBarcode() async {
    showMessage("Barcode scanner is temporarily unavailable in this build.",
        () {
      setState(() {
        isShowMessage = false;
      });
    });
  }

  getCurrency() {
    currency = (bloc.userData?.currency ?? "").isNotEmpty
        ? getCurrencySymbol(bloc.userData?.currency ?? "")
        : "\€";
  }

  getNotificationCountt() {
    print("apicount");
    bloc.userRepository.getNotificationCount().then((value) {
      if (value.status == 1) {
        print("notificationcount =");
        print(value);

        if (mounted)
          setState(() {
            // isLoadingLocal = false;
            unreadnotification = value.data ?? 0;
            isNotificationArrives = false;
          });
      } else if (value.apiStatusCode == 401) {
        showMessage(value.message ?? "", () {
          if (mounted)
            setState(() {
              isShowMessage = false;
              logoutaccount();
              // isLoadingLocal = false;
              isNotificationArrives = false;
              return bloc.add(Login());
            });
        });
      } else {
        print("notificationcount");
        print(value.message);
        showMessage(value.message ?? "", () {
          if (mounted)
            setState(() {
              isShowMessage = false;
              // isLoadingLocal = false;
              isNotificationArrives = false;
            });
        });
      }
    });
  }
}
