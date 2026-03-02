import 'dart:io';

import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/shared_pref_helper.dart';

class UploadCameraCaptureImage extends BaseStatefulWidget{
  UploadCameraCaptureImage({this.imageFile});

  final File imageFile;

  @override
  _UploadCameraCaptureImageState createState() => _UploadCameraCaptureImageState();
}

class _UploadCameraCaptureImageState extends BaseState<UploadCameraCaptureImage> with BasicScreen{
  bool loaded = false;
  String userid = prefs.getString(SharedPrefHelper.USER_ID);

  @override
  void initState() {
    super.initState();
  }

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
                    print("backbutton");
                    bloc.add(QrCodeEvent());
                    // return bloc.add(SideMenu());
                  },
                ),
                SizedBox(
                  width: deviceWidth * 0.025,
                ),
                Spacer(),
                IconButton(
                  // onPressed: () async {
                  //   print("userid=" + userid.toString());
                  //   if (widget.url != null && userid != null) {
                  //     changeLoadStatus();
                  //     bloc.userRepository
                  //         .uploadreceipt(widget.url, int.parse(userid))
                  //         .then((value) {
                  //       changeLoadStatus();
                  //       if (value.status == 1) {
                  //         print("upload receipt successful");
                  //         showMessage(value.message, () {
                  //           setState(() {
                  //             bloc.add(HomeScreenEvent());
                  //             isShowMessage = false;
                  //           });
                  //         });
                  //       }else if(value.apiStatusCode == 401){
                  //         showMessage(value.message, () {
                  //           setState(() {
                  //             isShowMessage = false;
                  //             logoutaccount();
                  //             return bloc.add(Login());
                  //           });
                  //         });
                  //       }
                  //       else {
                  //         print("upload receipt failed ");
                  //         print(value.message);
                  //         showMessage(value.message, () {
                  //           setState(() {
                  //             // bloc.add(WelcomeIn());
                  //             isShowMessage = false;
                  //           });
                  //         });
                  //       }
                  //     });
                  //   }
                  // },
                  icon: Icon(Icons.download),
                )
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15),
          height: deviceHeight,
          width: deviceWidth,
          color: colorWhite,
          child: Container(
            width: deviceWidth,
            height: deviceHeight,
            child:Image.file(
              widget.imageFile,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}