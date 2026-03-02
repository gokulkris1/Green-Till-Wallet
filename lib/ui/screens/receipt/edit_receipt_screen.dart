import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:greentill/models/responses/getreceiptlist_response.dart';
import 'package:greentill/models/responses/store_list_response.dart';
import 'package:greentill/ui/screens/receipt/warranty_card_detail_screen.dart';
import 'package:intl/intl.dart';

import 'package:currency_picker/currency_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:greentill/utils/strings.dart';
import 'package:image_picker/image_picker.dart';

class EditReceiptScreen extends BaseStatefulWidget {
  final int? receiptid;
  final String? receiptName;
  final String? storeLocation;
  final String? description;
  final String? currency;
  final String? amount;
  final String? purchaseDate;
  final String? url;
  final String? tagType;
  final String? receiptFromType;
  final int? storeid;
  final List<dynamic>? warrantycardslist;

  const EditReceiptScreen(
      {super.key,
      this.receiptid,
      this.receiptName,
      this.storeLocation,
      this.currency,
      this.amount,
      this.description,
      this.purchaseDate,
      this.warrantycardslist,
      this.url,
      this.receiptFromType,
      this.tagType,
      this.storeid});

  @override
  _EditReceiptScreenState createState() => _EditReceiptScreenState();
}

