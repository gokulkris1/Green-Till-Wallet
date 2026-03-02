import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/models/responses/getreceiptlist_response.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/ui/screens/qrloadedreceipt/upload_gallery_image.dart';
import 'package:greentill/ui/screens/qrscan/qr_code_screen.dart';
import 'package:greentill/ui/screens/receipt/receipt_detail_screen.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:greentill/utils/strings.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class ReceiptScreen extends BaseStatefulWidget {
  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends BaseState<ReceiptScreen> with BasicScreen {
  String userid = prefs.getString(SharedPrefHelper.USER_ID) ?? "0";
  bool isSearch = false;
  bool isSelected = false;
  bool isFirst = true;
  bool isLoadingLocal = true;
  List<Datum> receiptlist = [];
  List<String> getinitialword = [];
  List<Datum> selectedReceipts = [];
  List<int> selectedReceiptsIds = [];
  List<String> downloadedReceipts = [];
  bool isSearchloading = false;
  String listorder = "DESC";
  String receiptypeorder = "";
  int selectedYear = DateTime.now().year;
  var now = DateTime.now();
  int currentMonth = DateTime.now().month;
  String selectedMonth = DateFormat('MMM').format(DateTime.now());
  SfRangeValues _values = const SfRangeValues(1, 31);
  int selectedMonthIndex = DateTime.now().month;
  int maxDaysInMonth = 31;
  bool isFiltered = false;
  bool isDateFilterApplied = false;
  String startingDate = DateTime.now().toIso8601String();
  String endingDate = DateTime.now().toIso8601String();
  int minDaysInMonth = 1;
  TextEditingController searchcontroller = TextEditingController();
  List months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'June',
    'July',
    'Aug',
    'Sept',
    'Oct',
    'Nov',
    'Dec',
  ];
  final ReceivePort _port = ReceivePort();
  var _status;
  final DateFormat formatter = DateFormat('dd MMM yyyy');
  bool isShare = false;
  File? imageFile;
  bool isScaned = false;
  final _debouncer = Debouncer(milliseconds: 1000);
  FocusNode? searchFocusNode;
  String currency = "";
  final TextEditingController _startDate = TextEditingController();
  final TextEditingController _endDate = TextEditingController();
  DateTime StartDatecalendar = DateTime.now();
  DateTime EndDatecalendar = DateTime.now();
  int receiptCount = 0;

  double _parseAmount(dynamic value) {
    if (value == null) {
      return 0;
    }
    final text = value.toString().replaceAll(RegExp(r"[^0-9.\\-]"), "");
    return double.tryParse(text) ?? 0;
  }

  double get _totalSpend {
    return receiptlist.fold<double>(0, (sum, item) {
      return sum + _parseAmount(item.amount);
    });
  }

  double get _businessSpend {
    return receiptlist
        .where((item) => (item.tagType ?? "").toUpperCase() == "BUSINESS")
        .fold<double>(0, (sum, item) => sum + _parseAmount(item.amount));
  }

  double get _personalSpend {
    return receiptlist
        .where((item) => (item.tagType ?? "").toUpperCase() != "BUSINESS")
        .fold<double>(0, (sum, item) => sum + _parseAmount(item.amount));
  }

  int get _inProgressCount {
    return receiptlist.where((item) => item.inProgress == true).length;
  }

  Widget _receiptStatCard(
    String title,
    String value, {
    Color valueColor = gpTextPrimary,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: gpBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getSmallText(
            title,
            color: gpTextSecondary,
            fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
            weight: FontWeight.w600,
            lines: 1,
          ),
          const SizedBox(height: 6),
          getSmallText(
            value,
            color: valueColor,
            fontSize: CAPTION_TEXT_FONT_SIZE,
            weight: FontWeight.w700,
            lines: 1,
          ),
        ],
      ),
    );
  }

  _onSearchChanged(String value) {
    // if (_debounce?.isActive ?? false) _debounce.cancel();
    // _debounce = Timer(const Duration(seconds: 1), () {
    if (searchcontroller.text.isEmpty) {
      if (isDateFilterApplied) {
        print("query" + value.toString());
        setState(() {
          isSearchloading = true;
        });

        bloc.userRepository
            .getreceiptList(int.parse(userid),
                startdate: StartDatecalendar.toIso8601String(),
                enddate: EndDatecalendar.toIso8601String(),
                timezone: DateTime.now().timeZoneName.toString(),
                direction: listorder,
                query: value.trim().toString(),
                tagType: receiptypeorder)
            .then((value) {
          setState(() {
            isSearchloading = false;
          });

          if (value.status == 1) {
            receiptlist = value.data?.receiptList ?? [];
            receiptCount = value.data?.receiptCount ?? 0;
            print("receiptlist =");
            print(value);
            // showMessage(value.message ?? "", () {
            //   if (mounted)
            //     setState(() {
            //       // bloc.add(WelcomeIn());
            //       isShowMessage = false;
            //       bloc.add(ReceiptEvent());
            //     });
            // });
            // if (mounted)
            //   setState(() {
            //     isLoadingLocal = false;
            //   });
            print("filter receipt successful");
            // getreceiptlist();
            // showMessage(value.message ?? "", () {
            //   setState(() {
            //     //bloc.add(HomeScreenEvent());
            //     isShowMessage = false;
            //   });
            // });
          } else if (value.apiStatusCode == 401) {
            showMessage(value.message ?? "", () {
              if (mounted)
                setState(() {
                  isShowMessage = false;
                  logoutaccount();
                  return bloc.add(Login());
                });
            });
          } else {
            print("filter receipt failed ");
            print(value.message);
            showMessage(value.message ?? "", () {
              if (mounted)
                setState(() {
                  // bloc.add(WelcomeIn());
                  isShowMessage = false;
                  bloc.add(ReceiptEvent());
                });
            });
          }
        });
      } else {
        print("timezone" + DateTime.now().timeZoneName.toString());
        print("query" + value.toString());
        setState(() {
          isSearchloading = true;
        });

        bloc.userRepository
            .getreceiptList(int.parse(userid),
                // startdate: startingDate,
                // enddate: endingDate,
                // timezone: DateTime.now()
                //     .timeZoneName
                //     .toString(),
                direction: listorder,
                query: value.trim().toString(),
                tagType: receiptypeorder)
            .then((value) {
          setState(() {
            isSearchloading = false;
          });

          if (value.status == 1) {
            receiptlist = value.data?.receiptList ?? [];
            receiptCount = value.data?.receiptCount ?? 0;
            print("receiptlist =");
            print(value);
            // showMessage(value.message ?? "", () {
            //   if (mounted)
            //     setState(() {
            //       // bloc.add(WelcomeIn());
            //       isShowMessage = false;
            //       bloc.add(ReceiptEvent());
            //     });
            // });
            // if (mounted)
            //   setState(() {
            //     isLoadingLocal = false;
            //   });
            print("filter receipt successful");
            // getreceiptlist();
            // showMessage(value.message ?? "", () {
            //   setState(() {
            //     //bloc.add(HomeScreenEvent());
            //     isShowMessage = false;
            //   });
            // });
          } else if (value.apiStatusCode == 401) {
            showMessage(value.message ?? "", () {
              if (mounted)
                setState(() {
                  isShowMessage = false;
                  logoutaccount();
                  return bloc.add(Login());
                });
            });
          } else {
            print("filter receipt failed ");
            print(value.message);
            showMessage(value.message ?? "", () {
              if (mounted)
                setState(() {
                  // bloc.add(WelcomeIn());
                  isShowMessage = false;
                  bloc.add(ReceiptEvent());
                });
            });
          }
        });
      }
    } else {
      if (isDateFilterApplied) {
        print("query" + value.toString());
        setState(() {
          isSearchloading = true;
        });

        bloc.userRepository
            .getreceiptList(int.parse(userid),
                startdate: StartDatecalendar.toIso8601String(),
                enddate: EndDatecalendar.toIso8601String(),
                timezone: DateTime.now().timeZoneName.toString(),
                direction: listorder,
                query: value.trim().toString(),
                tagType: receiptypeorder)
            .then((value) {
          setState(() {
            isSearchloading = false;
          });

          if (value.status == 1) {
            receiptlist = value.data?.receiptList ?? [];
            receiptCount = value.data?.receiptCount ?? 0;
            print("receiptlist =");
            print(value);
            // showMessage(value.message ?? "", () {
            //   if (mounted)
            //     setState(() {
            //       // bloc.add(WelcomeIn());
            //       isShowMessage = false;
            //       bloc.add(ReceiptEvent());
            //     });
            // });
            // if (mounted)
            //   setState(() {
            //     isLoadingLocal = false;
            //   });
            print("filter receipt successful");
            // getreceiptlist();
            // showMessage(value.message ?? "", () {
            //   setState(() {
            //     //bloc.add(HomeScreenEvent());
            //     isShowMessage = false;
            //   });
            // });
          } else if (value.apiStatusCode == 401) {
            showMessage(value.message ?? "", () {
              if (mounted)
                setState(() {
                  isShowMessage = false;
                  logoutaccount();
                  return bloc.add(Login());
                });
            });
          } else {
            print("filter receipt failed ");
            print(value.message);
            showMessage(value.message ?? "", () {
              if (mounted)
                setState(() {
                  // bloc.add(WelcomeIn());
                  isShowMessage = false;
                  bloc.add(ReceiptEvent());
                });
            });
          }
        });
      } else {
        print("timezone" + DateTime.now().timeZoneName.toString());
        print("query" + value.toString());
        setState(() {
          isSearchloading = true;
        });

        bloc.userRepository
            .getreceiptList(int.parse(userid),
                // startdate: startingDate,
                // enddate: endingDate,
                // timezone: DateTime.now()
                //     .timeZoneName
                //     .toString(),
                direction: listorder,
                query: value.trim().toString(),
                tagType: receiptypeorder)
            .then((value) {
          setState(() {
            isSearchloading = false;
          });

          if (value.status == 1) {
            receiptlist = value.data?.receiptList ?? [];
            receiptCount = value.data?.receiptCount ?? 0;
            print("receiptlist =");
            print(value);
            // showMessage(value.message ?? "", () {
            //   if (mounted)
            //     setState(() {
            //       // bloc.add(WelcomeIn());
            //       isShowMessage = false;
            //       bloc.add(ReceiptEvent());
            //     });
            // });
            // if (mounted)
            //   setState(() {
            //     isLoadingLocal = false;
            //   });
            print("filter receipt successful");
            // getreceiptlist();
            // showMessage(value.message ?? "", () {
            //   setState(() {
            //     //bloc.add(HomeScreenEvent());
            //     isShowMessage = false;
            //   });
            // });
          } else if (value.apiStatusCode == 401) {
            showMessage(value.message ?? "", () {
              if (mounted)
                setState(() {
                  isShowMessage = false;
                  logoutaccount();
                  return bloc.add(Login());
                });
            });
          } else {
            print("filter receipt failed ");
            print(value.message);
            showMessage(value.message ?? "", () {
              if (mounted)
                setState(() {
                  // bloc.add(WelcomeIn());
                  isShowMessage = false;
                  bloc.add(ReceiptEvent());
                });
            });
          }
        });
      }
    }

    // });
  }

  @override
  void initState() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      _status = data[1];
      int progress = data[2];
      setState(() {});
    });
    FlutterDownloader.registerCallback(downloadCallback);
    // TODO: implement initState

    currentMonth = now.month;
    selectedMonth = months[currentMonth - 1];
    _values = SfRangeValues(DateTime(selectedYear, currentMonth, 05),
        DateTime(selectedYear, currentMonth, 25));
    maxDaysInMonth = DateUtils.getDaysInMonth(selectedYear, currentMonth);
    DateTime start = DateTime.parse(_values.start.toString());
    DateTime end = DateTime.parse(_values.end.toString());
    startingDate = start.toIso8601String().toString();
    endingDate = end.toIso8601String().toString();
    _startDate.text = formattedDate(DateTime.now().toString());
    _endDate.text = formattedDate(DateTime.now().toString());
    searchFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    searchcontroller.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    if (isFirst) {
      isFirst = false;
      getreceiptlist();
    }
    return isLoadingLocal == true
        ? loader()
        : WillPopScope(
            onWillPop: () async {
              if (isSelected || isSearch) {
                setState(() {
                  isSelected = false;
                  isSearch = false;
                  selectedReceipts = [];
                  selectedReceiptsIds = [];
                  searchcontroller.clear();
                  getreceiptlist();
                });
                print(selectedReceipts);
                return false;
              } else {
                bloc.add(HomeScreenEvent());
                return false;
              }
            },
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: gpLight,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(deviceHeight * 0.07),
                child: Container(
                  height: deviceHeight * 0.07,
                  width: deviceWidth,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15)),
                    color: gpLight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: HORIZONTAL_PADDING,
                        vertical: VERTICAL_PADDING),
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
                            if (isSelected || isSearch) {
                              setState(() {
                                isSelected = false;
                                isSearch = false;
                                selectedReceipts = [];
                                selectedReceiptsIds = [];
                                searchcontroller.clear();
                                getreceiptlist();
                              });
                            } else {
                              return bloc.add(HomeScreenEvent());
                            }

                            // return bloc.add(SideMenu());
                          },
                        ),
                        SizedBox(
                          width: deviceWidth * 0.025,
                        ),
                        appBarHeader(
                          isSearch ? search : receipt,
                          fontSize: BUTTON_FONT_SIZE,
                          bold: false,
                        ),
                        Spacer(),
                        Container(
                          width: deviceWidth * 0.21,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              isSearch
                                  ? SizedBox()
                                  : GestureDetector(
                                      child: Image.asset(
                                        IC_SEARCH,
                                        height: deviceHeight * 0.032,
                                        width: deviceWidth * 0.065,
                                        fit: BoxFit.fitHeight,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          isSearch = true;
                                          searchFocusNode?.requestFocus();
                                        });
                                      },
                                    ),
                              GestureDetector(
                                onTap: () {
                                  receiptFilter(
                                      context, DateTime.now(), DateTime.now());
                                  //receiptFilter(context);
                                  // selectedrecieptBottomSheet(context,(){},(){},(){
                                  //    logoutBottomSheet(context,confirmLogout,(){Navigator.pop(context);},(){});
                                  // });
                                },
                                child: Image.asset(
                                  IC_FILTER,
                                  height: deviceHeight * 0.032,
                                  width: deviceWidth * 0.065,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              body: SafeArea(
                child: Stack(
                  children: [
                    RefreshIndicator(
                      color: gpGreen,
                      onRefresh: () {
                        print("pulltorefresh");
                        return getreceiptlist();
                      },
                      child: Container(
                        height: deviceHeight,
                        width: deviceWidth,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            isSearch
                                ? Container(
                                    height: deviceHeight * 0.12,
                                    width: deviceWidth,
                                    decoration: BoxDecoration(
                                      color: gpLight,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            blurRadius: 10.0,
                                            offset: Offset(0.0, 0.05))
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: HORIZONTAL_PADDING,
                                      ),
                                      child: Column(
                                        children: [
                                          Spacer(),
                                          Container(
                                            height: deviceHeight * 0.06,
                                            width: deviceWidth,
                                            decoration: BoxDecoration(
                                              color: gpLight,
                                              border:
                                                  Border.all(color: gpBorder),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                            ),
                                            child: TextField(
                                              focusNode: searchFocusNode,
                                              controller: searchcontroller,
                                              style: TextStyle(
                                                color: gpTextPrimary,
                                              ),
                                              onChanged: (value) {
                                                // print("query" + value.toString());
                                                // searchcontroller.text =
                                                //     value.toString();
                                                // print("is filter" +
                                                //     isFiltered.toString());
                                                // if (value.toString().isEmpty) getreceiptlist();
                                                _debouncer.run(() {
                                                  _onSearchChanged(
                                                      searchcontroller.text
                                                          .trim());
                                                });
                                                // if (isFiltered == true) {
                                                //   if (userid != null) {
                                                //     print("query" +
                                                //         value.toString());
                                                //     setState(() {
                                                //       isSearchloading = true;
                                                //     });
                                                //
                                                //     bloc.userRepository
                                                //         .getreceiptList(
                                                //             int.parse(userid),
                                                //             startdate:
                                                //                 startingDate,
                                                //             enddate: endingDate,
                                                //             timezone:
                                                //                 DateTime.now()
                                                //                     .timeZoneName
                                                //                     .toString(),
                                                //             direction: listorder,
                                                //             query: value
                                                //                 .trim()
                                                //                 .toString())
                                                //         .then((value) {
                                                //       setState(() {
                                                //         isSearchloading = false;
                                                //       });
                                                //
                                                //       if (value.status == 1) {
                                                //         receiptlist = value.data;
                                                //         print("receiptlist =");
                                                //         print(value);
                                                //         // showMessage(value.message ?? "", () {
                                                //         //   if (mounted)
                                                //         //     setState(() {
                                                //         //       // bloc.add(WelcomeIn());
                                                //         //       isShowMessage = false;
                                                //         //       bloc.add(ReceiptEvent());
                                                //         //     });
                                                //         // });
                                                //         // if (mounted)
                                                //         //   setState(() {
                                                //         //     isLoadingLocal = false;
                                                //         //   });
                                                //         print(
                                                //             "filter receipt successful");
                                                //         // getreceiptlist();
                                                //         // showMessage(value.message ?? "", () {
                                                //         //   setState(() {
                                                //         //     //bloc.add(HomeScreenEvent());
                                                //         //     isShowMessage = false;
                                                //         //   });
                                                //         // });
                                                //       } else if (value
                                                //               .apiStatusCode ==
                                                //           401) {
                                                //         showMessage(value.message ?? "",
                                                //             () {
                                                //           if (mounted)
                                                //             setState(() {
                                                //               isShowMessage =
                                                //                   false;
                                                //               logoutaccount();
                                                //               return bloc
                                                //                   .add(Login());
                                                //             });
                                                //         });
                                                //       } else {
                                                //         print(
                                                //             "filter receipt failed ");
                                                //         print(value.message);
                                                //         showMessage(value.message ?? "",
                                                //             () {
                                                //           if (mounted)
                                                //             setState(() {
                                                //               // bloc.add(WelcomeIn());
                                                //               isShowMessage =
                                                //                   false;
                                                //               bloc.add(
                                                //                   ReceiptEvent());
                                                //             });
                                                //         });
                                                //       }
                                                //     });
                                                //   }
                                                // } else {
                                                //   if (userid != null) {
                                                //     print("timezone" +
                                                //         DateTime.now()
                                                //             .timeZoneName
                                                //             .toString());
                                                //     print("query" +
                                                //         value.toString());
                                                //     setState(() {
                                                //       isSearchloading = true;
                                                //     });
                                                //
                                                //     bloc.userRepository
                                                //         .getreceiptList(
                                                //             int.parse(userid),
                                                //             // startdate: startingDate,
                                                //             // enddate: endingDate,
                                                //             // timezone: DateTime.now()
                                                //             //     .timeZoneName
                                                //             //     .toString(),
                                                //             direction: listorder,
                                                //             query: value
                                                //                 .trim()
                                                //                 .toString())
                                                //         .then((value) {
                                                //       setState(() {
                                                //         isSearchloading = false;
                                                //       });
                                                //
                                                //       if (value.status == 1) {
                                                //         receiptlist = value.data;
                                                //         print("receiptlist =");
                                                //         print(value);
                                                //         // showMessage(value.message ?? "", () {
                                                //         //   if (mounted)
                                                //         //     setState(() {
                                                //         //       // bloc.add(WelcomeIn());
                                                //         //       isShowMessage = false;
                                                //         //       bloc.add(ReceiptEvent());
                                                //         //     });
                                                //         // });
                                                //         // if (mounted)
                                                //         //   setState(() {
                                                //         //     isLoadingLocal = false;
                                                //         //   });
                                                //         print(
                                                //             "filter receipt successful");
                                                //         // getreceiptlist();
                                                //         // showMessage(value.message ?? "", () {
                                                //         //   setState(() {
                                                //         //     //bloc.add(HomeScreenEvent());
                                                //         //     isShowMessage = false;
                                                //         //   });
                                                //         // });
                                                //       } else if (value
                                                //               .apiStatusCode ==
                                                //           401) {
                                                //         showMessage(value.message ?? "",
                                                //             () {
                                                //           if (mounted)
                                                //             setState(() {
                                                //               isShowMessage =
                                                //                   false;
                                                //               logoutaccount();
                                                //               return bloc
                                                //                   .add(Login());
                                                //             });
                                                //         });
                                                //       } else {
                                                //         print(
                                                //             "filter receipt failed ");
                                                //         print(value.message);
                                                //         showMessage(value.message ?? "",
                                                //             () {
                                                //           if (mounted)
                                                //             setState(() {
                                                //               // bloc.add(WelcomeIn());
                                                //               isShowMessage =
                                                //                   false;
                                                //               bloc.add(
                                                //                   ReceiptEvent());
                                                //             });
                                                //         });
                                                //       }
                                                //     });
                                                //   }
                                                // }
                                              },
                                              decoration: InputDecoration(
                                                prefixIcon: Image.asset(
                                                  IC_SEARCH,
                                                  height: 10,
                                                  width: 10,
                                                ),
                                                hintStyle: TextStyle(
                                                  color: gpTextMuted,
                                                ),
                                                // suffixIcon: GestureDetector(
                                                //   onTap: (){
                                                //     setState(() {
                                                //       searchcontroller.clear();
                                                //     });
                                                //
                                                //   },
                                                //   child: Image.asset(
                                                //     IC_CROSS,
                                                //     height: 10,
                                                //     width: 10,
                                                //   ),
                                                // ),
                                                hintText: "Search",
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                          // SizedBox(
                                          //   height: 12,
                                          // ),
                                          // Container(
                                          //   height: deviceHeight * 0.04,
                                          //   width: deviceWidth,
                                          //   child: ListView.builder(
                                          //       padding: EdgeInsets.zero,
                                          //       scrollDirection: Axis.horizontal,
                                          //       shrinkWrap: true,
                                          //       primary: false,
                                          //       itemCount: 8,
                                          //       itemBuilder: (context, index) {
                                          //         return Padding(
                                          //           padding: const EdgeInsets.only(
                                          //               right: 8.0, left: 6),
                                          //           child: Container(
                                          //             height: deviceHeight * 0.03,
                                          //             decoration: BoxDecoration(
                                          //               color: colorrecentsearch,
                                          //               border: Border.all(
                                          //                   color: colorgreyborder),
                                          //               borderRadius:
                                          //               BorderRadius.all(
                                          //                 Radius.circular(7),
                                          //               ),
                                          //             ),
                                          //             child: Row(
                                          //               mainAxisAlignment:
                                          //               MainAxisAlignment.start,
                                          //               children: [
                                          //                 Padding(
                                          //                   padding:
                                          //                   const EdgeInsets
                                          //                       .only(
                                          //                       left: 8,
                                          //                       top: 8,
                                          //                       bottom: 8),
                                          //                   child: getSmallText(
                                          //                       "Most Recent",
                                          //                       weight:
                                          //                       FontWeight.w400,
                                          //                       align: TextAlign
                                          //                           .center,
                                          //                       fontSize:
                                          //                       CAPTION_SMALLER_TEXT_FONT_SIZE),
                                          //                 ),
                                          //                 const SizedBox(
                                          //                   width: 8,
                                          //                 ),
                                          //                 Container(
                                          //                   height: 20,
                                          //                   width: 20,
                                          //                   margin: EdgeInsets.only(
                                          //                       top: 3,
                                          //                       bottom: 3,
                                          //                       right: 5),
                                          //                   decoration:
                                          //                   BoxDecoration(
                                          //                     border: Border.all(
                                          //                         color: colorGrey4,
                                          //                         width: 1),
                                          //                     // color: Colors.blue,
                                          //                     borderRadius:
                                          //                     BorderRadius
                                          //                         .circular(
                                          //                         30.0),
                                          //                   ),
                                          //                   padding:
                                          //                   const EdgeInsets
                                          //                       .all(5.5),
                                          //                   child: Image.asset(
                                          //                     IC_CROSS,
                                          //                   ),
                                          //                 )
                                          //               ],
                                          //             ),
                                          //           ),
                                          //         );
                                          //       }),
                                          // ),
                                          Spacer()
                                        ],
                                      ),
                                    ),
                                  )
                                : SizedBox()
                            // Container(
                            //   height: deviceHeight * 0.225,
                            //   width: deviceWidth,
                            //   decoration: BoxDecoration(
                            //     color: colorWhite,
                            //     boxShadow: <BoxShadow>[
                            //       BoxShadow(
                            //           color: Colors.grey.withOpacity(0.2),
                            //           blurRadius: 10.0,
                            //           offset: Offset(0.0, 0.05))
                            //     ],
                            //   ),
                            //   child: Padding(
                            //     padding: EdgeInsets.only(
                            //       left: HORIZONTAL_PADDING,
                            //     ),
                            //     child: Column(
                            //       mainAxisAlignment: MainAxisAlignment.start,
                            //       crossAxisAlignment:
                            //       CrossAxisAlignment.start,
                            //       children: [
                            //         Spacer(
                            //           flex: 4,
                            //         ),
                            //         getSmallText(suggestions,
                            //             weight: FontWeight.w500,
                            //             align: TextAlign.center,
                            //             fontSize: SUBTITLE_FONT_SIZE,
                            //             color: colorHomeText,
                            //             bold: true),
                            //         // Spacer(
                            //         //   flex: 2,
                            //         // ),
                            //         // Container(
                            //         //   height: deviceHeight * 0.15,
                            //         //   width: deviceWidth,
                            //         //   child: ListView.builder(
                            //         //       padding: EdgeInsets.zero,
                            //         //       scrollDirection: Axis.horizontal,
                            //         //       shrinkWrap: true,
                            //         //       primary: false,
                            //         //       itemCount: 20,
                            //         //       itemBuilder: (context, index) {
                            //         //         return Padding(
                            //         //           padding: EdgeInsets.only(
                            //         //             right: 14.0,
                            //         //           ),
                            //         //           child: LatestCouponListHome(
                            //         //               IC_DMART, "DMart"),
                            //         //         );
                            //         //       }),
                            //         // ),
                            //         //Spacer()
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            // isSearch
                            //     ? Container(
                            //   width: deviceWidth,
                            //   color: colorMyrecieptHomeBackground,
                            //   child: Padding(
                            //     padding: const EdgeInsets.only(
                            //         right: HORIZONTAL_PADDING * 1.4,
                            //         left: HORIZONTAL_PADDING * 1.4,
                            //         top: VERTICAL_PADDING * 2,
                            //         bottom: VERTICAL_PADDING),
                            //     child: getSmallText(resultsAvailable ?? "",
                            //         weight: FontWeight.w500,
                            //         bold: true,
                            //         fontSize: FORGET_PASSWORD_TEXT_FONT_SIZE,
                            //         color: colorBlack),
                            //   ),
                            // )
                            //     : Container(
                            //   color: colorMyrecieptHomeBackground,
                            //   height: VERTICAL_PADDING,
                            // ),
                            ,
                            if (receiptlist.isNotEmpty)
                              Container(
                                color: gpLight,
                                width: deviceWidth,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: HORIZONTAL_PADDING,
                                    vertical: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    getSmallText(
                                      "Receipt Overview",
                                      color: gpTextSecondary,
                                      fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                                      weight: FontWeight.w700,
                                    ),
                                    const SizedBox(height: 8),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          _receiptStatCard("Total Spend",
                                              "EUR ${_totalSpend.toStringAsFixed(2)}",
                                              valueColor: gpGreen),
                                          const SizedBox(width: 8),
                                          _receiptStatCard("Business",
                                              "EUR ${_businessSpend.toStringAsFixed(2)}"),
                                          const SizedBox(width: 8),
                                          _receiptStatCard("Personal",
                                              "EUR ${_personalSpend.toStringAsFixed(2)}"),
                                          const SizedBox(width: 8),
                                          _receiptStatCard("OCR In Progress",
                                              _inProgressCount.toString(),
                                              valueColor: gpImpactOrange),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            receiptCount == 0
                                ? SizedBox()
                                : Container(
                                    color: gpLight,
                                    padding: EdgeInsets.only(top: 8),
                                    width: deviceWidth,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: getTitle(
                                          receiptCount.toString() +
                                              " " +
                                              resultsAvailable,
                                          fontSize: SUBTITLE_FONT_SIZE,
                                          color: gpTextSecondary),
                                    ),
                                  ),
                            Container(
                              color: gpLight,
                              width: deviceWidth,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 4),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    ChoiceChip(
                                      label: const Text("All"),
                                      selected: receiptypeorder.isEmpty,
                                      onSelected: (_) {
                                        _applyReceiptTypeFilter("");
                                      },
                                      selectedColor: gpGreen.withOpacity(0.2),
                                      labelStyle: TextStyle(
                                        color: receiptypeorder.isEmpty
                                            ? gpTextPrimary
                                            : gpTextSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ChoiceChip(
                                      label: const Text("Business"),
                                      selected: receiptypeorder == "BUSINESS",
                                      onSelected: (_) {
                                        _applyReceiptTypeFilter("BUSINESS");
                                      },
                                      selectedColor: gpGreen.withOpacity(0.2),
                                      labelStyle: TextStyle(
                                        color: receiptypeorder == "BUSINESS"
                                            ? gpTextPrimary
                                            : gpTextSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ChoiceChip(
                                      label: const Text("Personal"),
                                      selected: receiptypeorder == "PERSONAL",
                                      onSelected: (_) {
                                        _applyReceiptTypeFilter("PERSONAL");
                                      },
                                      selectedColor: gpInfo.withOpacity(0.2),
                                      labelStyle: TextStyle(
                                        color: receiptypeorder == "PERSONAL"
                                            ? gpTextPrimary
                                            : gpTextSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              color: gpLight,
                              height: 8,
                            ),
                            Expanded(
                              child: Container(
                                color: gpLight,
                                child: receiptlist.length <= 0 ||
                                        receiptlist.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                IC_RECEIPT,
                                                height: deviceHeight * 0.08,
                                                width: deviceWidth * 0.16,
                                                fit: BoxFit.contain,
                                              ),
                                              const SizedBox(height: 12),
                                              getTitle(
                                                "No receipts yet",
                                                weight: FontWeight.w700,
                                                fontSize: TITLE_TEXT_FONT_SIZE,
                                                color: gpTextPrimary,
                                              ),
                                              const SizedBox(height: 6),
                                              getSmallText(
                                                "Capture your first receipt to keep expenses organised and audit-ready.",
                                                bold: false,
                                                isCenter: true,
                                                align: TextAlign.center,
                                                lines: 3,
                                                fontSize: SUBTITLE_FONT_SIZE,
                                                color: gpTextSecondary,
                                                weight: FontWeight.w500,
                                              ),
                                              const SizedBox(height: 16),
                                              getButton(
                                                "Add receipt",
                                                () {
                                                  AddNewReceipt(context);
                                                },
                                                width: deviceWidth * 0.6,
                                                height: deviceHeight * 0.055,
                                              ),
                                              const SizedBox(height: 10),
                                              GestureDetector(
                                                onTap: () {
                                                  _getFromGallery();
                                                },
                                                child: getSmallText(
                                                  "Upload from gallery",
                                                  bold: true,
                                                  isCenter: true,
                                                  align: TextAlign.center,
                                                  fontSize:
                                                      CAPTION_TEXT_FONT_SIZE,
                                                  color: gpInfo,
                                                  weight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : isSearchloading
                                        ? loader()
                                        : ListView.builder(
                                            padding: EdgeInsets.only(
                                                bottom: deviceHeight * 0.12),
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            physics:
                                                AlwaysScrollableScrollPhysics(),
                                            clipBehavior: Clip.none,
                                            primary: false,
                                            itemCount: receiptlist.length ?? 0,
                                            itemBuilder: (context, index) {
                                              // String createdatdate = formatter
                                              //     .format(receiptlist[index]
                                              //             ?.updatedAt ??
                                              //         DateTime.now())
                                              //     .toString();
                                              String currencyreceipt =
                                                  (receiptlist[index]
                                                                  .currency ??
                                                              "")
                                                          .isNotEmpty
                                                      ? getCurrencySymbol(
                                                          receiptlist[index]
                                                                  .currency ??
                                                              "")
                                                      : "";
                                              // print("currencyreceipt1");
                                              // print(currencyreceipt);
                                              String createdatdate = formatter
                                                  .format(receiptlist[index]
                                                          .purchaseDate ??
                                                      DateTime.now())
                                                  .toString();
                                              // String purchasedate =  formatter.format(DateTime.parse(receiptlist[index]?.purchaseDate) ?? DateTime.now()).toString();
                                              // print("purchasedate"+receiptlist[index].purchaseDate.toString());
                                              print(
                                                  'RECEIPT STATUS ${receiptlist[index].inProgress}');
                                              return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal:
                                                        HORIZONTAL_PADDING,
                                                  ),
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        if (receiptlist[index]
                                                                    .inProgress ==
                                                                true ||
                                                            isSelected) {
                                                          return;
                                                        }
                                                        Navigator.push(context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                          return ReceiptDetailScreen(
                                                            url: receiptlist[
                                                                        index]
                                                                    .path ??
                                                                "",
                                                            receiptid: receiptlist[
                                                                        index]
                                                                    .receiptId ??
                                                                0,
                                                            receiptName: receiptlist[
                                                                        index]
                                                                    .storeName
                                                                    .toString() ??
                                                                "",
                                                            description: receiptlist[
                                                                        index]
                                                                    .description
                                                                    .toString() ??
                                                                "",
                                                            storeLocation: receiptlist[
                                                                        index]
                                                                    .storeLocation
                                                                    .toString() ??
                                                                "",
                                                            currency: receiptlist[
                                                                        index]
                                                                    .currency
                                                                    .toString() ??
                                                                "",
                                                            amount: receiptlist[
                                                                        index]
                                                                    .amount
                                                                    .toString() ??
                                                                "",
                                                            purchaseDate: receiptlist[
                                                                        index]
                                                                    .purchaseDate
                                                                    .toString() ??
                                                                "",
                                                            warrantycardslist:
                                                                receiptlist[
                                                                        index]
                                                                    .warrantyCards,
                                                            isHome: false,
                                                            receiptFromType:
                                                                receiptlist[index]
                                                                        .receiptFromType ??
                                                                    "",
                                                            tagType: receiptlist[
                                                                        index]
                                                                    .tagType ??
                                                                "",
                                                            storeid: receiptlist[
                                                                        index]
                                                                    .storesId ??
                                                                null,
                                                          );
                                                        }));
                                                      },
                                                      onLongPress: () {
                                                        setState(() {
                                                          isSelected = true;
                                                          selectedReceipts.add(
                                                              receiptlist[
                                                                  index]);
                                                          selectedReceiptsIds
                                                              .add(receiptlist[
                                                                          index]
                                                                      .receiptId ??
                                                                  0);
                                                        });
                                                      },
                                                      child: CustomItemList(
                                                        isSelected,
                                                        (receiptlist[
                                                                            index]
                                                                        .storeLogo ??
                                                                    "")
                                                                .isEmpty
                                                            ? getInitials(receiptlist[
                                                                            index]
                                                                        .storeName ??
                                                                    "") ??
                                                                ""
                                                            : receiptlist[index]
                                                                    .storeLogo ??
                                                                "",
                                                        receiptlist[index]
                                                                .storeName ??
                                                            "",
                                                        createdatdate ?? "",
                                                        receiptlist[index]
                                                                .amount
                                                                .toString() ??
                                                            "",
                                                        "20",
                                                        isstorelogoavailable:
                                                            (receiptlist[index]
                                                                        .storeLogo ??
                                                                    "")
                                                                .isNotEmpty,
                                                        valueSelected:
                                                            selectedReceipts.contains(
                                                                    receiptlist[
                                                                        index])
                                                                ? true
                                                                : false,
                                                        selectFunction:
                                                            (bool value) async {
                                                          if (value == true) {
                                                            selectedReceipts
                                                                .add(
                                                                    receiptlist[
                                                                        index]);
                                                            selectedReceiptsIds
                                                                .add(receiptlist[
                                                                            index]
                                                                        .receiptId ??
                                                                    0);
                                                            print('selected');
                                                            print(
                                                                selectedReceipts);
                                                          } else {
                                                            if (selectedReceipts
                                                                .contains(
                                                                    receiptlist[
                                                                        index])) {
                                                              selectedReceipts
                                                                  .remove(
                                                                      receiptlist[
                                                                          index]);
                                                              selectedReceiptsIds
                                                                  .remove(receiptlist[
                                                                              index]
                                                                          .receiptId ??
                                                                      0);
                                                              print('selected');
                                                              print(
                                                                  selectedReceipts);
                                                              if (isShare) {
                                                                var file = await getPath(
                                                                    (receiptlist[index].receiptId ??
                                                                            0)
                                                                        .toString(),
                                                                    receiptlist[index]
                                                                            .path ??
                                                                        "");
                                                                print(file);
                                                                print(
                                                                    downloadedReceipts);
                                                                downloadedReceipts
                                                                    .remove(file
                                                                        .path);
                                                              }
                                                            }
                                                          }
                                                          setState(() {});
                                                        },
                                                        currency:
                                                            currencyreceipt ??
                                                                "",
                                                        inprogress: receiptlist[
                                                                    index]
                                                                .inProgress ??
                                                            false,
                                                        isLatest: receiptlist[
                                                                    index]
                                                                .latestReceipt ??
                                                            false,
                                                        isDuplicate:
                                                            receiptlist[index]
                                                                    .duplicate ??
                                                                false,
                                                        tagType:
                                                            receiptlist[index]
                                                                .tagType,
                                                      )));
                                            }),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                        child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              height: deviceHeight * 0.07,
                              width: deviceWidth * 0.45,
                              decoration: BoxDecoration(
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 30.0,
                                      offset: Offset(0.0, 0.05))
                                ],
                                // border: Border.all(color: colorhomebordercolor),
                                color: colortheme,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        bloc.add(HomeScreenEvent());
                                      },
                                      child:
                                          customFlotingButton("Home", IC_HOME)),
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return QrCodeScreen();
                                        }));
                                      },
                                      child: customFlotingButton(
                                          "Scan QR", IC_GREYQR)),
                                  GestureDetector(
                                      onTap: () {
                                        // bloc.add(HomeScreenEvent());
                                        showUserQr(context,
                                            customerID: bloc
                                                    .userData?.customerId
                                                    ?.toString() ??
                                                "",
                                            userQr: bloc.userData
                                                    ?.customerIdQrImage ??
                                                "",
                                            email: bloc.userData?.email ?? "");
                                      },
                                      child:
                                          customFlotingButton(idCard, IC_ID)),
                                ],
                              ),
                            ),
                          )

                          // getButton("Scan QR Code", () {
                          //   Navigator.push(context,
                          //       MaterialPageRoute(builder: (context) {
                          //     return QrCodeScreen();
                          //   }));
                          // }, width: deviceWidth * 0.45, assetImage: IC_SCAN)

                          ),
                    )),
                    Positioned.fill(
                        child: Padding(
                      padding: const EdgeInsets.only(bottom: 16, right: 16),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () {
                            AddNewReceipt(context);
                          },
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                                height: deviceHeight * 0.07,
                                width: deviceWidth * 0.14,
                                decoration: BoxDecoration(
                                  // boxShadow: <BoxShadow>[
                                  //   BoxShadow(
                                  //       color: Colors.grey.withOpacity(0.2),
                                  //       blurRadius: 30.0,
                                  //       offset: Offset(0.0, 0.05))
                                  // ],
                                  // border: Border.all(color: colorhomebordercolor),
                                  color: colorGradientFirst,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image.asset(
                                  IC_ADD,
                                  height: deviceHeight * 0.03,
                                  width: deviceWidth * 0.06,
                                  fit: BoxFit.scaleDown,
                                )),
                          ),
                        ),
                      ),
                    )),
                    isSelected
                        ? Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: colorWhite,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20))),
                                height: deviceHeight * 0.11,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          isShare = false;
                                        });
                                        await downloadReceipts();
                                        print(downloadedReceipts);
                                        setState(() {
                                          isSelected = false;
                                        });
                                      },
                                      child: Container(
                                        height: deviceHeight * 0.09,
                                        width: deviceWidth * 0.09,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image:
                                                    AssetImage(IC_DOWNLOAD))),
                                      ),
                                    ),
                                    // bottomSheetIcon(IC_DOWNLOAD, () {}),
                                    SizedBox(
                                      width: deviceWidth * 0.05,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          isShare = true;
                                        });
                                        await downloadReceipts();
                                        print(downloadedReceipts);
                                        if (downloadedReceipts.isEmpty) {
                                          showMessage('Receipt not selected',
                                              () {
                                            setState(() {
                                              isShowMessage = false;
                                            });
                                          });
                                        }
                                        final files = downloadedReceipts
                                            .map((path) => XFile(path))
                                            .toList();
                                        Share.shareXFiles(files);
                                      },
                                      child: Container(
                                        height: deviceHeight * 0.09,
                                        width: deviceWidth * 0.09,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: AssetImage(IC_SHARE))),
                                      ),
                                    ),
                                    // bottomSheetIcon(IC_SHARE, () {
                                    // }),
                                    SizedBox(
                                      width: deviceWidth * 0.05,
                                    ),
                                    bottomSheetIcon(IC_DELETE, () {
                                      logoutBottomSheet(context, deleteReceipt,
                                          () {
                                        Navigator.pop(context);
                                      }, () {
                                        Navigator.pop(context);
                                        if (selectedReceiptsIds.isEmpty) {
                                          showMessage('Receipt not selected',
                                              () {
                                            setState(() {
                                              isShowMessage = false;
                                            });
                                          });
                                        } else {
                                          setState(() {
                                            isLoadingLocal = true;
                                          });
                                          bloc.userRepository
                                              .deletereceipts(
                                                  selectedReceiptsIds)
                                              .then((value) {
                                            print("deleteresponse");
                                            print(value);
                                            setState(() {
                                              isLoadingLocal = false;
                                            });
                                            if (value.status == 1) {
                                              print("deletereceipt =");
                                              print(value);
                                              print(
                                                  "delete receipt successful");
                                              setState(() {
                                                isLoadingLocal = true;
                                                isSelected = false;
                                              });
                                              getreceiptlist();
                                            } else if (value.apiStatusCode ==
                                                401) {
                                              showMessage(value.message ?? "",
                                                  () {
                                                if (mounted)
                                                  setState(() {
                                                    isShowMessage = false;
                                                    logoutaccount();
                                                    isLoadingLocal = false;
                                                    return bloc.add(Login());
                                                  });
                                              });
                                            } else {
                                              print("filter receipt failed ");
                                              print(value.message);
                                              showMessage(value.message ?? "",
                                                  () {
                                                if (mounted)
                                                  setState(() {
                                                    // bloc.add(WelcomeIn());
                                                    isLoadingLocal = false;
                                                    isShowMessage = false;
                                                    bloc.add(ReceiptEvent());
                                                  });
                                              });
                                            }
                                          });
                                        }
                                      });
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SizedBox()
                  ],
                ),
              ),
            ),
          );
  }

  Future<void> _applyReceiptTypeFilter(String tagType) async {
    setState(() {
      receiptypeorder = tagType;
      isSearchloading = true;
    });

    final response = await bloc.userRepository.getreceiptList(
      int.parse(userid),
      startdate: isDateFilterApplied ? StartDatecalendar.toIso8601String() : "",
      enddate: isDateFilterApplied ? EndDatecalendar.toIso8601String() : "",
      timezone: DateTime.now().timeZoneName.toString(),
      direction: listorder,
      query: searchcontroller.text.trim(),
      tagType: receiptypeorder,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isSearchloading = false;
    });

    if (response.status == 1) {
      setState(() {
        receiptlist = response.data?.receiptList ?? [];
        receiptCount = response.data?.receiptCount ?? 0;
        isFiltered = isDateFilterApplied || receiptypeorder.isNotEmpty;
      });
      return;
    }

    if (response.apiStatusCode == 401) {
      showMessage(response.message ?? "", () {
        if (mounted) {
          setState(() {
            isShowMessage = false;
            logoutaccount();
            return bloc.add(Login());
          });
        }
      });
      return;
    }

    showMessage(response.message ?? "", () {
      if (mounted) {
        setState(() {
          isShowMessage = false;
        });
      }
    });
  }

  getreceiptlist() async {
    String userid = prefs.getString(SharedPrefHelper.USER_ID);

    bloc.userRepository.getreceiptList(int.parse(userid)).then((value) {
      if (value.status == 1) {
        //youtubeVideosResponse = value;
        final list = value.data?.receiptList ?? [];
        if (list.isNotEmpty) {
          print('RECEIPT DATA ${list[0].inProgress}');
        }
        receiptlist = list;
        receiptCount = value.data?.receiptCount ?? 0;
        if (mounted)
          setState(() {
            isLoadingLocal = false;
            isFiltered = false;
            isDateFilterApplied = false;
            receiptypeorder = "";
          });
      } else if (value.apiStatusCode == 401) {
        showMessage(value.message ?? "", () {
          setState(() {
            isShowMessage = false;
            logoutaccount();
            isLoadingLocal = false;
            return bloc.add(Login());
          });
        });
      } else {
        print(value.message);
        showMessage(value.message ?? "", () {
          if (mounted)
            setState(() {
              isShowMessage = false;
              isLoadingLocal = false;
              // getreceiptlist();
            });
        });
      }
    });
  }

  String getInitials(String bank_account_name) => bank_account_name.isNotEmpty
      ? bank_account_name.trim().split(' ').map((l) => l[0]).take(1).join()
      : '';

  Future<void> downloadReceipts() async {
    bool storagePermission = await checkPermission();
    if (storagePermission) {
      for (var receipt in selectedReceipts) {
        if (isShare) {
          await saveReceipt(receipt.path ?? "", receipt.receiptId.toString())
              .then((downloadPath) {
            if (downloadedReceipts.contains(downloadPath)) {
              print('Already downloaded');
            } else {
              downloadedReceipts.add(downloadPath);
            }
          });
        } else {
          await _requestDownload(
              receipt.path ?? "", receipt.receiptId.toString());
        }
      }
      if (!isShare) {
        showMessage('Receipt is downloaded', () {
          setState(() {
            isShowMessage = false;
            bloc.add(ReceiptEvent());
            selectedReceipts = [];
            selectedReceiptsIds = [];
            downloadedReceipts = [];
          });
        });
      }
    }
  }

  Future<bool> checkPermission() async {
    if (Permission.storage.status == PermissionStatus.granted) {
      if (Permission.notification.status == PermissionStatus.granted) {
        return true;
      } else {
        await Permission.notification.request();
        return true;
      }
    } else {
      await Permission.storage.request();
      return true;
    }
  }

  Future getPath(String name, String url) async {
    var externalStorageDirPath;
    print(name);
    if (Platform.isAndroid) {
      if (isShare) {
        externalStorageDirPath = (await getTemporaryDirectory()).path;
      } else {
        final dir = await getExternalStorageDirectory();
        externalStorageDirPath =
            dir?.path ?? (await getApplicationDocumentsDirectory()).path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath = (await getApplicationDocumentsDirectory()).path;
    }
    String path;
    if (url.contains('pdf')) {
      path = '$externalStorageDirPath/$name.pdf';
    } else {
      path = '$externalStorageDirPath/$name.png';
    }
    if (isShare) {
      File imgFile = new File(path);
      return imgFile;
    }
    return externalStorageDirPath;
  }

  Future<String> saveReceipt(String path, String name) async {
    var response = await get(Uri.parse(path));
    File imgFile = await getPath(name, path);
    imgFile.writeAsBytesSync(response.bodyBytes);
    return imgFile.path;
  }

  Future<void> AddNewReceipt(BuildContext context) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        backgroundColor: gpLight,
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
                          getSmallText(addnewreceipt ?? "",
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
                      // SizedBox(
                      //   height: deviceHeight * 0.02,
                      // ),

                      // GestureDetector(
                      //     onTap: (){
                      //       Navigator.pop(context);
                      //       Navigator.push(context,
                      //           MaterialPageRoute(builder: (context) {
                      //             return QrCodeScreen();
                      //           }));
                      //     },
                      //     child: uploadReceiptContainer(IC_SCAN_QR,scanQRCode)),
                      SizedBox(
                        height: deviceHeight * 0.012,
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            getImage();
                            // Navigator.push(context,
                            //     MaterialPageRoute(builder: (context) {
                            //   return CameraCapture();
                            // }));
                          },
                          child:
                              uploadReceiptContainer(IC_CAMERASELECT, camera)),
                      SizedBox(
                        height: deviceHeight * 0.012,
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _getFromGallery();
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

  Future<void> receiptFilter(
      BuildContext context, DateTime year, DateTime month) async {
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
              builder: (BuildContext context, StateSetter setStateNew) {
            return Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              height: deviceHeight * 0.65,
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
                          getSmallText(filter ?? "",
                              weight: FontWeight.w600,
                              bold: true,
                              fontSize: CAPTION_TEXT_FONT_SIZE,
                              color: gpTextPrimary),
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
                                border: Border.all(color: gpBorder, width: 1),
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
                        height: 4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          getSmallText(dateRange ?? "",
                              weight: FontWeight.w600,
                              bold: true,
                              fontSize: SUBTITLE_FONT_SIZE,
                              color: gpTextPrimary),
                          Spacer(),
                          // GestureDetector(
                          //   onTap: () {
                          //     showDialog(
                          //       context: context,
                          //       builder: (BuildContext context) {
                          //         return AlertDialog(
                          //           title: Text("Select Year"),
                          //           content: Container(
                          //             // Need to use container to add size constraint.
                          //             width: 300,
                          //             height: 300,
                          //             child: YearPicker(
                          //               firstDate: DateTime(
                          //                   DateTime.now().year - 100, 1),
                          //               lastDate: DateTime(
                          //                   DateTime.now().year + 100, 1),
                          //               initialDate: DateTime.now(),
                          //               selectedDate: year,
                          //               onChanged: (DateTime dateTime) {
                          //                 setStateNew(() {
                          //                   selectedYear = dateTime.year;
                          //                   _values = SfRangeValues(
                          //                       DateTime(selectedYear,
                          //                           selectedMonthIndex, 05),
                          //                       DateTime(selectedYear,
                          //                           selectedMonthIndex, 25));
                          //
                          //                   DateTime start = DateTime.parse(
                          //                       _values.start.toString());
                          //                   DateTime end = DateTime.parse(
                          //                       _values.end.toString());
                          //                   startingDate = start
                          //                       .toIso8601String()
                          //                       .toString();
                          //                   endingDate = end
                          //                       .toIso8601String()
                          //                       .toString();
                          //                   maxDaysInMonth =
                          //                       dateUtility.daysInMonth(
                          //                           selectedMonthIndex,
                          //                           selectedYear);
                          //                 });
                          //                 Navigator.pop(context);
                          //               },
                          //             ),
                          //           ),
                          //         );
                          //       },
                          //     );
                          //   },
                          //   child: Container(
                          //       height: deviceHeight * 0.04,
                          //       decoration: BoxDecoration(
                          //         border:
                          //             Border.all(color: colorGrey4, width: 1),
                          //         color: colorGrey7,
                          //         borderRadius: BorderRadius.circular(6.0),
                          //       ),
                          //       child: Row(
                          //         children: [
                          //           SizedBox(
                          //             width: 4,
                          //           ),
                          //           getTitle(selectedYear.toString(),
                          //               weight: FontWeight.w400,
                          //               color: colorAccentLight,
                          //               fontSize:
                          //                   CAPTION_SMALLER_TEXT_FONT_SIZE),
                          //           Icon(
                          //             Icons.keyboard_arrow_down,
                          //             color: colorgreytext,
                          //             size: 20,
                          //           ),
                          //           SizedBox(
                          //             width: 4,
                          //           ),
                          //         ],
                          //       )),
                          // ),
                          // SizedBox(
                          //   width: 4,
                          // ),
                          // Container(
                          //     height: deviceHeight * 0.04,
                          //     width: deviceWidth * 0.15,
                          //     decoration: BoxDecoration(
                          //       color: colorGrey7,
                          //       border: Border.all(color: colorGrey4, width: 1),
                          //       // color: Colors.blue,
                          //       borderRadius: BorderRadius.circular(6.0),
                          //     ),
                          //     child: Row(
                          //       children: [
                          //         SizedBox(
                          //           width: 4,
                          //         ),
                          //         Expanded(
                          //           child: DropdownButton(
                          //             dropdownColor: colorWhite,
                          //             menuMaxHeight: 250,
                          //             hint: getTitle(selectedMonth.toString(),
                          //                 weight: FontWeight.w400,
                          //                 color: colorAccentLight,
                          //                 fontSize:
                          //                     CAPTION_SMALLER_TEXT_FONT_SIZE),
                          //             isExpanded: false,
                          //             icon: Expanded(
                          //               child: Icon(
                          //                 Icons.keyboard_arrow_down,
                          //                 color: colorgreytext,
                          //                 size: 20,
                          //               ),
                          //             ),
                          //             // iconSize: 30.0,
                          //             style: TextStyle(
                          //               color: colorAccentLight,
                          //             ),
                          //             items: months.map(
                          //               (val) {
                          //                 return DropdownMenuItem<String>(
                          //                   value: val,
                          //                   child: Text(val),
                          //                 );
                          //               },
                          //             ).toList(),
                          //             onChanged: (val) {
                          //               setStateNew(
                          //                 () {
                          //                   selectedMonth = val;
                          //                   if (months
                          //                       .contains(selectedMonth)) {
                          //                     selectedMonthIndex = months
                          //                             .indexOf(selectedMonth) +
                          //                         1;
                          //                   }
                          //                   _values = SfRangeValues(
                          //                       DateTime(selectedYear,
                          //                           selectedMonthIndex, 05),
                          //                       DateTime(selectedYear,
                          //                           selectedMonthIndex, 25));
                          //
                          //                   DateTime start = DateTime.parse(
                          //                       _values.start.toString());
                          //                   DateTime end = DateTime.parse(
                          //                       _values.end.toString());
                          //                   startingDate = start
                          //                       .toIso8601String()
                          //                       .toString();
                          //                   endingDate = end
                          //                       .toIso8601String()
                          //                       .toString();
                          //                   maxDaysInMonth =
                          //                       dateUtility.daysInMonth(
                          //                           selectedMonthIndex,
                          //                           selectedYear);
                          //                 },
                          //               );
                          //             },
                          //             underline: Container(),
                          //           ),
                          //         ),
                          //         // SizedBox(
                          //         //   width: 4,
                          //         // ),
                          //       ],
                          //     )),
                        ],
                      ),

                      //New

                      SizedBox(
                        height: deviceHeight * 0.015,
                      ),

                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 48,
                            width: deviceWidth * 0.4,
                            child: getCommonTextFormField(
                                context: context,
                                // bordersidecolor: Colors.transparent,
                                // filledcolor: colorGrey7,
                                controller: _startDate,
                                suffixIcon: Image.asset(
                                  IC_CALENDAR,
                                  color: gpGreen,
                                ),
                                hintText: "Start Date",
                                readOnly: true,
                                onTap: () async {
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
                                            color: gpLight,
                                            child: CupertinoDatePicker(
                                              mode:
                                                  CupertinoDatePickerMode.date,
                                              onDateTimeChanged: (value) {
                                                setState(() {
                                                  StartDatecalendar = value;
                                                  print(StartDatecalendar);
                                                });
                                                print(
                                                    StartDatecalendar); //StartDatecalendar output format => 2021-03-10 00:00:00.000
                                                String formattedDate =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(
                                                            StartDatecalendar);
                                                print(
                                                    formattedDate); //formatted date output using intl package =>  2021-03-16
                                                //you can implement different kind of Date Format here according to your requirement

                                                setState(() {
                                                  _startDate.text =
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
                                    StartDatecalendar = picked;

                                    print(
                                        StartDatecalendar); //StartDatecalendar output format => 2021-03-10 00:00:00.000
                                    // String formattedDate =
                                    // DateFormat('yyyy-MM-dd').format(StartDatecalendar);
                                    // print(
                                    //     formattedDate); //formatted date output using intl package =>  2021-03-16
                                    //you can implement different kind of Date Format here according to your requirement

                                    setState(() {
                                      _startDate.text = formattedDate(
                                          StartDatecalendar
                                              .toString()); //set output date to TextField value.
                                    });
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
                          Spacer(),
                          SizedBox(
                            height: 48,
                            width: deviceWidth * 0.4,
                            child: getCommonTextFormField(
                                context: context,
                                // bordersidecolor: Colors.transparent,
                                // filledcolor: colorGrey7,
                                controller: _endDate,
                                suffixIcon: Image.asset(
                                  IC_CALENDAR,
                                  color: gpGreen,
                                ),
                                hintText: "End Date",
                                readOnly: true,
                                onTap: () async {
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
                                              mode:
                                                  CupertinoDatePickerMode.date,
                                              onDateTimeChanged: (value) {
                                                setState(() {
                                                  EndDatecalendar = value;
                                                  print(EndDatecalendar);
                                                });
                                                print(
                                                    EndDatecalendar); //StartDatecalendar output format => 2021-03-10 00:00:00.000
                                                String formattedDate =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(
                                                            EndDatecalendar);
                                                print(
                                                    formattedDate); //formatted date output using intl package =>  2021-03-16
                                                //you can implement different kind of Date Format here according to your requirement

                                                setState(() {
                                                  _endDate.text =
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
                                    EndDatecalendar = picked;

                                    print(
                                        EndDatecalendar); //pickedDate output format => 2021-03-10 00:00:00.000
                                    // String formattedDate =
                                    // DateFormat('yyyy-MM-dd').format(pickedDate);
                                    // print(
                                    //     formattedDate); //formatted date output using intl package =>  2021-03-16
                                    //you can implement different kind of Date Format here according to your requirement

                                    setState(() {
                                      _endDate.text = formattedDate(EndDatecalendar
                                          .toString()); //set output date to TextField value.
                                    });
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
                        ],
                      ),

                      // Column(
                      //   children: [
                      //     Container(
                      //       height: 16,
                      //       child: SfRangeSlider(
                      //         min: DateTime(selectedYear, selectedMonthIndex,
                      //             minDaysInMonth),
                      //         max: DateTime(selectedYear, selectedMonthIndex,
                      //             maxDaysInMonth),
                      //         values: _values,
                      //         interval: 1,
                      //         dateFormat: DateFormat.d(),
                      //         dateIntervalType: DateIntervalType.days,
                      //         activeColor: Colors.green,
                      //         inactiveColor: Colors.grey,
                      //         startThumbIcon: thumbIcon(),
                      //         endThumbIcon: thumbIcon(),
                      //         enableTooltip: true,
                      //         minorTicksPerInterval: 1,
                      //         onChanged: (SfRangeValues values) {
                      //           setStateNew(() {
                      //             _values = values;
                      //             DateTime start =
                      //                 DateTime.parse(_values.start.toString());
                      //             DateTime end =
                      //                 DateTime.parse(_values.end.toString());
                      //             startingDate =
                      //                 start.toIso8601String().toString();
                      //             endingDate = end.toIso8601String().toString();
                      //             print("Value=2");
                      //             print(start
                      //                 .toIso8601String()); // 2020-01-02 03:04:05.000
                      //             print(end
                      //                 .toIso8601String()); // 2020-01-02 03:04:05.000
                      //             print("Value=");
                      //             print(_values.start);
                      //             print(_values.end);
                      //           });
                      //         },
                      //       ),
                      //     ),
                      //     Row(
                      //       children: [
                      //         getSmallText("${minDaysInMonth} ${selectedMonth}",
                      //             weight: FontWeight.w400,
                      //             bold: true,
                      //             fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                      //             color: colorgreytext),
                      //         Spacer(),
                      //         getSmallText("${maxDaysInMonth} ${selectedMonth}",
                      //             weight: FontWeight.w400,
                      //             bold: true,
                      //             fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                      //             color: colorgreytext),
                      //       ],
                      //     )
                      //   ],
                      // ),

                      SizedBox(
                        height: deviceHeight * 0.025,
                      ),
                      getSmallText(receiptType ?? "",
                          weight: FontWeight.w500,
                          bold: true,
                          fontSize: SUBTITLE_FONT_SIZE,
                          color: colorHomeText),
                      SizedBox(
                        height: deviceHeight * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CustomRadioWidget(
                            value: "",
                            groupValue: receiptypeorder,
                            onChanged: (value) {
                              setStateNew(() {
                                receiptypeorder = value.toString();
                              });
                            },
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          new Text(
                            'All Receipts',
                            style: new TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CustomRadioWidget(
                            value: "PERSONAL",
                            groupValue: receiptypeorder,
                            onChanged: (value) {
                              setStateNew(() {
                                receiptypeorder = value.toString();
                              });
                            },
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          new Text(
                            'Personal Receipts',
                            style: new TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          CustomRadioWidget(
                            value: "BUSINESS",
                            groupValue: receiptypeorder,
                            onChanged: (value) {
                              setStateNew(() {
                                receiptypeorder = value.toString();
                              });
                            },
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          new Text(
                            'Business Receipts',
                            style: new TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: deviceHeight * 0.02,
                      ),

                      getSmallText(sortBy ?? "",
                          weight: FontWeight.w500,
                          bold: true,
                          fontSize: SUBTITLE_FONT_SIZE,
                          color: colorHomeText),
                      SizedBox(
                        height: deviceHeight * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CustomRadioWidget(
                            value: "ASC",
                            groupValue: listorder,
                            onChanged: (value) {
                              setStateNew(() {
                                listorder = value.toString();
                              });
                            },
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Icon(
                            Icons.arrow_upward_rounded,
                            size: 28,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          new Text(
                            'By ascending order',
                            style: new TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          CustomRadioWidget(
                            value: "DESC",
                            groupValue: listorder,
                            onChanged: (value) {
                              setStateNew(() {
                                listorder = value.toString();
                              });
                            },
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Icon(
                            Icons.arrow_downward,
                            size: 28,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          new Text(
                            'By descending order',
                            style: new TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: deviceHeight * 0.025,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          getButton("Reset", () {
                            Navigator.pop(context);
                            setState(() {
                              isLoadingLocal = true;
                              isSearch = false;
                              isFiltered = false;
                              isDateFilterApplied = false;
                              receiptypeorder = "";
                              listorder = "DESC";
                              StartDatecalendar = DateTime.now();
                              EndDatecalendar = DateTime.now();
                              _startDate.text = "";
                              _endDate.text = "";
                            });
                            getreceiptlist();
                          },
                              width: deviceWidth * 0.35,
                              color: gpLight,
                              textColor: gpGreen,
                              height: deviceHeight * 0.06),
                          SizedBox(
                            width: 10,
                          ),
                          getButton(applyFilter, () {
                            Navigator.pop(context);
                            print("EndDatecalendar");
                            print(startingDate);
                            print(endingDate);
                            print(StartDatecalendar.toIso8601String());
                            print(EndDatecalendar);
                            print("timezone" +
                                DateTime.now().timeZoneName.toString());
                            changeLoadStatus();
                            final hasDateFilter = _startDate.text.isNotEmpty ||
                                _endDate.text.isNotEmpty;
                            bloc.userRepository
                                .getreceiptList(int.parse(userid),
                                    startdate: hasDateFilter
                                        ? StartDatecalendar.toIso8601String()
                                        : "",
                                    enddate: hasDateFilter
                                        ? EndDatecalendar.toIso8601String()
                                        : "",
                                    query: searchcontroller.text,
                                    tagType: receiptypeorder,
                                    timezone:
                                        DateTime.now().timeZoneName.toString(),
                                    direction: listorder)
                                .then((value) {
                              changeLoadStatus();
                              if (value.status == 1) {
                                receiptlist = value.data?.receiptList ?? [];
                                receiptCount = value.data?.receiptCount ?? 0;
                                print("receiptlist =");
                                print(value);
                                setState(() {
                                  isDateFilterApplied = hasDateFilter;
                                  isFiltered = hasDateFilter ||
                                      receiptypeorder.isNotEmpty;
                                });
                                // if (mounted)
                                //   setState(() {
                                //     isLoadingLocal = false;
                                //   });
                                print("filter receipt successful");
                                // getreceiptlist();
                                // showMessage(value.message ?? "", () {
                                //   setState(() {
                                //     //bloc.add(HomeScreenEvent());
                                //     isShowMessage = false;
                                //   });
                                // });
                              } else if (value.apiStatusCode == 401) {
                                showMessage(value.message ?? "", () {
                                  if (mounted)
                                    setState(() {
                                      isShowMessage = false;
                                      logoutaccount();
                                      return bloc.add(Login());
                                    });
                                });
                              } else {
                                print("filter receipt failed ");
                                print(value.message);
                                showMessage(value.message ?? "", () {
                                  if (mounted)
                                    setState(() {
                                      // bloc.add(WelcomeIn());
                                      isShowMessage = false;
                                      bloc.add(ReceiptEvent());
                                    });
                                });
                              }
                            });
                          },
                              width: deviceWidth * 0.35,
                              height: deviceHeight * 0.06),
                        ],
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

  Future<void> _requestDownload(String link, String name) async {
    final String path = await getPath(name, link);
    print(path);
    if (await File(name).exists()) {
      return;
    } else {
      await FlutterDownloader.enqueue(
        url: link,
        savedDir: path,
        saveInPublicStorage: true,
        showNotification: true,
        openFileFromNotification: true,
      );
    }
  }

  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    if (send != null) {
      send.send([id, status, progress]);
    }
  }

  _getFromGallery() async {
    bool isGalleryGranted = await Permission.photos.request().isLimited;
    if (!isGalleryGranted) {
      isGalleryGranted =
          await Permission.photos.request() == PermissionStatus.granted;
    }

    if (!isGalleryGranted) {
      debugPrint("no permission given gallery");
      debugPrint("issue with selected photos");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please give permission to access photos in settings')),
      );
      // Have not permission to camera
      return;
    }

    final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: deviceWidth,
        maxHeight: deviceHeight,
        imageQuality: 90);
    if (pickedFile == null) {
      return;
    }
    setState(() {
      imageFile = File(pickedFile.path);
    });
    Future.delayed(Duration.zero, () async {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return UploadGalleryImage(
          imageFile: imageFile,
          isGallery: false,
          receiptType: "GALLERY",
        );
      }));
    });
  }

  Future getImage() async {
    bool isCameraGranted = await Permission.camera.request().isGranted;
    if (!isCameraGranted) {
      isCameraGranted =
          await Permission.camera.request() == PermissionStatus.granted;
    }

    if (!isCameraGranted) {
      debugPrint("no permission given camera");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please give permission to access camera in settings')),
      );
      // Have not permission to camera
      return;
    }
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
          source: ImageSource.camera,
          maxWidth: deviceWidth,
          maxHeight: deviceHeight,
          imageQuality: 90);
      if (pickedFile == null) {
        return;
      }
      final imagePath = pickedFile.path;
      final dir = await path_provider.getTemporaryDirectory();
      String filename = imagePath.split('/').last;
      print(filename);
      String targetPath = dir.absolute.path + '/$filename';
      final compressed =
          await testCompressAndGetFile(File(imagePath), targetPath);
      if (!mounted) {
        return;
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return UploadGalleryImage(
          imageFile: compressed ?? File(imagePath),
          isGallery: false,
          receiptType: "CAMERA",
        );
      }));
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  // Future getImage() async {
  //   String imagePath;
  //   File _value;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   // We also handle the message potentially returning null.
  //   try {
  //     imagePath = await EdgeDetection.detectEdge;
  //     setState(() {});
  //     print('imageeeee');
  //     print("$imagePath");
  //     if (imagePath != null) {
  //       final dir = await path_provider.getTemporaryDirectory();
  //       String filename = imagePath.split('/').last;
  //       print(filename);
  //       String targetPath = dir.absolute.path + '/$filename';
  //       await testCompressAndGetFile(File(imagePath), targetPath).then((value) {
  //         setState(() {
  //           _value = value;
  //         });
  //         if(_value != null) return Navigator.push(context, MaterialPageRoute(builder: (context) {
  //           return UploadGalleryImage(
  //             imageFile: _value,
  //             isGallery: false,
  //           );
  //         }));
  //       });
  //     }
  //
  //   } on PlatformException catch (e) {
  //     imagePath = e.toString();
  //   }
  // }
  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    print('testCompressAndGetFile');
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: Platform.isIOS ? 60 : 70,
      minHeight: deviceHeight.toInt(),
      minWidth: deviceWidth.toInt(),

      format: Platform.isIOS ? CompressFormat.png : CompressFormat.jpeg,
      // minWidth: 1024,
      // minHeight: 1024,
      rotate: 0,
    );
    final compressedFile = result != null ? File(result.path) : file;
    print("file.lengthSync()");
    print(file.lengthSync());
    print("compressedFile.lengthSync()");
    print(compressedFile.lengthSync());
    return compressedFile;
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
//   File scannedDocument;
//   PermissionStatus status;
//   File _value;
//   String targetPath;
//   @override
//   void initState() {
//     if (Platform.isAndroid)
//       askPermission();
//     else if(Platform.isIOS)
//       status = PermissionStatus.granted;
//     // isFirst = true;
//     super.initState();
//   }
//
//   askPermission() async {
//     status = await Permission.camera.status;
//     if (status == PermissionStatus.denied) {
//       status = await Permission.camera.request();
//     }
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print('camera capture build');
//     // bool isFirst = true;
//     return
//     //   scannedDocument != null
//     //     ? UploadGalleryImage(
//     //   imageFile: _value,
//     //   isGallery: false,
//     // )
//     //     :
//     status.isGranted
//         ? Stack(
//           children: [
//             Positioned.fill(
//               child: DocumentScanner(
//                 noGrayScale: true,
//                 onDocumentScanned: (ScannedImage scannedImage) async {
//                   final dir = await path_provider.getTemporaryDirectory();
//                   String filename = scannedImage.croppedImage.split('/').last;
//                   print(filename);
//                    targetPath = dir.absolute.path + '/$filename';
//                   print("document : " + scannedImage.croppedImage);
//                   // setState(() {
//                   scannedDocument = File.fromUri(Uri.parse(scannedImage.croppedImage));
//                   setState(() {
//
//                   });
//                   // isFirst = false;
//                   // });
//                   // await testCompressAndGetFile(scannedDocument, targetPath).then((value) {
//                   //   setState(() {
//                   //     _value = value;
//                   //   });
//                   //   Navigator.push(context, MaterialPageRoute(builder: (context){
//                   //     return UploadGalleryImage(
//                   //           imageFile: _value,
//                   //           isGallery: false,
//                   //         );
//                   //   }));
//                   // });
//                 },
//               ),
//             ),
//             Positioned.fill(
//                 bottom: 20,
//                 child: GestureDetector(
//                   onTap: ()async{
//                     if(scannedDocument != null){
//                       await testCompressAndGetFile(scannedDocument, targetPath).then((value) {
//                         setState(() {
//                           _value = value;
//                         });
//                         Navigator.push(context, MaterialPageRoute(builder: (context){
//                           return UploadGalleryImage(
//                             imageFile: _value,
//                             isGallery: false,
//                           );
//                         })).then((value) {
//                           setState(() {
//                             scannedDocument = null;
//
//                           });
//                         });
//                       });
//
//                     }
//                     // else{
//                     //   print("snackbar");
//                     //
//                     //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     //     content: getSmallText(
//                     //         "Please capture a receipt"),
//                     //   ));
//                     // }
//
//                   },
//                   child: Align(
//                     alignment: Alignment.bottomCenter,
//                     child: Icon(Icons.camera,size: deviceHeight*0.08,color: colorWhite,),
//                   ),
//                 ))
//           ],
//         )
//         : Center(child: CircularProgressIndicator());
//   }
//
//   Future<File> testCompressAndGetFile(File file, String targetPath) async {
//     print('testCompressAndGetFile');
//     final result = await FlutterImageCompress.compressAndGetFile(
//       file.absolute.path,
//       targetPath,
//       quality: 80,
//       // minWidth: 1024,
//       // minHeight: 1024,
//       rotate: 0,
//     );
//     print("file.lengthSync()");
//     print(file.lengthSync());
//     print(result?.lengthSync());
//     return result;
//   }
//
//   File createFile(String path) {
//     final file = File(path);
//     if (!file.existsSync()) {
//       file.createSync(recursive: true);
//     }
//     return file;
//   }
// }
