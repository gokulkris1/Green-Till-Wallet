import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'dart:ui';
import 'package:currency_picker/src/currencies.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/ui/screens/rewards/redeem_voucher_detail_screen.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:greentill/utils/strings.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

SharedPrefHelper prefs = SharedPrefHelper.instance;
final DateFormat formatter = DateFormat('dd MMM yyyy');
final DateFormat formatterNew = DateFormat('dd/MM/yyyy');
final DateFormat formattercoupon = DateFormat('dd MMM');

Text getSmallText(String text,
    {bool bold = false,
    Color color = colorAccentLight,
    double? fontSize,
    TextAlign? align,
    FontWeight weight = FontWeight.w400,
    bool isCenter = false,
    bool underLine = false,
    int? lines}) {
  return Text(
    text,
    textAlign: align,
    maxLines: lines ?? 5,
    style: TextStyle(
        decoration: underLine ? TextDecoration.underline : null,
        color: color,
        fontWeight: weight,
        fontSize: fontSize ?? SUBTITLE_FONT_SIZE,
        fontFamily: "Avenir"),
    overflow: TextOverflow.ellipsis,
  );
}

Text getTitle(String text,
    {bool bold = false,
    bool isCenter = false,
    FontWeight? weight,
    double? fontSize,
    Color color = colorBlack,
    int? lines}) {
  return Text(
    text,
    maxLines: lines,
    textAlign: isCenter ? TextAlign.center : TextAlign.start,
    style: TextStyle(
        color: color,
        fontSize: fontSize ?? TITLE_TEXT_FONT_SIZE,
        fontWeight: weight ?? (bold ? FontWeight.w800 : FontWeight.normal),
        fontFamily: 'Avenir'),
    overflow: TextOverflow.ellipsis,
  );
}

Text appBarHeader(String text,
    {bool bold = false,
    bool isCenter = false,
    double? fontSize,
    Color color = gpTextPrimary,
    FontWeight weight = FontWeight.w500,
    int? lines}) {
  return Text(
    text,
    maxLines: lines,
    textAlign: isCenter ? TextAlign.center : TextAlign.start,
    style: TextStyle(
        color: color,
        fontSize: fontSize ?? APPBAR_HEADER,
        fontWeight: weight,
        fontFamily: bold ? 'Avenir' : 'Avenir'),
    overflow: TextOverflow.ellipsis,
  );
}

Text getSmallIcon(String text,
    {bool bold = false,
    bool isEnd = false,
    double? fontSize,
    Color color = colorBlack,
    int? lines}) {
  // return Icon(Icons.close, size: fontSize, color: color);
  return Text(
    text,
    maxLines: lines,
    textAlign: isEnd ? TextAlign.end : TextAlign.start,
    style: TextStyle(
      color: color,
      fontSize: fontSize ?? BODY1_TEXT_FONT_SIZE,
      fontWeight: bold ? FontWeight.bold : FontWeight.w500,
    ),
  );
}

Widget getCommonBottomSheetTitleView({
  required ThemeData baseTheme,
  required BuildContext context,
  required String title,
  String actionTitle = "",
  GestureTapCallback? onActionButtonTap,
}) {
  return Container(
    height: 35,
    margin: const EdgeInsets.only(top: 5),
    child: Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        Container(
          width: double.maxFinite,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: colorBlack,
                fontSize: CAPTION_BIGGER_TEXT_FONT_SIZE,
                fontFamily: 'RubikRegular'),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            InkWell(
              onTap: onActionButtonTap,
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  actionTitle,
                  style: baseTheme.textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget getCommonDivider({double thickness = COMMON_DIVIDER_THICKNESS}) {
  return Divider(
    thickness: thickness,
    color: colorgreyborder,
  );
}

Widget getCommonTextFormField(
    {required BuildContext context,
    String hintText = "",
    bool obscureText = false,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    int maxLines = 1,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color filledcolor = colorWhite,
    String? initialvalue,
    FocusNode? focusNode,
    Color bordersidecolor = colorTextfeild,
    EdgeInsetsGeometry contentPadding =
        const EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 0),
    TextAlign textAlign = TextAlign.start,
    TextEditingController? controller,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onSubmitted,
    FormFieldValidator<String>? validator,
    GestureTapCallback? onTap,
    ValueChanged<String>? onTextChanged,
    bool isCapitalise = true}) {
  ThemeData baseTheme = Theme.of(context);
  var resolvedKeyboardType = keyboardType;
  var resolvedTextInputAction = textInputAction;
  var resolvedOnSubmitted = onSubmitted;

  if (maxLines > 1) {
    resolvedKeyboardType = TextInputType.multiline;
    resolvedTextInputAction = TextInputAction.newline;
  }

  if (resolvedOnSubmitted == null &&
      resolvedTextInputAction == TextInputAction.next) {
    resolvedOnSubmitted = (value) {
      print("va" + value);
      //FocusScope.of(context).nextFocus();
    };
  }

  return TextFormField(
    style: baseTheme.textTheme.bodyLarge,
    focusNode: focusNode,
    maxLines: maxLines,
    controller: controller,
    keyboardType: resolvedKeyboardType,
    obscureText: obscureText,
    inputFormatters: inputFormatters,
    textInputAction: resolvedTextInputAction,
    initialValue: initialvalue,
    textCapitalization:
        isCapitalise ? TextCapitalization.sentences : TextCapitalization.none,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    onFieldSubmitted: resolvedOnSubmitted,
    validator: validator,
    autofocus: false,
    readOnly: readOnly,
    textAlign: textAlign,
    onTap: onTap,
    onChanged: onTextChanged,
    decoration: InputDecoration(
      isDense: false,
      labelText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorMaxLines: 2,
      errorStyle: (baseTheme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
        color: errorRed,
        fontSize: CAPTION_TEXT_FONT_SIZE,
        fontWeight: FontWeight.w300,
      ),
      filled: true,
      fillColor: filledcolor,
      hintStyle: (baseTheme.textTheme.titleSmall ?? const TextStyle())
          .copyWith(fontSize: 16, fontWeight: FontWeight.w300),
      labelStyle: (baseTheme.textTheme.titleSmall ?? const TextStyle())
          .copyWith(fontSize: 16, fontWeight: FontWeight.w300),
      floatingLabelStyle: TextStyle(color: colorTextfeild),
      contentPadding: contentPadding,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: bordersidecolor, width: 0.4)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: bordersidecolor, width: 0.4)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: bordersidecolor, width: 0.4)),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorRed, width: 0.8),
      ),
    ),
  );
}

Widget getCountryTextFormField({
  required BuildContext context,
  String hintText = "",
  bool readOnly = true,
  int maxLines = 1,
  Widget? prefixIcon,
  Widget? suffixIcon,
  FormFieldValidator<String>? validator,
  TextEditingController? controller,
  EdgeInsetsGeometry contentPadding =
      const EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 0),
  TextAlign textAlign = TextAlign.start,
  GestureTapCallback? onTap,
  ValueChanged<String>? onTextChanged,
}) {
  ThemeData baseTheme = Theme.of(context);

  return TextFormField(
    controller: controller,
    enabled: true,
    style: baseTheme.textTheme.bodyLarge,
    maxLines: maxLines,
    autofocus: false,
    readOnly: readOnly,
    textAlign: textAlign,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: validator,
    onTap: onTap,
    onChanged: onTextChanged,
    decoration: InputDecoration(
      floatingLabelAlignment: FloatingLabelAlignment.start,
      floatingLabelBehavior: hintText == Selectcountry
          ? FloatingLabelBehavior.never
          : FloatingLabelBehavior.always,
      hintText: hintText,
      isDense: false,
      labelText: Selectcountry,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorMaxLines: 2,
      // errorStyle: baseTheme.textTheme.bodyText1
      //     .copyWith(color: Colors.red, fontSize: CAPTION_TEXT_FONT_SIZE),
      errorStyle: (baseTheme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
        color: errorRed,
        fontSize: CAPTION_TEXT_FONT_SIZE,
        fontWeight: FontWeight.w300,
      ),
      filled: true,
      fillColor: colorWhite,
      hintStyle: (baseTheme.textTheme.titleSmall ?? const TextStyle())
          .copyWith(fontSize: 16, fontWeight: FontWeight.w300),
      labelStyle: (baseTheme.textTheme.titleSmall ?? const TextStyle())
          .copyWith(fontSize: 16, fontWeight: FontWeight.w300),
      floatingLabelStyle: TextStyle(color: colorTextfeild),
      contentPadding: contentPadding,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: colorTextfeild, width: 0.4)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: colorTextfeild, width: 0.4)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: colorTextfeild, width: 0.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorRed, width: 0.8),
      ),
    ),
  );
}