class _EditReceiptScreenState extends BaseState<EditReceiptScreen>
    with BasicScreen {
  String userid = prefs.getString(SharedPrefHelper.USER_ID) ?? "0";
  final formGlobalKey = GlobalKey<FormState>();
  final TextEditingController _storeName = TextEditingController();
  final TextEditingController _storeLocation = TextEditingController();
  final TextEditingController _dateOfPurchase = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _currencyTextController = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  Currency? selectedCurrency;
  final ImagePicker imgpicker = ImagePicker();
  List<XFile> imagefiles = [];
  List<File> files = [];
  List<File> allFiles = [];
  DateTime? pickedDate;
  List<String> displayUrls = [];
  bool isFirst = true;
  final DateFormat formatter = DateFormat('dd MMM yyyy');
  List<DatumStoreList> storeList = [];
  bool isLoadingLocal = true;
  bool isHydratingReceipt = false;
  bool didStartHydration = false;
  String receiptImageUrl = "";
  List<String> _facilityAttended = ["PERSONAL", "BUSINESS"];
  String? _selectfacilityAttended;
  bool isStoreSelected = false;
  String? selectedname;

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

  int? selectedStoreId;

  static String _displayStringForOption(DatumStoreList option) =>
      option.storeName ?? "";

  @override
  Widget buildBody(BuildContext context) {
    if (isFirst) {
      isFirst = false;
      print("widget.tagType");
      print(widget.tagType);
      print(widget.receiptFromType);
      // getAllFiles();
      getDisplayUrls();
      print("_storname");
      print(widget.receiptName);
      receiptImageUrl = widget.url ?? "";
      _storeName.text = widget.receiptName ?? "";
      _storeLocation.text = widget.storeLocation ?? "";
      final purchaseDate = widget.purchaseDate ?? "";
      _dateOfPurchase.text = purchaseDate.isEmpty || purchaseDate == "null"
          ? ""
          : formattedDate(purchaseDate) ?? "";
      _description.text = widget.description ?? "";
      _amount.text = widget.amount ?? "";
      _currencyTextController.text = widget.currency ?? "";
      _selectfacilityAttended = widget.tagType ?? "";
      if ((_selectfacilityAttended ?? "").isEmpty) {
        _selectfacilityAttended = "PERSONAL";
      }
      selectedStoreId = widget.storeid;
      selectedname = widget.receiptName;
      print("selectedstoreid:-");
      print(selectedStoreId);
      print(widget.storeid);

      getStorelist();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startReceiptHydrationIfNeeded();
      });
      // _selectc.text = widget.amount ?? "";
    }
    return isLoadingLocal == true
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
                      horizontal: HORIZONTAL_PADDING,
                      vertical: VERTICAL_PADDING),
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
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      // Spacer(),
                      Container(
                        height: deviceHeight * 0.05,
                        width: deviceWidth * 0.09,
                        margin: EdgeInsets.only(left: 6),
                        child: CachedNetworkImage(
                          imageUrl: receiptImageUrl,
                          errorWidget: (context, url, error) => Center(
                              child: Icon(
                            Icons.error,
                            color: colortheme,
                          )),

                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Center(
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
                      ),

                      Expanded(
                        child: Container(
                            margin: EdgeInsets.only(left: 8),
                            // width: deviceWidth * 0.5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: getTitle(widget.receiptName ?? "",
                                      bold: true,
                                      // isCenter: true,
                                      fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                                      color: colorBlack,
                                      weight: FontWeight.w400,
                                      lines: 1),
                                ),
                                getTitle("Edit Receipt",
                                    bold: true,
                                    // isCenter: true,
                                    fontSize: BUTTON_FONT_SIZE,
                                    color: colorgreytext,
                                    weight: FontWeight.w400,
                                    lines: 1),
                              ],
                            )),
                      )
                      // Container(
                      //   width: deviceWidth * 0.21,
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.end,
                      //     children: [
                      //       GestureDetector(
                      //         onTap: () {
                      //
                      //         },
                      //         child: Image.asset(
                      //           IC_EDIT,
                      //           height: deviceHeight * 0.032,
                      //           width: deviceWidth * 0.065,
                      //           fit: BoxFit.fitHeight,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: Form(
                key: formGlobalKey,
                child: Container(
                  height: deviceHeight,
                  width: deviceWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: HORIZONTAL_PADDING,
                        vertical: VERTICAL_PADDING),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: deviceHeight * 0.03,
                          ),
                          if (isHydratingReceipt)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: gpGreen.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: gpGreen.withOpacity(0.25)),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    height: 14,
                                    width: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: gpGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: getSmallText(
                                      "Fetching OCR details from your receipt...",
                                      color: gpTextSecondary,
                                      fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                                      weight: FontWeight.w600,
                                      lines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          RawAutocomplete(
                            // textEditingController: _storeName,
                            initialValue:
                                TextEditingValue(text: _storeName.text ?? ""),
                            displayStringForOption: _displayStringForOption,
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '' ||
                                  textEditingValue.text.isEmpty) {
                                print("textisempty");
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _storeName.text = "";
                                  if (_storeName.text != (selectedname ?? "")) {
                                    selectedStoreId = null;
                                  }
                                  print("updatedstoreid1");
                                  print(selectedStoreId);
                                });
                                // setState(() {
                                //   _storeName.text = "";
                                //   //if(!isStoreSelected){
                                //     selectedStoreId = null;
                                //
                                //   //}
                                //   // isStoreSelected = false;
                                // });
                                return const Iterable<DatumStoreList>.empty();
                              } else {
                                print("texteditingvalue:-");
                                print(textEditingValue.text);

                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  // setState(() {
                                  _storeName.text = textEditingValue.text;
                                  if (_storeName.text != (selectedname ?? "")) {
                                    selectedStoreId = null;
                                  }
                                  print("updatedstoreid");
                                  print(selectedStoreId);
                                  // isStoreSelected = false;
                                  // });
                                });

                                List<DatumStoreList> matches =
                                    <DatumStoreList>[];
                                matches.addAll(storeList);

                                matches.retainWhere(
                                    (DatumStoreList continent) =>
                                        (continent.storeName ?? "")
                                            .toLowerCase()
                                            .contains(textEditingValue.text
                                                .toLowerCase()));
                                print("mathes");
                                print(matches);
                                return matches;
                              }
                            },
                            onSelected: (DatumStoreList selection) {
                              print('You just selected');
                              print(selection.storeName);
                              print(selection.storeId);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                // setState(() {
                                selectedname = selection.storeName ?? "";
                                _storeName.text = selection.storeName ?? "";
                                selectedStoreId = selection.storeId;
                                isStoreSelected = true;
                                print("selectedstoreid");
                                print(selectedStoreId);
                                // });
                              });
                            },
                            fieldViewBuilder: (BuildContext context,
                                TextEditingController textEditingController,
                                FocusNode focusNode,
                                VoidCallback onFieldSubmitted) {
                              // textEditingController.text =
                              //     widget.receiptName ?? "";
                              return SizedBox(
                                width: deviceWidth * 0.8,
                                child: getCommonTextFormField(
                                  context: context,
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  hintText: "Store name",
                                  validator: (text) {
                                    if ((text?.trim() ?? "").isEmpty) {
                                      return "Please enter store name";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSubmitted: (String value) {},
                                ),
                              );
                            },
                            optionsViewBuilder: (BuildContext context,
                                void Function(DatumStoreList) onSelected,
                                Iterable<DatumStoreList> options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                    child: SizedBox(
                                        height: 52.0 * options.length,
                                        width: deviceWidth * 0.8,
                                        child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: Container(
                                              color: colorWhite,
                                              // height: 100,
                                              child: Column(
                                                children: options.map((opt) {
                                                  return InkWell(
                                                      onTap: () {
                                                        onSelected(opt);
                                                      },
                                                      child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 0),
                                                          child: Card(
                                                              child: Container(
                                                            width:
                                                                double.infinity,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            child: Text(
                                                                opt.storeName ??
                                                                    ""),
                                                          ))));
                                                }).toList(),
                                              ),
                                            )))),
                              );
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          // SizedBox(
                          //   width: deviceWidth * 0.8,
                          //   child: getCommonTextFormField(
                          //       context: context,
                          //       controller: _storeName,
                          //       hintText: storeNameSmall,
                          //       validator: (text) {
                          //         if (text == null || text.isEmpty) {
                          //           return "Please enter store name";
                          //         } else {
                          //           return null;
                          //         }
                          //       }),
                          // ),
                          // const SizedBox(
                          //   height: 15,
                          // ),
                          SizedBox(
                            width: deviceWidth * 0.8,
                            child: getCommonTextFormField(
                              context: context,
                              readOnly: widget.receiptFromType == "QR_SCANNED"
                                  ? true
                                  : false,
                              controller: _storeLocation,
                              hintText: storeLocationSmall,
                              // validator: (text) {
                              //   if (text == null || text.isEmpty) {
                              //     return "Please enter store location";
                              //   } else {
                              //     return null;
                              //   }
                              // }
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            width: deviceWidth * 0.8,
                            child: getCommonTextFormField(
                                context: context,
                                controller: _dateOfPurchase,
                                hintText: dateofpurchaseSmall,
                                readOnly: true,
                                onTap: () async {
                                  if (widget.receiptFromType == "QR_SCANNED") {
                                    return null;
                                  } else {
                                    if (Platform.isIOS) {
                                      await showCupertinoModalPopup(
                                          context: context,
                                          builder: (BuildContext builder) {
                                            return Container(
                                              height: MediaQuery.of(context)
                                                      .copyWith()
                                                      .size
                                                      .height *
                                                  0.25,
                                              color: Colors.white,
                                              child: CupertinoDatePicker(
                                                mode: CupertinoDatePickerMode
                                                    .date,
                                                onDateTimeChanged: (value) {
                                                  setState(() {
                                                    pickedDate = value;
                                                    print(pickedDate);
                                                  });
                                                  print(
                                                      pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                                  final formattedDate =
                                                      DateFormat('yyyy-MM-dd')
                                                          .format(pickedDate ??
                                                              DateTime.now());
                                                  print(
                                                      formattedDate); //formatted date output using intl package =>  2021-03-16
                                                  //you can implement different kind of Date Format here according to your requirement

                                                  setState(() {
                                                    _dateOfPurchase.text =
                                                        formattedDate; //set output date to TextField value.
                                                  });
                                                },
                                                initialDateTime: DateTime.now(),
                                                minimumDate: DateTime(1900),
                                                maximumDate: DateTime.now(),
                                              ),
                                            );
                                          });
                                    } else {
                                      final picked = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now());
                                      if (picked == null) {
                                        return;
                                      }
                                      pickedDate = picked;

                                      print(
                                          pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                      // String formattedDate =
                                      // DateFormat('yyyy-MM-dd').format(pickedDate);
                                      // print(
                                      //     formattedDate); //formatted date output using intl package =>  2021-03-16
                                      //you can implement different kind of Date Format here according to your requirement

                                      setState(() {
                                        _dateOfPurchase.text = formattedDate(
                                            pickedDate
                                                .toString()); //set output date to TextField value.
                                      });
                                    }
                                  }
                                },
                                validator: (text) {
                                  if ((text?.trim() ?? "").isEmpty) {
                                    return "Please enter date of purchase";
                                  } else {
                                    return null;
                                  }
                                }),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            width: deviceWidth * 0.8,
                            child: getCommonTextFormField(
                              context: context,
                              controller: _description,
                              readOnly: true,
                              // widget.receiptFromType == "QR_SCANNED"
                              //     ? true
                              //     : false,
                              hintText: descriptionSmall,
                              // validator: (text) {
                              //   if (text == null || text.isEmpty) {
                              //     return "Please enter description";
                              //   } else {
                              //     return null;
                              //   }
                              // }
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            width: deviceWidth * 0.8,
                            child: getCurrencyTextFormField(
                              readOnly: true,
                              // isCurrencypresent: true,
                              controller: _currencyTextController,
                              validator: (text) {
                                if ((text?.trim() ?? "").isEmpty) {
                                  return "Please select currency";
                                } else {
                                  print("Selected currency is=" + (text ?? ""));
                                  return null;
                                }
                              },
                              onTap: () {
                                // if (widget.receiptFromType == "QR_SCANNED") {
                                //   return null;
                                // } else {
                                showCurrencyPicker(
                                  context: context,
                                  showFlag: true,
                                  showCurrencyName: true,
                                  showCurrencyCode: true,
                                  onSelect: (Currency currency) {
                                    selectedCurrency = currency;
                                    setState(() => _currencyTextController
                                        .text = currency.code);
                                  },
                                );
                                // }
                              },
                              suffixIcon: Image.asset(
                                IC_ARROW_DOWN,
                                width: 20,
                                height: 20,
                              ),
                              context: context,
                              hintText:
                                  "${selectedCurrency?.symbol ?? ""}  ${selectedCurrency?.code ?? ""}",
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            width: deviceWidth * 0.8,
                            child: getCommonTextFormField(
                                context: context,
                                controller: _amount,
                                readOnly: widget.receiptFromType == "QR_SCANNED"
                                    ? true
                                    : false,
                                keyboardType: TextInputType.number,
                                hintText: amount,
                                validator: (text) {
                                  if ((text?.trim() ?? "").isEmpty) {
                                    return "Please enter amount";
                                  } else {
                                    return null;
                                  }
                                }),
                          ),

                          const SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            width: deviceWidth * 0.8,
                            child: DropdownButtonFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                final selected = _selectfacilityAttended ?? "";
                                print("text$selected");
                                if (selected.isEmpty) {
                                  return "Please enter receipt type";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                errorStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: errorRed,
                                          fontSize: CAPTION_TEXT_FONT_SIZE,
                                          fontWeight: FontWeight.w300,
                                        ) ??
                                    const TextStyle(
                                      color: errorRed,
                                      fontSize: CAPTION_TEXT_FONT_SIZE,
                                      fontWeight: FontWeight.w300,
                                    ),
                                floatingLabelAlignment:
                                    FloatingLabelAlignment.start,
                                floatingLabelBehavior:
                                    (_selectfacilityAttended ?? "").isEmpty
                                        ? FloatingLabelBehavior.never
                                        : FloatingLabelBehavior.always,
                                isDense: false,
                                labelText: "Receipt Type",
                                filled: true,
                                fillColor: colorWhite,
                                floatingLabelStyle:
                                    TextStyle(color: colorTextfeild),
                                contentPadding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 20, bottom: 0),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: colorTextfeild, width: 0.4)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: colorTextfeild, width: 0.4)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: colorTextfeild, width: 0.4)),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: errorRed, width: 0.8),
                                ),
                              ),
                              dropdownColor: colorWhite,
                              menuMaxHeight: 250,
                              hint: getSmallText("Receipt Type",
                                  weight: FontWeight.w300,
                                  color: colorTextfeild,
                                  fontSize: 16),
                              isExpanded: false,
                              icon: Image.asset(
                                IC_ARROW_DOWN,
                                width: 20,
                                height: 20,
                              ),
                              style: TextStyle(
                                color: colorAccentLight,
                              ),
                              items: _facilityAttended.map((location) {
                                return DropdownMenuItem(
                                  child: new Text(
                                    location,
                                    style: TextStyle(
                                        fontSize: BODY4_TEXT_FONT_SIZE,
                                        fontWeight: FontWeight.w400,
                                        color: colorBlack,
                                        fontFamily: 'RubikRegular'),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  value: location,
                                );
                              }).toList(),
                              value: _selectfacilityAttended,
                              onChanged: (newValue) {
                                setState(() {
                                  _selectfacilityAttended = newValue as String?;
                                });
                              },
                            ),
                          ),
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                                child: Container(
                                  height: deviceHeight * 0.055,
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
                                                    imageUrl:
                                                        displayUrls[index] ??
                                                            "",
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Center(
                                                                child: Icon(
                                                      Icons.error,
                                                      color: colortheme,
                                                    )),

                                                    progressIndicatorBuilder: (context,
                                                            url,
                                                            downloadProgress) =>
                                                        Center(
                                                            child: SizedBox(
                                                                height: 20,
                                                                width: 20,
                                                                child: CircularProgressIndicator(
                                                                    value: downloadProgress
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
                                                    imageBuilder: (context,
                                                            imageProvider) =>
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color: colorWhite,
                                                          // borderRadius:
                                                          // BorderRadius.circular(100),
                                                          image: DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              fit: BoxFit
                                                                  .scaleDown),
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
                                                      displayUrls
                                                          .removeAt(index);
                                                      // allFiles = [];
                                                      // getAllFiles();
                                                      setState(() {});
                                                    },
                                                    child: Icon(
                                                      Icons.cancel_outlined,
                                                      size: 22,
                                                    )),
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
                                          child: Image.file(
                                            File(imageone.path),
                                            alignment: Alignment.center,
                                            fit: BoxFit.scaleDown,
                                          ),
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
                                          child: Icon(
                                            Icons.cancel_outlined,
                                            size: 22,
                                          )),
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
                            height: deviceHeight * 0.025,
                          ),
                          getButton(Save, () async {
                            print("fileslength" + allFiles.length.toString());
                            await convertToFile();
                            print("allFiles");
                            print(allFiles);
                            print("userid" + userid.toString());
                            print("receiptid" + widget.receiptid.toString());
                            if (formGlobalKey.currentState?.validate() ??
                                false) {
                              print("selectedstoreidbtn");
                              print(selectedStoreId);
                              changeLoadStatus();
                              await getAllFiles();
                              bloc.userRepository
                                  .editReceiptInfo(
                                      int.parse(userid), widget.receiptid ?? 0,
                                      storeName: _storeName.text.trim(),
                                      storeLocation: _storeLocation.text.trim(),
                                      // description: _description.text.trim(),
                                      currency:
                                          _currencyTextController.text.trim(),
                                      amount: _amount.text.trim(),
                                      timeZone: "Asia/Kolkata",
                                      purchaseDate:
                                          pickedDate?.toIso8601String() ?? "",
                                      warrantycards: allFiles,
                                      tagType: _selectfacilityAttended ?? "",
                                      storesId: selectedStoreId ?? 0)
                                  .then((value) {
                                changeLoadStatus();
                                if (value.status == 1) {
                                  print("edit receipt successful");
                                  showMessage(value.message ?? "", () {
                                    setState(() {
                                      // Navigator.pop(context);
                                      // Navigator.pop(context);
                                      Navigator.of(context)
                                          .popUntil(ModalRoute.withName("/"));
                                      bloc.add(HomeScreenEvent());
                                      isShowMessage = false;
                                    });
                                  });
                                } else if (value.apiStatusCode == 401) {
                                  showMessage(value.message ?? "", () {
                                    setState(() {
                                      isShowMessage = false;
                                      logoutaccount();
                                      return bloc.add(Login());
                                    });
                                  });
                                } else {
                                  print("Edit receipt failed ");
                                  print(value.message);
                                  showMessage(value.message ?? "", () {
                                    setState(() {
                                      // bloc.add(WelcomeIn());
                                      isShowMessage = false;
                                      Navigator.pop(context);
                                    });
                                  });
                                }
                              });
                            }
                            // else{
                            //   showMessage("You can only upload 3 warranty cards!", (){
                            //     setState(() {
                            //       isShowMessage = false;
                            //     });
                            //   });
                            // }
                          },
                              width: deviceWidth * 0.8,
                              fontsize: BUTTON_FONT_SIZE),
                          SizedBox(
                            height: deviceHeight * 0.025,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  bool _isEmptyField(dynamic value) {
    final text = (value ?? "").toString().trim();
    return text.isEmpty || text.toLowerCase() == "null";
  }

  bool _needsServerHydration() {
    if ((widget.receiptid ?? 0) <= 0) {
      return false;
    }
    if (!_isEmptyField(widget.receiptName) ||
        !_isEmptyField(widget.amount) ||
        !_isEmptyField(widget.purchaseDate) ||
        !_isEmptyField(widget.currency) ||
        !_isEmptyField(widget.description)) {
      return false;
    }
    return true;
  }

  void _applyReceiptDataFromServer(Datum receipt) {
    final serverStore = (receipt.storeName ?? "").toString();
    final serverLocation = (receipt.storeLocation ?? "").toString();
    final serverDescription = (receipt.description ?? "").toString();
    final serverCurrency = (receipt.currency ?? "").toString();
    final serverAmount = (receipt.amount ?? "").toString();
    final serverTag = (receipt.tagType ?? "").toString().trim().toUpperCase();

    if (_isEmptyField(_storeName.text) && !_isEmptyField(serverStore)) {
      _storeName.text = serverStore;
      selectedname = serverStore;
    }
    if (_isEmptyField(_storeLocation.text) && !_isEmptyField(serverLocation)) {
      _storeLocation.text = serverLocation;
    }
    if (_isEmptyField(_description.text) && !_isEmptyField(serverDescription)) {
      _description.text = serverDescription;
    }
    if (_isEmptyField(_currencyTextController.text) &&
        !_isEmptyField(serverCurrency)) {
      _currencyTextController.text = serverCurrency;
    }
    if (_isEmptyField(_amount.text) && !_isEmptyField(serverAmount)) {
      _amount.text = serverAmount;
    }
    if (_isEmptyField(_dateOfPurchase.text) && receipt.purchaseDate != null) {
      _dateOfPurchase.text =
          formattedDate(receipt.purchaseDate.toString()) ?? "";
    }
    if (receipt.storesId != null && receipt.storesId! > 0) {
      selectedStoreId = receipt.storesId;
    }
    if ((receipt.path ?? "").isNotEmpty) {
      receiptImageUrl = receipt.path ?? "";
    }
    if (displayUrls.isEmpty && (receipt.warrantyCards ?? []).isNotEmpty) {
      displayUrls = receipt.warrantyCards!
          .where((w) => (w.path ?? "").isNotEmpty)
          .map((w) => w.path ?? "")
          .toList();
    }
    if (serverTag == "BUSINESS" || serverTag == "PERSONAL") {
      _selectfacilityAttended = serverTag;
    }
  }

  bool _hasServerExtractedData(Datum receipt) {
    return !_isEmptyField(receipt.storeName) ||
        !_isEmptyField(receipt.amount) ||
        !_isEmptyField(receipt.currency) ||
        receipt.purchaseDate != null;
  }

  Future<void> _startReceiptHydrationIfNeeded() async {
    if (didStartHydration || !_needsServerHydration()) {
      return;
    }
    didStartHydration = true;
    if (!mounted) {
      return;
    }
    setState(() {
      isHydratingReceipt = true;
    });
    const maxAttempts = 4;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final response = await bloc.userRepository.getreceiptList(
        int.tryParse(userid) ?? 0,
        direction: "DESC",
        timezone: DateTime.now().timeZoneName.toString(),
      );
      if (response.status == 1) {
        Datum? serverReceipt;
        for (final receipt in (response.data?.receiptList ?? [])) {
          if (receipt.receiptId == widget.receiptid) {
            serverReceipt = receipt;
            break;
          }
        }
        if (serverReceipt != null) {
          if (mounted) {
            setState(() {
              _applyReceiptDataFromServer(serverReceipt!);
            });
          }
          final serverReady = _hasServerExtractedData(serverReceipt) &&
              !(serverReceipt.inProgress ?? false);
          if (serverReady) {
            break;
          }
        }
      }
      if (attempt < maxAttempts - 1) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      isHydratingReceipt = false;
    });
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
    print(displayUrls);
    print("displayUrls123");
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
    print("files.length121");
    print(files);
  }

  getStorelist() async {
    bloc.userRepository.getstorelist(searchQuery: "").then((value) {
      if (value.status == 1) {
        storeList = value.data ?? [];
        print("storelist =");
        print(value);

        if (mounted)
          setState(() {
            isLoadingLocal = false;
          });
      } else if (value.apiStatusCode == 401) {
        showMessage(value.message ?? "", () {
          setState(() {
            isShowMessage = false;
            isLoadingLocal = false;
            logoutaccount();
            return bloc.add(Login());
          });
        });
      } else {
        print(value.message);
        showMessage(value.message ?? "", () {
          setState(() {
            isShowMessage = false;
            isLoadingLocal = false;
          });
        });
      }
    });
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
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
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
                              margin:
                                  EdgeInsets.only(top: 3, bottom: 3, right: 5),
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
                            File file = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (ctx) => CameraCapture()));
                            print("PATHHHH");
                            print(file.path);
                            setState(() {
                              imagefiles.add(XFile(file.path));
                            });
                            print(imagefiles);
                          },
                          child:
                              uploadReceiptContainer(IC_CAMERASELECT, camera)),
                      SizedBox(
                        height: deviceHeight * 0.012,
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            openImages();
                          },
                          child: uploadReceiptContainer(
                              IC_UPLOAD, uploadfromgallery)),
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
                        if (controller != null &&
                            controller!.value.isInitialized) {
                          //check if controller is initialized
                          image =
                              await controller!.takePicture(); //capture image
                          if (image == null) return;
                          if (!mounted) return;
                          await testCompressAndGetFile(File(image!.path))
                              .then((value) {
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
