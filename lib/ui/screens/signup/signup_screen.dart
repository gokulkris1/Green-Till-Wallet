import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';

class SignUpScreen extends BaseStatefulWidget{
  @override
  _SignUpScreenState createState() => _SignUpScreenState();

}

class _SignUpScreenState extends BaseState<SignUpScreen> with BasicScreen{
  final TextEditingController _firstname = TextEditingController();
  final TextEditingController _lastname = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password= TextEditingController();
  final TextEditingController _confirmpassword= TextEditingController();
  final TextEditingController _selectcountry= TextEditingController();
  final TextEditingController _mobilenumber= TextEditingController();
  bool _value = false;

  @override
  Widget buildBody(BuildContext context) {
   return Scaffold(
     resizeToAvoidBottomInset: false,
     backgroundColor: colorWhite,
     body: SafeArea(
       child: Container(
         height: MediaQuery.of(context).size.height,
         width: MediaQuery.of(context).size.width,
         child: Padding(
           padding:  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING,vertical: VERTICAL_PADDING),
           child: SingleChildScrollView(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.start,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 Container(
                     child: Image.asset(IC_GREENTILL_IMAGE, height:deviceHeight*0.15,width: deviceWidth*0.35,)),
                 const SizedBox(height: 15,),
                 SizedBox(
                   width: deviceWidth*0.8,
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       getSmallText(SignupHeading,bold: true,fontSize: TITLE_TEXT_FONT_SIZE,color: colorBlack),
                       getTitle(Signup,bold: true,fontSize: TITLE_TEXT_FONT_SIZE),
                     ],
                   ),
                 ),
                 const SizedBox(height: 20,),
                 getSmallText(Signupcontent,weight: FontWeight.w400,align: TextAlign.center,fontSize: SUBTITLE_FONT_SIZE),
                 const SizedBox(height: 30,),
                 SizedBox(
                   width: deviceWidth*0.8,
                   child: getCommonTextFormField(
                     context: context,
                     controller: _firstname,
                     hintText: Firstname,
                   ),
                 ),
                 const SizedBox(height: 15,),
                 SizedBox(
                   width: deviceWidth*0.8,
                   child: getCommonTextFormField(
                     context: context,
                     controller: _lastname,
                     hintText: Lastname,
                   ),
                 ),

                 const SizedBox(height: 15,),
                 SizedBox(
                   width: deviceWidth*0.8,
                   child: getCommonTextFormField(
                     context: context,
                     controller: _email,
                     hintText: Email,
                   ),
                 ),

                 const SizedBox(height: 15,),
                 SizedBox(
                   width: deviceWidth*0.8,
                   child: getCommonTextFormField(
                     context: context,
                     controller: _password,
                     hintText: Password,
                   ),
                 ),
                 const SizedBox(height: 15,),
                 SizedBox(
                   width: deviceWidth*0.8,
                   child: getCommonTextFormField(
                     context: context,
                     controller: _confirmpassword,
                     hintText: Confirmpassword,
                   ),
                 ),

                 const SizedBox(height: 15,),
                 SizedBox(
                   width: deviceWidth*0.8,
                   child: getCommonTextFormField(
                     context: context,
                     controller: _selectcountry,
                     hintText: Selectcountry,
                     suffixIcon: InkWell(
                         onTap: () {
                           //_toggle();
                         },
                         child: Icon(Icons.keyboard_arrow_down)),
                   ),
                 ),

                 const SizedBox(height: 15,),
                 SizedBox(
                   width: deviceWidth*0.8,
                   child: getCommonTextFormField(
                     context: context,
                     controller: _mobilenumber,
                     hintText: Mobilenumber,
                     prefixIcon: InkWell(
                         onTap: () {
                           //_toggle();
                         },
                         child:  Image.asset(IC_INDIAN_FLAG)),
                   ),
                 ),
                 const SizedBox(height: 20,),

                 SizedBox(
                   width: deviceWidth*0.8,
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.start,
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: [
                       const SizedBox(
                         width: 1,
                       ),
                       Center(
                           child: InkWell(
                             onTap: () {
                               setState(() {
                                 _value = !_value;
                               });
                             },
                             child: Container(
                               height: 22,
                               width: 22,
                               decoration: const BoxDecoration(
                                   shape: BoxShape.circle,
                                   color: colortheme),
                               child: Padding(
                                   padding: const EdgeInsets.all(0.0),
                                   child: _value
                                       ? const Icon(
                                     Icons.check,
                                     size: 16.0,
                                     color: Colors.white,
                                   )
                                       : Container(
                                     height: 22,
                                     width: 22,
                                     decoration: const BoxDecoration(
                                         shape: BoxShape.circle,
                                         color: colorBackgroundInput),
                                   )),
                             ),
                           )),
                       SizedBox(
                         width: 12,
                       ),

                           getSmallText(AgreeTothe,fontSize: SUBTITLE_FONT_SIZE,color: colorAccentLight),
                           getTitle(termsandcondition,bold: true,fontSize: SUBTITLE_FONT_SIZE,color:colorAccentLight ),

                     ],
                   ),
                 ),
                 const SizedBox(height: 20,),

                 getButton(Signup, (){},width:deviceWidth*0.8, fontsize:BUTTON_FONT_SIZE ),

               ],
             ),
           ),
         ),
       ),
     ),
   );
  }

}