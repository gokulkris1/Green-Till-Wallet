import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';

class CardDeletedScreen extends BaseStatefulWidget {
  @override
  _CardDeletedScreenState createState() => _CardDeletedScreenState();
}

class _CardDeletedScreenState extends BaseState<CardDeletedScreen>
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
                getSmallText(deleted,
                    weight: FontWeight.w500,
                    bold: false,
                    fontSize: BUTTON_FONT_SIZE,
                    color: colortheme),
                SizedBox(
                  height: deviceHeight * 0.01,
                ),
                getSmallText(cardDeleted,
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
