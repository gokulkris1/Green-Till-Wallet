import 'package:flutter/cupertino.dart';
import 'package:greentill/models/common/globals.dart';

const MOBILE_PATTERN = r'^(?:[+0]9)?[0-9]{10}$';
const EMAIL_PATTERN =
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
const ddMMMyyFormat = "dd MMM, yyyy";
// const PASSWORD_PATTERN = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
const PASSWORD_PATTERN = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
// const APP_ID = "";

double deviceHeight = MediaQuery.of(Globals.globalContext).size.height;
double deviceWidth = MediaQuery.of(Globals.globalContext).size.width;
