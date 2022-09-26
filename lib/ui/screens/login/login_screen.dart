import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';


class LoginScreen extends BaseStatefulWidget{
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseState<LoginScreen> with BasicScreen{
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscureText = true;
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  @override
  Widget buildBody(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding:  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING,vertical: VERTICAL_PADDING),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          child: Image.asset(IC_GREENTILL_IMAGE, height:deviceHeight*0.15,width: deviceWidth*0.35,)),
                      const SizedBox(height: 15,),
                      getTitle(WelcomeLogin,bold: true,fontSize: TITLE_TEXT_FONT_SIZE),
                      const SizedBox(height: 20,),
                      getSmallText(LoginContent,weight: FontWeight.w400,align: TextAlign.center,fontSize: SUBTITLE_FONT_SIZE),
                      const SizedBox(height: 30,),

                      SizedBox(
                        width: deviceWidth*0.8,
                        child: getCommonTextFormField(
                          context: context,
                          controller: _email,
                          hintText: Email,
                        ),
                      ),

                      const SizedBox(height: 20,),
                      SizedBox(
                        width: deviceWidth*0.8,
                        child: getCommonTextFormField(
                          context: context,
                          controller: _password,
                          suffixIcon: InkWell(
                              onTap: () {
                                _toggle();
                              },
                              child:  _obscureText == true ?Image.asset(IC_PASSWORD_HIDE):Image.asset(IC_PASSWORD_SHOW)),

                          hintText: Password,
                        ),
                      ),
                      const SizedBox(height: 20,),
                      SizedBox(
                          width: deviceWidth*0.8,
                          child: getSmallText(ForgetPassword,weight: FontWeight.w400,fontSize: SUBTITLE_FONT_SIZE,align: TextAlign.end)),
                      const SizedBox(height: 20,),

                      getButton(Signin, (){},width:deviceWidth*0.8, fontsize:BUTTON_FONT_SIZE ),
                      const SizedBox(height: 25,),
                      SizedBox(
                          width: deviceWidth*0.8,
                          child: getSmallText(orloginwith,weight: FontWeight.w400,fontSize: SUBTITLE_FONT_SIZE,align: TextAlign.center)),
                      const SizedBox(height: 25,),

                      SizedBox(
                        width: deviceWidth*0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialLoginButton(IC_FACEBOOK),
                            const SizedBox(width: 15,),
                            SocialLoginButton(IC_GOOGLE)
                          ],
                        ),
                      ),




                    ],
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 35),
                    child: SizedBox(
                      width: deviceWidth*0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            Didnothaveaccount,
                            style: TextStyle(
                                color: colorAccentLight,
                                fontSize: FORGET_PASSWORD_TEXT_FONT_SIZE,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'AvenirBook'),
                          ),
                          GestureDetector(
                              onTap: () {
                                //return bloc.add(SignUp());
                              },
                              child: const Text(
                                Signup,
                                style: TextStyle(
                                    color: colorBlack,
                                    fontSize: SUBTITLE_FONT_SIZE,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'AvenirBold'),
                              )),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
