import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';

class CardStatusScreen extends BaseStatefulWidget {
  final String cardStatus;

  final String cardStatusString;
  bool deleteFlag = false;

  CardStatusScreen({this.cardStatus, this.cardStatusString, this.deleteFlag});

  @override
  _CardStatusScreenState createState() => _CardStatusScreenState();
}

class _CardStatusScreenState extends BaseState<CardStatusScreen>
    with BasicScreen {
  @override
  Widget buildBody(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorWhite,
      body: SafeArea(
        child: Container(
          height: deviceHeight,
          width: deviceWidth,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: HORIZONTAL_PADDING,
              vertical: VERTICAL_PADDING * 7,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  IC_CIRCLE_TICK,
                  height: deviceHeight * 0.15,
                  width: deviceWidth * 0.2,
                ),
                getSmallText(widget.cardStatus,
                    weight: FontWeight.w500,
                    bold: false,
                    fontSize: BUTTON_FONT_SIZE,
                    color: colortheme),
                SizedBox(
                  height: deviceHeight * 0.01,
                ),
                getSmallText(widget.cardStatusString,
                    weight: FontWeight.w500,
                    bold: true,
                    fontSize: SUBTITLE_FONT_SIZE,
                    align: TextAlign.center,
                    color: colorBlack),
                SizedBox(
                  height: deviceHeight * 0.03,
                ),
                getButton(
                  "Okay",
                  () {
                    if (widget.deleteFlag) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      // Navigator.pop(context);
                      // Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                    bloc.add(HomeScreenEvent());
                    // }));
                  },
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
