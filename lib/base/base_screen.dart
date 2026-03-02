import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
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
    with WidgetsBindingObserver {
  const BaseStatefulWidget({super.key});
}

abstract class BaseState<Screen extends BaseStatefulWidget>
    extends State<Screen> with RouteAware /*, WidgetsBindingObserver*/ {}

mixin BasicScreen<Screen extends BaseStatefulWidget> on BaseState<Screen> {
  late AppLocalizations localizations;
  late MainBloc bloc;

  Color appBarColor = colorWhite;
  bool isLoading = false;
  bool isBlurred = false;
  bool isShowMessage = false;
  bool isPostAnswerPopup = false;
  String message = "";
  VoidCallback? f;
  String postanswermessage = "";
  VoidCallback? onclick;
  BuildContext? baseContext;
  bool gestureEnabled = false;

  @override
  initState() {
    super.initState();
    if (!kIsWeb && Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    }
    changeStatusColor(appBarColor);
  }

  changeStatusColor(Color color) async {
    appBarColor = color;
  }

  @override
  Widget build(BuildContext context) {
    baseContext = context;
    Globals.globalContext = context;
    localizations = AppLocalizations.of(context)!;
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
      backgroundColor: colorWhite,

      body: SafeArea(
        child: Stack(children: [
          isShowMessage
              ? WillPopScope(
                  onWillPop: () {
                    Navigator.of(context).popUntil(ModalRoute.withName("/"));
                    bloc.add(HomeScreenEvent());
                    return Future.value(false);
                  },
                  child: Scaffold(
                    body: AlertDialog(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getTitle("Green Till",
                              bold: true,
                              isCenter: true,
                              fontSize: TITLE_TEXT_FONT_SIZE,
                              color: colortheme,
                              weight: FontWeight.w700),
                          // GestureDetector(
                          //   onTap: f,
                          //   child: getSmallIcon("x",
                          //       color: colorBlack,
                          //       bold: false,
                          //       fontSize: BODY2_TEXT_FONT_SIZE,
                          //       isEnd: false),
                          // ),
                        ],
                      ),
                      content: GestureDetector(
                        child: getSmallText(
                          message.isNotEmpty
                              ? message
                              : "Something went wrong!",
                          bold: true,
                          isCenter: true,
                          fontSize: BUTTON_FONT_SIZE,
                          color: colorBlack,
                          weight: FontWeight.w500,
                        ),
                        onTap: gestureEnabled
                            ? () {
                                Navigator.pop(context);
                              }
                            : null,
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text("OK"),
                          onPressed: () {
                            f?.call();
                          },
                        )
                      ],
                    ),
                  ),
                )
              : isLoading
                  ? loader()
                  : isBlurred
                      ? const Scaffold(
                          backgroundColor: Colors.transparent,
                          body: Center(),
                        )
                      : GestureDetector(
                          onTap: () {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          },
                          child: buildBody(context)),
        ]),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  AppBar? buildAppBar(BuildContext context) {
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

  showMessage(String message, VoidCallback f, [bool gestureEnabled = false]) {
    final normalizedMessage = _normalizeMessage(message);
    setState(() {
      this.isShowMessage = true;
      this.message = normalizedMessage;
      this.f = f;
      this.gestureEnabled = gestureEnabled;
    });
  }

  String _normalizeMessage(String message) {
    final raw = message.trim();
    if (raw.isEmpty) {
      return "Something went wrong. Please try again.";
    }
    final lower = raw.toLowerCase();

    // Backend SMTP auth failure is a server-side email infrastructure issue.
    if ((lower.contains("authenticationfailedexception") ||
            lower.contains("javax.mail")) &&
        lower.contains("535")) {
      return "Email service is temporarily unavailable on the server. "
          "Please sign in with an existing account for now, or try again later.";
    }

    if (lower.contains("type 'firebaseexception' is not a subtype of type")) {
      return "Preview build error: unsupported Firebase operation for this platform.";
    }

    // Prevent raw exception payloads from filling the whole dialog.
    if (raw.length > 260) {
      return "${raw.substring(0, 257)}...";
    }
    return raw;
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: getTitle("OK"),
      onPressed: () {
        f?.call();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: getTitle("Green Till"),
      content: getTitle(message.isNotEmpty ? message : "Something went wrong."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