Widget getCurrencyTextFormField({
  required BuildContext context,
  String hintText = "",
  bool readOnly = true,
  int maxLines = 1,
  Widget? prefixIcon,
  bool isCurrencypresent = false,
  Widget? suffixIcon,
  FormFieldValidator<String>? validator,
  TextEditingController? controller,
  EdgeInsetsGeometry contentPadding =
      const EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 0),
  TextAlign textAlign = TextAlign.start,
  GestureTapCallback? onTap,
  ValueChanged<String>? onTextChanged,
}) {
  ThemeData baseTheme = Theme.of(context);

  return TextFormField(
    controller: controller,
    enabled: true,
    style: baseTheme.textTheme.bodyLarge,
    maxLines: maxLines,
    autofocus: false,
    readOnly: readOnly,
    textAlign: textAlign,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: validator,
    onTap: onTap,
    onChanged: onTextChanged,
    decoration: InputDecoration(
      floatingLabelAlignment: FloatingLabelAlignment.start,
      floatingLabelBehavior: hintText == Selectcurrency
          ? FloatingLabelBehavior.never
          : FloatingLabelBehavior.always,
      hintText: hintText,
      isDense: false,
      labelText: isCurrencypresent ? currencySmall : Selectcurrency,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorMaxLines: 2,
      // errorStyle: baseTheme.textTheme.bodyText1
      //     .copyWith(color: Colors.red, fontSize: CAPTION_TEXT_FONT_SIZE),
      errorStyle: (baseTheme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
        color: errorRed,
        fontSize: CAPTION_TEXT_FONT_SIZE,
        fontWeight: FontWeight.w300,
      ),
      filled: true,
      fillColor: colorWhite,
      hintStyle: (baseTheme.textTheme.titleSmall ?? const TextStyle())
          .copyWith(fontSize: 16, fontWeight: FontWeight.w300),
      labelStyle: (baseTheme.textTheme.titleSmall ?? const TextStyle())
          .copyWith(fontSize: 16, fontWeight: FontWeight.w300),
      floatingLabelStyle: TextStyle(color: colorTextfeild),
      contentPadding: contentPadding,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: colorTextfeild, width: 0.4)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: colorTextfeild, width: 0.4)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: colorTextfeild, width: 0.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorRed, width: 0.8),
      ),
    ),
  );
}

Future<dynamic> showCommonErrorDialog(
    ThemeData baseTheme, BuildContext context, String message,
    {String title = "Error"}) async {
  return await showDialog(
      context: context,
      useSafeArea: true,
      builder: (BuildContext context) => Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 50,
                      color: colorRed,
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              title,
                              style: (baseTheme.textTheme.displayMedium ??
                                      const TextStyle())
                                  .copyWith(
                                      color: Colors.black, fontSize: 26.0),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 25.0),
                                child: Image.asset(
                                  IC_GALLERY_OPTION,
                                  width: 24,
                                  height: 24,
                                  color: Colors.black,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 100,
                      color: colorRed,
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Center(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                message,
                                textAlign: TextAlign.center,
                                style: (baseTheme.textTheme.titleMedium ??
                                        const TextStyle())
                                    .copyWith(
                                        color: Colors.black, fontSize: 16.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ));
}

ThemeData buildAppTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
      primaryColor: colorBlack,
      primaryColorDark: colorBlack,
      primaryColorLight: colorBlack,
      buttonTheme: base.buttonTheme,
      scaffoldBackgroundColor: Colors.white,
      // textTheme: _buildTextTheme(base.textTheme),
      // primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
      // accentTextTheme: _buildTextTheme(base.accentTextTheme),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        labelStyle: base.textTheme.titleSmall,
        contentPadding: const EdgeInsets.only(bottom: 0),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: colorBlack));
}

Widget getButton(String text, VoidCallback function,
    {Color color = colorGradientFirst,
    String? assetImage,
    double height = 52,
    bool isBold = true,
    double? width,
    Color bordercolor = colorGradientFirst,
    Color textColor = colorWhite,
    double fontsize = BUTTON_FONT_SIZE}) {
  return SizedBox(
    height: height,
    width: width,
    child: ElevatedButton(
      onPressed: function,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        elevation: 1,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide(color: bordercolor),
      ),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (assetImage != null)
              Container(
                margin: EdgeInsets.only(right: 10, left: 5),
                child: Image.asset(
                  assetImage!,
                  color: colorWhite,
                  fit: BoxFit.fill,
                  width: 25,
                  height: 25,
                ),
              ),
            Container(
              child: getTitle(
                text,
                weight: FontWeight.w800,
                bold: isBold,
                color: textColor,
                fontSize: fontsize,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget SocialLoginButton(String image, VoidCallback ontap) {
  return GestureDetector(
    onTap: () {
      ontap();
    },
    child: Container(
        height: deviceHeight * 0.05,
        width: deviceWidth * 0.12,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: colorSocialMediabtncolor),
          image: DecorationImage(
            image: AssetImage(image),
          ),
        )),
  );
}

// Widget HomePageProfileIcon(){
//   return Stack(
//     children: [
//       Cont
//     ],
//   )
// }

Widget HomeScreenTabRow(
    VoidCallback onReceipttap,
    VoidCallback onCoupontap,
    VoidCallback onRewardtap,
    VoidCallback onStoretap,
    VoidCallback onShoppingtap,
    VoidCallback onSurveytap) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING * 0.5),
    width: deviceWidth,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
              onTap: () {
                return onReceipttap();
              },
              child: HomeScreenTabItem(IC_RECEIPT, "Receipts")),
          SizedBox(
            width: deviceWidth * 0.025,
          ),
          GestureDetector(
            onTap: () {
              return onRewardtap();
            },
            child: HomeScreenTabItem(IC_REWARD, "Rewards"),
          ),
          SizedBox(
            width: deviceWidth * 0.025,
          ),
          GestureDetector(
              onTap: () {
                return onCoupontap();
              },
              child: HomeScreenTabItem(IC_COUPON, "Offers")),
          SizedBox(
            width: deviceWidth * 0.025,
          ),
          GestureDetector(
            onTap: () {
              return onStoretap();
            },
            child: HomeScreenTabItem(IC_STORE, "Loyalty Cards"),
          ),
          SizedBox(
            width: deviceWidth * 0.025,
          ),
          GestureDetector(
            onTap: () {
              return onShoppingtap();
            },
            child: HomeScreenTabItem(IC_SHOPPING, "Shopping"),
          ),
          SizedBox(
            width: deviceWidth * 0.025,
          ),
          GestureDetector(
            onTap: () {
              return onSurveytap();
            },
            child: HomeScreenTabItem(IC_SURVEY, "Surveys"),
          ),
          SizedBox(
            width: deviceWidth * 0.025,
          ),
        ],
      ),
    ),
  );
}

Widget HomeScreenTabItem(String image, String heading) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Card(
        shape: CircleBorder(),
        elevation: 3,
        child: Container(
          height: deviceHeight * 0.06,
          width: deviceWidth * 0.14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: gpGreen,
            //image: DecorationImage(image: AssetImage(image), fit: BoxFit.scaleDown,alignment: Alignment.center,)
          ),
          child: Center(
            child: Image.asset(
              image,
              color: gpLight,
              height: deviceHeight * 0.035,
              width: deviceWidth * 0.07,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
      SizedBox(
        height: deviceHeight * 0.01,
      ),
      getSmallText(heading,
          weight: FontWeight.w500,
          bold: true,
          fontSize: SUBTITLE_FONT_SIZE,
          color: gpTextPrimary),
    ],
  );
}

