import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfViewerPage extends BaseStatefulWidget {
  final File file;
  final String url;

  PdfViewerPage(this.file, this.url);



  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends BaseState<PdfViewerPage> with BasicScreen {

  Future<bool> saveFile(String url, String fileName) async {
    try {
      if (await _requestPermission(Permission.storage)) {
        Directory directory;
        directory = await getExternalStorageDirectory();
        String newPath = "";
        List<String> paths = directory.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/" + folder;
          } else {
            break;
          }
        }
        newPath = newPath + "/PDF_Download";
        directory = Directory(newPath);

        File saveFile = File(directory.path + "/$fileName");
        if (kDebugMode) {
          print(saveFile.path);
        }
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        if (await directory.exists()) {
          await Dio().download(
            url,
            saveFile.path,
          );
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget buildBody(BuildContext context) {
    final name = basename(widget.file.path);
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
                    print("backbutton");
                    Navigator.pop(context);
                    // Navigator.pop(context);
                    // bloc.add(QrCodeEvent());
                    // return bloc.add(SideMenu());
                  },
                ),
                SizedBox(
                  width: deviceWidth * 0.025,
                ),
                Spacer(),
                IconButton(
                  // onPressed: () async {
                  //   print("userid=" + userid.toString());
                  //   if (widget.url != null && userid != null) {
                  //     changeLoadStatus();
                  //     bloc.userRepository
                  //         .uploadreceipt(widget.url, int.parse(userid))
                  //         .then((value) {
                  //       changeLoadStatus();
                  //       if (value.status == 1) {
                  //         print("upload receipt successful");
                  //         showMessage(value.message, () {
                  //           setState(() {
                  //             bloc.add(HomeScreenEvent());
                  //             isShowMessage = false;
                  //           });
                  //         });
                  //       }else if(value.apiStatusCode == 401){
                  //         showMessage(value.message, () {
                  //           setState(() {
                  //             isShowMessage = false;
                  //             logoutaccount();
                  //             return bloc.add(Login());
                  //           });
                  //         });
                  //       }
                  //       else {
                  //         print("upload receipt failed ");
                  //         print(value.message);
                  //         showMessage(value.message, () {
                  //           setState(() {
                  //             // bloc.add(WelcomeIn());
                  //             isShowMessage = false;
                  //           });
                  //         });
                  //       }
                  //     });
                  //   }
                  // },
                  icon: Icon(Icons.download),
                )
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15),
          height: deviceHeight,
          width: deviceWidth,
          color: colorWhite,
          child: PDFView(
            filePath: widget.file.path,
          ),
        ),
      ),
    );
  }
}