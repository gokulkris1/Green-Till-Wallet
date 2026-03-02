import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/models/responses/getreceiptlist_response.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/ui/screens/pdfviewer/pdf_viewer.dart';
import 'package:greentill/ui/screens/receipt/edit_receipt_screen.dart';
import 'package:greentill/ui/screens/receipt/receipt_pdf.dart';
import 'package:greentill/ui/screens/receipt/warranty_card_detail_screen.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:greentill/utils/strings.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ReceiptDetailScreen extends BaseStatefulWidget {
  const ReceiptDetailScreen(
      {super.key,
        this.url,
        this.receiptName,
        this.receiptid,
        this.storeLocation,
        this.currency,
        this.amount,
        this.description,
        this.purchaseDate,
        this.warrantycardslist,
        this.isHome = false,
        this.receiptFromType,
        this.tagType,
        this.storeid
      });

  final String? url;
  final String? receiptName;
  final String? storeLocation;
  final String? description;
  final String? currency;
  final String? amount;
  final String? purchaseDate;
  final String? tagType;
  final String? receiptFromType;
  final int? receiptid;
  final int? storeid;
  final List<dynamic>? warrantycardslist;
  final bool isHome;
  @override
  _ReceiptDetailScreenState createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends BaseState<ReceiptDetailScreen> with BasicScreen {
  String userid = prefs.getString(SharedPrefHelper.USER_ID) ?? "0";
  bool loaded = false;
  bool _isShare = false;
  bool _isCrop = false;
  bool _isInfo = false;
  final ImagePicker imgpicker = ImagePicker();
  List<String> displayUrls = [];
  bool isLoading = false;
  openImages() async {
    try {
      var pickedfiles = await imgpicker.pickMultiImage();
      //you can use ImageCourse.camera for Camera capture
      imagefiles.addAll(pickedfiles);
      setState(() {});
        } catch (e) {
      print("error while picking file.");
    }
  }

  bool isFirst = true;
  bool isCropLoading = true;
  http.Response? responseData;
  final _controller = CropController();
  List<XFile> imagefiles = [];
  List<File> files = [];
  List<File> allFiles = [];
  Uint8List? _croppedData;
  set croppedData(Uint8List value) {
    setState(() {
      _croppedData = value;
    });
  }

  @override
  void initState() {


    super.initState();
  }

  parseImage() async {
    final url = widget.url ?? "";
    if (url.isNotEmpty) {
      await http.get(Uri.parse(url)).then((value) {
        responseData = value;
        print("responsedata");
        print(responseData?.bodyBytes);
        if (mounted) {
          setState(() {
            isCropLoading = false;
          });
        }
      });
    } else {
      setState(() {
        isCropLoading = false;
      });
    }
  }

  @override
  Widget buildBody(BuildContext context) {
    if (isFirst) {
      isFirst = false;
      print("purchasedate121");
      print(widget.purchaseDate);
      print(widget.tagType);
      print(widget.receiptFromType);
      parseImage();
      // getAllFiles();
      getDisplayUrls();
    }
    return isCropLoading ?Center(child: CircularProgressIndicator(backgroundColor: Colors.black26,
      valueColor: AlwaysStoppedAnimation<Color>(
        colortheme, //<-- SEE HERE
      ),)) :WillPopScope(
      onWillPop: () async {
        if(widget.isHome){
          Navigator.pop(context);
          bloc.add(HomeScreenEvent());
        }else{
          Navigator.pop(context);
        }
        // Navigator.pop(context);
        //  bloc.add(HomeScreenEvent());
        return false;

      },
      child: Scaffold(
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      child: Image.asset(
                        IC_BACK_ARROW_TWO_COLOR,
                        height: 24,
                        width: 24,
                        fit: BoxFit.fill,
                      ),
                      onTap: () {
                        if(widget.isHome){
                          Navigator.pop(context);
                          bloc.add(HomeScreenEvent());
                        }else{
                          Navigator.pop(context);
                        }

                      },
                    ),
                  ),
                  _isInfo
                      ? Container(
                    height: deviceHeight * 0.05,
                    width: deviceWidth * 0.09,
                    margin: EdgeInsets.only(left: 6),
                    child: CachedNetworkImage(
                      imageUrl: widget.url ?? "",
                      errorWidget: (context, url, error) => Center(child: Icon(Icons.error,color: colortheme,)),

                      progressIndicatorBuilder: (context, url, downloadProgress) =>
                          Center(
                              child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      value: downloadProgress.progress))),
                      // placeholder: (context, url) => Container(
                      //   decoration: BoxDecoration(
                      //     color: colorBackgroundButton,
                      //     borderRadius: BorderRadius.circular(18),
                      //     image: DecorationImage(
                      //         image: AssetImage(IC_PROFILE_IMAGE),
                      //         fit: BoxFit.cover),
                      //   ),
                      // ),
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          //color: colorBackgroundButton,
                          borderRadius: BorderRadius.circular(6),
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  )
                      : SizedBox(),
                  _isInfo
                      ? Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 8),
                      child: getTitle(widget.receiptName ?? "",
                          bold: true,
                          // isCenter: true,
                          fontSize: BUTTON_FONT_SIZE,
                          color: colorBlack,
                          weight: FontWeight.w400,
                          lines: 1),
                    ),
                  )
                      : SizedBox(),
                  _isCrop ?Spacer():SizedBox(),
                  _isCrop
                      ? Center(
                    child: GestureDetector(
                      onTap: () {
                        _controller.crop();
                      },
                      child: Container(
                        height: deviceHeight * 0.03,
                        child: Row(
                          children: [
                            Image.asset(
                              IC_RIGHT,
                              fit: BoxFit.fill,
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            getTitle(
                              Save,
                              weight: FontWeight.w400,
                              color: colorgreytext,
                              fontSize: CAPTION_TEXT_FONT_SIZE,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      : SizedBox(),
                  _isInfo
                      ? Center(
                    child: Container(
                      width: deviceWidth * 0.21,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              print("navigation");
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return EditReceiptScreen(
                                      receiptid: widget.receiptid,
                                      receiptName: widget.receiptName,
                                      description: widget.description,
                                      currency: widget.currency,
                                      storeLocation: widget.storeLocation,
                                      amount: widget.amount,
                                      url: widget.url ?? "",
                                      purchaseDate: widget.purchaseDate,
                                      warrantycardslist: widget.warrantycardslist,
                                      receiptFromType: widget.receiptFromType ?? "",
                                      tagType: widget.tagType ?? "",
                                      storeid: widget.storeid,);
                                  }));
                            },
                            child: Image.asset(
                              IC_EDIT_RECEIPT,
                              height: deviceHeight * 0.025,
                              width: deviceWidth * 0.06,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : SizedBox()
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.zero,
                //padding:  EdgeInsets.only(right: HORIZONTAL_PADDING*2,left:HORIZONTAL_PADDING*2,top: VERTICAL_PADDING*2,bottom:deviceHeight * 0.12, ),
                child: _isInfo
                    ? SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: HORIZONTAL_PADDING,
                        vertical: VERTICAL_PADDING * 2),
                    child: Column(
                      children: [
                        receiptDetailsRow(IC_SHOPICON, storeName,
                            (widget.receiptName ?? "").toString()),
                        SizedBox(
                          height: deviceHeight * 0.025,
                        ),
                        receiptDetailsRow(IC_LOCATION, storeLocation,
                            widget.storeLocation.toString() ?? ""),
                        SizedBox(
                          height: deviceHeight * 0.025,
                        ),
                        receiptDetailsRow(
                            IC_CALENDAR,
                            dateofpurchase,
                            (widget.purchaseDate ?? "").isEmpty ||
                                    widget.purchaseDate == "null"
                                ? ""
                                : formattedDate(widget.purchaseDate.toString()) ??
                                ""),
                        SizedBox(
                          height: deviceHeight * 0.025,
                        ),
                        GestureDetector(
                          onTap: (){
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text(description),
                                content:  Container(
                                  child: SingleChildScrollView(child: Text(widget.description.toString() ?? ""))),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: Container(
                                      // color: Colors.green,
                                      // padding: const EdgeInsets.all(6),
                                      child: Text("OK"),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: receiptDetailsRow(IC_DESCRIPTION, description,
                              widget.description.toString() ?? ""),
                        ),
                        SizedBox(
                          height: deviceHeight * 0.025,
                        ),
                        receiptDetailsRow(
                            IC_WALLET, currency, widget.currency.toString() ?? ""),
                        SizedBox(
                          height: deviceHeight * 0.025,
                        ),
                        receiptDetailsRow(
                            IC_WALLET, amountcapital, widget.amount.toString() ?? ""),
                        SizedBox(
                          height: deviceHeight * 0.025,
                        ),
                        receiptDetailsRow(
                            IC_RECEIPT_TYPE, receiptType, widget.tagType ?? ""),
                        SizedBox(
                          height: deviceHeight * 0.025,
                        ),
                        MySeparator(color: colorseprator),
                        SizedBox(
                          height: deviceHeight * 0.025,
                        ),
                        GestureDetector(
                          onTap: () {
                            addNewWarrantyCard(context);
                          },
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(6),
                            strokeWidth: 1,
                            dashPattern: [8, 4],
                            padding: const EdgeInsets.all(2),
                            color: colorBlack,
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(6)),
                              child: Container(
                                height: deviceHeight * 0.06,
                                width: deviceWidth * 0.6,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline_sharp,
                                      size: 26,
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    getTitle(addWarranty,
                                        color: colorBlack,
                                        weight: FontWeight.w500,
                                        lines: 5,
                                        fontSize: BUTTON_FONT_SIZE),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        displayUrls.length > 0
                            ? Container(
                          height: deviceHeight * 0.12,
                          width: deviceWidth,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              primary: false,
                              itemCount: displayUrls.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: 14.0,
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                          child: Card(
                                            child: Container(
                                              height: deviceHeight * 0.12,
                                              width: deviceWidth * 0.35,
                                              child: CachedNetworkImage(
                                                imageUrl: displayUrls[index]
                                                    ??
                                                    "",
                                                errorWidget: (context, url, error) => Center(child: Icon(Icons.error,color: colortheme,)),

                                                progressIndicatorBuilder: (context, url,
                                                    downloadProgress) =>
                                                    Center(
                                                        child: SizedBox(
                                                            height: 20,
                                                            width: 20,
                                                            child:
                                                            CircularProgressIndicator(
                                                                value:
                                                                downloadProgress
                                                                    .progress))),
                                                // placeholder: (context, url) => Container(
                                                //   decoration: BoxDecoration(
                                                //     color: colorBackgroundButton,
                                                //     borderRadius: BorderRadius.circular(18),
                                                //     image: DecorationImage(
                                                //         image: AssetImage(IC_PROFILE_IMAGE),
                                                //         fit: BoxFit.cover),
                                                //   ),
                                                // ),
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (ctx) =>
                                                                    WarrantyCardDetailScreen(
                                                                        url: displayUrls[
                                                                        index])));
                                                      },
                                                      child: Container(
                                                        // padding: EdgeInsets.symmetric(horizontal: 4),
                                                        decoration: BoxDecoration(
                                                          color: colorWhite,
                                                          // borderRadius:
                                                          // BorderRadius.circular(100),
                                                          image: DecorationImage(
                                                              image: imageProvider,
                                                              alignment: Alignment.center,
                                                              fit: BoxFit.scaleDown),
                                                        ),
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          )),
                                      Positioned(
                                        right: 0,
                                        // bottom: deviceHeight * 0.08,
                                        child: GestureDetector(
                                            onTap: () {
                                              displayUrls.removeAt(index);
                                              // allFiles = [];
                                              // getAllFiles();
                                              setState(() {});
                                            },
                                            child:  Icon(Icons.cancel_outlined,size: 22,)
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        )
                            : SizedBox(),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            children: imagefiles.map((imageone) {
                              return Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (ctx) =>
                                                  WarrantyCardDetailScreen(
                                                      url: imageone.path,
                                                      isFile: true)));
                                    },
                                    child: Container(
                                        child: Card(
                                          child: Container(
                                            height: deviceHeight * 0.12,
                                            width: deviceWidth * 0.35,
                                            child: Center(
                                                child: Image.file(
                                                  File(imageone.path),
                                                  fit: BoxFit.scaleDown,
                                                )),
                                          ),
                                        )),
                                  ),
                                  Positioned(
                                    right: 0,
                                    // bottom: deviceHeight * 0.08,
                                    child: GestureDetector(
                                        onTap: () {
                                          imagefiles.remove(imageone);
                                          setState(() {});
                                        },
                                        child: Icon(Icons.cancel_outlined,size: 22,)
                                    ),
                                  )
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(
                          height: deviceHeight * 0.025,
                        ),
                        MySeparator(color: colorseprator),
                        SizedBox(
                          height: deviceHeight * 0.04,
                        ),
                        getButton(Save, () async {
                          await convertToFile();
                          // print("allFiles");
                          // print(allFiles);
                          changeLoadStatus();
                          await getAllFiles();
                          bloc.userRepository
                              .editReceiptInfo(int.parse(userid), widget.receiptid ?? 0,
                              storeName: (widget.receiptName ?? "").trim(),
                              storeLocation: (widget.storeLocation ?? "").trim(),
                              // description: widget.description.trim(),
                              currency: (widget.currency ?? "").trim(),
                              amount: (widget.amount ?? "").trim(),
                              timeZone: "Asia/Kolkata",
                              purchaseDate: (widget.purchaseDate ?? "").isEmpty ||
                                      widget.purchaseDate == "null"
                                  ? ""
                                  : DateTime.parse(widget.purchaseDate ?? "")
                                  .toIso8601String(),
                              warrantycards: allFiles,
                              storesId: widget.storeid ?? 0)
                              .then((value) {
                            // print("uploadreceiptstatus:-");
                            // print(value.status);
                            changeLoadStatus();
                            if (value.status == 1) {
                              print("edit receipt successful");
                              showMessage(value.message, () {
                                setState(() {
                                  // Navigator.pop(context);

                                  Navigator.of(context)
                                      .popUntil(ModalRoute.withName("/"));
                                  bloc.add(HomeScreenEvent());
                                  isShowMessage = false;
                                });
                              });
                            } else if (value.apiStatusCode == 401) {
                              showMessage(value.message, () {
                                setState(() {
                                  isShowMessage = false;
                                  logoutaccount();
                                  return bloc.add(Login());
                                });
                              });
                            } else {
                              print("Edit receipt failed ");
                              print(value.message);
                              showMessage(value.message, () {
                                setState(() {
                                  // bloc.add(WelcomeIn());
                                  isShowMessage = false;
                                  Navigator.of(context)
                                      .popUntil(ModalRoute.withName("/"));
                                  bloc.add(HomeScreenEvent());
                                });
                              });
                            }
                          });
                        }, width: deviceWidth * 0.8, fontsize: BUTTON_FONT_SIZE),
                        SizedBox(
                          height: deviceHeight * 0.1,
                        ),
                      ],
                    ),
                  ),
                )
                    : _isCrop
                    ? Visibility(
                  visible: _croppedData == null,
                  child: FutureBuilder(
                      future:
                      Future.delayed(Duration(milliseconds: 500), () => true),
                      builder: (context, snapshot) {
                        return Container(
                          margin: EdgeInsets.only(bottom: deviceHeight * 0.11),
                          child: Crop(
                            controller: _controller,
                            image: responseData?.bodyBytes ?? Uint8List(0),
                            onCropped: (cropped) {
                              if (cropped is CropSuccess) {
                                croppedData = cropped.croppedImage;
                              }
                            },
                            cornerDotBuilder: (size, edgeAlignment) =>
                            const DotControl(color: colortheme),
                          ),
                        );
                      }),
                  replacement: Container(
                    alignment: Alignment.topCenter,
                    height: double.infinity,
                    width: double.infinity,
                    padding:
                    EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    child: Image.memory(
                      _croppedData ?? Uint8List(0),
                      fit: BoxFit.contain,
                    ),
                  ),
                )
                    : (widget.url ?? "").contains(".pdf") ?
                ReceiptPDFViewer(
                    url: widget.url ?? "",
                  //"https://deliver.goshippo.com/ab64256b6f6144dd93dd6800629cf3df.pdf?Expires=1693904867&Signature=e7yi1I4cphHk1WN~0YvdvFxptl8tIcj00up-dYYvoSSgaacnwpMgUU~vVlzOdwEPU6QBSSbECOhJvz7dhaOt39s4mHzUNpj028ql6xHtDVRg1syJD3DuFtuDOXcaqka7nwwlCCWDT2PMX9DOUw~SngDitLEKugUR-jezRSynqNDZgDX-~L-6EiMMth5Lqjs0l12kwHKkgEL2psI6Pz8A7PUQwR7opmi3DyCuQJ5j5w41xUKP9ZZCRqJkeVCUeUX0X-VybDMG1CXUiLKmHkyXIIgsRcLk9a5DiGGb4rQTlsTLPyt56cYr7D0rolhnYlxRp~y7Hce98Gbp0a5a2OBD5g__&Key-Pair-Id=APKAJRICFXQ2S4YUQRSQ",
                )
                    :Container(
                  padding: EdgeInsets.all(15),
                  height: deviceHeight,
                  width: deviceWidth,
                  color: colorWhite,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.url ?? "",
                          imageBuilder: (context, imageProvider) => InteractiveViewer(
                            child: SingleChildScrollView(
                              child: Container(
                                height: deviceHeight,
                                width: deviceWidth,
                                margin: EdgeInsets.only(bottom: deviceHeight * 0.10),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.contain,
                                    // colorFilter:
                                    //     ColorFilter.mode(Colors.red, BlendMode.colorBurn),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          placeholder: (context, url) => Center(child: CircularProgressIndicator(backgroundColor: Colors.black26,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colortheme, //<-- SEE HERE
                            ),)),
                          errorWidget: (context, url, error) => Center(child: Icon(Icons.error,color: colortheme,)),
                        ),
                        // SizedBox(height: 10,),
                      ],
                    ),
                  ),
                  // child: Image.network(
                  //   widget.url,
                  //   fit: BoxFit.fill,
                  // ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: const BoxDecoration(
                      color: colorbackgroundcoupons,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                  height: deviceHeight * 0.11,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            _isShare = true;
                            _isCrop = false;
                            _isInfo = false;
                          });
                          final path = await saveReceipt(
                              widget.url ?? "", widget.receiptName ?? "");
                          Share.shareXFiles([XFile(path)]);
                        },
                        child: Container(
                          height: deviceHeight * 0.09,
                          width: deviceWidth * 0.09,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(image: AssetImage(IC_SHARE))),
                        ),
                      ),
                      (widget.url ?? "").contains(".pdf") ?SizedBox():SizedBox(
                        width: deviceWidth * 0.05,
                      ),
                      (widget.url ?? "").contains(".pdf") ? SizedBox():bottomSheetIcon(IC_CROP, () {
                        setState(() {
                          _isCrop = true;
                          _isInfo = false;
                          _isShare = false;
                        });
                      }),
                      SizedBox(
                        width: deviceWidth * 0.05,
                      ),
                      bottomSheetIcon(IC_INFORMATION, () {
                        setState(() {
                          _isInfo = true;
                          _isCrop = false;
                          _isShare = false;
                        });
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getDisplayUrls() async {
    for (var imagefile in (widget.warrantycardslist ?? [])) {
      print(imagefile.path);
      displayUrls.add(imagefile.path);
      // allFiles.add(await urlToFile(imagefile.path));
    }
    setState(() {});
    // print("Allfilesdata");
    // print(allFiles);
  }

  getAllFiles() async {
    for (var imageFile in displayUrls) {
      allFiles.add(await urlToFile(imageFile));
    }
    print("Allfilesdata");
    print(allFiles);
  }

  Future<void> convertToFile() async {
    print(files.length);
    for (var image in imagefiles) {
      final File imagefile = await File(image.path);
      files.add(imagefile);
      allFiles.add(imagefile);
    }
    setState(() {});
    print("files.length");
    print(files);
  }

  Future<String> saveReceipt(String path, String name) async {
    var response = await get(Uri.parse(path));
    File imgFile = await getPath(name,path);
    imgFile.writeAsBytesSync(response.bodyBytes);
    return imgFile.path;
  }

  Future getPath(String name, String url) async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      externalStorageDirPath = (await getTemporaryDirectory()).path;
    } else if (Platform.isIOS) {
      externalStorageDirPath = (await getApplicationDocumentsDirectory()).path;
    }
    String path;
    if (url.contains('pdf')) {
      path = '$externalStorageDirPath/$name.pdf';
    } else {
      path = '$externalStorageDirPath/$name.png';
    }
    File imgFile = new File(path);
    return imgFile;
  }

  Future<void> addNewWarrantyCard(BuildContext context) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        backgroundColor: colorWhite,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStatereceipt) {
                return Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                  height: deviceHeight * 0.3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: HORIZONTAL_PADDING * 1.5,
                        vertical: VERTICAL_PADDING * 1.5),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              getSmallText(addWarranty ?? "",
                                  weight: FontWeight.w500,
                                  bold: true,
                                  fontSize: CAPTION_TEXT_FONT_SIZE,
                                  color: colorBlack),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  margin: EdgeInsets.only(top: 3, bottom: 3, right: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: colorGrey4, width: 1),
                                    // color: Colors.blue,
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: const EdgeInsets.all(5.5),
                                  child: Image.asset(
                                    IC_CROSS,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          getCommonDivider(),
                          SizedBox(
                            height: deviceHeight * 0.012,
                          ),
                          GestureDetector(
                              onTap: () async {
                                Navigator.pop(context);
                                print('on camera');
                                File file = await Navigator.push(context,
                                    MaterialPageRoute(builder: (ctx) => CameraCapture()));
                                print("PATHHHH");
                                print(file.path);
                                setState(() {
                                  imagefiles.add(XFile(file.path));
                                });
                                print(imagefiles);
                              },
                              child: uploadReceiptContainer(IC_CAMERASELECT, camera)),
                          SizedBox(
                            height: deviceHeight * 0.012,
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                openImages();
                              },
                              child: uploadReceiptContainer(IC_UPLOAD, uploadfromgallery)),
                          SizedBox(
                            height: deviceHeight * 0.012,
                          ),
                          // SizedBox(height: deviceHeight*0.1,),
                        ],
                      ),
                    ),
                  ),
                );
              });
        });
  }
}