Widget CoinsAvailableWidget(String coins, {String? points, String? currency}) {
  return Card(
    shape: RoundedRectangleBorder(
      // side: BorderSide(color: colorcoinborder, width: 0),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    elevation: 2,
    child: Container(
      height: deviceHeight * 0.06,
      width: deviceWidth,
      decoration: BoxDecoration(
          color: gpLight,
          border: Border.all(color: gpBorder),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Image.asset(
                  IC_RING,
                  height: 24,
                ),
                SizedBox(
                  width: 2,
                ),
                Row(
                  children: [
                    getTitle("You have ",
                        weight: FontWeight.w400,
                        lines: 1,
                        isCenter: true,
                        fontSize: SUBTITLE_FONT_SIZE,
                        color: gpTextSecondary),
                    getTitle(points ?? "",
                        weight: FontWeight.w400,
                        isCenter: true,
                        lines: 1,
                        fontSize: SUBTITLE_FONT_SIZE,
                        color: gpTextPrimary),
                    getTitle(" available coins",
                        weight: FontWeight.w400,
                        isCenter: true,
                        lines: 1,
                        fontSize: SUBTITLE_FONT_SIZE,
                        color: gpTextSecondary),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                getTitle("${currency ?? ""}",
                    weight: FontWeight.w800,
                    fontSize: BUTTON_FONT_SIZE,
                    color: gpGreen),
                getTitle(" $coins",
                    weight: FontWeight.w800,
                    fontSize: BUTTON_FONT_SIZE,
                    color: gpGreen),
              ],
            )
          ],
        ),
      ),
    ),
  );
}

Widget HeaderViewAll(String heading, Function viewAll, {bool isEmpty = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      getSmallText(heading,
          weight: FontWeight.w800,
          align: TextAlign.center,
          fontSize: SUBTITLE_FONT_SIZE,
          color: gpTextPrimary,
          bold: true),
      isEmpty
          ? SizedBox()
          : GestureDetector(
              onTap: () {
                viewAll();
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  getSmallText(viewAllcontent,
                      weight: FontWeight.w600,
                      align: TextAlign.center,
                      fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
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
            )
    ],
  );
}

Widget MyreceiptGridItem(String storelogo, String storename, String date,
    {bool inprogress = false,
    bool isstorelogoavailable = false,
    bool isDuplicate = false,
    String? tagType}) {
  final String? statusText =
      inprogress ? "In progress" : (isDuplicate ? "Duplicate" : null);
  final Color statusColor = isDuplicate ? gpError : gpImpactOrange;
  final String? tagText = () {
    final raw = tagType?.trim() ?? "";
    if (raw.isEmpty) {
      return null;
    }
    if (raw.toLowerCase() == "business") {
      return "Business";
    }
    if (raw.toLowerCase() == "personal") {
      return "Personal";
    }
    return raw;
  }();
  final Color tagColor = tagText == "Business" ? gpGreen : gpInfo;

  return Container(
    height: deviceHeight * 0.1,
    width: deviceWidth * 0.15,
    decoration: BoxDecoration(
        border: Border.all(color: gpBorder),
        color: gpLight,
        borderRadius: BorderRadius.all(Radius.circular(10))),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: statusText != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: statusColor.withOpacity(0.35)),
                  ),
                  child: getSmallText(statusText,
                      color: statusColor,
                      weight: FontWeight.w600,
                      fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE),
                ),
                const SizedBox(height: 6),
                getSmallText(storename,
                    weight: FontWeight.w600,
                    align: TextAlign.center,
                    lines: 1,
                    fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                    color: gpTextPrimary),
                getSmallText(date,
                    weight: FontWeight.w400,
                    align: TextAlign.center,
                    lines: 1,
                    fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                    color: gpTextMuted),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  height: deviceHeight * 0.03,
                  child: isstorelogoavailable
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: CachedNetworkImage(
                              imageUrl: storelogo ?? "",
                              errorWidget: (context, url, error) => Container(
                                decoration: BoxDecoration(
                                  // shape: BoxShape.circle,
                                  //borderRadius:
                                  //BorderRadius.circular(18),
                                  color: gpLight,
                                  // image: DecorationImage(
                                  //     image: AssetImage(
                                  //         IC_SURVEY),
                                  //     fit: BoxFit.scaleDown),
                                ),
                                child: Center(
                                    child: getSmallText(getInitials(storelogo),
                                        weight: FontWeight.w500,
                                        align: TextAlign.center,
                                        color: gpTextPrimary,
                                        fontSize: BODY1_TEXT_FONT_SIZE)),
                              ),
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Center(
                                      child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              value:
                                                  downloadProgress.progress))),
                              // placeholder: (context, url) => Container(
                              //   decoration: BoxDecoration(
                              //     color: colorBackgroundButton,
                              //     borderRadius: BorderRadius.circular(18),
                              //     image: DecorationImage(
                              //         image: AssetImage(IC_PROFILE_IMAGE),
                              //         fit: BoxFit.cover),
                              //   ),
                              // ),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  color: gpLight,
                                  // shape: BoxShape.circle,
                                  // borderRadius:
                                  // BorderRadius.circular(100),
                                  image: DecorationImage(
                                      alignment: Alignment.center,
                                      image: imageProvider,
                                      fit: BoxFit.scaleDown),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: getSmallText(getInitials(storename),
                              weight: FontWeight.w500,
                              align: TextAlign.center,
                              color: gpTextPrimary,
                              fontSize: SUBTITLE_FONT_SIZE)),
                ),
                getTitle(storename ?? "",
                    weight: FontWeight.w500,
                    lines: 1,
                    isCenter: true,
                    fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                    color: gpTextPrimary,
                    bold: true),
                getSmallText(date ?? "",
                    weight: FontWeight.w400,
                    align: TextAlign.center,
                    fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                    color: gpTextMuted,
                    bold: true),
                if (tagText != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: tagColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: tagColor.withOpacity(0.35)),
                    ),
                    child: getSmallText(tagText,
                        color: tagColor,
                        weight: FontWeight.w600,
                        fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE),
                  ),
                ],
              ],
            ),
    ),
  );
}

Widget LatestCouponListHome(String? logo, String title,
    {String? offerpercent, bool isstorelogoavailable = false}) {
  return Container(
    width: deviceWidth * 0.15,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: deviceHeight * 0.07,
          width: deviceWidth * 0.14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: gpBorder),
            color: gpLight,

            // image: DecorationImage(
            //   image: AssetImage(logo),
            //   fit: BoxFit.scaleDown
            // ),
          ),
          child: isstorelogoavailable
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CachedNetworkImage(
                      imageUrl: logo ?? "",
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          //borderRadius:
                          //BorderRadius.circular(18),
                          color: gpLight,
                          // image: DecorationImage(
                          //     image: AssetImage(
                          //         IC_GREENTILL_IMAGE),
                          //     fit: BoxFit.scaleDown),
                        ),
                        child: Center(
                            child: getSmallText(getInitials(logo ?? ""),
                                weight: FontWeight.w500,
                                align: TextAlign.center,
                                color: gpTextPrimary,
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
                        // padding: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: gpLight,
                          // borderRadius: BorderRadius.circular(100),
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              alignment: Alignment.center,
                              image: imageProvider,
                              fit: BoxFit.scaleDown),
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: getSmallText(logo ?? "",
                      weight: FontWeight.w500,
                      align: TextAlign.center,
                      color: gpTextPrimary,
                      fontSize: BODY1_TEXT_FONT_SIZE)),
        ),
        SizedBox(
          height: 2,
        ),
        getTitle(title ?? "",
            weight: FontWeight.w500,
            bold: true,
            lines: 1,
            isCenter: true,
            fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
            color: gpTextPrimary),
        SizedBox(
          height: 5,
        ),
        getTitle(offerpercent ?? "",
            bold: true,
            weight: FontWeight.w800,
            fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
            color: colortheme),
      ],
    ),
  );
}

