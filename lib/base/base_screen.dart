import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/models/common/globals.dart';
import 'package:greentill/ui/res/app_localizations.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/utils/common_widgets.dart';


abstract class BaseStatefulWidget extends StatefulWidget
    with WidgetsBindingObserver {}

abstract class BaseState<Screen extends BaseStatefulWidget>
    extends State<Screen> with RouteAware /*, WidgetsBindingObserver*/ {}

mixin BasicScreen<Screen extends BaseStatefulWidget> on BaseState<Screen> {
  AppLocalizations localizations;
  MainBloc bloc;

  Color appBarColor = colorWhite;
  bool isLoading = false;
  bool isBlurred = false;
  bool isShowMessage = false;
  bool isPostAnswerPopup = false;
  String message = "";
  Function f;
  String postanswermessage = "";
  Function onclick;
  BuildContext baseContext;
  bool gestureEnabled = false;

  @override
  initState() {
    super.initState();
    if (Platform.isIOS) SystemChrome.setEnabledSystemUIOverlays([]);
    changeStatusColor(appBarColor);
  }

  changeStatusColor(Color color) async {
    appBarColor = color;
  }

  @override
  Widget build(BuildContext context) {
    baseContext = context;
    Globals.globalContext = context;
    localizations = AppLocalizations.of(context);
    bloc = BlocProvider.of<MainBloc>(context);
    return Scaffold(
      extendBody: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          backgroundColor: appBarColor,
          elevation: 0,
        ),
      ),
      // backgroundColor: Colors.transparent,
      backgroundColor:
           colorWhite,

      body: SafeArea(
        child: Stack(children: [
          isShowMessage
              ? Scaffold(
                  body: AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getTitle("Green Till",
                            fontSize: 18, bold: true, color: colorGreen),
                        GestureDetector(
                          onTap: f,
                          child: getSmallIcon("x",
                            color: colorBlack,
                            bold: false,
                            fontSize: BODY2_TEXT_FONT_SIZE,
                            isEnd: false
                          ),
                        ),
                      ],
                    ),
                    content: GestureDetector(
                      child: Text(message ?? "Something went wrong!"),
                      onTap: gestureEnabled
                          ? () {
                              Navigator.pop(context);
                            }
                          : null,
                    ),
                    // actions: <Widget>[
                    //   FlatButton(
                    //     onPressed: f,
                    //     child: Container(
                    //       margin: EdgeInsets.only(
                    //           top: 7, right: 0, left: 30, bottom: 0),
                    //       child: getSmallIcon("x",
                    //           color: colorBlack,
                    //           bold: false,
                    //           fontSize: BODY2_TEXT_FONT_SIZE,
                    //           isEnd: true),
                    //     ),
                    //   )
                    // ],
                  ),
                )

                  : isLoading
                      ? Scaffold(
                          body: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Text("Loading..."),
                                Container(
                                    margin: const EdgeInsets.all(10),
                                    child: const CircularProgressIndicator()),
                              ],
                            ),
                          ),
                        )
                      : isBlurred
                          ? const Scaffold(
                              backgroundColor: Colors.transparent,
                              body: Center(),
                            )
                          : buildBody(context),
        ]),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return null;
  }

  Widget buildBody(BuildContext context);

  changeLoadStatus() {
    setState(() {
      this.isLoading = !this.isLoading;
    });
  }

  changeBlurredStatus() {
    setState(() {
      this.isBlurred = !this.isBlurred;
    });
  }

  showMessage(String message, Function f, [bool gestureEnabled = false]) {
    setState(() {
      this.isShowMessage = true;
      this.message = message;
      this.f = f;
      this.gestureEnabled = gestureEnabled;
    });
  }

}
