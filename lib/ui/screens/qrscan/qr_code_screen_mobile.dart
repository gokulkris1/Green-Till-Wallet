import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/ui/screens/qrloadedreceipt/qr_loaded_receipt.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../pdfviewer/pdf_viewer.dart';

class QrCodeScreen extends BaseStatefulWidget {
  @override
  _QrCodeScreenState createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends BaseState<QrCodeScreen> with BasicScreen {
  Barcode? result;
  bool isQRScreen = false;
  bool isCameraScreen = true;
  bool isGalleryScreen = true;
  File? selectedImageFile;
  Image _profileImage = Image.asset(IC_SELECT_PROFILE);
  String? receiptname;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    print(result?.code);
    final code = result?.code ?? "";
    String updatedurl = "";
    // https://greentill-cms.openxcell.dev/receipt/greentillReceipt_1700720098562.pdf
    // Development

    if (code.isNotEmpty) {
      var parts = code.split('dev/');
      var prefix = parts[0].trim();
      var suffix = parts.sublist(1).join('dev/').trim();
      String addurl =
          "https://openxcell-development-public.s3.ap-south-1.amazonaws.com/greentill/development/";
      print("prefix" + prefix);
      print("suffix" + suffix);
      updatedurl = addurl + suffix;
    }

    // Production
    // var parts = result.code.split('co/');
    // var prefix = parts[0].trim();
    // var suffix = parts.sublist(1).join('co/').trim();
    // String addurl = "https://receipts.greentill.co/greentill/production/";
    // print("prefix"+prefix);
    // print("suffix"+suffix);
    // updatedurl = addurl + suffix;
    // print("newurl" + updatedurl);
  
    return (updatedurl.isNotEmpty)
        ? updatedurl.contains(".pdf")
            ? PDFViewer(
                url:updatedurl,
                    //"https://deliver.goshippo.com/ab64256b6f6144dd93dd6800629cf3df.pdf?Expires=1693904867&Signature=e7yi1I4cphHk1WN~0YvdvFxptl8tIcj00up-dYYvoSSgaacnwpMgUU~vVlzOdwEPU6QBSSbECOhJvz7dhaOt39s4mHzUNpj028ql6xHtDVRg1syJD3DuFtuDOXcaqka7nwwlCCWDT2PMX9DOUw~SngDitLEKugUR-jezRSynqNDZgDX-~L-6EiMMth5Lqjs0l12kwHKkgEL2psI6Pz8A7PUQwR7opmi3DyCuQJ5j5w41xUKP9ZZCRqJkeVCUeUX0X-VybDMG1CXUiLKmHkyXIIgsRcLk9a5DiGGb4rQTlsTLPyt56cYr7D0rolhnYlxRp~y7Hce98Gbp0a5a2OBD5g__&Key-Pair-Id=APKAJRICFXQ2S4YUQRSQ",
              )
            : QRLoadedReceipt(
                url: updatedurl,
    )
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
                      bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
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
                        },
                      ),
                      SizedBox(
                        width: deviceWidth * 0.025,
                      ),
                      appBarHeader(
                        isGalleryScreen && isCameraScreen
                            ? qrCode
                            : isGalleryScreen && isQRScreen
                                ? camera
                                : uploadFromGallery,
                        fontSize: BUTTON_FONT_SIZE,
                        bold: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // bottomNavigationBar: Container(
            //   height: deviceHeight * 0.2,
            //   decoration: BoxDecoration(
            //     color: colorMyrecieptHomeBackground,
            //     borderRadius: const BorderRadius.only(
            //       topLeft: Radius.circular(15),
            //       topRight: Radius.circular(15),
            //     ),
            //   ),
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       Spacer(),
            //       getSmallText(or,
            //           weight: FontWeight.w400,
            //           align: TextAlign.center,
            //           fontSize: SUBTITLE_FONT_SIZE),
            //       Spacer(),
            //       Container(
            //         width: deviceWidth,
            //         child: Padding(
            //           padding: EdgeInsets.only(
            //             right: deviceWidth * 0.05,
            //           ),
            //           child: Row(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               isCameraScreen
            //                   ? SizedBox(
            //                       width: deviceWidth * 0.05,
            //                     )
            //                   : SizedBox(
            //                       width: 0,
            //                     ),
            //               Visibility(
            //                   visible: isCameraScreen,
            //                   child: CustomQrButton(IC_QR_CAMERA, camera, () {
            //                     setState(() {
            //                       isCameraScreen = false;
            //                       isGalleryScreen = true;
            //                       isQRScreen = true;
            //                     });
            //                   })),
            //               isGalleryScreen
            //                   ? SizedBox(
            //                       width: deviceWidth * 0.05,
            //                     )
            //                   : SizedBox(
            //                       width: 0,
            //                     ),
            //               Visibility(
            //                   visible: isGalleryScreen,
            //                   child: CustomQrButton(
            //                       IC_UPLOAD, uploadFromGallery, () {
            //                     setState(() {
            //                       isGalleryScreen = false;
            //                       isQRScreen = true;
            //                       isCameraScreen = true;
            //                     });
            //                   })),
            //               isQRScreen
            //                   ? SizedBox(
            //                       width: deviceWidth * 0.05,
            //                     )
            //                   : SizedBox(
            //                       width: 0,
            //                     ),
            //               Visibility(
            //                   visible: isQRScreen,
            //                   child: CustomQrButton(IC_SCAN_QR, scanQRCode, () {
            //                     setState(() {
            //                       isQRScreen = false;
            //                       isCameraScreen = true;
            //                       isGalleryScreen = true;
            //                     });
            //                   })),
            //             ],
            //           ),
            //         ),
            //       ),
            //       Spacer(
            //         flex: 2,
            //       )
            //     ],
            //   ),
            // ),
            body: SafeArea(
                child:
                    // isGalleryScreen && isCameraScreen
                    //     ?
                    Scaffold(
              body: Column(
                children: <Widget>[
                  Expanded(flex: 4, child: _buildQrView(context)),
                  // Expanded(
                  //   child: Text(result != null
                  //       ? "'Barcode Type: ${describeEnum(result.format)} Data: ${result.code}"
                  //       : "Scan a code"),
                  //   flex: 1,
                  // )
                ],
              ),
            )
                // : isGalleryScreen && isQRScreen
                //     ? CameraCapture()
                //     : UploadReceiptFolder()
                ),
          );
  }



}