Widget LatestSuggestionsListHome(String title, Color containerColor,
    {String? offerpercent}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      // color: colorbackgroundcoupons,
      color: containerColor,
      border: Border.all(color: colorbordercoupons),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Center(
      child: getSmallText(title ?? "",
          weight: FontWeight.w500,
          bold: true,
          fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
          color: colorHomeText),
    ),
  );
}

Widget MyRewardItemList(String storelogo, String storename,
    VoidCallback onclaimclick, bool isSelected) {
  return Container(
    height: deviceHeight * 0.08,
    width: deviceWidth * 0.22,
    decoration: BoxDecoration(
        color: colormyrewardsbackground,
        border: Border.all(color: colorclaimnowbackground, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(5))),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(),
        Container(
          height: deviceHeight * 0.04,
          child: CachedNetworkImage(
            imageUrl: storelogo,
            errorWidget: (context, url, error) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  //color: colorBackgroundButton,
                  // image: DecorationImage(
                  //     image: AssetImage(IC_PROFILE), fit: BoxFit.scaleDown),
                ),
                child: Image.asset(
                  IC_HOME_BANNER,
                  fit: BoxFit.fill,
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
              height: deviceHeight * 0.04,
              decoration: BoxDecoration(
                //color: colorBackgroundButton,
                borderRadius: BorderRadius.only(
                    // topLeft: Radius.circular(10.0),
                    // topRight: Radius.circular(10.0),
                    ),
                image: DecorationImage(
                    image: imageProvider, fit: BoxFit.scaleDown),
              ),
            ),
          ),
        ),
        Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: getTitle(storename ?? "",
              weight: FontWeight.w500,
              isCenter: true,
              lines: 1,
              fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
              color: colorBlack,
              bold: true),
        ),
        Spacer()
        // GestureDetector(
        //   onTap: () {
        //     onclaimclick();
        //   },
        //   child: Container(
        //     width: deviceWidth * 0.22,
        //     height: deviceHeight * 0.03,
        //     decoration: BoxDecoration(
        //         color: isSelected ? colortheme : colorclaimnowbackground,
        //         borderRadius: BorderRadius.only(
        //             bottomRight: Radius.circular(5),
        //             bottomLeft: Radius.circular(5))),
        //     child: Center(
        //       child: getSmallText("Claim Now",
        //           fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
        //           weight: FontWeight.w500,
        //           align: TextAlign.center,
        //           color: isSelected ? colorWhite : colorBlack),
        //     ),
        //   ),
        // )
      ],
    ),
  );
}

Widget StoreCardListHome(String logo, String title,
    {bool isstorelogoavailable = false}) {
  return Container(
    width: deviceWidth * 0.15,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
            height: deviceHeight * 0.07,
            width: deviceWidth * 0.14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: gpBorder),
              color: gpLight,
              // image: widget.isCoupons
              //     ? DecorationImage(image: AssetImage(widget.logo))
              //     : null
            ),
            child: isstorelogoavailable
                ? Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CachedNetworkImage(
                      imageUrl: logo ?? "",
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          //borderRadius:
                          //BorderRadius.circular(18),
                          color: gpLight,
                          // image: DecorationImage(
                          //     image: AssetImage(
                          //         IC_GREENTILL_IMAGE),
                          //     fit: BoxFit.scaleDown),
                        ),
                        child: Center(
                            child: getSmallText(getInitials(title),
                                weight: FontWeight.w500,
                                align: TextAlign.center,
                                color: gpTextPrimary,
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
                          color: gpLight,
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
                    child: getSmallText(logo,
                        weight: FontWeight.w500,
                        align: TextAlign.center,
                        color: gpTextPrimary,
                        fontSize: BODY1_TEXT_FONT_SIZE))),
        SizedBox(
          height: 2,
        ),
        getTitle(title ?? "",
            weight: FontWeight.w500,
            bold: true,
            isCenter: true,
            lines: 1,
            fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
            color: gpTextPrimary),
      ],
    ),
  );
}

Widget MyShoppingLinkGridItem(String storelogo, String storename,
    {bool isSurvey = false}) {
  return Card(
    elevation: isSurvey ? 0 : 0,
    // shape: RoundedRectangleBorder(
    //   borderRadius: BorderRadius.circular(5),
    //   side: BorderSide(
    //       color: colormyreceiptbordercolor, width: 0),
    // ),
    child: Container(
      alignment: Alignment.center,
      height: deviceHeight * 0.09,
      width: deviceWidth * 0.14,
      padding: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: gpBorder),
        color: gpLight,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: isSurvey ? Colors.black12 : gpLight,
              blurRadius: isSurvey ? 6.0 : 0.0,
              offset: Offset(0.0, 0.05))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4),
              height: deviceHeight * 0.035,
              child: isSurvey
                  ?
                  //Image.asset(storelogo,fit: BoxFit.fill,)
                  Center(
                      child: getSmallText(getInitials(storename),
                          weight: FontWeight.w500,
                          align: TextAlign.center,
                          color: gpTextPrimary,
                          fontSize: SUBTITLE_FONT_SIZE))
                  : CachedNetworkImage(
                      imageUrl: storelogo,
                      errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            //color: colorBackgroundButton,
                            // image: DecorationImage(
                            //     image: AssetImage(IC_PROFILE), fit: BoxFit.scaleDown),
                          ),
                          child: Image.asset(
                            IC_HOME_BANNER,
                            fit: BoxFit.fill,
                          )
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
                        height: deviceHeight * 0.035,
                        decoration: BoxDecoration(
                          //color: colorBackgroundButton,
                          borderRadius: BorderRadius.only(
                              // topLeft: Radius.circular(10.0),
                              // topRight: Radius.circular(10.0),
                              ),
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.scaleDown),
                        ),
                      ),
                    ),
            ),
          ),
          getTitle(storename ?? "",
              weight: FontWeight.w500,
              isCenter: true,
              lines: 1,
              fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
              color: colorBlack,
              bold: true),
        ],
      ),
    ),
  );
}

Widget StoreCardListGridItem(String storelogo, String storename,
    {bool isstorelogoavailable = false,
    Color color = Colors.white,
    Color border = colormyreceiptbordercolor}) {
  print("storenamehs");
  print(getInitials(storename));
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
        border: Border.all(color: border),
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(15))),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Container(
        //   height: deviceHeight * 0.1,
        //   width: deviceWidth * 0.14,
        //   decoration: BoxDecoration(
        //     shape: BoxShape.circle,
        //     border: Border.all(color: colorbordercoupons),
        //     color: colorWhite,
        //     image: DecorationImage(
        //       image: AssetImage(storelogo),
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
                      imageUrl: storelogo ?? "",
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
                            child: getSmallText(getInitials(storename),
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
                    child: getSmallText(storelogo,
                        weight: FontWeight.w500,
                        align: TextAlign.center,
                        color: colorBlack,
                        fontSize: BODY1_TEXT_FONT_SIZE))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: getTitle(storename ?? "",
              weight: FontWeight.w500,
              fontSize: BUTTON_FONT_SIZE,
              lines: 1,
              isCenter: true,
              color: colorBlack,
              bold: true),
        ),
      ],
    ),
  );
}

