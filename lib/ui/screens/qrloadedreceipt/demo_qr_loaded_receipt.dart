
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/common_widgets.dart';

class DemoQRLoadedReceipt extends BaseStatefulWidget {
  DemoQRLoadedReceipt({this.url});

  final String url;

  @override
  _DemoQRLoadedReceiptState createState() => _DemoQRLoadedReceiptState();
}

class _DemoQRLoadedReceiptState extends BaseState<DemoQRLoadedReceipt>
    with BasicScreen {
  bool loaded = false;

  @override
  void initState() {
    super.initState();
  }

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
                    // return bloc.add(SideMenu());
                  },
                ),
                SizedBox(
                  width: deviceWidth * 0.025,
                ),
                Spacer(),
                IconButton(
                  onPressed: () async {
                    showMessage("Receipt Downloaded!", () {
                      setState(() {
                        // bloc.add(WelcomeIn());
                        Navigator.pop(context);
                        isShowMessage = false;
                      });
                    });
                  },
                  icon: Icon(Icons.download),
                )
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15),
          height: deviceHeight,
          width: deviceWidth,
          color: colorWhite,
          child: CachedNetworkImage(
            imageUrl: widget.url,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.fill,
                  // colorFilter:
                  //     ColorFilter.mode(Colors.red, BlendMode.colorBurn),
                ),
              ),
            ),
            placeholder: (context, url) => loader(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          // child: Image.network(
          //   widget.url,
          //   fit: BoxFit.fill,
          // ),
        ),
      ),
    );
  }
}