// class CameraCapture extends StatefulWidget {
//   const CameraCapture({Key key}) : super(key: key);
//
//   @override
//   State<CameraCapture> createState() => _CameraCaptureState();
// }
//
// class _CameraCaptureState extends State<CameraCapture> {
//   List<CameraDescription> cameras; //list out the camera available
//   CameraController controller; //controller for camera
//   XFile image;
//
//   @override
//   void initState() {
//     loadCamera();
//     super.initState();
//   }
//
//   loadCamera() async {
//     cameras = await availableCameras();
//     if (cameras != null) {
//       controller = CameraController(cameras[0], ResolutionPreset.max);
//       //cameras[0] = first camera, change to 1 to another camera
//
//       controller.initialize().then((_) {
//         if (!mounted) {
//           return;
//         }
//         setState(() {});
//       });
//     } else {
//       print("No camera found");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         Positioned.fill(
//           child: Container(
//               child: controller == null
//                   ? Center(child: Text("Loading Camera..."))
//                   : !controller.value.isInitialized
//                       ? Center(
//                           child: CircularProgressIndicator(),
//                         )
//                       : CameraPreview(controller)),
//         ),
//         Positioned.fill(
//           child: Align(
//               alignment: Alignment.bottomCenter,
//               child: GestureDetector(
//                   onTap: () async {
//                     try {
//                       if (controller != null) {
//                         //check if contrller is not null
//                         if (controller.value.isInitialized) {
//                           //check if controller is initialized
//                           image = await controller.takePicture(); //capture image
//                           if (!mounted) return;
//                           Navigator.push(context, MaterialPageRoute(builder: (context) {
//                             return UploadGalleryImage(
//                               imageFile: File(image.path),
//                             );
//                           }));
//                         }
//                       }
//                     } catch (e) {
//                       print(e); //show error
//                     }
//                   },
//                   child: Padding(
//                     padding: EdgeInsets.only(bottom: deviceHeight * 0.02),
//                     child: Icon(
//                       Icons.camera,
//                       size: deviceHeight * 0.08,
//                       color: colorWhite,
//                     ),
//                   ))),
//         ),
//
//         // Container( //show captured image
//         //   padding: EdgeInsets.all(30),
//         //   child: image == null?
//         //   Text("No image captured"):
//         //   Image.file(File(image.path), height: 300,),
//         //   //display captured image
//         // )
//       ],
//     );
//   }
// }
//
// class UploadReceiptFolder extends StatefulWidget {
//   const UploadReceiptFolder({Key key}) : super(key: key);
//
//   @override
//   State<UploadReceiptFolder> createState() => _UploadReceiptFolderState();
// }
//
// class _UploadReceiptFolderState extends State<UploadReceiptFolder> {
//   File imageFile;
//   Future<File> pickFile() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf'],
//     );
//     if (result == null) return null;
//     return File(result.paths.first ?? '');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//         padding: const EdgeInsets.symmetric(
//             horizontal: HORIZONTAL_PADDING * 2, vertical: VERTICAL_PADDING),
//         child: Container(
//           width: deviceWidth,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Spacer(),
//               Image.asset(
//                 IC_UPLOAD_IMAGE,
//                 height: deviceHeight * 0.15,
//                 width: deviceWidth * 0.2,
//               ),
//               getSmallText(uploadFromFolderOrGallery,
//                   weight: FontWeight.w500,
//                   bold: true,
//                   fontSize: APPBAR_HEADER,
//                   color: colorBlack),
//               SizedBox(
//                 height: deviceHeight * 0.01,
//               ),
//               getSmallText(filetypes,
//                   weight: FontWeight.w400,
//                   bold: true,
//                   fontSize: SUBTITLE_FONT_SIZE,
//                   align: TextAlign.center,
//                   color: colorAccentLight),
//               Spacer(),
//               UploadReceiptWidget(IC_UPLOAD, uploadFromFolder, () async {
//                 String url = '';
//                 final file = await pickFile();
//                 if (file == null) return;
//
//                 if (file.path.split('.').last == "pdf") {
//                   openPdf(context, file, url);
//                 } else {
//                   Future.delayed(Duration.zero, () async {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) {
//                       return UploadGalleryImage(
//                         imageFile: File(file.path),
//                       );
//                     }));
//                   });
//                 }
//               }),
//               SizedBox(
//                 height: deviceHeight * 0.02,
//               ),
//               UploadReceiptWidget(IC_UPLOAD, uploadFromGallery, () {
//                 print("imaged");
//                 _getFromGallery();
//               }),
//               Spacer(
//                 flex: 4,
//               ),
//             ],
//           ),
//         ));
//     // Future.delayed(Duration.zero, () async {
//     //   Navigator.push(context, MaterialPageRoute(builder: (context){
//     //     return UploadGalleryImage(
//     //       imageFile: imageFile,
//     //     );
//     //   }));
//     // });
//   }
//
//   _getFromGallery() async {
//     PickedFile pickedFile = await ImagePicker().getImage(
//       source: ImageSource.gallery,
//       maxWidth: deviceWidth,
//       maxHeight: deviceHeight,
//     );
//     if (pickedFile != null) {
//       setState(() {
//         imageFile = File(pickedFile.path);
//       });
//       Future.delayed(Duration.zero, () async {
//         Navigator.push(context, MaterialPageRoute(builder: (context) {
//           return UploadGalleryImage(
//             imageFile: imageFile,
//           );
//         }));
//       });
//     }
//   }
//
//   void openPdf(BuildContext context, File file, String url) => Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => PdfViewerPage(file, url),
//         ),
//       );
// }
