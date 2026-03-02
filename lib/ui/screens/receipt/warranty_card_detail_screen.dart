import 'dart:io';

import 'package:flutter/material.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';

import '../../../base/base_screen.dart';

class WarrantyCardDetailScreen extends BaseStatefulWidget {
  final String? url;
  final bool isFile;

  const WarrantyCardDetailScreen({super.key, this.url, this.isFile = false});

  @override
  _WarrantyCardDetailScreenState createState() => _WarrantyCardDetailScreenState();
}

class _WarrantyCardDetailScreenState extends BaseState<WarrantyCardDetailScreen>
    with BasicScreen {
  @override
  Widget buildBody(BuildContext context) {
    return Scaffold(
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
            child: GestureDetector(
              child: Image.asset(
                IC_BACK_ARROW_TWO_COLOR,
                height: 24,
                width: 24,
                alignment: Alignment.centerLeft,
                // fit: BoxFit.fill,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: InteractiveViewer(
          child: widget.isFile
              ? Image.file(
                  File(widget.url ?? ""),
                  fit: BoxFit.contain,
                )
              : Image.network(
                  widget.url ?? "",
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}
