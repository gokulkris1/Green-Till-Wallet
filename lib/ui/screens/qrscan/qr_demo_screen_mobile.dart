import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/screens/pdfviewer/demo_pdf_viewer.dart';
import 'package:greentill/ui/screens/qrloadedreceipt/demo_qr_loaded_receipt.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrDemoScreen extends StatefulWidget {
  const QrDemoScreen({Key key}) : super(key: key);

  @override
  State<QrDemoScreen> createState() => _QrDemoScreenState();
}

class _QrDemoScreenState extends State<QrDemoScreen> {
  Barcode result;
  bool isQRScreen = false;
  bool isCameraScreen = true;
  bool isGalleryScreen = true;
  File selectedImageFile;

  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
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
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    String updatedurl;
    // var parts = result.code.split('dev/');
    // var prefix = parts[0].trim();
    // var suffix = parts.sublist(1).join('dev/').trim();
    // String addurl =
    //     "https://openxcell-development-public.s3.ap-south-1.amazonaws.com/greentill/development/";
    // print("prefix" + prefix);
    // print("suffix" + suffix);
    // updatedurl = addurl + suffix;
    var parts = result.code.split('co/');
    var prefix = parts[0].trim();
    var suffix = parts.sublist(1).join('co/').trim();
    String addurl = "https://receipts.greentill.co/greentill/production/";
    print("prefix"+prefix);
    print("suffix"+suffix);
    updatedurl = addurl + suffix;
    print("newurl" + updatedurl);
  
    return (updatedurl != null)
        ? updatedurl.contains(".pdf")
        ? DemoPDFViewer(
        url:updatedurl
      //"https://deliver.goshippo.com/ab64256b6f6144dd93dd6800629cf3df.pdf?Expires=1693904867&Signature=e7yi1I4cphHk1WN~0YvdvFxptl8tIcj00up-dYYvoSSgaacnwpMgUU~vVlzOdwEPU6QBSSbECOhJvz7dhaOt39s4mHzUNpj028ql6xHtDVRg1syJD3DuFtuDOXcaqka7nwwlCCWDT2PMX9DOUw~SngDitLEKugUR-jezRSynqNDZgDX-~L-6EiMMth5Lqjs0l12kwHKkgEL2psI6Pz8A7PUQwR7opmi3DyCuQJ5j5w41xUKP9ZZCRqJkeVCUeUX0X-VybDMG1CXUiLKmHkyXIIgsRcLk9a5DiGGb4rQTlsTLPyt56cYr7D0rolhnYlxRp~y7Hce98Gbp0a5a2OBD5g__&Key-Pair-Id=APKAJRICFXQ2S4YUQRSQ",
    )
        : DemoQRLoadedReceipt(
      url: updatedurl,
    ): Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorWhite,
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
