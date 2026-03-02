import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/ui/screens/information/info_screen.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:greentill/utils/strings.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class RedeemVoucherDetailScreen extends BaseStatefulWidget {
  final double? amount;
  final int? userpoints;
  final dynamic totalvoucherpoints;
  final String? icon;
  final String? link;
  final String? vouchername;
  final String? description;
  final int? redeemId;
  final String? currency;

  const RedeemVoucherDetailScreen(
      {super.key,
        this.amount,
        this.userpoints,
        this.totalvoucherpoints,
        this.icon,
        this.link,
        this.vouchername,
        this.description,
        this.redeemId,
        this.currency});


  @override
  _RedeemVoucherDetailScreenState createState() => _RedeemVoucherDetailScreenState();
}

class _RedeemVoucherDetailScreenState
    extends BaseState<RedeemVoucherDetailScreen> with BasicScreen {
  String userid = prefs.getString(SharedPrefHelper.USER_ID) ?? "0";

  @override
  Widget buildBody(BuildContext context) {
    final double userPoints = (widget.userpoints ?? 0).toDouble();
    final double totalVoucherPoints =
        widget.totalvoucherpoints is num ? (widget.totalvoucherpoints as num).toDouble() : 0.0;
    return Scaffold(
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
                    Navigator.pop(context);
                    // return bloc.add(HomeScreenEvent());

                    // return bloc.add(SideMenu());
                  },
                ),
                SizedBox(
                  width: deviceWidth * 0.025,
                ),
                appBarHeader(
                  widget.vouchername ?? "",
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
                          Navigator.push(context, MaterialPageRoute(builder: (context){
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
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          height: deviceHeight,
          width: deviceWidth,
          child: SingleChildScrollView(
            child: Container(
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
              padding: EdgeInsets.symmetric(
                horizontal: HORIZONTAL_PADDING,
                vertical: VERTICAL_PADDING * 2,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: deviceWidth,
                    height: deviceHeight * 0.23,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.icon ?? "",
                      errorWidget: (context, url, error) => Center(child: Icon(Icons.error,color: colortheme,)),

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
                        decoration: BoxDecoration(
                          //color: colorBackgroundButton,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.scaleDown),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: deviceHeight * 0.02,
                  ),
                  Container(
                    width: deviceWidth,
                    padding: EdgeInsets.symmetric(
                      horizontal: HORIZONTAL_PADDING,
                      vertical: VERTICAL_PADDING * 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorWhite,
                      border: Border.all(
                          width: 1, color: colormyreceiptbordercolor),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                getSmallText(widget.vouchername ?? "",
                                    color: colorBlack,
                                    fontSize: BODY3_TEXT_FONT_SIZE,
                                    weight: FontWeight.w500,
                                    isCenter: true),
                                SizedBox(
                                  width: deviceWidth * 0.02,
                                ),
                                getTitle("${widget.currency ?? ""}",
                                    //"$currency 500",
                                    color: colortheme,
                                    lines: 1,
                                    fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                                    weight: FontWeight.w900,
                                    isCenter: true),
                                getSmallText((widget.amount ?? 0).toStringAsFixed(2),
                                    color: colortheme,
                                    fontSize: SUBTITLE_FONT_SIZE,
                                    weight: FontWeight.w900,
                                    isCenter: true),
                              ],
                            ),
                            Row(
                              children: [
                                getTitle(
                                  "You have Earned ",
                                  bold: false,
                                  weight: FontWeight.w500,
                                  fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                                  color: colorgreytext,
                                ),
                                getTitle(
                                  userPoints >= totalVoucherPoints
                                      ? totalVoucherPoints.toString()
                                      : userPoints.toString(),
                                  bold: true,
                                  weight: FontWeight.w800,
                                  fontSize: SUBTITLE_FONT_SIZE,
                                  color: colorBlack,
                                ),
                                getTitle(
                                  " points",
                                  bold: false,
                                  weight: FontWeight.w500,
                                  fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                                  color: colorgreytext,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: deviceHeight * 0.015,
                            ),
                            userPoints >= totalVoucherPoints ?SizedBox():
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    getSmallText((totalVoucherPoints - userPoints).toString(),
                                        color: colorBlack,
                                        bold: true,
                                        weight: FontWeight.w800),
                                    Container(
                                      width: deviceWidth * 0.6,
                                      child: getTitle(
                                          "Points you need to earn to redeem this voucher",
                                          bold: false,
                                          weight: FontWeight.w500,
                                          lines: 3,
                                          fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                                          color: colorgreytext),
                                    ),
                                  ],
                                )

                          ],
                        ),
                        CircularPercentIndicator(
                          radius: 18.0,
                          lineWidth: 3.0,
                          // percent: 0.75,
                          percent: totalVoucherPoints == 0
                              ? 0.0
                              : (userPoints / totalVoucherPoints).clamp(0.0, 1.0),
                          backgroundWidth: 18,
                          progressColor: colortheme,
                          fillColor: colorpaymentbackground,
                          backgroundColor: colorpaymentbackground,
                          // center: new Text("100%")
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: deviceHeight * 0.02,
                  ),
                  Container(
                    width: deviceWidth,
                    padding: EdgeInsets.symmetric(
                      horizontal: HORIZONTAL_PADDING,
                      vertical: VERTICAL_PADDING * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: colorWhite,
                      border: Border.all(
                          width: 1, color: colormyreceiptbordercolor),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          getSmallText(
                            "Description",
                            color: colorBlack,
                            bold: true,
                            weight: FontWeight.w800,
                            fontSize: BUTTON_FONT_SIZE,
                          ),
                          SizedBox(height: deviceHeight*0.015,),
                          getSmallText(
                            widget.description ?? "",
                            color: colorBlack,
                            weight: FontWeight.w400,
                            fontSize: FORGET_PASSWORD_TEXT_FONT_SIZE,
                          ),
                        ]),
                  ),
                  SizedBox(
                    height: deviceHeight * 0.02,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: HORIZONTAL_PADDING * 1.5,
                    ),
                    child: getButton(Redeem, () {
                      if (userPoints >= totalVoucherPoints) {
                        changeLoadStatus();
                        bloc.userRepository
                            .redeemProduct(
                            // userid: int.parse(userid),
                            redeemid: widget.redeemId ?? 0)
                            .then((value) {
                          changeLoadStatus();
                          if (value.status == 1) {
                            print("redeem voucher successful");
                            if(mounted)
                            showMessage(value.message ?? "", () {
                              setState(() {
                                isShowMessage = false;
                                // Navigator.of(context)
                                //     .popUntil(ModalRoute.withName("/"));
                                Navigator.pop(context);
                                bloc.add(RewardScreenEvent());
                              });
                            });

                          }
                          else if(value.apiStatusCode == 401){
                            showMessage(value.message ?? "", () {
                              setState(() {
                                Navigator.pop(context);
                                isShowMessage = false;
                                logoutaccount();
                                return bloc.add(Login());
                              });
                            });
                          }
                          else {
                            print("redeem voucher failed ");
                            print(value.message);
                            if(mounted)
                            showMessage(value.message ?? "", () {
                              setState(() {
                                // bloc.add(WelcomeIn());
                                // Navigator.pop(context);
                                isShowMessage = false;
                                Navigator.pop(context);
                                bloc.add(RewardScreenEvent());
                                // Navigator.of(context)
                                //     .popUntil(ModalRoute.withName("/"));
                                // bloc.add(HomeScreenEvent());
                              });
                            });
                          }
                        });

                      }
                    },
                    color: userPoints >= totalVoucherPoints ? colortheme : colorGrey,
                    bordercolor: Colors.transparent,
                  ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
