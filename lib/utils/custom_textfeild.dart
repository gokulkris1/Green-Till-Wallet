
import 'package:flutter/material.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:intl/intl.dart';

import '../ui/res/dimen_resources.dart';

class CustomTextField extends StatefulWidget {
  // const CustomTextField({Key key}) : super(key: key);

  final String hintText;
  TextInputType keyboardType;
  TextEditingController controller;
  bool enabled = true;
  bool isPassword = false;
  bool bold = false;
  double font;
  int lines = 1;
  bool bottomPadding = false;
  bool isPhone = false;
  bool isFirstCap = false;
  Function function;
  Color color = colorBlack;
  int maxChar;
  String assetImage;
  Function onTap;
  Function onicontap;
  Function onchange;

  CustomTextField({
    this.controller,
    this.bold,
    this.assetImage,
    this.bottomPadding,
    this.color,
    this.enabled,
    this.font,
    this.function,
    this.hintText,
    this.isFirstCap,
    this.isPassword,
    this.isPhone,
    this.keyboardType,
    this.lines,
    this.maxChar,
    this.onTap,
    this.onicontap,
    this.onchange
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  int colorFlag = 0;

  @override
  Widget build(BuildContext context) {
    return widget.isFirstCap
        ? Container(
      child: Row(
        children: [
          TextField(
            textAlignVertical: TextAlignVertical.center,
            minLines: widget.lines,
            maxLines: widget.lines,
            controller: widget.controller,
            enabled: widget.enabled,
            obscureText: widget.isPassword,
            onSubmitted: widget.function,
            maxLength: widget.maxChar,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(
                fontSize: BODY4_TEXT_FONT_SIZE,
                fontWeight: FontWeight.w400,
                color: widget.color,
                fontFamily: 'RubikRegular'),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                // borderSide: colorFlag == 1 ? BorderSide(
                //     width: 2, color: borderColor) : BorderSide(
                //     width: 0, color: borderColor) ,
              ),
              counterText: '',
              hintText: widget.hintText,
              hintStyle: TextStyle(
                  fontSize: BODY4_TEXT_FONT_SIZE,
                  fontWeight:
                  widget.bold ? FontWeight.w600 : FontWeight.w400,
                  color: colorAccentLight,
                  fontFamily: 'RubikRegular'),
              border: InputBorder.none,
              contentPadding: widget.bottomPadding
                  ? EdgeInsets.symmetric(vertical: 13.5, horizontal: 15)
                  : EdgeInsets.symmetric(vertical: 0.0, horizontal: 15),
            ),
            keyboardType: widget.keyboardType,
            textAlign: TextAlign.left,
          ),
          widget.assetImage == null
              ? Container()
              : Container(
            margin: EdgeInsets.only(right: 15, left: 15),
            child: Image.asset(
              widget.assetImage,
              fit: BoxFit.fill,
              width: 18,
              height: 18,
            ),
          ),
        ],
      ),
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
    )
        : Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          // do stuff
          setState(() {
            colorFlag = 1;
          });
        } else {
          setState(() {
            colorFlag = 0;
          });
        }
      },
      child: Container(
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          onChanged: widget.onchange,
          minLines: widget.lines,
          maxLines: widget.lines,
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: widget.isPassword,
          onSubmitted: widget.function,
          maxLength: widget.maxChar,

          style: TextStyle(
              fontSize: BODY4_TEXT_FONT_SIZE,
              fontWeight: FontWeight.w400,
              color: widget.color,
              fontFamily: 'RubikRegular'),
          decoration: InputDecoration(
            suffixIconConstraints: BoxConstraints(
              minHeight: 15,
              minWidth: 15,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(width: 2, color: Colors.transparent),
            ),
            counterText: '',
            hintText: widget.hintText,
            hintStyle: TextStyle(
                fontSize: BODY4_TEXT_FONT_SIZE,
                fontWeight: FontWeight.w400,
                color: colorGrey,
                fontFamily: 'RubikRegular'),
            border: InputBorder.none,
            contentPadding:
            EdgeInsets.symmetric(vertical: 15.5, horizontal: 15),
          ),
          keyboardType: widget.keyboardType,
          textAlign: TextAlign.left,
        ),
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
      ),
    );
  }
}