Widget SidemenuWidget(String icon, String title, Function ontap) {
  return GestureDetector(
    onTap: () {
      ontap();
    },
    child: Container(
      height: deviceHeight * 0.062,
      width: deviceWidth,
      decoration: BoxDecoration(
          color: gpLight,
          border: Border.all(color: gpBorder),
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: HORIZONTAL_PADDING, vertical: VERTICAL_PADDING),
        child: Row(
          children: [
            Image.asset(
              icon,
              height: 22,
              width: 22,
            ),
            SizedBox(
              width: 16,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: getSmallText(title,
                  color: gpTextSecondary,
                  weight: FontWeight.w500,
                  fontSize: SUBTITLE_FONT_SIZE),
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
    ),
  );
}

Widget uploadReceiptContainer(String icon, String title) {
  return Container(
    height: deviceHeight * 0.07,
    width: deviceWidth,
    decoration: BoxDecoration(
        color: colorWhite,
        border: Border.all(color: colorgreyborder),
        borderRadius: BorderRadius.all(Radius.circular(10))),
    child: Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: HORIZONTAL_PADDING, vertical: VERTICAL_PADDING),
      child: Row(
        children: [
          Image.asset(
            icon,
            height: 22,
            width: 22,
          ),
          SizedBox(
            width: 16,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: getSmallText(title,
                color: colorgreytext,
                weight: FontWeight.w400,
                fontSize: SUBTITLE_FONT_SIZE),
          ),
        ],
      ),
    ),
  );
}

Future<void> logoutBottomSheet(BuildContext context, String title,
    VoidCallback ondecline, VoidCallback onaccept) async {
  await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          height: deviceHeight * 0.22,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Spacer(),
              getSmallText(title,
                  fontSize: BUTTON_FONT_SIZE,
                  bold: true,
                  weight: FontWeight.w500,
                  color: colorBlack,
                  isCenter: true,
                  align: TextAlign.center),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getButton("NO", () {
                    return ondecline();
                  },
                      width: deviceWidth * 0.25,
                      color: colorWhite,
                      textColor: colorGradientFirst,
                      height: deviceHeight * 0.06),
                  SizedBox(
                    width: 10,
                  ),
                  getButton("YES", () {
                    return onaccept();
                  }, width: deviceWidth * 0.25, height: deviceHeight * 0.06),
                ],
              ),
              Spacer()
            ],
          ),
        );
      });
}

Future<void> deleteaccountBottomSheet(BuildContext context, String title,
    VoidCallback ondecline, VoidCallback onaccept) async {
  await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          height: deviceHeight * 0.4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Spacer(),
              Image.asset(
                IC_EXCLAIM,
                height: deviceHeight * 0.1,
                width: deviceWidth * 0.2,
              ),
              Spacer(),
              getSmallText(Deleteaccountalert,
                  fontSize: BUTTON_FONT_SIZE,
                  bold: true,
                  weight: FontWeight.w500,
                  color: colordeleteaccount,
                  isCenter: true,
                  align: TextAlign.center),
              Spacer(),
              getSmallText(title,
                  fontSize: BUTTON_FONT_SIZE,
                  bold: true,
                  weight: FontWeight.w500,
                  color: colorBlack,
                  isCenter: true,
                  align: TextAlign.center),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getButton("NO", () {
                    return ondecline();
                  },
                      width: deviceWidth * 0.25,
                      color: colorWhite,
                      textColor: colorGradientFirst,
                      height: deviceHeight * 0.06),
                  SizedBox(
                    width: 10,
                  ),
                  getButton("YES", () {
                    return onaccept();
                  }, width: deviceWidth * 0.25, height: deviceHeight * 0.06),
                ],
              ),
              Spacer(
                flex: 2,
              )
            ],
          ),
        );
      });
}

class CustomItemList extends StatefulWidget {
  final bool isSelected;
  final String logo;
  final String storeName;
  final String date;
  final String price;
  final String coins;
  final String? currency;
  final bool isCoupons;
  final bool valueSelected;
  final ValueChanged<bool>? selectFunction;
  final bool isstorelogoavailable;
  final bool? inprogress;
  final bool isLatest;
  final bool? isDuplicate;
  final String? tagType;

  const CustomItemList(
    this.isSelected,
    this.logo,
    this.storeName,
    this.date,
    this.price,
    this.coins, {
    this.isCoupons = false,
    this.valueSelected = false,
    this.selectFunction,
    this.isstorelogoavailable = false,
    this.currency,
    this.inprogress,
    this.isLatest = false,
    this.isDuplicate,
    this.tagType,
    super.key,
  });

  @override
  State<CustomItemList> createState() => _CustomItemListState();
}

class _CustomItemListState extends State<CustomItemList> {
  late bool _valueSelected;

  @override
  void initState() {
    super.initState();
    _valueSelected = widget.valueSelected;
  }

