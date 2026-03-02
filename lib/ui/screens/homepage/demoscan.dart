import 'package:flutter/material.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/ui/screens/qrscan/qr_demo_screen.dart';
import 'package:greentill/utils/common_widgets.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({Key key}) : super(key: key);

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
                child:Image.asset(IC_DEMO_IMAGE2) ),
            Positioned.fill(
                child: Padding(
                  padding:  EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.08),
                  child: Align(
                    alignment: Alignment.bottomCenter,

                    child: Container(
                      // height: deviceHeight * 0.08,
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: MediaQuery.of(context).size.width * 0.17,
                      decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 30.0,
                              offset: Offset(0.0, 0.05))
                        ],
                        border: Border.all(color: colorhomebordercolor),
                        color: colorWhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // customFlotingButtonn("Home", IC_HOME),
                          GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (context) {
                                          return QrDemoScreen();
                                        }));
                              },
                              child: customFlotingButtonn(
                                  "Scan QR", IC_GREYQR,textcolor: colorBlack))
                        ],
                      ),
                    ),
                  ),
                ) )
          ],
        ),
      ),
    );
  }

  Widget customFlotingButtonn(String title, String icon,
      {Color textcolor = colorWhite}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          icon,
          height: MediaQuery.of(context).size.height * 0.035,
          fit: BoxFit.fill,
        ),
        SizedBox(
          height: 4,
        ),
        getSmallText(title ?? "",
            weight: FontWeight.w900,
            align: TextAlign.center,
            color: textcolor,
            fontSize: CAPTION_SMALLEST_TEXT_FONT_SIZE),
      ],
    );
  }
}
