import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';
import 'package:greentill/utils/validations.dart';

class ForgotPasswordScreen extends BaseStatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends BaseState<ForgotPasswordScreen>
    with BasicScreen, InputValidationMixin {
  final TextEditingController _email = TextEditingController();
  final formGlobalKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _email.dispose();
  }
  @override
  Widget buildBody(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorWhite,
      appBar: AppBar(
        backgroundColor: colorWhite,
        elevation: 0,
        title: appBarHeader(forgotPassword,bold: true,weight: FontWeight.w800),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_outlined, color: Colors.black),
          onPressed: () => bloc.add(Login()),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: formGlobalKey,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: HORIZONTAL_PADDING, vertical: 0),
              child: Column(
                children: [
                  getSmallText(forgotPasswordcontent,
                      weight: FontWeight.w400,
                      align: TextAlign.center,
                      fontSize: SUBTITLE_FONT_SIZE),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: deviceWidth * 0.8,
                    child: getCommonTextFormField(
                      context: context,
                      controller: _email,
                      hintText: Email,
                      validator: (email) {
                        if (isEmailValid(email?.trim() ?? ""))
                          return null;
                        else
                          return 'Please Enter a valid email address';
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  getButton(sendInstruction, () {
                    if (formGlobalKey.currentState?.validate() ?? false) {
                      changeLoadStatus();
                      bloc.userRepository.forgotpassword(_email.text.trim()).then((value) {
                        changeLoadStatus();
                        if (value.status == 1) {
                          print("mail has been sent");
                          showMessage(value.message ?? "", () {
                            setState(() {
                              isShowMessage = false;
                              bloc.add(PasswordRecover());
                            });
                          });
                        } else {
                          print(value.message);
                          showMessage(value.message ?? "", () {
                            setState(() {
                              isShowMessage = false;
                              isLoading = false;
                            });
                          });
                        }
                      });
                      //return bloc.add(PasswordRecover());
                    }

                  }, width: deviceWidth * 0.8, fontsize: BUTTON_FONT_SIZE),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
