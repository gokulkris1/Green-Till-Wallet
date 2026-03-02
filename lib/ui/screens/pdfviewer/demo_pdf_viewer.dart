import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
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

class DemoPDFViewer extends BaseStatefulWidget {
  DemoPDFViewer({this.url});

  final String url;

  @override
  _DemoPDFViewerState createState() => _DemoPDFViewerState();
}

class _DemoPDFViewerState extends BaseState<DemoPDFViewer> with BasicScreen {
  String urlPDFPath = "";
  bool exists = true;
  int _totalPages = 0;
  int _currentPage = 0;
  bool pdfReady = false;
  PDFViewController _pdfViewController;
  bool loaded = false;
  String userid = prefs.getString(SharedPrefHelper.USER_ID);
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
                    showMessage("Receipt Downloaded!", () {
                      setState(() {
                        // bloc.add(WelcomeIn());
                        Navigator.pop(context);
                        isShowMessage = false;
                      });
                    });
                  },
                  icon: Icon(Icons.download),
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
          color: colorWhite,
          child: Column(children: <Widget>[
            Expanded(
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
                    _totalPages = _pages;
                    pdfReady = true;
                  });
                },
                onViewCreated: (PDFViewController vc) {
                  setState(() {
                    _pdfViewController = vc;
                  });
                },
                onPageChanged: (int page, int total) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                onPageError: (page, e) {},
              ),
            ),
          ]),
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
                  _pdfViewController.setPage(_currentPage);
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
                  _pdfViewController.setPage(_currentPage);
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