  @override
  Widget build(BuildContext context) {
    final String? statusText = widget.inprogress == true
        ? "In progress"
        : (widget.isDuplicate == true ? "Duplicate" : null);
    final Color statusColor =
        widget.isDuplicate == true ? gpError : gpImpactOrange;
    final String? tagText = () {
      final raw = widget.tagType?.trim();
      if (raw == null || raw.isEmpty) {
        return null;
      }
      if (raw.toLowerCase() == "business") {
        return "Business";
      }
      if (raw.toLowerCase() == "personal") {
        return "Personal";
      }
      return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
    }();
    final Color tagColor = tagText == "Business" ? gpGreen : gpInfo;
    final String amountText = () {
      if (widget.isCoupons) {
        return widget.price;
      }
      final raw = widget.price.trim();
      if (raw.isEmpty) {
        return "";
      }
      final value = double.tryParse(raw);
      if (value == null) {
        return raw;
      }
      final currency = widget.currency ?? "";
      return currency.isNotEmpty
          ? "$currency ${value.toStringAsFixed(2)}"
          : value.toStringAsFixed(2);
    }();

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        height: deviceHeight * 0.095,
        width: deviceWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Visibility(
              visible: widget.isSelected,
              child: Center(
                  child: InkWell(
                onTap: () {
                  setState(() {
                    _valueSelected = !_valueSelected;
                  });
                  widget.selectFunction?.call(_valueSelected);
                },
                child: Container(
                  height: 26,
                  width: 26,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: gpGreen),
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: _valueSelected
                        ? const Icon(
                            Icons.check,
                            size: 16.0,
                            color: gpLight,
                          )
                        : Container(
                            height: 26,
                            width: 26,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: gpBorder),
                          ),
                  ),
                ),
              )),
            ),
            widget.isSelected
                ? SizedBox(
                    width: deviceWidth * 0.04,
                  )
                : SizedBox(),
            Expanded(
              child: Container(
                height: deviceHeight * 0.095,
                decoration: BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12.0,
                          offset: Offset(0.0, 0.04))
                    ],
                    color: gpLight,
                    border: Border.all(color: gpBorder),
                    borderRadius: BorderRadius.all(Radius.circular(14))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: widget.isLatest
                          ? deviceWidth * 0.015
                          : deviceWidth * 0.03,
                    ),
                    widget.isLatest
                        ? Container(
                            height: 6,
                            width: 6,
                            margin: EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                                color: gpGreen, shape: BoxShape.circle),
                          )
                        : SizedBox(),
                    Container(
                      height: deviceHeight * 0.07,
                      width: deviceWidth * 0.13,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: gpBorder),
                        color: gpLight,
                        // image: widget.isCoupons
                        //     ? DecorationImage(image: AssetImage(widget.logo))
                        //     : null
                      ),
                      child: widget.isCoupons
                          ? widget.isstorelogoavailable
                              ? Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.logo ?? "",
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        //borderRadius:
                                        //BorderRadius.circular(18),
                                        color: gpLight,
                                        // image: DecorationImage(
                                        //     image: AssetImage(
                                        //         IC_GREENTILL_IMAGE),
                                        //     fit: BoxFit.scaleDown),
                                      ),
                                      child: Center(
                                          child: getSmallText(
                                              getInitials(widget.storeName),
                                              weight: FontWeight.w500,
                                              align: TextAlign.center,
                                              color: gpTextPrimary,
                                              fontSize: BODY1_TEXT_FONT_SIZE)),
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
                                    // placeholder: (context, url) => Container(
                                    //   decoration: BoxDecoration(
                                    //     color: colorBackgroundButton,
                                    //     borderRadius: BorderRadius.circular(18),
                                    //     image: DecorationImage(
                                    //         image: AssetImage(IC_PROFILE_IMAGE),
                                    //         fit: BoxFit.cover),
                                    //   ),
                                    // ),
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        color: gpLight,
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
                                  child: getSmallText(widget.logo,
                                      weight: FontWeight.w500,
                                      align: TextAlign.center,
                                      color: gpTextPrimary,
                                      fontSize: BODY1_TEXT_FONT_SIZE))
                          : widget.isstorelogoavailable
                              ? Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.logo ?? "",
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        //borderRadius:
                                        //BorderRadius.circular(18),
                                        color: gpLight,
                                        // image: DecorationImage(
                                        //     image: AssetImage(
                                        //         IC_GREENTILL_IMAGE),
                                        //     fit: BoxFit.scaleDown),
                                      ),
                                      child: Center(
                                          child: getSmallText(
                                              getInitials(widget.storeName),
                                              weight: FontWeight.w500,
                                              align: TextAlign.center,
                                              color: gpTextPrimary,
                                              fontSize: BODY1_TEXT_FONT_SIZE)),
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
                                    // placeholder: (context, url) => Container(
                                    //   decoration: BoxDecoration(
                                    //     color: colorBackgroundButton,
                                    //     borderRadius: BorderRadius.circular(18),
                                    //     image: DecorationImage(
                                    //         image: AssetImage(IC_PROFILE_IMAGE),
                                    //         fit: BoxFit.cover),
                                    //   ),
                                    // ),
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        color: gpLight,
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
                                  child: getSmallText(widget.logo,
                                      weight: FontWeight.w500,
                                      align: TextAlign.center,
                                      color: gpTextPrimary,
                                      fontSize: BODY1_TEXT_FONT_SIZE)),
                    ),
                    SizedBox(
                      width: deviceWidth * 0.028,
                    ),
                    Container(
                      width: widget.isSelected
                          ? deviceWidth * 0.34
                          : deviceWidth * 0.39,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (statusText != null || tagText != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (statusText != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        border: Border.all(
                                            color:
                                                statusColor.withOpacity(0.35)),
                                      ),
                                      child: getSmallText(statusText,
                                          color: statusColor,
                                          weight: FontWeight.w600,
                                          fontSize:
                                              CAPTION_SMALLER_TEXT_FONT_SIZE),
                                    ),
                                  if (statusText != null && tagText != null)
                                    const SizedBox(width: 6),
                                  if (tagText != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: tagColor.withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        border: Border.all(
                                            color: tagColor.withOpacity(0.35)),
                                      ),
                                      child: getSmallText(tagText,
                                          color: tagColor,
                                          weight: FontWeight.w600,
                                          fontSize:
                                              CAPTION_SMALLER_TEXT_FONT_SIZE),
                                    ),
                                ],
                              ),
                            ),
                          Container(
                            width:
                                // widget.isSelected
                                //     ?
                                widget.isSelected
                                    ? deviceWidth * 0.35
                                    : deviceWidth * 0.4,
                            // : deviceWidth * 0.45,
                            child: getTitle(widget.storeName ?? "",
                                weight: FontWeight.w600,
                                bold: true,
                                lines: 1,
                                fontSize: CAPTION_TEXT_FONT_SIZE,
                                color: gpTextPrimary),
                          ),
                          SizedBox(
                            height: deviceHeight * 0.006,
                          ),
                          getSmallText(widget.date ?? "",
                              weight: FontWeight.w400,
                              bold: true,
                              fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                              color: gpTextMuted),
                        ],
                      ),
                    ),
                    // Spacer(),
                    Expanded(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              child: Align(
                                child: getTitle(amountText,
                                    weight: FontWeight.w800,
                                    bold: true,
                                    lines: 1,
                                    fontSize: BUTTON_FONT_SIZE,
                                    color: gpGreen),
                                alignment: Alignment.centerRight,
                              ),
                              // width: deviceWidth * 0.2,
                            ),
                            SizedBox(
                              height: deviceHeight * 0.006,
                            ),
                            widget.isCoupons
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: deviceWidth * 0.15,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: getSmallText(
                                              widget.coins ?? "",
                                              weight: FontWeight.w500,
                                              bold: true,
                                              fontSize:
                                                  CAPTION_SMALLER_TEXT_FONT_SIZE,
                                              color: gpTextPrimary),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox()
                            // Row(
                            //         children: [
                            //           Image.asset(
                            //             IC_COIN,
                            //             height: 16,
                            //             width: 16,
                            //           ),
                            //           SizedBox(
                            //             width: 4,
                            //           ),
                            //           getSmallText(widget.coins + " Coins" ?? "",
                            //               weight: FontWeight.w500,
                            //               bold: true,
                            //               fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                            //               color: colorBlack),
                            //         ],
                            //       )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: deviceWidth * 0.03,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<void> selectedrecieptBottomSheet(
    BuildContext context,
    VoidCallback ondownload,
    VoidCallback onshare,
    VoidCallback ondelete) async {
  await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      backgroundColor: gpLight,
      context: context,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          height: deviceHeight * 0.13,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                IC_DOWNLOAD,
                height: deviceHeight * 0.05,
                width: deviceWidth * 0.07,
                fit: BoxFit.fitHeight,
              ),
              SizedBox(
                width: deviceWidth * 0.07,
              ),
              Image.asset(
                IC_SHARE,
                height: deviceHeight * 0.05,
                width: deviceWidth * 0.07,
                fit: BoxFit.fitHeight,
              ),
              SizedBox(
                width: deviceWidth * 0.07,
              ),
              GestureDetector(
                onTap: () => ondelete(),
                child: Image.asset(
                  IC_DELETE,
                  height: deviceHeight * 0.05,
                  width: deviceWidth * 0.07,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ],
          ),
        );
      });
}

class MySliderApp extends StatefulWidget {
  const MySliderApp({super.key});

  @override
  _MySliderAppState createState() => _MySliderAppState();
}

class _MySliderAppState extends State<MySliderApp> {
  SfRangeValues _values =
      SfRangeValues(DateTime(2002, 07, 05), DateTime(2002, 07, 25));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 16,
          child: SfRangeSlider(
            min: DateTime(2002, 07, 01),
            max: DateTime(2002, 07, 30),
            values: _values,
            interval: 1,
            dateFormat: DateFormat.d(),
            dateIntervalType: DateIntervalType.days,
            activeColor: Colors.green,
            inactiveColor: Colors.grey,
            startThumbIcon: thumbIcon(),
            endThumbIcon: thumbIcon(),
            enableTooltip: true,
            minorTicksPerInterval: 1,
            onChanged: (SfRangeValues values) {
              setState(() {
                _values = values;
                print("Value=");
                print(_values.start);
                print(_values.end);
              });
            },
          ),
        ),
        Row(
          children: [
            getSmallText("1 July" ?? "",
                weight: FontWeight.w400,
                bold: true,
                fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                color: colorgreytext),
            Spacer(),
            getSmallText("1 July" ?? "",
                weight: FontWeight.w400,
                bold: true,
                fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                color: colorgreytext),
          ],
        )
      ],
    );
  }
}

