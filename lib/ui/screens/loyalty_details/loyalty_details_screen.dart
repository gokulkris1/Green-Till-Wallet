import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/models/responses/home_page_response.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';

class LoyaltyDetailsScreen extends BaseStatefulWidget {
  final StoreCardList storeCardList;

  const LoyaltyDetailsScreen({super.key, required this.storeCardList});

  @override
  _LoyaltyDetailsScreenState createState() => _LoyaltyDetailsScreenState();
}

class _LoyaltyDetailsScreenState extends BaseState<LoyaltyDetailsScreen> with BasicScreen {
  @override
  Widget buildBody(BuildContext context) {
    final double requiredStamps =
        (widget.storeCardList.requiredStampsForReward ?? 0).toDouble();
    final double currentStamps =
        (widget.storeCardList.currentStamps ?? 0).toDouble();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorstorecardbackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(deviceHeight * 0.07),
        child: Container(
          height: deviceHeight * 0.07,
          width: deviceWidth,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.withOpacity(0.2), blurRadius: 30.0, offset: Offset(0.0, 0.05))
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
                  },
                ),
                SizedBox(
                  width: deviceWidth * 0.025,
                ),
                appBarHeader(
                  widget.storeCardList.storeName ?? "",
                  fontSize: BUTTON_FONT_SIZE,
                  bold: false,
                )
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          height: deviceHeight,
          width: deviceWidth,
          child: SingleChildScrollView(
            child: Container(
              width: deviceWidth,
              height: deviceHeight,
              decoration: BoxDecoration(
                color: colorstorecardbackground,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10.0,
                      offset: Offset(0.0, 0.05))
                ],
              ),
              padding: EdgeInsets.symmetric(
                horizontal: HORIZONTAL_PADDING,
                vertical: VERTICAL_PADDING * 2,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      imageUrl: widget.storeCardList.stampImage ?? "",
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          color: colorWhite,
                        ),
                      ),
                      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                          child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(value: downloadProgress.progress))),
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          color: colorWhite,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          image: DecorationImage(
                              // alignment: Alignment.center,
                              image: imageProvider,
                              fit: BoxFit.fill),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: deviceHeight * 0.02,
                  ),
                  Container(
                    width: deviceWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: colorWhite,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: GridView.builder(
                        shrinkWrap: false,
                        padding: EdgeInsets.all(20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                        ),
                        itemCount: requiredStamps.round(),
                        /*itemCount: 100,*/
                        itemBuilder: (context, index) {
                          print('BENTELLY ${widget.storeCardList.requiredStampsForReward}');
                          if (index == requiredStamps.round() - 1) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: colortheme, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: index <= (currentStamps - 1)
                                    ? Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Image.asset(
                                          IC_COFFEE_BEAN,
                                        ),
                                      )
                                    : Text(
                                        'REWARD',
                                        style: TextStyle(
                                          color: colorBlack,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            );
                          } else if (index <= requiredStamps.round()) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: colortheme, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: index <= (currentStamps - 1)
                                    ? Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Image.asset(IC_COFFEE_BEAN),
                                          ),
                                          Center(
                                            child: Text(
                                              '${index + 1}', // Display the current stamp number
                                              style: TextStyle(
                                                color: colorBlack,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    : Text(
                                        '${index + 1}', // Display the current stamp number
                                        style: TextStyle(
                                          color: colorBlack,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            );
                          } else {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: colortheme, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                  child: Text(
                                    '${currentStamps.round() == 0 ? '' : currentStamps.round()}'),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: deviceHeight * 0.01,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: getSmallText(stampEveryPurchase,
                        bold: true,
                        fontSize: BUTTON_FONT_SIZE,
                        color: colorBlack,
                        weight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: deviceHeight * 0.03,
                  ),
                  Container(
                    width: deviceWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: deviceHeight * 0.04),
                        Container(
                          width: deviceWidth * 0.6,
                          height: deviceHeight * 0.15,
                          child: CachedNetworkImage(
                            fit: BoxFit.fill,
                            imageUrl: widget.storeCardList.barcodeImage ?? "",
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                color: colorWhite,
                              ),
                            ),
                            progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        value: downloadProgress.progress))),
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                color: colorWhite,
                                // borderRadius: BorderRadius.circular(100),
                                image: DecorationImage(
                                    // alignment: Alignment.center,
                                    image: imageProvider,
                                    fit: BoxFit.fill),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: deviceHeight * 0.02),
                        getTitle(widget.storeCardList.storeNumber ?? "",
                            lines: 1,
                            weight: FontWeight.w800,
                            fontSize: SUBTITLE_FONT_SIZE,
                            color: colorbarcodetext),
                        SizedBox(height: deviceHeight * 0.02),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: deviceHeight * 0.02,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
