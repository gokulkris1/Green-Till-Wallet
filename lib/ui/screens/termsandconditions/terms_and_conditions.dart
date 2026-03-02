import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../res/image_resources.dart';

class TermsAndConditionsScreen extends BaseStatefulWidget {
  @override
  _TermsAndConditionsScreenState createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends BaseState<TermsAndConditionsScreen>
    with BasicScreen {
  bool isLoadingLocal = true;
  String content = "";
  bool isFirst = true;

  @override
  Widget buildBody(BuildContext context) {
    if (isFirst) {
      isFirst = false;
      getTermsAndConditions();
    }
    return isLoadingLocal == true
        ? loader()
        : Scaffold(
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
                      horizontal: HORIZONTAL_PADDING,
                      vertical: VERTICAL_PADDING),
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
                          bloc.add(SideMenu());
                        },
                      ),
                      SizedBox(
                        width: deviceWidth * 0.025,
                      ),
                      Expanded(
                        child: appBarHeader(
                          TermsAndConditions,
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
              child: Container(
                height: deviceHeight,
                width: deviceWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: HORIZONTAL_PADDING,
                      vertical: VERTICAL_PADDING),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Html(
                          onLinkTap: (url, attributes, element) async {
                            if (url == null) return;
                            final uri = Uri.tryParse(url);
                            if (uri == null) return;
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                          style: {
                            "body": Style(
                              color: colorAccentLight,
                              fontSize: FontSize(SUBTITLE_FONT_SIZE),
                              fontWeight: FontWeight.w400,
                            ),
                          },
                          data: content,
                        ),
                        // getSmallText(termsandConditionsContent,
                        //     weight: FontWeight.w400,
                        //     align: TextAlign.center,
                        //     fontSize: SUBTITLE_FONT_SIZE),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Future getTermsAndConditions() async {
    bloc.userRepository
        .getstaticpage(type: "TERMS_AND_CONDITION")
        .then((value) {
      if (value.status == 1) {
        content = value.data?.content ?? "";

        if (mounted)
          setState(() {
            isLoadingLocal = false;
          });
      } else if (value.apiStatusCode == 401) {
        showMessage(value.message ?? "", () {
          setState(() {
            isShowMessage = false;
            logoutaccount();
            isLoadingLocal = false;
            return bloc.add(Login());
          });
        });
      } else {
        print(value.message);
        showMessage(value.message ?? "", () {
          setState(() {
            isShowMessage = false;
            isLoadingLocal = false;
          });
        });
      }
    });
  }
}