Widget thumbIcon() {
  return Container(
    padding: EdgeInsets.all(3),
    child: Container(
      decoration: BoxDecoration(
        color: colorGradientFirst,
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),
    decoration: BoxDecoration(
      color: colorWhite,
      borderRadius: BorderRadius.circular(20.0),
    ),
  );
}

Future<void> receiptDetailEdit(BuildContext context) async {
  await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      backgroundColor: gpLight,
      context: context,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          height: deviceHeight * 0.5,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: HORIZONTAL_PADDING * 1.5,
                vertical: VERTICAL_PADDING * 1.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    getSmallText(information ?? "",
                        weight: FontWeight.w600,
                        bold: true,
                        fontSize: BUTTON_FONT_SIZE,
                        color: gpTextPrimary),
                    Container(
                      height: 20,
                      width: 20,
                      margin: EdgeInsets.only(top: 3, bottom: 3, right: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: gpBorder, width: 1),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.all(5.5),
                      child: Image.asset(
                        IC_CROSS,
                      ),
                    )
                  ],
                ),
                getCommonDivider(),
                Spacer(),
                SizedBox(
                  width: deviceWidth * 0.8,
                  child: getCommonTextFormField(
                    context: context,
                    //controller: _email,
                    hintText: selectStore,
                    validator: (email) {
                      // if (isEmailValid(email))
                      //   return null;
                      // else
                      //   return 'Enter a valid email address';
                    },
                    suffixIcon: Image.asset(
                      IC_ARROW_DOWN,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
                SizedBox(
                  height: deviceHeight * 0.02,
                ),
                SizedBox(
                  width: deviceWidth * 0.8,
                  child: getCommonTextFormField(
                    context: context,
                    //controller: _password,
                    hintText: selectStoreBranch,
                    //obscureText: _obscureText,
                    validator: (password) {
                      // if (isPasswordValid(password))
                      //   return null;
                      // else
                      //   return 'Enter a valid password';
                    },
                    suffixIcon: Image.asset(
                      IC_ARROW_DOWN,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
                SizedBox(
                  height: deviceHeight * 0.02,
                ),
                SizedBox(
                  width: deviceWidth * 0.8,
                  child: getCommonTextFormField(
                    context: context,
                    //controller: _password,
                    hintText: amount,
                    //obscureText: _obscureText,
                    validator: (password) {
                      // if (isPasswordValid(password))
                      //   return null;
                      // else
                      //   return 'Enter a valid password';
                    },
                  ),
                ),
                SizedBox(
                  height: deviceHeight * 0.02,
                ),
                getButton(updateReceipt, () {
                  // if (formGlobalKey.currentState.validate()) {
                  //   return  bloc.add(EmailVerification());
                  // }
                }, width: deviceWidth * 0.8, fontsize: BUTTON_FONT_SIZE),
                Spacer(),
              ],
            ),
          ),
        );
      });
}

Widget CustomQrButton(String icon, String title, VoidCallback onclick) {
  return GestureDetector(
    onTap: () {
      onclick();
    },
    child: Container(
      height: deviceHeight * 0.12,
      width: deviceWidth * 0.38,
      decoration: BoxDecoration(
          border: Border.all(color: colorqrscreenborder),
          color: colorWhite,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Column(
        children: [
          Spacer(
            flex: 2,
          ),
          Image.asset(
            icon,
            height: deviceHeight * 0.03,
            width: deviceWidth * 0.06,
            fit: BoxFit.fill,
          ),
          Spacer(),
          getSmallText(title ?? "",
              weight: FontWeight.w400,
              bold: true,
              fontSize: SUBTITLE_FONT_SIZE,
              color: colorgreytext),
          Spacer(
            flex: 2,
          ),
        ],
      ),
    ),
  );
}

Widget UploadReceiptWidget(String icon, String title, VoidCallback onclick,
    {double? width}) {
  return GestureDetector(
    onTap: () {
      onclick();
    },
    child: Container(
      height: deviceHeight * 0.06,
      width: width ?? deviceWidth,
      decoration: BoxDecoration(
          border: Border.all(color: colorqrscreenborder),
          color: colorWhite,
          borderRadius: BorderRadius.all(Radius.circular(6))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            height: deviceHeight * 0.03,
            width: deviceWidth * 0.06,
            fit: BoxFit.fill,
          ),
          SizedBox(
            width: deviceWidth * 0.05,
          ),
          getSmallText(title,
              weight: FontWeight.w400,
              bold: true,
              fontSize: SUBTITLE_FONT_SIZE,
              color: colorgreytext),
        ],
      ),
    ),
  );
}

loader() {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Loading..."),
          Container(
            margin: EdgeInsets.all(10),
            child: CircularProgressIndicator(
              backgroundColor: Colors.black26,
              valueColor: AlwaysStoppedAnimation<Color>(
                colortheme, //<-- SEE HERE
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

convertHEIC2PNG(String path2) async {
  String jpegPath = path2;
  String fileExtension = path2.substring(path2.indexOf("."), path2.length);
  fileExtension = fileExtension.replaceAll(".", "");
  print(fileExtension);
  // if (fileExtension.toLowerCase() == 'heic') {
  //   jpegPath = await HeicToJpg.convert(path2);
  //   print(jpegPath);
  // }
  return File(jpegPath);
}

void showNoMailAppsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Open Mail App"),
        content: Text("No mail apps installed"),
        actions: <Widget>[
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      );
    },
  );
}

Future<void> logoutaccount() async {
  prefs.clear();
  final googleSignIn = GoogleSignIn();
  await googleSignIn.signOut();

  signOut();
}

Widget bottomSheetIcon(String icon, VoidCallback function) {
  return GestureDetector(
    onTap: () {
      function();
    },
    child: Container(
      height: deviceHeight * 0.09,
      width: deviceWidth * 0.09,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: AssetImage(icon))),
    ),
  );
}

Future<void> claimRewardsBottomSheet(
    BuildContext context, String title, VoidCallback onOk) async {
  await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          height: deviceHeight * 0.26,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Spacer(),
              Image.asset(
                IC_STACK_COINS,
                height: deviceHeight * 0.06,
                width: deviceWidth * 0.12,
                fit: BoxFit.fill,
              ),
              Spacer(),
              getTitle(title,
                  fontSize: BUTTON_FONT_SIZE,
                  bold: true,
                  weight: FontWeight.w500,
                  color: colorBlack,
                  isCenter: true,
                  lines: 2),
              Spacer(),
              getButton("OK", () {
                return onOk();
              },
                  width: deviceWidth * 0.25,
                  color: colortheme,
                  textColor: colorWhite,
                  height: deviceHeight * 0.06),
              Spacer()
            ],
          ),
        );
      });
}

Widget receiptDetailsRow(String icon, String storetitle, String info) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: deviceHeight * 0.03,
        width: deviceWidth * 0.06,
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(icon), fit: BoxFit.fill)),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 0, left: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getTitle(storetitle,
                  color: gpTextMuted,
                  weight: FontWeight.w500,
                  lines: 1,
                  fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE),
              SizedBox(
                height: 2,
              ),
              getTitle(info,
                  color: gpTextPrimary,
                  weight: FontWeight.w600,
                  lines: 5,
                  fontSize: BUTTON_FONT_SIZE),
            ],
          ),
        ),
      )
    ],
  );
}

class MySeparator extends StatelessWidget {
  const MySeparator({super.key, this.height = 1, this.color = Colors.black});
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 2.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}

Widget customFlotingButton(String title, String icon,
    {Color textcolor = colorWhite}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(
        icon,
        height: deviceHeight * 0.035,
        fit: BoxFit.fill,
        // color: colortheme,
      ),
      SizedBox(
        height: 4,
      ),
      getSmallText(title ?? "",
          weight: FontWeight.w800,
          align: TextAlign.center,
          color: textcolor,
          fontSize: CAPTION_SMALLEST_TEXT_FONT_SIZE),
    ],
  );
}

String getInitials(String bank_account_name) => bank_account_name.isNotEmpty
    ? bank_account_name.trim().split(' ').map((l) => l[0]).take(1).join()
    : '';

String formattedDate(String date) {
  DateTime updatedDate = DateTime.parse(date);
  return formatterNew.format(updatedDate);
}

// DateTime stringToDate(String date){
//   return DateTime.parse(date);
// }
Future<File> urlToFile(String imageUrl) async {
// generate random number.
  var rng = new Random();
// get temporary directory of device.
  Directory tempDir = await getTemporaryDirectory();
// get temporary path from temporary directory.
  String tempPath = tempDir.path;
// create a new file in temporary path with random file name.
  File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
// call http.get method and pass imageUrl into it to get response.
  http.Response response = await http.get(Uri.parse(imageUrl));
// write bodyBytes received in response to file.
  await file.writeAsBytes(response.bodyBytes);
// now return the file which is created with random name in
// temporary directory and image bytes from response is written to // that file.
  return file;
}

