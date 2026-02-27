import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/app_localizations.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/utils/common_widgets.dart';

abstract class BaseStatefulWidget extends StatefulWidget {
  const BaseStatefulWidget({super.key});
}

abstract class BaseState<Screen extends BaseStatefulWidget>
    extends State<Screen> with RouteAware {}

mixin BasicScreen<Screen extends BaseStatefulWidget> on BaseState<Screen> {
  late AppLocalizations localizations;
  late MainBloc bloc;

  Color appBarColor = colorWhite;
  bool isLoading = false;
  bool isBlurred = false;
  bool isShowMessage = false;
  String message = "";
  VoidCallback? onMessageDismissed;
  bool gestureEnabled = false;

  @override
  void initState() {
    super.initState();
    changeStatusColor(appBarColor);
  }

  void changeStatusColor(Color color) {
    appBarColor = color;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: color,
      statusBarBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    localizations = AppLocalizations.of(context);
    bloc = context.read<MainBloc>();
    return Scaffold(
      extendBody: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: appBarColor,
          elevation: 0,
        ),
      ),
      backgroundColor: colorWhite,
      body: SafeArea(
        child: Stack(
          children: [
            buildBody(context),
            if (isBlurred)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            if (isLoading)
              const Positioned.fill(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Loading..."),
                      SizedBox(height: 16),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            if (isShowMessage)
              Positioned.fill(
                child: GestureDetector(
                  onTap: gestureEnabled ? onMessageDismissed : null,
                  child: Center(
                    child: AlertDialog(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getTitle("Green Till",
                              fontSize: 18, bold: true, color: colorGreen),
                          GestureDetector(
                            onTap: onMessageDismissed,
                            child: getSmallIcon(
                              "x",
                              color: colorBlack,
                              fontSize: BODY2_TEXT_FONT_SIZE,
                            ),
                          ),
                        ],
                      ),
                      content: Text(
                          message.isEmpty ? "Something went wrong!" : message),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget buildBody(BuildContext context);

  void changeLoadStatus() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  void changeBlurredStatus() {
    setState(() {
      isBlurred = !isBlurred;
    });
  }

  void showMessage(
    String newMessage,
    VoidCallback? onDismiss, [
    bool allowGestureDismiss = false,
  ]) {
    setState(() {
      isShowMessage = true;
      message = newMessage;
      onMessageDismissed = onDismiss ?? hideMessage;
      gestureEnabled = allowGestureDismiss;
    });
  }

  void hideMessage() {
    setState(() {
      isShowMessage = false;
      message = "";
      onMessageDismissed = null;
      gestureEnabled = false;
    });
  }
}
