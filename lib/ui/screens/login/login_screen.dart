import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';

class LoginScreen extends BaseStatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseState<LoginScreen> with BasicScreen {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width * 0.9;
    final bloc = context.read<MainBloc>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: HORIZONTAL_PADDING, vertical: VERTICAL_PADDING),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                IC_GREENTILL_IMAGE,
                height: size.height * 0.15,
                width: size.width * 0.35,
              ),
              const SizedBox(height: 15),
              getTitle(WelcomeLogin,
                  bold: true, fontSize: TITLE_TEXT_FONT_SIZE),
              const SizedBox(height: 20),
              getSmallText(
                LoginContent,
                weight: FontWeight.w400,
                align: TextAlign.center,
                fontSize: SUBTITLE_FONT_SIZE,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: width,
                child: getCommonTextFormField(
                  context: context,
                  controller: _email,
                  hintText: Email,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: width,
                child: getCommonTextFormField(
                  context: context,
                  controller: _password,
                  hintText: Password,
                  obscureText: _obscureText,
                  suffixIcon: IconButton(
                    icon: Image.asset(
                        _obscureText ? IC_PASSWORD_HIDE : IC_PASSWORD_SHOW),
                    onPressed: _toggle,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: width,
                child: getSmallText(
                  ForgetPassword,
                  weight: FontWeight.w400,
                  fontSize: SUBTITLE_FONT_SIZE,
                  align: TextAlign.end,
                ),
              ),
              const SizedBox(height: 20),
              getButton(
                Signin,
                () => bloc.add(const CompleteAuthentication()),
                width: width,
                fontsize: BUTTON_FONT_SIZE,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: width,
                child: getSmallText(
                  orloginwith,
                  weight: FontWeight.w400,
                  fontSize: SUBTITLE_FONT_SIZE,
                  align: TextAlign.center,
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    socialLoginButton(context, IC_FACEBOOK),
                    const SizedBox(width: 15),
                    socialLoginButton(context, IC_GOOGLE),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              Row(
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
                  TextButton(
                    onPressed: () => bloc.add(const NavigateToSignUp()),
                    child: const Text(
                      Signup,
                      style: TextStyle(
                          color: colorBlack,
                          fontSize: SUBTITLE_FONT_SIZE,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'AvenirBold'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