Widget earnedPointsCard(String count, String points, bool isPointsCompleted,
    {String? type, String? logo}) {
  final logoPath = logo ?? IC_COIN;
  return Card(
    margin: EdgeInsets.symmetric(horizontal: 20),
    color: colorWhite,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    child: Container(
      height: deviceHeight * 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            width: 48,
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: colorfeedbackreceiptt),
            child: Image.asset(logoPath,
                color: isPointsCompleted ? colortheme : null),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    getSmallText(type ?? ""),
                    // SizedBox(height: deviceHeight * 0.01),
                    getTitle(
                      count ?? "",
                      weight: FontWeight.w800,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    getSmallText(earnedPoints),
                    // SizedBox(height: deviceHeight * 0.01),
                    getTitle(
                      points ?? "",
                      weight: FontWeight.w800,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class CustomRadioWidget<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final double width;
  final double height;

  const CustomRadioWidget(
      {super.key,
      required this.value,
      required this.groupValue,
      required this.onChanged,
      this.width = 20,
      this.height = 20});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          onChanged(value);
        },
        child: Container(
          height: this.height,
          width: this.width,
          decoration: ShapeDecoration(
              shape: CircleBorder(),
              color: value == groupValue ? colortheme : colorGray),
          child: Center(
            child: Container(
              height: value == groupValue
                  ? this.height - this.height / 2
                  : this.height - 4,
              width: value == groupValue
                  ? this.width - this.width / 2
                  : this.width - 4,
              decoration: ShapeDecoration(
                shape: CircleBorder(),
                color: colorWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget customCreditCard(BuildContext context,
    {String? logo,
    String? creditCardNumber,
    String? cvv,
    String? amount,
    String? date,
    String? image,
    String? currency}) {
  return Card(
    elevation: 1,
    margin: EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Container(
      height: deviceHeight * 0.26,
      // margin: EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: colorBlack,
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING * 1.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Spacer(
              flex: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getSmallText(
                  giftVoucher,
                  color: colorWhite,
                  fontSize: CAPTION_SMALLEST_TEXT_FONT_SIZE,
                  weight: FontWeight.w700,
                ),
                // Image.network(
                //   logo,
                //   fit: BoxFit.scaleDown,
                //   width: deviceWidth*0.12,
                //   height: deviceHeight*0.05,
                // ),
              ],
            ),
            getTitle(
              creditCardNumber ?? "",
              color: colorWhite,
              fontSize: CAPTION_BIG_TEXT2_FONT_SIZE,
              weight: FontWeight.w500,
            ),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Image.asset(
            //       IC_CVV,
            //       height: 18,
            //       width: 18,
            //       fit: BoxFit.scaleDown,
            //     ),
            //     SizedBox(width: 4),
            //     getSmallText(cvv, color: colorWhite,weight: FontWeight.w400,fontSize: SUBTITLE_FONT_SIZE,isCenter: true),
            //   ],
            // ),
            Spacer(),
            MySeparator(
              color: colorWhite,
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        getTitle(
                          currency ?? "",
                          color: colorWhite,
                          weight: FontWeight.w800,
                          fontSize: BUTTON_FONT_SIZE,
                        ),
                        getTitle(
                          amount ?? "",
                          color: colorWhite,
                          weight: FontWeight.w800,
                          fontSize: BUTTON_FONT_SIZE,
                        ),
                      ],
                    ),
                    getSmallText(spentOnVoucher,
                        color: colorWhite,
                        fontSize: CAPTION_SMALLEST_TEXT_FONT_SIZE,
                        weight: FontWeight.w400),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getSmallText(
                      expiryDate,
                      color: colorWhite,
                      weight: FontWeight.w400,
                      fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                    ),
                    getSmallText(
                      date ?? "",
                      color: colorWhite,
                      weight: FontWeight.w400,
                      fontSize: BUTTON_FONT_SIZE,
                    ),
                  ],
                ),
              ],
            ),
            Spacer(
              flex: 2,
            )
          ],
        ),
      ),
    ),
  );
}

Widget FeedbackWidget(String image, String title, bool isSelected) {
  return Container(
    child: Column(
      children: [
        Container(
          height: deviceHeight * 0.07,
          width: deviceWidth * 0.1,
          decoration: BoxDecoration(
            color: isSelected ? colortheme : null,
            shape: BoxShape.circle,
            // image: DecorationImage(
            //   image: AssetImage(image),
            // )
          ),
          child: Image.asset(
            image,
            color: isSelected ? colorWhite : null,
          ),
        ),
        getTitle(title ?? "",
            lines: 1,
            isCenter: true,
            color: isSelected ? colorBlack : colorfeedbackreceipt,
            fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
            weight: FontWeight.w500)
      ],
    ),
  );
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

String getCurrencySymbol(String code) {
  try {
    var currencyList = currencies.firstWhere((element) {
      return element["code"] == code || element["name"] == code;
    });

    return currencyList["symbol"]?.toString() ?? "";
  } catch (e) {
    print("erree");
    return "";
  }
}

Future<void> showUserQr(BuildContext context,
    {String? userQr, String? customerID, String? email}) async {
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
            builder: (BuildContext context, StateSetter setStatereceipt) {
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
                        getSmallText(qrheadingcard ?? "",
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
                      height: deviceHeight * 0.012,
                    ),

                    Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: colorGrey4, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      elevation: 1,
                      child: Container(
                        height: deviceHeight * 0.28,
                        width: deviceWidth,
                        decoration: BoxDecoration(
                          border: Border.all(color: colorGrey4, width: 1),
                          // color: Colors.blue,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Spacer(),
                            Container(
                              height: deviceHeight * 0.18,
                              width: deviceWidth * 0.4,
                              child: CachedNetworkImage(
                                imageUrl: userQr ?? "",
                                errorWidget: (context, url, error) => Container(
                                  height: deviceHeight * 0.18,
                                  width: deviceWidth * 0.4,
                                  child: Center(
                                    child: Icon(Icons.error),
                                  ),
                                ),
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) => Center(
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
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  height: deviceHeight * 0.18,
                                  width: deviceWidth * 0.4,
                                  decoration: BoxDecoration(
                                    color: colorWhite,
                                    image: DecorationImage(
                                        // colorFilter: ColorFilter.mode(
                                        //     colortheme, BlendMode.screen),
                                        alignment: Alignment.center,
                                        image: imageProvider,
                                        fit: BoxFit.fill),
                                  ),
                                ),
                              ),
                            ),
                            Spacer(),
                            Container(
                              width: deviceWidth * 0.75,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  getTitle(customerid,
                                      fontSize: BUTTON_FONT_SIZE,
                                      weight: FontWeight.w600,
                                      color: colorBlack,
                                      isCenter: true),
                                  Flexible(
                                      child: getTitle(customerID ?? "",
                                          fontSize: BUTTON_FONT_SIZE,
                                          weight: FontWeight.w400,
                                          color: colorBlack,
                                          isCenter: true,
                                          lines: 1)),
                                ],
                              ),
                            ),
                            Spacer(),
                            Container(
                              width: deviceWidth * 0.75,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  getTitle("Email: ",
                                      fontSize: BUTTON_FONT_SIZE,
                                      weight: FontWeight.w600,
                                      color: colorBlack,
                                      isCenter: true),
                                  Flexible(
                                      child: getTitle(email ?? "",
                                          fontSize: BUTTON_FONT_SIZE,
                                          weight: FontWeight.w400,
                                          color: colorBlack,
                                          isCenter: true,
                                          lines: 1)),
                                ],
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    )

                    // SizedBox(height: deviceHeight*0.1,),
                  ],
                ),
              ),
            ),
          );
        });
      });
}

String convertToAgo(DateTime input) {
  Duration diff = DateTime.now().difference(input);

  if (diff.inDays > 1) {
    return '${diff.inDays}d';
  } else if (diff.inDays == 1) {
    return '${diff.inDays}d';
  } else if (diff.inHours > 1) {
    return '${diff.inHours}h';
  } else if (diff.inHours == 1) {
    return '${diff.inHours}h';
  } else if (diff.inMinutes > 1) {
    return '${diff.inMinutes}m';
  } else if (diff.inMinutes == 1) {
    return '${diff.inMinutes}m';
  } else if (diff.inSeconds > 1) {
    return '${diff.inSeconds}s';
  } else if (diff.inSeconds == 1) {
    return '${diff.inSeconds}s';
  } else {
    // return 'just now';
    return 'jn';
  }
}
