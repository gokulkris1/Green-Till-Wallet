import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/screens/receipt/feedback_receipt_screen.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/shared_pref_helper.dart';

class QRLoadedReceipt extends BaseStatefulWidget {
  const QRLoadedReceipt({super.key, this.url});

  final String? url;

  @override
  _QRLoadedReceiptState createState() => _QRLoadedReceiptState();
}

class _QRLoadedReceiptState extends BaseState<QRLoadedReceipt>
    with BasicScreen {
  bool loaded = false;
  String userid = prefs.getString(SharedPrefHelper.USER_ID) ?? "0";
  bool isFirst = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget buildBody(BuildContext context) {
    if (isFirst) {
      isFirst = false;
    }
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
                    Navigator.pop(context);
                    // return bloc.add(SideMenu());
                  },
                ),
                SizedBox(
                  width: deviceWidth * 0.025,
                ),
                Spacer(),
                IconButton(
                  onPressed: () async {
                    print("userid=" + userid.toString());
                    changeLoadStatus();
                    bloc.userRepository
                        .uploadreceipt(widget.url ?? "", int.parse(userid))
                        .then((value) {
                      changeLoadStatus();
                      if (value.status == 1) {
                        print("upload receipt successful");
                        // Some issue with even data passing
                        // if(int.parse(userid) != null && value.data != null)
                        //   bloc.add(SendFeedbackDataEvent(userid: int.parse(userid),receiptid: value?.data ?? 0,message: value?.message ?? "",imagefrom: "QRSCAN", ));

                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return FeedbackReceiptScreen(userid: int.parse(userid),receiptid: value.data ?? 0,message: value.message ?? "",imagefrom: "QRSCAN");
                        }));
                          // Navigator.push(context, MaterialPageRoute(builder: (context){
                          //   return FeedbackReceiptScreen(userid: int.parse(userid),receiptid: value?.data ?? 0,message: value?.message ?? "",imagefrom: "QRSCAN",);
                          // }));
                        // bloc.add(FeedbackEvent());
                        // showMessage(value.message, () {
                        //   setState(() {
                        //     Navigator.pop(context);
                        //     isShowMessage = false;
                        //     bloc.add(HomeScreenEvent());
                        //   });
                        // });
                      }else if(value.apiStatusCode == 401){
                        showMessage(value.message ?? "", () {
                          setState(() {
                            Navigator.pop(context);
                            isShowMessage = false;
                            logoutaccount();
                            return bloc.add(Login());
                          });
                        });
                      }
                      else {
                        print("upload receipt failed ");
                        print(value.message);
                        showMessage(value.message ?? "", () {
                          setState(() {
                            // bloc.add(WelcomeIn());
                            Navigator.pop(context);
                            isShowMessage = false;
                            bloc.add(HomeScreenEvent());
                          });
                        });
                      }
                    });
                                    },
                  icon:  Icon(
                    Icons.task_alt,
                    color: Colors.green,
                    size: 24,
                  ),
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.url ?? "",
                    imageBuilder: (context, imageProvider) => InteractiveViewer(
                      child: SingleChildScrollView(
                        child: Container(
                          height: deviceHeight,
                          width: deviceWidth,
                          margin: EdgeInsets.only(bottom: deviceHeight * 0.10),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.contain,
                              // colorFilter:
                              //     ColorFilter.mode(Colors.red, BlendMode.colorBurn),
                            ),
                          ),
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Center(child: CircularProgressIndicator(backgroundColor: Colors.black26,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colortheme, //<-- SEE HERE
                      ),)),
                    errorWidget: (context, url, error) => Center(child: Icon(Icons.error,color: colortheme,)),
                  ),
                ],
              ),
            ),
          ),

      ),
    );
  }

}
