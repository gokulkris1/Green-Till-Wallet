import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/models/responses/getnotificationlist_response.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class NotificationScreen extends BaseStatefulWidget{
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends BaseState<NotificationScreen> with BasicScreen{
  List<NotificationList> notificationlist = [];
  bool isLoadingLocal = true;
  bool isFirst = true;
  bool _isInAsyncCall = false;

  @override
  Widget buildBody(BuildContext context) {

    if (isFirst) {
      isFirst = false;
      getNotificationListing();
    }
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
                horizontal: HORIZONTAL_PADDING,
                vertical: VERTICAL_PADDING),
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
                    bloc.add(HomeScreenEvent());
                  },
                ),
                SizedBox(
                  width: deviceWidth * 0.025,
                ),
                Expanded(
                  child: appBarHeader(
                    "Notifications",
                    fontSize: BUTTON_FONT_SIZE,
                    bold: false,
                  ),
                ),
                notificationlist.length <= 0 ||
                    notificationlist.isEmpty ?SizedBox():TextButton(
                  onPressed: (){
                    print("clear all notifications");
                    setState(() {
                      _isInAsyncCall = true;

                    });
                    deleteallnotifications();
                  },
                  child: getTitle("Clear all",fontSize: SUBTITLE_FONT_SIZE,
                    color: colortheme,
                    bold: true,),
                )
              ],
            ),
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isInAsyncCall,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: colorstorecardbackground,
                  child:
                  notificationlist.length <= 0 ||
                      notificationlist.isEmpty
                      ? Center(
                    child: getSmallText(
                        "No Notifications available!",
                        bold: true,
                        isCenter: true,
                        fontSize: BUTTON_FONT_SIZE,
                        color: colorBlack,
                        weight: FontWeight.w500),
                  )
                      :
                  ListView.builder(
                      padding: EdgeInsets.only(
                          bottom: deviceHeight * 0.12),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      clipBehavior: Clip.none,
                      primary: false,
                      itemCount: notificationlist.length,
                      itemBuilder: (context,index){
                        String notifyTime = convertToAgo(DateTime.parse('${notificationlist[index].createdAt}Z'));
                        // print("notifytime");
                        // print(notifyTime);
                        return Slidable(
                          startActionPane:  ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                // An action can be bigger than the others.
                                flex: 2,
                                onPressed: (f){
                                  debugPrint("d");
                                  setState(() {
                                    _isInAsyncCall = true;

                                  });
                                  return singlenotificationdelete(
                                      notificationlist[index].sentNotificationId ??
                                          0);
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),



                          child: Padding(
                            padding: const EdgeInsets
                                .symmetric(
                              horizontal:
                              HORIZONTAL_PADDING,
                            ),
                            child: GestureDetector(
                                onTap: (){
                                  // return Navigator.push(context, MaterialPageRoute(builder: (context){
                                  //   return SurveyScreenWebview(link: surveylist[index]['surveyLink'],);
                                  // }));
                                },
                                child: NotificationListWidget(notificationlist[index].image ?? "",title: notificationlist[index].title ?? "",
                                    description: notificationlist[index].description ?? "",
                                  isstorelogoavailable:(notificationlist[index]
                                      .image ?? "")
                                      .isEmpty
                                      ? false
                                      : true,
                                time: notifyTime ?? ""),
                          )),
                        );

                      }),

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget NotificationListWidget(String logo,{bool isstorelogoavailable = false, required String title, required String description, required String time}){
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        // height: deviceHeight * 0.09,
        width: deviceWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                // height: deviceHeight * 0.09,
                padding: EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10.0,
                          offset: Offset(0.0, 0.05))
                    ],
                    color: colorWhite,
                    border: Border.all(color: colorgreyborder),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: deviceWidth * 0.02,
                    ),
                    Container(
                      height: deviceHeight * 0.07,
                      width: deviceWidth * 0.10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colorbordercoupons),
                        color: colorWhite,
                        // image: widget.isCoupons
                        //     ? DecorationImage(image: AssetImage(widget.logo))
                        //     : null
                      ),
                      child:
                      isstorelogoavailable
                          ? Center(
                            child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CachedNetworkImage(
                            imageUrl: logo ?? "",
                            errorWidget: (context, url, error) =>
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    //borderRadius:
                                    //BorderRadius.circular(18),
                                    color: colorWhite,
                                    image: DecorationImage(
                                        image: AssetImage(
                                            IC_SURVEY),
                                        fit: BoxFit.scaleDown),
                                  ),
                                  child: Center(
                                      child: getSmallText(
                                          getInitials(title),
                                          weight: FontWeight.w500,
                                          align: TextAlign.center,
                                          color: colorBlack,
                                          fontSize: BODY1_TEXT_FONT_SIZE)),
                                ),
                            progressIndicatorBuilder: (context, url,
                                downloadProgress) =>
                                Center(
                                    child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child:
                                        CircularProgressIndicator(
                                            value: downloadProgress
                                                .progress))),
                            // placeholder: (context, url) => Container(
                            //   decoration: BoxDecoration(
                            //     color: colorBackgroundButton,
                            //     borderRadius: BorderRadius.circular(18),
                            //     image: DecorationImage(
                            //         image: AssetImage(IC_PROFILE_IMAGE),
                            //         fit: BoxFit.cover),
                            //   ),
                            // ),
                            imageBuilder: (context, imageProvider) =>
                                Container(
                                  decoration: BoxDecoration(
                                    color: colorWhite,
                                    // shape: BoxShape.circle,
                                    // borderRadius:
                                    // BorderRadius.circular(100),
                                    image: DecorationImage(
                                        alignment: Alignment.center,
                                        image: imageProvider,
                                        fit: BoxFit.scaleDown),
                                  ),
                                ),
                        ),
                      ),
                          )
                          : Center(
                          child: getSmallText("N",
                              weight: FontWeight.w500,
                              align: TextAlign.center,
                              color: colorBlack,
                              fontSize: BODY1_TEXT_FONT_SIZE)),

                    ),
                    SizedBox(
                      width: deviceWidth * 0.03,
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: deviceWidth*0.62,
                              child: getTitle(title ?? "",
                                  weight: FontWeight.w500,
                                  bold: true,
                                  lines: 1,
                                  fontSize: CAPTION_TEXT_FONT_SIZE,
                                  color: colorBlack),
                            ),
                            // Spacer(),
                            getTitle(time ?? "",
                                weight: FontWeight.w400,
                                lines: 1,
                                fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                                color: colorAccentLight),
                          ],
                        ),

                        // SizedBox(
                        //   height: deviceHeight * 0.01,
                        // ),
                        Container(
                          width: deviceWidth*0.6,
                          child: getTitle(description ?? "",
                              weight: FontWeight.w400,
                              bold: true,
                              lines: 5,
                              fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                              color: colorAccentLight),
                        ),

                      ],
                    ),


                    // Spacer(),
                    // Column(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     Container(
                    //       // width: deviceWidth*0.6,
                    //       child: getTitle("h" ?? "",
                    //           weight: FontWeight.w500,
                    //           bold: true,
                    //           lines: 1,
                    //           fontSize: CAPTION_TEXT_FONT_SIZE,
                    //           color: colorBlack),
                    //     ),
                    //     // SizedBox(
                    //     //   height: deviceHeight * 0.01,
                    //     // ),
                    //     Container(
                    //       // width: deviceWidth*0.6,
                    //       child: getTitle("" ?? "",
                    //           weight: FontWeight.w400,
                    //           bold: true,
                    //           lines: 2,
                    //           fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                    //           color: colorAccentLight),
                    //     ),
                    //
                    //   ],
                    // ),
                    // SizedBox(
                    //   width: deviceWidth * 0.02,
                    // ),

                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  getNotificationListing() async {

    await bloc.userRepository
        .getNotificationList()
        .then((value) {
      if (value.status == 1) {
        notificationlist = value.data?.notificationList ?? [];
        print("notificationlist =");
        print(value);

        if (mounted)
          setState(() {
            isLoadingLocal = false;
          });
      } else if (value.apiStatusCode == 401) {
        showMessage(value.message ?? "", () {
          setState(() {
            isShowMessage = false;
            isLoadingLocal = false;
            logoutaccount();
            return bloc.add(Login());
          });
        });
      } else {
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


  singlenotificationdelete(int notificationid) async {
    String userid = prefs.getString(SharedPrefHelper.USER_ID);

    bloc.userRepository.singledeletenotification(userid: int.parse(userid),sentNotificationId:notificationid ).then((value) {
      if (value.status == 1) {
        print("deletenotificaton =");
        print(value);

        if (mounted)
          setState(() {
            _isInAsyncCall = false;
            getNotificationListing();

          });
      } else if (value.apiStatusCode == 401) {
        showMessage(value.message ?? "", () {
          if(mounted)
            setState(() {
              isShowMessage = false;
              logoutaccount();
              _isInAsyncCall = false;
              return bloc.add(Login());
            });
        });
      } else {
        print("value.message");
        print(value.message);
        showMessage(value.message ?? "", () {
          if(mounted)
            setState(() {
              isShowMessage = false;
              _isInAsyncCall = false;
            });
        });
      }
    });
    }


  deleteallnotifications() async {
    String userid = prefs.getString(SharedPrefHelper.USER_ID);

    bloc.userRepository.deleteallnotifications(userid: int.parse(userid) ).then((value) {
      if (value.status == 1) {
        print("clearall =");
        print(value);

        if (mounted)
          setState(() {
            _isInAsyncCall = false;
            getNotificationListing();

          });
      } else if (value.apiStatusCode == 401) {
        showMessage(value.message ?? "", () {
          if(mounted)
            setState(() {
              isShowMessage = false;
              logoutaccount();
              _isInAsyncCall = false;
              return bloc.add(Login());
            });
        });
      } else {
        print("value.message");
        print(value.message);
        showMessage(value.message ?? "", () {
          if(mounted)
            setState(() {
              isShowMessage = false;
              _isInAsyncCall = false;
            });
        });
      }
    });
    }


}
