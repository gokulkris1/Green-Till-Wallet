import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/screens/receipt/feedback_receipt_screen.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';

import 'package:greentill/utils/common_widgets.dart';

class PDFViewer extends BaseStatefulWidget {
  const PDFViewer({super.key, required this.url});

  final String url;

  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends BaseState<PDFViewer> with BasicScreen {
  String urlPDFPath = "";
  bool exists = true;
  int _totalPages = 0;
  int _currentPage = 0;
  bool pdfReady = false;
  PDFViewController? _pdfViewController;
  bool loaded = false;
  String userid = prefs.getString(SharedPrefHelper.USER_ID) ?? "0";
  bool isFirst = true;
  Future<File> getFileFromUrl(String url, {name}) async {
    final File _file = File(url.substring(1, url.indexOf('receipt/')));
    final fileName = basename(_file.path);
    print("Pdf file name =");
    print(fileName);
    try {
      var data = await http.get(Uri.parse(url));
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$fileName");
      print(dir.path);
      File urlFile = await file.writeAsBytes(bytes);
      return urlFile;
    } catch (e) {
      throw Exception("Error opening url file");
    }
  }

  @override
  void initState() {
    getFileFromUrl(widget.url).then(
      (value) => {
        setState(() {
          urlPDFPath = value.path;
          loaded = true;
          exists = true;
                })
      },
    );
    super.initState();
  }

  @override
  Widget buildBody(BuildContext context) {
    if (isFirst) {
      isFirst = false;
    }
    print(urlPDFPath);
    return !loaded
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
                        .uploadreceipt(widget.url, int.parse(userid))
                        .then((value) {
                      changeLoadStatus();
                      if (value.status == 1) {
                        print("upload receipt successful");
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return FeedbackReceiptScreen(userid: int.parse(userid),receiptid: value.data ?? 0,message: value.message ?? "",imagefrom: "QRSCAN");
                        }));
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
                  icon: Icon(
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
              child: SingleChildScrollView(
                child: Container(
                  // height: deviceHeight,
                  // width: deviceWidth,
                  color: colorWhite,
                  child: Column(children: <Widget>[
                    Container(
                      height: deviceHeight*0.8,
                      width: deviceWidth,
                      color: colorWhite,
                      child: PDFView(
                        filePath: urlPDFPath,
                        autoSpacing: true,
                        enableSwipe: true,
                        pageSnap: true,
                        swipeHorizontal: true,
                        nightMode: false,
                        onError: (e) {
                          //Show some error message or UI
                        },
                        onRender: (_pages) {
                          setState(() {
                            _totalPages = _pages ?? 0;
                            pdfReady = true;
                          });
                        },
                        onViewCreated: (PDFViewController vc) {
                          setState(() {
                            _pdfViewController = vc;
                          });
                        },
                        onPageChanged: (int? page, int? total) {
                          setState(() {
                            _currentPage = page ?? 0;
                          });
                        },
                        onPageError: (page, e) {},
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  iconSize: 50,
                  color: Colors.black,
                  onPressed: () {
                    setState(() {
                      if (_currentPage > 0) {
                        _currentPage--;
                        _pdfViewController?.setPage(_currentPage);
                      }
                    });
                  },
                ),
                Text(
                  "${_currentPage + 1}/$_totalPages",
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  iconSize: 50,
                  color: Colors.black,
                  onPressed: () {
                    setState(() {
                      if (_currentPage < _totalPages - 1) {
                        _currentPage++;
                        _pdfViewController?.setPage(_currentPage);
                      }
                    });
                  },
                ),
              ],
            ),
          );
  }

}
