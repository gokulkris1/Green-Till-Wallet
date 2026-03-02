import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SurveyScreenWebview extends BaseStatefulWidget {
  final String link;
  final String title;

  const SurveyScreenWebview({super.key, required this.link, required this.title});

  @override
  _SurveyScreenWebviewState createState() => _SurveyScreenWebviewState();
}

class _SurveyScreenWebviewState extends BaseState<SurveyScreenWebview>
    with BasicScreen {
  late final WebViewController _controller;
  bool isLoadingLocal = true;
  final _key = UniqueKey();

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (finish) {
            if (!mounted) return;
            setState(() {
              isLoadingLocal = false;
            });
          },
        ),
      );
    final uri = Uri.tryParse(widget.link);
    if (uri != null && uri.scheme.isNotEmpty) {
      _controller.loadRequest(uri);
    } else {
      isLoadingLocal = false;
    }
  }

  @override
  Widget buildBody(BuildContext context) {
    print(widget.link);
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
                      // bloc.add(HomeScreenEvent());
                    },
                  ),
                  SizedBox(
                    width: deviceWidth * 0.025,
                  ),
                  Expanded(
                    child: appBarHeader(
                      widget.title,
                      fontSize: BUTTON_FONT_SIZE,
                      bold: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        body:
        SafeArea(
          child: Stack(
            children: <Widget>[
              WebViewWidget(
                key: _key,
                controller: _controller,
              ),
              isLoadingLocal ? Center( child: loader(),)
                  : Stack(),
            ],
          ),
        )
    );
  }
}
