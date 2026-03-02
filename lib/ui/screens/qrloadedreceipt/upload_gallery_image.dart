import 'dart:io';

import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/shared_pref_helper.dart';

import '../receipt/feedback_receipt_screen.dart';

class UploadGalleryImage extends BaseStatefulWidget {
  const UploadGalleryImage(
      {super.key, this.imageFile, this.isGallery = false, this.receiptType});

  final File? imageFile;
  final bool isGallery;
  final String? receiptType;

  @override
  _UploadGalleryImageState createState() => _UploadGalleryImageState();
}

class _UploadGalleryImageState extends BaseState<UploadGalleryImage>
    with BasicScreen {
  bool loaded = false;
  bool _isUploading = false;
  String userid = prefs.getString(SharedPrefHelper.USER_ID) ?? "0";
  String _selectedReceiptType = "BUSINESS";

  Future<void> _updateReceiptTagType(int receiptId) async {
    if (receiptId <= 0) {
      return;
    }
    await bloc.userRepository.editReceiptInfo(
      int.parse(userid),
      receiptId,
      tagType: _selectedReceiptType,
      timeZone: DateTime.now().timeZoneName.toString(),
    );
  }

  bool _isTransientUploadFailure(String? message) {
    final text = (message ?? "").toLowerCase();
    return text.contains("time out") ||
        text.contains("timeout") ||
        text.contains("socket") ||
        text.contains("internet");
  }

  Future<void> _submitUpload() async {
    if (_isUploading) {
      return;
    }
    File? imageFile = widget.imageFile;
    if (imageFile != null) {
      imageFile = await convertHEIC2PNG(imageFile.path);
    }
    if (imageFile == null) {
      showMessage("Could not read receipt image. Please try again.", () {
        if (mounted) {
          setState(() {
            isShowMessage = false;
          });
        }
      });
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _isUploading = true;
    });

    changeLoadStatus();
    try {
      var value = await bloc.userRepository.uploadgalleryornative(
        userid: int.parse(userid),
        profilePhoto: imageFile,
        receipttype: widget.receiptType ?? "GALLERY",
      );
      if (value.status != 1 && _isTransientUploadFailure(value.message)) {
        value = await bloc.userRepository.uploadgalleryornative(
          userid: int.parse(userid),
          profilePhoto: imageFile,
          receipttype: widget.receiptType ?? "GALLERY",
        );
      }

      if (!mounted) {
        return;
      }

      if (value.status == 1) {
        final receiptId = value.data ?? 0;
        if (receiptId <= 0) {
          showMessage(
              "Receipt upload completed but ID was missing. Please refresh receipts list.",
              () {
            if (mounted) {
              setState(() {
                isShowMessage = false;
                bloc.add(ReceiptEvent());
              });
            }
          });
          return;
        }
        await _updateReceiptTagType(receiptId);
        if (!mounted) {
          return;
        }
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return FeedbackReceiptScreen(
            userid: int.parse(userid),
            receiptid: receiptId,
            message: value.message ?? "",
            imagefrom: "INAPP",
            initialTagType: _selectedReceiptType,
          );
        }));
      } else if (value.apiStatusCode == 401) {
        showMessage(value.message ?? "", () {
          if (mounted) {
            setState(() {
              isShowMessage = false;
              logoutaccount();
              bloc.add(Login());
            });
          }
        });
      } else if (value.apiStatusCode == 500) {
        showMessage("Upload receipt failed", () {
          if (mounted) {
            setState(() {
              isShowMessage = false;
            });
          }
        });
      } else {
        showMessage(value.message ?? "Upload receipt failed", () {
          if (mounted) {
            setState(() {
              isShowMessage = false;
            });
          }
        });
      }
    } finally {
      changeLoadStatus();
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget buildBody(BuildContext context) {
    print(widget.imageFile?.path);
    print(widget.imageFile?.lengthSync());
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
                    if (widget.isGallery) {
                      Navigator.pop(context);
                      // bloc.add(QrCodeEvent());
                      return bloc.add(ReceiptEvent());
                    } else {
                      Navigator.pop(context);
                      // Navigator.pop(context);
                      // bloc.add(QrCodeEvent());
                      return bloc.add(ReceiptEvent());
                    }
                  },
                ),
                SizedBox(
                  width: deviceWidth * 0.025,
                ),
                Spacer(),
                IconButton(
                  onPressed: _isUploading ? null : _submitUpload,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: gpGreen,
                          ),
                        )
                      : const Icon(
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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(15),
            // height: deviceHeight,
            width: deviceWidth,
            color: colorWhite,
            child: Column(
              children: [
                Container(
                  width: deviceWidth,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: gpLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: gpBorder),
                  ),
                  child: Row(
                    children: [
                      getSmallText(
                        "Receipt Type",
                        color: gpTextSecondary,
                        weight: FontWeight.w600,
                        fontSize: CAPTION_TEXT_FONT_SIZE,
                      ),
                      const Spacer(),
                      ChoiceChip(
                        selected: _selectedReceiptType == "BUSINESS",
                        label: const Text("Business"),
                        onSelected: (_) {
                          setState(() {
                            _selectedReceiptType = "BUSINESS";
                          });
                        },
                        selectedColor: gpGreen.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _selectedReceiptType == "BUSINESS"
                              ? gpDark
                              : gpTextSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        selected: _selectedReceiptType == "PERSONAL",
                        label: const Text("Personal"),
                        onSelected: (_) {
                          setState(() {
                            _selectedReceiptType = "PERSONAL";
                          });
                        },
                        selectedColor: gpInfo.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _selectedReceiptType == "PERSONAL"
                              ? gpDark
                              : gpTextSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: deviceWidth,
                  child: Image.file(
                    widget.imageFile ?? File(""),
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
