import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';

class InfoScreen extends BaseStatefulWidget{
  @override
  _InfoScreenState createState() => _InfoScreenState();

}

class _InfoScreenState extends BaseState<InfoScreen> with BasicScreen{

  final List<Step> _steps = getSteps();

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
                    Navigator.pop(context);
                    // return bloc.add(RewardScreenEvent());

                    // return bloc.add(SideMenu());
                  },
                ),
                SizedBox(
                  width: deviceWidth * 0.025,
                ),
                appBarHeader(
                  inform,
                  fontSize: BUTTON_FONT_SIZE,
                  bold: false,
                ),

              ],
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Container(
          height: deviceHeight,
          width: deviceWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: deviceHeight * 0.16,
                width: deviceWidth,
                decoration: BoxDecoration(
                  color: colorWhite,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: HORIZONTAL_PADDING,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Spacer(
                        flex: 3,
                      ),
                      getSmallText(earnpointsinfocontent,
                          weight: FontWeight.w500,
                          align: TextAlign.start,
                          fontSize: SUBTITLE_FONT_SIZE,
                          color: colorBlack,
                          bold: true),
                      Spacer(
                        flex: 2,
                      ),
                      getSmallText(infocontent,
                          weight: FontWeight.w500,
                          align: TextAlign.start,
                          fontSize: SUBTITLE_FONT_SIZE,
                          color: colorBlack,
                          bold: true),
                      Spacer()
                    ],
                  ),
                ),
              ),
              Container(
                color: colorstorecardbackground,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: HORIZONTAL_PADDING,
                      vertical: VERTICAL_PADDING),
                  child: Container(
                    decoration: BoxDecoration(
                        color: colorWhite,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 30.0,
                              offset: Offset(0.0, 0.05))
                        ],
                        border: Border.all(
                            color: colormyreceiptbordercolor),
                        borderRadius:
                        BorderRadius.all(Radius.circular(10))),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.symmetric(horizontal: 16),
                        collapsedIconColor: Colors.black,
                        iconColor: Colors.black,
                        // key: PageStorageKey<Step>(root),
                        title: getTitle("How do I use my points?",fontSize:BUTTON_FONT_SIZE ,weight: FontWeight.w900,color: colorinfoheader),
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 16,left: 16,bottom: 8),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                        width: deviceWidth*0.15,
                                        child: getTitle("POINTS",fontSize:SUBTITLE_FONT_SIZE ,weight: FontWeight.w500,color: colorinfoheader)),
                                    SizedBox(width: deviceWidth*0.12,),
                                    getTitle("ACTION",fontSize:SUBTITLE_FONT_SIZE ,weight: FontWeight.w500,color: colorinfoheader),
                                  ],
                                ),
                                getCommonDivider(),
                                Row(
                                  children: [
                                    SizedBox(
                                        width: deviceWidth*0.15,
                                        child: getTitle("100",fontSize:SUBTITLE_FONT_SIZE ,weight: FontWeight.w900,color: colorAccentLight)),
                                    SizedBox(width: deviceWidth*0.12,),
                                    getTitle("Make a purchase",fontSize:SUBTITLE_FONT_SIZE ,weight: FontWeight.w400,color: colorAccentLight),
                                  ],
                                ),
                                SizedBox(height: 4,),
                                Row(
                                  children: [
                                    SizedBox(
                                        width: deviceWidth*0.15,
                                        child: getTitle("50",fontSize:SUBTITLE_FONT_SIZE ,weight: FontWeight.w900,color: colorAccentLight)),
                                    SizedBox(width: deviceWidth*0.12,),
                                    getTitle("Review a purchase",fontSize:SUBTITLE_FONT_SIZE ,weight: FontWeight.w400,color: colorAccentLight),
                                  ],
                                ),
                                SizedBox(height: 4,),

                                Row(
                                  children: [
                                    SizedBox(
                                        width: deviceWidth*0.15,
                                        child: getTitle("50",fontSize:SUBTITLE_FONT_SIZE ,weight: FontWeight.w900,color: colorAccentLight)),
                                    SizedBox(width: deviceWidth*0.12,),
                                    Expanded(child: getTitle("Upload a photo with your review",fontSize:SUBTITLE_FONT_SIZE ,weight: FontWeight.w400,color: colorAccentLight)),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],

                        // root.children.map(_buildTiles).toList(),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Container(
                    color: colorstorecardbackground,
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) =>
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: HORIZONTAL_PADDING,
                                vertical: VERTICAL_PADDING*0.5),
                            child: Container(
                                decoration: BoxDecoration(
                                    color: colorWhite,
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 30.0,
                                          offset: Offset(0.0, 0.05))
                                    ],
                                    border: Border.all(
                                        color: colormyreceiptbordercolor),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                                child: EntryItem(_steps[index])),
                          ),
                      itemCount: _steps.length,
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

}







// Displays one Entry. If the entry has children then it's displayed
// with an ExpansionTile.
class EntryItem extends StatelessWidget {
  const EntryItem(this.entry);

  final Step entry;

  Widget _buildTiles(Step root, {required BuildContext context}) {
    if (root.body.isEmpty) return ListTile(title: Text(root.title));
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding:    EdgeInsets.only(right: 16,left: 16,bottom: 0),

        collapsedIconColor: Colors.black,
        iconColor: Colors.black,
        key: PageStorageKey<Step>(root),
        title: getTitle(root.title,fontSize:BUTTON_FONT_SIZE ,weight: FontWeight.w900,color: colorinfoheader),
        children: <Widget>[
          ListTile(  title: getTitle(root.body,fontSize:SUBTITLE_FONT_SIZE ,weight: FontWeight.w400,color: colorAccentLight),),
        ],

        // root.children.map(_buildTiles).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry,context: context);
  }
}

class Step {
  Step(
      this.title,
      this.body,
      [this.isExpanded = false]
      );
  String title;
  String body;
  bool isExpanded;
}

List<Step> getSteps() {
  return [
    Step('How do I use my points?', 'Redeem your points for coupons and get extra \ndiscounts.Tap on the Redeem tab to get \nstarted.'),
    Step('How do I use my points?', 'Redeem your points for coupons and get extra \ndiscounts.Tap on the Redeem tab to get \nstarted.'),
  ];
}