class CameraCapture extends StatefulWidget {
  const CameraCapture({super.key});

  @override
  State<CameraCapture> createState() => _CameraCaptureState();
}

class _CameraCaptureState extends State<CameraCapture> {
  List<CameraDescription> cameras = []; // list out the camera available
  CameraController? controller; // controller for camera
  XFile? image;

  @override
  void initState() {
    print('initstate');
    loadCamera();
    super.initState();
  }

  Future<void> loadCamera() async {
    cameras = await availableCameras();
    if (cameras.isEmpty) return;
    controller = CameraController(cameras[0], ResolutionPreset.max);
    // cameras[0] = first camera, change to 1 to another camera
    await controller!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Container(
                child: controller == null || !controller!.value.isInitialized
                    ? Center(
                  child: CircularProgressIndicator(),
                )
                    : CameraPreview(controller!)),
          ),
          Positioned.fill(
            child: Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                    onTap: () async {
                      try {
                        //check if controller is not null
                        if (controller != null && controller!.value.isInitialized) {
                          //check if controller is initialized
                          image = await controller!.takePicture(); //capture image
                          if (image == null) return;
                          if (!mounted) return;
                          await testCompressAndGetFile(File(image!.path)).then((value) {
                            Navigator.pop(context, value);
                          });
                        }
                                            } catch (e) {
                        print(e.toString()); //show error
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(bottom: deviceHeight * 0.02),
                      child: Icon(
                        Icons.camera,
                        size: deviceHeight * 0.08,
                        color: colorWhite,
                      ),
                    ))),
          ),
        ],
      ),
    );
  }

  Future<File> testCompressAndGetFile(File file) async {
    String filePath = file.absolute.path;

    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    print('testCompressAndGetFile');
    print(filePath);
    print(outPath);
    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: Platform.isIOS ? 60 : 70,
      minHeight: deviceHeight.toInt(),
      minWidth: deviceWidth.toInt(),

      format: Platform.isIOS ? CompressFormat.png : CompressFormat.jpeg,
      // minWidth: 1024,
      // minHeight: 1024,
      rotate: 0,
    );
    final compressedFile = result != null ? File(result.path) : file;
    print(compressedFile);
    print("file.lengthSync()");
    print(file.lengthSync());
    print(compressedFile.lengthSync());
    return compressedFile;
  }
}
