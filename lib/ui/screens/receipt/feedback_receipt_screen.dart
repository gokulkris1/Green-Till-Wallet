import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/ui/screens/receipt/edit_receipt_screen.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';

class FeedbackReceiptScreen extends BaseStatefulWidget {
  final int receiptid;
  final int userid;
  final String message;
  final String imagefrom;
  final String initialTagType;
  const FeedbackReceiptScreen(
      {this.receiptid = 0,
      this.userid = 0,
      this.message = "",
      this.imagefrom = "",
      this.initialTagType = "BUSINESS"});

  @override
  _FeedbackReceiptScreenState createState() => _FeedbackReceiptScreenState();
}

class _FeedbackReceiptScreenState extends BaseState<FeedbackReceiptScreen>
    with BasicScreen {
  final formGlobalKey = GlobalKey<FormState>();
  final TextEditingController _feedbackcontroller = TextEditingController();
  bool _isSubmittingFeedback = false;
  int _isMoodSelected = 2;
  List<Map<String, String>> feedbackMoods = [
    {"icon": IC_WORST_GREY, "title": "Worst", "selectedvalue": "1"},
    {"icon": IC_POOR_GREY, "title": "Poor", "selectedvalue": "2"},
    {"icon": IC_NICE_GREY, "title": "Nice", "selectedvalue": "3"},
    {"icon": IC_GOOD_GREY, "title": "Good", "selectedvalue": "4"},
    {"icon": IC_BEST_GREY, "title": "Best", "selectedvalue": "5"},
  ];
  String _rating = "3";

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _feedbackcontroller.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    print("receiptid");
    print(widget.receiptid);
    print(widget.userid);
    print(widget.message);
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popUntil(ModalRoute.withName("/"));
        bloc.add(HomeScreenEvent());
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: colorstorecardbackground,
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
                      Navigator.of(context).popUntil(ModalRoute.withName("/"));
                      bloc.add(HomeScreenEvent());
                      // return bloc.add(SideMenu());
                    },
                  ),
                  SizedBox(
                    width: deviceWidth * 0.025,
                  ),
                  appBarHeader(
                    receipt,
                    fontSize: BUTTON_FONT_SIZE,
                    bold: false,
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
                padding: EdgeInsets.symmetric(
                  horizontal: HORIZONTAL_PADDING,
                  vertical: VERTICAL_PADDING,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        IC_UPLOAD_ICON,
                        height: deviceHeight * 0.15,
                        width: deviceWidth * 0.2,
                      ),
                      // getSmallText(congratulations,
                      //     weight: FontWeight.w500,
                      //     bold: false,
                      //     fontSize: BUTTON_FONT_SIZE,
                      //     color: colortheme),
                      SizedBox(
                        height: deviceHeight * 0.005,
                      ),
                      getTitle(widget.message ?? "",
                          weight: FontWeight.w600,
                          bold: true,
                          fontSize: BUTTON_FONT_SIZE,
                          lines: 1,
                          isCenter: true,
                          color: colorBlack),
                      SizedBox(
                        height: deviceHeight * 0.02,
                      ),

                      Divider(
                        thickness: 1.0,
                        color: colorseprator,
                      ),
                      SizedBox(
                        height: deviceHeight * 0.02,
                      ),
                      // SizedBox(
                      //   height: deviceHeight * 0.03,
                      // ),
                      // getButton(
                      //   "Okay",
                      //       () {
                      //         bloc.add(HomeScreenEvent());
                      //         Navigator.of(context)
                      //             .popUntil(ModalRoute.withName("/"));
                      //         // }));
                      //   },
                      //     width: deviceWidth*0.8
                      // ),
                      // Spacer(),
                      // SizedBox(height: deviceHeight*0.04,),
                      // Align(
                      //   alignment: Alignment.topCenter,
                      //   child: getTitle(
                      //     feedback,
                      //     weight: FontWeight.w500,
                      //     color: colorBlack,
                      //     fontSize: BODY1_TEXT_FONT_SIZE,
                      //   ),
                      // ),
                      // SizedBox(height: deviceHeight*0.02,),

                      getTitle(
                        receiptFeedback,
                        weight: FontWeight.w600,
                        color: colorBlack,
                        fontSize: SUBTITLE_FONT_SIZE,
                      ),
                      SizedBox(
                        height: deviceHeight * 0.01,
                      ),

                      Container(
                        height: deviceHeight * 0.11,
                        width: deviceWidth,
                        child: Center(
                          child: ListView.builder(
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              primary: false,
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isMoodSelected = index;
                                      _rating = feedbackMoods[index]
                                              ['selectedvalue'] ??
                                          "";
                                    });
                                    print("rating");
                                    print(_rating);
                                  },
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                        right: 14.0,
                                      ),
                                      child: FeedbackWidget(
                                          feedbackMoods[index]['icon'] ?? "",
                                          feedbackMoods[index]['title'] ?? "",
                                          _isMoodSelected == index
                                              ? true
                                              : false)),
                                );
                              }),
                        ),
                      ),
                      // SizedBox(
                      //   height: deviceHeight * 0.01,
                      // ),

                      Divider(
                        thickness: 1.0,
                        color: colorseprator,
                      ),
                      SizedBox(
                        height: deviceHeight * 0.02,
                      ),

                      getTitle(
                        feedbackcontent,
                        weight: FontWeight.w600,
                        color: colorBlack,
                        fontSize: SUBTITLE_FONT_SIZE,
                      ),
                      SizedBox(
                        height: deviceHeight * 0.03,
                      ),

                      SizedBox(
                        width: deviceWidth * 0.8,
                        child: getCommonTextFormField(
                          context: context,
                          controller: _feedbackcontroller,
                          hintText: yourFeedback,
                          maxLines: 2,
                          // validator: (feedback) {
                          //   if (feedback.isEmpty || feedback == null){
                          //     return "Please write feedback";
                          //   } else {
                          //     return null;
                          //   }
                          // },
                        ),
                      ),
                      SizedBox(
                        height: deviceHeight * 0.03,
                      ),

                      getButton(
                          _isSubmittingFeedback ? "Submitting..." : "Submit",
                          () async {
                        if (_isSubmittingFeedback) {
                          return;
                        }
                        if (_rating.isNotEmpty
                            // && formGlobalKey.currentState.validate()
                            ) {
                          if (mounted) {
                            setState(() {
                              _isSubmittingFeedback = true;
                            });
                          }
                          changeLoadStatus();
                          debugPrint("ratingint" + _rating);
                          try {
                            final value = await bloc.userRepository
                                .sendfeedback(
                                    userid: widget.userid,
                                    feedback: _feedbackcontroller.text.trim(),
                                    rating: _rating,
                                    receiptid: widget.receiptid);
                            print("sendfeedback");
                            print(value);

                            if (value.status == 1) {
                              print("sendfeedback =");
                              print(value);
                              print("sendfeedback successful");
                              showMessage(value.message ?? "", () {
                                if (mounted) {
                                  setState(() {
                                    // bloc.add(WelcomeIn());
                                    isShowMessage = false;
                                    Navigator.of(context)
                                        .popUntil(ModalRoute.withName("/"));
                                    bloc.add(HomeScreenEvent());
                                  });
                                }
                              });
                            } else if (value.apiStatusCode == 401) {
                              showMessage(value.message ?? "", () {
                                if (mounted) {
                                  setState(() {
                                    isShowMessage = false;
                                    logoutaccount();
                                    return bloc.add(Login());
                                  });
                                }
                              });
                            } else {
                              print("sendfeedback failed ");
                              print(value.message);
                              showMessage(value.message ?? "", () {
                                if (mounted) {
                                  setState(() {
                                    // bloc.add(WelcomeIn());
                                    isShowMessage = false;
                                    Navigator.of(context)
                                        .popUntil(ModalRoute.withName("/"));
                                    bloc.add(HomeScreenEvent());
                                  });
                                }
                              });
                            }
                          } finally {
                            changeLoadStatus();
                            if (mounted) {
                              setState(() {
                                _isSubmittingFeedback = false;
                              });
                            }
                          }
                        }
                      }, width: deviceWidth * 0.8),
                      SizedBox(
                        height: deviceHeight * 0.02,
                      ),
                      getButton(
                        "Review Receipt Details",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditReceiptScreen(
                                receiptid: widget.receiptid,
                                receiptFromType: widget.imagefrom,
                                tagType: widget.initialTagType,
                              ),
                            ),
                          );
                        },
                        width: deviceWidth * 0.8,
                        color: gpLight,
                        textColor: gpGreen,
                      ),
                      SizedBox(
                        height: deviceHeight * 0.08,
                      ),

                      GestureDetector(
                        onTap: () {
                          if (mounted)
                            setState(() {
                              Navigator.of(context)
                                  .popUntil(ModalRoute.withName("/"));
                              bloc.add(HomeScreenEvent());
                            });
                        },
                        child: getTitle("Skip Feedback",
                            color: colortheme,
                            weight: FontWeight.w800,
                            lines: 1,
                            fontSize: BUTTON_FONT_SIZE),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
