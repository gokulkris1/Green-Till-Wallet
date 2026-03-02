import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';

class CardAddedScreen extends BaseStatefulWidget {
  @override
  _CardAddedScreenState createState() => _CardAddedScreenState();
}

class _CardAddedScreenState extends BaseState<CardAddedScreen>
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
                getSmallText(congratulations,
                    weight: FontWeight.w500,
                    bold: false,
                    fontSize: BUTTON_FONT_SIZE,
                    color: colortheme),
                SizedBox(
                  height: deviceHeight * 0.01,
                ),
                getSmallText(cardAdded,
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
                    bloc.add(HomeScreenEvent());
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
