import 'package:flutter/material.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;

import 'common_widgets.dart';

class ImageUploadOptionsBottomSheet extends StatelessWidget {
  final ValueChanged<File> onImageSelected;

  const ImageUploadOptionsBottomSheet({
    super.key,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData baseTheme = Theme.of(context);
    //AppLocalizations localizations = AppLocalizations.of(context);

    return Container(
      height: 250,
      child: Column(
        children: <Widget>[
          getCommonBottomSheetTitleView(
            baseTheme: baseTheme,
            context: context,
            title: "Upload",
          ),
          getCommonDivider(),
          Expanded(
            child: Container(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    getIconWithTitleView(baseTheme, IC_GALLERY_OPTION,
                        "Upload From Gallery", onTap: () {
                          getImage(ImageSource.gallery);
                          Navigator.pop(context);
                        }),
                    getIconWithTitleView(baseTheme, IC_CAMERA_OPTION,
                        "Capture Picture Now", onTap: () {
                          getImage(ImageSource.camera);
                          Navigator.pop(context);
                        }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getIconWithTitleView(
      ThemeData baseTheme, String imagePath, String title,
      {GestureTapCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(imagePath),
            Container(
              height: 16,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
                style: const TextStyle(
                    color: colorBlack,
                    fontSize:  SUBTITLE_FONT_SIZE ,
                    fontFamily: 'RubikRegular'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getImage(ImageSource imageSource) async {
    //var image = await ImagePicker.pickImage(source: imageSource);
    final XFile? image =
        await ImagePicker().pickImage(source: imageSource, imageQuality: 20);
    // await ImagePicker().getImage(source: imageSource, imageQuality: 20,maxWidth: 200.0, maxHeight: 300.0);
    if (image != null) {
      onImageSelected(File(image.path));
    }
  }
}
