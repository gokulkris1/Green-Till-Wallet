import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';

class ContactUSScreen extends BaseStatefulWidget{
  @override
  _ContactUSScreenState createState() => _ContactUSScreenState();
}

class _ContactUSScreenState extends BaseState<ContactUSScreen> with BasicScreen{
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
          color: colorstorecardbackground,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: HORIZONTAL_PADDING,
                vertical: VERTICAL_PADDING),
            child: Row(
              children: [
                GestureDetector(
                  child: Image.asset(IC_BACK_ARROW_TWO_COLOR,height: 24,width: 24,fit: BoxFit.fill,),
                  onTap: (){
                    return bloc.add(SideMenu());
                  },),
                SizedBox(width: deviceWidth*0.025,),

                Expanded(
                  child:
                  appBarHeader(
                    contactUS,
                    fontSize: BUTTON_FONT_SIZE,
                    bold: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // appBar: AppBar(
      //   // shape: const RoundedRectangleBorder(
      //   //   // borderRadius: BorderRadius.vertical(
      //   //   //   bottom: Radius.circular(15),
      //   //   // ),
      //   // ),
      //   elevation: 0,
      //   backgroundColor: colorMyrecieptHomeBackground,
      //   title: appBarHeader(
      //     contactUS,
      //     bold: false,
      //   ),
      //   centerTitle: true,
      //   leading: GestureDetector(
      //     child: Image.asset(IC_BACK_ARROW_TWO_COLOR),
      //     onTap: () {
      //       return bloc.add(SideMenu());
      //     },
      //   ),
      // ),

      body: SafeArea(
        child: Container(
          height: deviceHeight,
          width: deviceWidth,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: deviceHeight*0.3,
                  width: deviceWidth,
                  color:colorstorecardbackground ,
                  child: Column(
                    children: [
                      Image.asset(IC_PERSON,height: deviceHeight*0.13,width: deviceWidth*0.3,fit: BoxFit.fill,),
                      Spacer(),
                      getTitle(dropLine,bold: true,isCenter: true,fontSize:BODY1_TEXT_FONT_SIZE,weight: FontWeight.w500 ),
                      Spacer(),
                      getSmallText(dropLineContent,
                          weight: FontWeight.w400,
                          align: TextAlign.center,
                          fontSize: SUBTITLE_FONT_SIZE),
                      Spacer(flex: 2,),

                    ],
                  ),
                ),
                Container(
                  height: deviceHeight*0.24,
                  width: deviceWidth,
                  color:colorWhite ,
                  child: Column(
                    children: [
                      Spacer(),
                      Image.asset(IC_MESSAGE_CIRCLE,height: deviceHeight*0.06,width: deviceWidth*0.12,fit: BoxFit.fill,),
                      Spacer(),
                      getSmallText(mailAccountContent,bold: true,isCenter: true,fontSize:BUTTON_FONT_SIZE,color: colorBlack,weight: FontWeight.w500 ),
                      Spacer(),
                      getSmallText(mailContent,
                          weight: FontWeight.w400,
                          align: TextAlign.center,
                          fontSize: SUBTITLE_FONT_SIZE),
                      Spacer(flex: 2,),

                    ],
                  ),
                ),
                // Container(
                //   height: deviceHeight*0.24,
                //   width: deviceWidth,
                //   color:colorWhite ,
                //   child: Column(
                //     children: [
                //       Spacer(),
                //       Image.asset(IC_PHONE_CIRCLE,height: deviceHeight*0.06,width: deviceWidth*0.12,fit: BoxFit.fill,),
                //       Spacer(),
                //       getSmallText(phoneNumber,bold: true,isCenter: true,fontSize:BUTTON_FONT_SIZE,color: colorBlack,weight: FontWeight.w500 ),
                //       Spacer(),
                //       getSmallText(phoneNumberContent,
                //           weight: FontWeight.w400,
                //           align: TextAlign.center,
                //           fontSize: SUBTITLE_FONT_SIZE),
                //       Spacer(flex: 2,),
                //
                //     ],
                //   ),
                // )

              ],
            ),
          ),

        ),
      ),
    );
  }

}