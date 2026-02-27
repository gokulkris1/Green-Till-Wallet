import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';

class SignUpScreen extends BaseStatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends BaseState<SignUpScreen> with BasicScreen {
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _selectCountry = TextEditingController();
  final TextEditingController _mobileNumber = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _selectCountry.dispose();
    _mobileNumber.dispose();
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
            horizontal: HORIZONTAL_PADDING,
            vertical: VERTICAL_PADDING,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                IC_GREENTILL_IMAGE,
                height: size.height * 0.15,
                width: size.width * 0.35,
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getSmallText(
                      SignupHeading,
                      bold: true,
                      fontSize: TITLE_TEXT_FONT_SIZE,
                      color: colorBlack,
                    ),
                    getTitle(Signup,
                        bold: true, fontSize: TITLE_TEXT_FONT_SIZE),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              getSmallText(
                Signupcontent,
                weight: FontWeight.w400,
                align: TextAlign.center,
                fontSize: SUBTITLE_FONT_SIZE,
              ),
              const SizedBox(height: 30),
              _buildTextField(context, _firstName, Firstname, width),
              const SizedBox(height: 15),
              _buildTextField(context, _lastName, Lastname, width),
              const SizedBox(height: 15),
              _buildTextField(context, _email, Email, width,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 15),
              _buildTextField(context, _password, Password, width,
                  obscureText: true),
              const SizedBox(height: 15),
              _buildTextField(context, _confirmPassword, Confirmpassword, width,
                  obscureText: true),
              const SizedBox(height: 15),
              _buildTextField(
                context,
                _selectCountry,
                Selectcountry,
                width,
                suffixIcon: const Icon(Icons.keyboard_arrow_down),
              ),
              const SizedBox(height: 15),
              _buildTextField(
                context,
                _mobileNumber,
                Mobilenumber,
                width,
                keyboardType: TextInputType.phone,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(IC_INDIAN_FLAG),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _acceptedTerms = !_acceptedTerms;
                        });
                      },
                      child: Container(
                        height: 22,
                        width: 22,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: colortheme,
                        ),
                        child: _acceptedTerms
                            ? const Icon(Icons.check,
                                size: 16.0, color: Colors.white)
                            : Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorBackgroundInput,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          getSmallText(
                            AgreeTothe,
                            fontSize: SUBTITLE_FONT_SIZE,
                            color: colorAccentLight,
                          ),
                          getTitle(
                            termsandcondition,
                            bold: true,
                            fontSize: SUBTITLE_FONT_SIZE,
                            color: colorAccentLight,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              getButton(
                Signup,
                () {
                  if (!_acceptedTerms) {
                    showMessage(
                      "Please agree to the terms to continue.",
                      hideMessage,
                      true,
                    );
                    return;
                  }
                  bloc.add(const CompleteAuthentication());
                },
                width: width,
                fontsize: BUTTON_FONT_SIZE,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => bloc.add(const NavigateToLogin()),
                child: const Text("Already have an account? Sign in"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String hint,
    double width, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      width: width,
      child: getCommonTextFormField(
        context: context,
        controller: controller,
        hintText: hint,
        obscureText: obscureText,
        keyboardType: keyboardType,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
