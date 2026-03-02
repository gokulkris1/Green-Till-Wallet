import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';
import 'package:greentill/utils/validations.dart';

class ChangePasswordScreen extends BaseStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends BaseState<ChangePasswordScreen> with BasicScreen,InputValidationMixin{
  final formGlobalKey = GlobalKey<FormState>();
  final TextEditingController _currentpassword = TextEditingController();
  final TextEditingController _newpassword = TextEditingController();
  final TextEditingController _confirmnewpassword = TextEditingController();
  bool _obscureTextold = true;
  bool _obscureTextnew = true;
  bool _obscureTextconfirm = true;
  bool isLoadingLocal = false;

  @override
  void dispose() {
    _currentpassword.dispose();
    _newpassword.dispose();
    _confirmnewpassword.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
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
                   return bloc.add(SideMenu());
                 },
               ),
               SizedBox(width: deviceWidth*0.025,),

               Expanded(
                 child: appBarHeader(
                   changePasswordcontent,
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
       child: Form(
         key: formGlobalKey,
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
                   const SizedBox(
                     height: 30,
                   ),
                   SizedBox(
                     width: deviceWidth * 0.8,
                     child: getCommonTextFormField(
                         context: context,
                         controller: _currentpassword,
                         obscureText: _obscureTextold,
                         hintText: currentPassword,
                       validator: (password) {
                         if (isPasswordValid(password?.trim() ?? ""))
                           return null;
                         else
                           return 'Please enter a valid password';
                       },
                       suffixIcon: InkWell(
                           onTap: () {
                             setState(() {
                               _obscureTextold = !_obscureTextold;
                             });
                           },
                           child: _obscureTextold == true
                               ? Image.asset(IC_PASSWORD_HIDE)
                               : Image.asset(IC_PASSWORD_SHOW)),
                     ),
                   ),

                   const SizedBox(
                     height: 15,
                   ),
                   SizedBox(
                     width: deviceWidth * 0.8,
                     child: getCommonTextFormField(
                         context: context,
                         controller: _newpassword,
                         obscureText: _obscureTextnew,
                         hintText: newPassword,
                       validator: (password) {
                         if (isPasswordValid(password?.trim() ?? ""))
                           return null;
                         else
                           return 'Please enter a valid password';
                       },
                       suffixIcon: InkWell(
                           onTap: () {
                             setState(() {
                               _obscureTextnew = !_obscureTextnew;
                             });
                           },
                           child: _obscureTextnew == true
                               ? Image.asset(IC_PASSWORD_HIDE)
                               : Image.asset(IC_PASSWORD_SHOW)),
                         ),
                   ),

                   const SizedBox(
                     height: 15,
                   ),

                   SizedBox(
                     width: deviceWidth * 0.8,
                     child: getCommonTextFormField(
                         context: context,
                         controller: _confirmnewpassword,
                         obscureText: _obscureTextconfirm,
                         hintText: Confirmpassword,
                       validator: (password) {
                         if ((password?.trim() ?? "") ==
                             _newpassword.text.trim().toString()) {
                           return null;
                         } else {
                           return 'Password does not match';
                         }
                       },
                       suffixIcon: InkWell(
                           onTap: () {
                             setState(() {
                               _obscureTextconfirm = !_obscureTextconfirm;
                             });
                           },
                           child: _obscureTextconfirm == true
                               ? Image.asset(IC_PASSWORD_HIDE)
                               : Image.asset(IC_PASSWORD_SHOW)),
                     ),
                   ),
                   const SizedBox(
                     height: 20,
                   ),
                   getButton(Save, () async {
                     print("_current" + _currentpassword.text.trim().toString());
                     print("_new" + _newpassword.text.trim().toString());
                     if (formGlobalKey.currentState?.validate() ?? false) {
                       setState(() {
                         isLoadingLocal = true;
                       });
                       bloc.userRepository.changepassword(_currentpassword.text.trim(), _newpassword.text.trim()).then((value) {
                         if(value.status == 1){
                           showMessage(value.message ?? "", () {
                             if(mounted)
                               setState(() {
                                 // Navigator.pop(context);
                                 // Navigator.pop(context);
                                 Navigator.of(context)
                                     .popUntil(ModalRoute.withName("/"));
                                 bloc.add(HomeScreenEvent());
                                 isShowMessage = false;
                               });
                           });
                         }else if (value.apiStatusCode == 401) {
                           showMessage(value.message ?? "", () {
                             setState(() {
                               isShowMessage = false;
                               isLoadingLocal = false;
                               logoutaccount();
                               return bloc.add(Login());
                             });
                           });
                         }else {
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
                   }, width: deviceWidth * 0.8, fontsize: BUTTON_FONT_SIZE),
                 ],
               ),
             ),
           ),
         ),
       ),
     ),
   );
  }


}
