import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';

class QrDemoScreen extends BaseStatefulWidget {
  const QrDemoScreen({super.key});

  @override
  _QrDemoScreenState createState() => _QrDemoScreenState();
}

class _QrDemoScreenState extends BaseState<QrDemoScreen>
    with BasicScreen {
  @override
  Widget buildBody(BuildContext context) {
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
                  offset: const Offset(0.0, 0.05))
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
                    return bloc.add(HomeScreenEvent());
                  },
                ),
                SizedBox(width: deviceWidth * 0.025),
                Expanded(
                  child: appBarHeader(
                    scanQRCode,
                    fontSize: BUTTON_FONT_SIZE,
                    bold: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: getSmallText(
            "QR demo isn't supported on web preview.\nPlease use iOS/Android.",
            isCenter: true,
            fontSize: SUBTITLE_FONT_SIZE,
            color: colorAccentLight,
            weight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
