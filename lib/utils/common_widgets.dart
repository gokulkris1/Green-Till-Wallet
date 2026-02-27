import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';

Text getSmallText(
  String text, {
  bool bold = false,
  Color color = colorAccentLight,
  double? fontSize,
  TextAlign? align,
  FontWeight weight = FontWeight.w400,
  bool underLine = false,
}) {
  return Text(
    text,
    textAlign: align,
    style: TextStyle(
        decoration: underLine ? TextDecoration.underline : null,
        color: color,
        fontWeight: bold ? FontWeight.bold : weight,
        fontSize: fontSize ?? SUBTITLE_FONT_SIZE,
        fontFamily: "AvenirBook"),
  );
}

Text getTitle(
  String text, {
  bool bold = false,
  bool isCenter = false,
  double? fontSize,
  Color color = colorBlack,
  int? lines,
}) {
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

Text getSmallIcon(
  String text, {
  bool bold = false,
  bool isEnd = false,
  double? fontSize,
  Color color = colorBlack,
  int? lines,
}) {
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
  return SizedBox(
    height: 35,
    child: Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: colorBlack,
                fontSize: CAPTION_BIGGER_TEXT_FONT_SIZE,
                fontFamily: 'RubikRegular'),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            InkWell(
              onTap: onActionButtonTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  actionTitle,
                  style: baseTheme.textTheme.labelSmall,
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
    color: colorGray,
  );
}

Widget getCommonTextFormField({
  required BuildContext context,
  String hintText = "",
  bool obscureText = false,
  bool readOnly = false,
  TextInputType keyboardType = TextInputType.text,
  TextInputAction textInputAction = TextInputAction.next,
  int maxLines = 1,
  Widget? prefixIcon,
  Widget? suffixIcon,
  FocusNode? focusNode,
  EdgeInsetsGeometry contentPadding =
      const EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 0),
  TextAlign textAlign = TextAlign.start,
  TextEditingController? controller,
  List<TextInputFormatter>? inputFormatters,
  ValueChanged<String>? onSubmitted,
  String? Function(String?)? validator,
  GestureTapCallback? onTap,
  ValueChanged<String>? onTextChanged,
  bool isCapitalise = true,
}) {
  final baseTheme = Theme.of(context);

  TextInputType resolvedKeyboardType = keyboardType;
  TextInputAction resolvedTextInputAction = textInputAction;

  if (maxLines > 1) {
    resolvedKeyboardType = TextInputType.multiline;
    resolvedTextInputAction = TextInputAction.newline;
  }

  return TextFormField(
    style: baseTheme.textTheme.bodyMedium,
    focusNode: focusNode,
    maxLines: maxLines,
    controller: controller,
    keyboardType: resolvedKeyboardType,
    obscureText: obscureText,
    inputFormatters: inputFormatters,
    textInputAction: resolvedTextInputAction,
    textCapitalization:
        isCapitalise ? TextCapitalization.sentences : TextCapitalization.none,
    onFieldSubmitted: onSubmitted,
    validator: validator,
    autovalidateMode: AutovalidateMode.onUserInteraction,
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
      filled: true,
      fillColor: colorWhite,
      hintStyle: baseTheme.textTheme.bodySmall
          ?.copyWith(fontSize: 16, fontWeight: FontWeight.w300),
      labelStyle: baseTheme.textTheme.bodySmall
          ?.copyWith(fontSize: 16, fontWeight: FontWeight.w300),
      floatingLabelStyle: const TextStyle(color: colorTextfeild),
      contentPadding: contentPadding,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: colorTextfeild, width: 0.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: colorTextfeild, width: 0.4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: colorTextfeild, width: 0.4),
      ),
    ),
  );
}

Future<dynamic> showCommonErrorDialog(
  ThemeData baseTheme,
  BuildContext context,
  String message, {
  String title = "Error",
}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) => Center(
      child: SizedBox(
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
                        style: baseTheme.textTheme.headlineSmall?.copyWith(
                          color: Colors.black,
                          fontSize: 26.0,
                        ),
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
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: baseTheme.textTheme.titleMedium?.copyWith(
                          color: Colors.black,
                          fontSize: 16.0,
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
    ),
  );
}

Widget getButton(
  String text,
  VoidCallback onPressed, {
  Color color = colorGreen,
  String? assetImage,
  double height = 52,
  bool isBold = true,
  double? width,
  double fontsize = BUTTON_FONT_SIZE,
}) {
  return SizedBox(
    height: height,
    width: width,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.black26,
      ),
      child: Ink(
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
            getTitle(
              text,
              bold: isBold,
              color: colorWhite,
              fontSize: fontsize,
            ),
            if (assetImage != null) ...[
              const SizedBox(width: 8),
              Image.asset(
                assetImage,
                color: colorWhite,
                fit: BoxFit.fill,
                width: 15,
                height: 15,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

Widget socialLoginButton(BuildContext context, String image) {
  final size = MediaQuery.of(context).size;
  return Container(
    height: size.height * 0.06,
    width: size.width * 0.13,
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      border: Border.all(color: colorSocialMediabtncolor),
      image: DecorationImage(
        image: AssetImage(image),
      ),
    ),
  );
}
