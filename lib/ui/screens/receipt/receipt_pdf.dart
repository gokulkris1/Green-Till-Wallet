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

import 'package:greentill/utils/common_widgets.dart';

class ReceiptPDFViewer extends BaseStatefulWidget {
  const ReceiptPDFViewer({super.key, required this.url});

  final String url;

  @override
  _ReceiptPDFViewerState createState() => _ReceiptPDFViewerState();
}

class _ReceiptPDFViewerState extends BaseState<ReceiptPDFViewer> with BasicScreen {
  String urlPDFPath = "";
  bool exists = true;
  int _totalPages = 0;
  int _currentPage = 0;
  bool pdfReady = false;
  PDFViewController? _pdfViewController;
  bool loaded = false;
  String userid = prefs.getString(SharedPrefHelper.USER_ID) ?? "0";
  Future<File> getFileFromUrl(String url, {name}) async {
    final File _file = File(url.substring(1, url.indexOf('receipt/')));
    final fileName = basename(_file.path);
    print("Pdf file name =");
    print(widget.url);
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
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.only(bottom: deviceHeight * 0.11),
            height: deviceHeight*0.89,
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
