import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/models/responses/getsurveylist_response.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/ui/screens/surveys/survey_detail_screen.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';

class SurveyScreen extends BaseStatefulWidget{
  @override
  _SurveyScreenState createState() => _SurveyScreenState();
}

class _SurveyScreenState extends BaseState<SurveyScreen> with BasicScreen {
  List<DatumSurvey> surveylist = [];
  bool isLoadingLocal = true;
  bool isFirst = true;

  // List<Map<String,String>> surveylist = [
  //   {
  //     "icon" : IC_SURVEY,
  //     "title" : "Survey - 1 Introduction",
  //     "surveyLink" : "https://docs.google.com/forms/d/e/1FAIpQLSfZhwVZms7Fg8XELQqw7KYY_Q58ufW3MqnlrtTe9JDHy-R_Pw/viewform?usp=sf_link"
  //   },
  //   {
  //     "icon" : IC_SURVEY,
  //     "title" : "Survey - 2 Electrical/Electronics",
  //     "surveyLink" : "https://docs.google.com/forms/d/e/1FAIpQLSdmg8dDly-2a5ROobgUcZEnG7nwiRD-SNi1VajvS1bWHoNJzQ/viewform?usp=sf_link"
  //   },
  // ];
  @override
  Widget buildBody(BuildContext context) {
    if (isFirst) {
      isFirst = false;
      getSurveyListing();
    }
    return isLoadingLocal == true
        ? loader()
        : Scaffold(
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
                    "Surveys",
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
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: colorstorecardbackground,
                child:
                 surveylist.length <= 0 ||
                     surveylist.isEmpty
                    ? Center(
                  child: getSmallText("No survey link available!",
                      bold: true,
                      isCenter: true,
                      fontSize: BUTTON_FONT_SIZE,
                      color: colorBlack,
                      weight: FontWeight.w500),
                ):
                ListView.builder(
                    padding: EdgeInsets.only(
                        bottom: deviceHeight * 0.12),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    clipBehavior: Clip.none,
                    primary: false,
                    itemCount: surveylist.length,
                    itemBuilder: (context,index){
                      return Padding(
                        padding: const EdgeInsets
                            .symmetric(
                          horizontal:
                          HORIZONTAL_PADDING,
                        ),
                        child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                return SurveyScreenWebview(
                                  link: surveylist[index].surveyLink ?? "",
                                  title: surveylist[index].title ?? "",
                                );
                              }));
                            },
                            child: SurveyListWidget(IC_SURVEY_GREEN,survey:surveylist[index].title ?? "" )),
                      );

                    }),

              ),
            ),
          ],
        ),
      ),
    );
  }
Widget SurveyListWidget(String logosurvey,{bool isstorelogoavailable = false, required String survey}){
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        height: deviceHeight * 0.09,
        width: deviceWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                height: deviceHeight * 0.09,
                padding: EdgeInsets.symmetric(horizontal: 12),
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
                    // Container(
                    //   height: deviceHeight * 0.04,
                    //   width: deviceWidth * 0.08,
                    //   decoration: BoxDecoration(
                    //     // border: Border.all(color: colorbordercoupons),
                    //     color: colorWhite,
                    //     // image: widget.isCoupons
                    //     //     ? DecorationImage(image: AssetImage(widget.logo))
                    //     //     : null
                    //   ),
                    //   child: Image.asset(logosurvey,fit: BoxFit.fill,)
                    //
                    // ),
                    // SizedBox(
                    //   width: deviceWidth * 0.03,
                    // ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: deviceWidth*0.6,
                      child: getTitle(survey,
                          weight: FontWeight.w500,
                          bold: true,
                          lines: 1,
                          fontSize: CAPTION_TEXT_FONT_SIZE,
                          color: colorBlack),
                    ),

                      ],
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios,color: colorBlack,size: 18,)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
}

  getSurveyListing() async {

      await bloc.userRepository
          .getSurveyList()
          .then((value) {
        if (value.status == 1) {
          surveylist = value.data ?? [];
          print("surveylist =");
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

}
