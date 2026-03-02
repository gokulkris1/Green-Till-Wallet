import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';


class ResetPasswordScreen extends BaseStatefulWidget{
  @override
  _ResetPasswordScreenState  createState() => _ResetPasswordScreenState();

}

class _ResetPasswordScreenState extends BaseState<ResetPasswordScreen> with BasicScreen{
  final TextEditingController _password= TextEditingController();
  final TextEditingController _confirmpassword= TextEditingController();
  bool _passwordValue = false;
  bool _confirmPasswordValue = false;
  String countryValue = "";
  String stateValue = "";
  String cityValue = "";
  String address = "";
  @override
  Widget buildBody(BuildContext context) {
   return Scaffold(
     resizeToAvoidBottomInset: false,
     backgroundColor: colorWhite,
     appBar: AppBar(
       backgroundColor: colorWhite,
       elevation: 0,
       title: appBarHeader(resendPassword,bold: true,weight: FontWeight.w800),
       centerTitle: false,
       leading: IconButton(
         icon: const Icon(Icons.arrow_back_outlined, color: Colors.black),
         onPressed: () => Navigator.pop(context),
       ),
     ),
     body: SafeArea(
       child: Container(
         height: MediaQuery.of(context).size.height,
         width: MediaQuery.of(context).size.width,
         child: Padding(
           padding:  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING,vertical: 0),
           child: Column(
             children: [
               getSmallText(resendPasswordcontent,weight: FontWeight.w400,align: TextAlign.center,fontSize: SUBTITLE_FONT_SIZE),
               const SizedBox(height: 30,),
               SizedBox(
                 width: deviceWidth*0.8,
                 child: getCommonTextFormField(
                   context: context,
                   controller: _password,
                   hintText: Password,
                   suffixIcon: InkWell(
                       onTap: () {
                         setState(() {
                           _passwordValue = !_passwordValue;
                         });
                       },
                       child:  _passwordValue == true ?Image.asset(IC_PASSWORD_HIDE):Image.asset(IC_PASSWORD_SHOW)),
                 ),
               ),
               const SizedBox(height: 20,),
               SizedBox(
                 width: deviceWidth*0.8,
                 child: getCommonTextFormField(
                   context: context,
                   controller: _confirmpassword,
                   hintText: Confirmpassword,
                   suffixIcon: InkWell(
                       onTap: () {
                         setState(() {
                           _confirmPasswordValue = !_confirmPasswordValue;
                         });
                       },
                       child:  _confirmPasswordValue == true ?Image.asset(IC_PASSWORD_HIDE):Image.asset(IC_PASSWORD_SHOW)),
                 ),
               ),
               const SizedBox(height: 20,),

               getButton(resendPassword, (){},width:deviceWidth*0.8, fontsize:BUTTON_FONT_SIZE ),

             ],
           ),
         ),
       ),
     ),
   );
  }
}
