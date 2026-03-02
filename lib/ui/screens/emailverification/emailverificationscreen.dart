import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';

class EmailVerificationScreen extends BaseStatefulWidget{
  @override
  _EmailVerificationScreenState  createState() => _EmailVerificationScreenState();

}

class _EmailVerificationScreenState extends BaseState<EmailVerificationScreen> with BasicScreen {
  @override
  Widget buildBody(BuildContext context) {
   return Scaffold(
     resizeToAvoidBottomInset: false,
     backgroundColor: colorWhite,
     appBar: AppBar(
       backgroundColor: colorWhite,
       elevation: 0,
       // leading: IconButton(
       //   icon: Icon(Icons.arrow_back_outlined, color: Colors.black),
       //   onPressed: () => bloc.add(Settings()),
       // ),
     ),
     body: SafeArea(
       child: Container(
         height: MediaQuery.of(context).size.height,
         width: MediaQuery.of(context).size.width,
         child:Padding(
           padding:  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING,vertical: 0),
           child: Column(
             children: [
               Container(
                   child: Image.asset(IC_EMAIL_VERIFY, height:deviceHeight*0.1,width: deviceWidth*0.35,fit: BoxFit.fill,)),

               const SizedBox(height: 20,),
               getSmallText(Emailverificationcontent,weight: FontWeight.w400,align: TextAlign.center,fontSize: SUBTITLE_FONT_SIZE),
               const SizedBox(height: 20,),
               getButton(openemail, ()async{
                 showMessage("Open mail app is temporarily unavailable in this build.", () {
                   setState(() {
                     isShowMessage = false;
                   });
                 });
               },width:deviceWidth*0.8, fontsize:BUTTON_FONT_SIZE ),
               const SizedBox(height: 20,),
               GestureDetector(
                   onTap: (){
                     bloc.add(Login());
                   },
                   child: getSmallText(skipfornow,weight: FontWeight.w400,align: TextAlign.center,fontSize: SUBTITLE_FONT_SIZE)),
               Spacer(),
               Padding(
                 padding: const EdgeInsets.only(bottom:HORIZONTAL_PADDING ),
                 child: SizedBox(
                   width: deviceWidth*0.8,
                   child: GestureDetector(
                     onTap: (){
                       bloc.add(SignUp());
                     },
                     child: RichText(
                       textAlign: TextAlign.center,
                       text: const TextSpan(
                         style: TextStyle(
                           fontSize: 14.0,
                           color: Colors.black,
                         ),
                         children: <TextSpan>[
                           TextSpan(text: notReceivedEmail,style: TextStyle(fontSize: SUBTITLE_FONT_SIZE,color: colorAccentLight,fontWeight: FontWeight.w400)),
                           TextSpan(text: tryAnotherMail, style: TextStyle(fontWeight: FontWeight.w800,fontSize: SUBTITLE_FONT_SIZE,color: colorBlack)),
                         ],
                       ),
                     ),
                   ),
                   // child: Column(
                   //   mainAxisAlignment: MainAxisAlignment.center,
                   //   children: [
                   //     getSmallText(notReceivedEmail,bold: true,fontSize: SUBTITLE_FONT_SIZE,color: colorAccentLight),
                   //     getTitle(tryAnotherMail,bold: true,fontSize: SUBTITLE_FONT_SIZE),
                   //   ],
                   // ),
                 ),
               ),

             ],

           ),
         ) ,
       ),
     ),

   );
  }


}
