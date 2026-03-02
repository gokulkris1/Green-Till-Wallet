import 'package:cached_network_image/cached_network_image.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class CouponsDetailsScreen extends BaseStatefulWidget {
  final String? storeName;
  final String? discount;
  final String? storelogo;
  final String? barcodeimage;
  final String? barcodenumber;
  final String? description;
  final String? backgroundimage;
  final String? currency;
  final String? discounttype;
  final DateTime? fromdate;
  final DateTime? todate;
  final String? couponlink;

  const CouponsDetailsScreen(
      {super.key,
      this.storeName,
      this.discount,
      this.storelogo,
      this.barcodeimage,
      this.barcodenumber,
      this.fromdate,
      this.todate,
      this.currency,
      this.description,
      this.backgroundimage,
      this.discounttype,
      this.couponlink});

  @override
  _CouponsDetailsScreenState createState() => _CouponsDetailsScreenState();
}

class _CouponsDetailsScreenState extends BaseState<CouponsDetailsScreen>
    with BasicScreen {
  @override
  Widget buildBody(BuildContext context) {
    print(widget.backgroundimage);
    print(widget.discounttype);
    print(widget.currency);
    print(widget.couponlink);
    print((widget.backgroundimage ?? "").contains(".svg"));

    String fromDate =
        formattercoupon.format(widget.fromdate ?? DateTime.now()).toString();
    String toDate =
        formattercoupon.format(widget.todate ?? DateTime.now()).toString();
    return Scaffold(
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
                  },
                ),
                SizedBox(
                  width: deviceWidth * 0.025,
                ),
                appBarHeader(
                  coupon,
                  fontSize: BUTTON_FONT_SIZE,
                  bold: false,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        width: deviceWidth,
        height: deviceHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: deviceHeight * 0.045,
            ),
            FlipCard(
              front: CouponCard(
                width: deviceWidth * 0.8,
                height: deviceHeight * 0.7,
                curveRadius: 70,
                curvePosition: deviceHeight * 0.44,
                shadow: BoxShadow(
                  offset: Offset(0, 0),
                  blurRadius: 1,
                  color: colorGrey,
                  blurStyle: BlurStyle.outer,
                ),
                firstChild: Column(
                  children: [
                    Stack(
                      children: [
                        Column(
                          children: [
                            Stack(
                              alignment: AlignmentDirectional.centerEnd,
                              children: [
                                Container(
                                  height: deviceHeight * 0.20,
                                  width: deviceWidth * 0.8,
                                  decoration: BoxDecoration(
                                      // border: Border(bottom: BorderSide(color: colorGrey.withOpacity(0.4)))
                                      // color: colortheme,
                                      //   image: DecorationImage(
                                      //       image: NetworkImage(widget.storelogo ?? "",),
                                      //       fit: BoxFit.fill,
                                      //       opacity: 0.4
                                      //   )
                                      ),
                                  child:
                                      // widget.backgroundimage.contains(".svg") ?
                                      // SvgPicture.network(
                                      //   widget.backgroundimage ?? "",
                                      //   placeholderBuilder: (BuildContext context) => Container(
                                      //       // padding: const EdgeInsets.all(30.0),
                                      //       child: Center(child: const CircularProgressIndicator())),
                                      // ):
                                      CachedNetworkImage(
                                    imageUrl: widget.backgroundimage ?? "",
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        color: colorWhite,
                                      ),
                                      child: Center(
                                          child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        child: Icon(
                                          Icons.error,
                                          size: 32,
                                          color: colortheme,
                                        ),
                                      )
                                          // getSmallText(
                                          //     getInitials(widget?.storeName),
                                          //     weight: FontWeight.w500,
                                          //     align: TextAlign.center,
                                          //     color: colorBlack,
                                          //     fontSize: TEXT_FIELD_FONT_SIZE7)
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
                                                        value: downloadProgress
                                                            .progress))),
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        color: colorWhite,
                                        // border: Border.all(
                                        //     color: colorcoupondetail, width: 1),
                                        // borderRadius: BorderRadius.circular(100),
                                        image: DecorationImage(
                                            alignment: Alignment.center,
                                            image: imageProvider,
                                            // opacity: 0.4,
                                            fit: BoxFit.fill),
                                      ),
                                    ),
                                  ),
                                ),
                                // Positioned.fill(
                                //   // right: deviceWidth * 0.04,
                                //   // left: deviceWidth * 0.58,
                                //   // bottom: deviceHeight * 0.17,
                                //   child: Padding(
                                //     padding:
                                //         const EdgeInsets.only(right: 16, top: 16),
                                //     child: Align(
                                //       alignment: Alignment.topRight,
                                //       child: Container(
                                //         height: deviceHeight * 0.07,
                                //         width: deviceWidth * 0.14,
                                //         alignment: Alignment.centerRight,
                                //         child: CachedNetworkImage(
                                //           imageUrl: widget.storelogo,
                                //           errorWidget: (context, url, error) =>
                                //               Container(
                                //             decoration: BoxDecoration(
                                //               shape: BoxShape.circle,
                                //               // borderRadius:
                                //               // BorderRadius.circular(100),
                                //               color: colorWhite,
                                //               image: DecorationImage(
                                //                 image: AssetImage(
                                //                     IC_GREENTILL_IMAGE),
                                //               ),
                                //             ),
                                //           ),
                                //           progressIndicatorBuilder: (context, url,
                                //                   downloadProgress) =>
                                //               Center(
                                //                   child: SizedBox(
                                //                       height: 20,
                                //                       width: 20,
                                //                       child:
                                //                           CircularProgressIndicator(
                                //                               value:
                                //                                   downloadProgress
                                //                                       .progress))),
                                //           // placeholder: (context, url) => Container(
                                //           //   decoration: BoxDecoration(
                                //           //     color: colorBackgroundButton,
                                //           //     borderRadius: BorderRadius.circular(18),
                                //           //     image: DecorationImage(
                                //           //         image: AssetImage(IC_PROFILE_IMAGE),
                                //           //         fit: BoxFit.cover),
                                //           //   ),
                                //           // ),
                                //           imageBuilder:
                                //               (context, imageProvider) =>
                                //                   Container(
                                //             decoration: BoxDecoration(
                                //               color: colorWhite,
                                //               borderRadius:
                                //                   BorderRadius.circular(100),
                                //               image: DecorationImage(
                                //                   image: imageProvider,
                                //                   fit: BoxFit.cover),
                                //             ),
                                //           ),
                                //         ),
                                //         // foregroundDecoration: BoxDecoration(
                                //         //     color: colorGradientSecond,
                                //         //     image: DecorationImage(
                                //         //       image: AssetImage(
                                //         //         IC_DMART,
                                //         //       ),
                                //         //       fit: BoxFit.contain,
                                //         //     )),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: deviceHeight * 0.08,
                                ),
                                getTitle(
                                  widget.storeName ?? "",
                                  bold: true,
                                  fontSize: CATEGORY_INITIAL_TEXT_FONT_SIZE,
                                  weight: FontWeight.w500,
                                ),
                                SizedBox(
                                  height: deviceHeight * 0.03,
                                ),
                                DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(6),
                                  strokeWidth: 1,
                                  dashPattern: [8, 4],
                                  padding: const EdgeInsets.all(2),
                                  color: colortheme,
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6)),
                                    child: Container(
                                      height: deviceHeight * 0.045,
                                      width: deviceWidth * 0.6,
                                      alignment: Alignment.center,
                                      child: getTitle(
                                          widget.discounttype == "PERCENTAGE"
                                              ? (widget.discount ?? "") + "% Discount"
                                              : widget.discounttype == "AMOUNT"
                                                  ? (widget.currency ?? "") +
                                                      "" +
                                                      (widget.discount ?? "") +
                                                      " Discount"
                                                  : "",
                                          color: colortheme,
                                          weight: FontWeight.w500,
                                          lines: 1,
                                          fontSize: BUTTON_FONT_SIZE),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: deviceHeight * 0.045,
                                  width: deviceWidth * 0.6,
                                  alignment: Alignment.center,
                                  child: getTitle(
                                      "Valid from " +
                                          fromDate +
                                          " to " +
                                          toDate,
                                      color: colorGrey,
                                      weight: FontWeight.w500,
                                      lines: 1,
                                      fontSize: SUBTITLE_FONT_SIZE),
                                ),
                                SizedBox(
                                  height: deviceHeight * 0.02,
                                ),
                                // getSmallText(expiresIn30DaysCaps,
                                //     fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE),
                              ],
                            )
                          ],
                        ),
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(top: deviceHeight * 0.12),
                            alignment: Alignment.bottomCenter,
                            height: deviceHeight * 0.14,
                            width: deviceWidth * 0.28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: colorcoupondetail, width: 1.5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: CachedNetworkImage(
                                imageUrl: widget.storelogo ?? "",
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
                                      child: getSmallText(
                                          getInitials(widget.storeName ?? ""),
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
                                                value: downloadProgress
                                                    .progress))),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    color: colorWhite,
                                    border: Border.all(
                                        color: colorcoupondetail, width: 1),
                                    borderRadius: BorderRadius.circular(100),
                                    image: DecorationImage(
                                        alignment: Alignment.center,
                                        image: imageProvider,
                                        fit: BoxFit.scaleDown),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                secondChild: Container(
                  width: deviceWidth,
                  child: Column(
                    children: [
                      MySeparator(
                        color: colorseprator,
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Container(
                        width: deviceWidth * 0.5,
                        height: deviceHeight * 0.1,
                        child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          imageUrl: widget.barcodeimage ?? "",
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
                            width: deviceWidth * 0.5,
                            height: deviceHeight * 0.1,
                            decoration: BoxDecoration(
                              color: colorWhite,
                              // borderRadius: BorderRadius.circular(100),
                              image: DecorationImage(
                                  colorFilter: ColorFilter.mode(
                                      colorbarcodetext, BlendMode.screen),
                                  // alignment: Alignment.center,
                                  image: imageProvider,
                                  fit: BoxFit.fitWidth),
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      SelectableText(
                        widget.barcodenumber ?? "",
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: SUBTITLE_FONT_SIZE,
                            color: colorbarcodetext),
                        maxLines: 1,
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if ((widget.couponlink ?? "").isNotEmpty) {
                            final uri = Uri.parse(widget.couponlink!);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
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
                                getTitle("Go to link",
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
                      Spacer(
                        flex: 1,
                      ),
                    ],
                  ),
                ),
              ),
              back: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: CouponCard(
                      width: deviceWidth * 0.8,
                      height: deviceHeight * 0.7,
                      curveRadius: 70,
                      curvePosition: deviceHeight * 0.44,
                      shadow: BoxShadow(
                        offset: Offset(0, 0),
                        blurRadius: 1,
                        color: colorGrey,
                        blurStyle: BlurStyle.outer,
                      ),
                      firstChild: Container(),
                      secondChild: Container(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      alignment: Alignment.topCenter,
                      // color: Colors.green,
                      height: deviceHeight * 0.65,
                      width: deviceWidth * 0.7,
                      child: SingleChildScrollView(
                        child: getTitle(
                          widget.description ?? "",
                          bold: true,
                          lines: 1000,
                          // isCenter: true,
                          fontSize: BODY4_TEXT_FONT_SIZE,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getInitials(String bank_account_name) => bank_account_name.isNotEmpty
      ? bank_account_name.trim().split(' ').map((l) => l[0]).take(1).join()
      : '';
}
