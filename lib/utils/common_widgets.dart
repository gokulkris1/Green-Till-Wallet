import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import 'dart:io';


SharedPrefHelper prefs = SharedPrefHelper.instance;

Text getSmallText(String text,
    {bool bold = false,
      Color color = colorAccentLight,
      double fontSize,
      TextAlign align,
      FontWeight weight = FontWeight.w400,
      bool isCenter = false,
      bool underLine = false}) {
  return Text(
    text,
    textAlign: align,
    style: TextStyle(
      decoration: underLine ? TextDecoration.underline : null,
      color: color,
      fontWeight: weight,
        fontSize: fontSize ?? SUBTITLE_FONT_SIZE,
      fontFamily: "AvenirBook"
    ),
  );
}

Text getTitle(String text,
    {bool bold = false,
      bool isCenter = false,
      double fontSize,
      Color color = colorBlack,
      int lines}) {
  return Text(
    text,
    maxLines: lines,
    textAlign: isCenter ? TextAlign.center : TextAlign.start,
    style: TextStyle(
        color: color,
        fontSize: fontSize ?? TITLE_TEXT_FONT_SIZE,
        fontWeight: bold ? FontWeight.w800 : FontWeight.normal,
        fontFamily: 'AvenirBold'),
    overflow: TextOverflow.ellipsis,
  );
}

Text getSmallIcon(String text,
    {bool bold = false,
      bool isEnd = false,
      double fontSize,
      Color color = colorBlack,
      int lines}) {
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
  @required ThemeData baseTheme,
  @required BuildContext context,
  @required String title,
  String actionTitle = "",
  GestureTapCallback onActionButtonTap,
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
                  style: baseTheme.textTheme.caption,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget getCommonDivider({double thickness}) {
  thickness ??= COMMON_DIVIDER_THICKNESS;
  return Divider(
    thickness: thickness,
    color: colorGray,
  );
}

Widget getCommonTextFormField(
    {@required BuildContext context,
      String hintText = "",
      bool obscureText = false,
      bool readOnly = false,
      TextInputType keyboardType = TextInputType.text,
      TextInputAction textInputAction = TextInputAction.next,
      int maxLines = 1,
      Widget prefixIcon,
      Widget suffixIcon,
      FocusNode focusNode,
      EdgeInsetsGeometry contentPadding =
      const EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 0),
      TextAlign textAlign = TextAlign.start,
      TextEditingController controller,
      List<TextInputFormatter> inputFormatters,
      Function(String) onSubmitted,
      Function(String) validator,
      GestureTapCallback onTap,
      ValueChanged<String> onTextChanged,
      bool isCapitalise = true}) {
  ThemeData baseTheme = Theme.of(context);

  if (maxLines > 1) {
    keyboardType = TextInputType.multiline;
    textInputAction = TextInputAction.newline;
  }

  if (onSubmitted == null && textInputAction == TextInputAction.next) {
    onSubmitted = (value) {
      FocusScope.of(context).nextFocus();
    };
  }

  return TextFormField(
    style: baseTheme.textTheme.bodyText1,
    focusNode: focusNode,
    maxLines: maxLines,
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    inputFormatters: inputFormatters,
    textInputAction: textInputAction,
    textCapitalization:
    isCapitalise ? TextCapitalization.sentences : TextCapitalization.none,
    onFieldSubmitted: onSubmitted,
    validator: validator,
    autovalidateMode: AutovalidateMode.always,
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
      errorStyle: baseTheme.textTheme.bodyText1
          .copyWith(color: Colors.red, fontSize: CAPTION_TEXT_FONT_SIZE),
      filled: true,
      fillColor: colorWhite,
      hintStyle: baseTheme.textTheme.subtitle2
          .copyWith(fontSize: 16, fontWeight: FontWeight.w300),
      labelStyle: baseTheme.textTheme.subtitle2
          .copyWith(fontSize: 16, fontWeight: FontWeight.w300),
      floatingLabelStyle: TextStyle(color: colorTextfeild ),
       contentPadding: contentPadding,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: colorTextfeild, width: 0.4)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: colorTextfeild, width: 0.4)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: colorTextfeild, width: 0.4)),
    ),
  );
}


Future<dynamic> showCommonErrorDialog(
    ThemeData baseTheme, BuildContext context, String message,
    {String title: "Error"}) async {
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
                  color:  colorRed
                      ,
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          title,
                          style: baseTheme.textTheme.headline2.copyWith(
                              color:  Colors.black,
                              fontSize: 26.0),
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
                            )),
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
                            style: baseTheme.textTheme.subtitle1.copyWith(
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
      accentColor: colorBlack,
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
        labelStyle: base.textTheme.subtitle2,
        contentPadding: const EdgeInsets.only(bottom: 0),
      ));
}

Container getButton(String text, Function function,
    {Color color = colorGreen,
      String assetImage,
      double height = 52,
      bool isBold = true,
      double width,
      double fontsize = BUTTON_FONT_SIZE}) {
  return Container(
    height: height,
    width: width,
    child: RaisedButton(
      onPressed: function,
      padding: EdgeInsets.all(0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [colorGradientSecond, colorGradientFirst],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: getTitle(
                text,
                bold: isBold,
                color: colorWhite,
                fontSize: fontsize,
              ),
            ),
            assetImage == null
                ? Container()
                : Container(
              margin: EdgeInsets.only(right: 5, left: 5),
              child: Image.asset(
                assetImage,
                color: colorWhite,
                fit: BoxFit.fill,
                width: 15,
                height: 15,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Container SocialLoginButton(String image){
  return Container(
    height: deviceHeight*0.06,
    width: deviceWidth*0.13,
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: colorSocialMediabtncolor),
      image:  DecorationImage(
        image: AssetImage(image),
      ),
      )
    );

}