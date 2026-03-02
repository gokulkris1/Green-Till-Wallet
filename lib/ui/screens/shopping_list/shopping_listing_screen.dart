import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/models/responses/get_shoppinglist_response.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/ui/screens/shopping_list/shopping_link_webview.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:greentill/utils/strings.dart';

class ShoppingListingScreen extends BaseStatefulWidget{
  @override
  _ShoppingListingScreenScreenState createState() => _ShoppingListingScreenScreenState();
}

class _ShoppingListingScreenScreenState extends BaseState<ShoppingListingScreen> with BasicScreen {
  bool isFirst = true;
  bool isLoadingLocal = true;
  List<DatumShoppingList> shoppingLinkList = [];
  bool isStoreListingLoading = false;
  String userid = prefs.getString(SharedPrefHelper.USER_ID) ?? "0";
  bool isSearch = false;
  TextEditingController searchcontroller = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 1000);
  FocusNode? searchFocusNode;

  @override
  void initState() {
    searchFocusNode = FocusNode();
    super.initState();
  }

  _onSearchChanged(String value) {
    // if (debounce?.isActive ?? false) debounce.cancel();
    // _debounce = Timer(const Duration(seconds: 1), () {
    if (searchcontroller.text.isEmpty) {
      setState(() {
        isStoreListingLoading = true;
      });
      bloc.userRepository
          .getShoppingListing(
          query:
      value.trim().toString())
          .then((value) {
        setState(() {
          isStoreListingLoading = false;
        });
        if (value.status == 1) {
          //youtubeVideosResponse = value;
          shoppingLinkList = value.data ?? [];

          // if (mounted)
          //   setState(() {
          //     isLoadingLocal = false;
          //     isCouponsLoading = false;
          //   });
        } else if (value.apiStatusCode ==
            401) {
          showMessage(value.message ?? "", () {
            setState(() {
              isShowMessage = false;
              logoutaccount();
              isStoreListingLoading = false;
              return bloc.add(Login());
            });
          });
        } else {
          print(value.message);
          showMessage(value.message ?? "", () {
            setState(() {
              isShowMessage = false;
              isStoreListingLoading = false;
              // bloc.add(Shop());
              //getCategorieslist();
            });
          });
        }
      });
    }
    else {
      setState(() {
        isStoreListingLoading = true;
      });
      bloc.userRepository
          .getShoppingListing(
          query:
      value.trim().toString())
          .then((value) {
        setState(() {
          isStoreListingLoading = false;
        });
        if (value.status == 1) {
          //youtubeVideosResponse = value;
          shoppingLinkList = value.data ?? [];

          // if (mounted)
          //   setState(() {
          //     isLoadingLocal = false;
          //     isCouponsLoading = false;
          //   });
        } else if (value.apiStatusCode ==
            401) {
          showMessage(value.message ?? "", () {
            setState(() {
              isShowMessage = false;
              logoutaccount();
              isStoreListingLoading = false;
              return bloc.add(Login());
            });
          });
        } else {
          print(value.message);
          showMessage(value.message ?? "", () {
            setState(() {
              isShowMessage = false;
              isStoreListingLoading = false;
              // bloc.add(StoreCardEvent());
              //getCategorieslist();
            });
          });
        }
      });
    }

    // });
  }

  @override
  void dispose() {
    searchcontroller.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    if (isFirst) {
      isFirst = false;
      getShoppingLinklist();
    }

    return isLoadingLocal == true
        ? loader()
        :
     Scaffold(
     resizeToAvoidBottomInset: false,
     backgroundColor: colorstorecardbackground,
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
             children: [
               GestureDetector(
                 child: Image.asset(
                   IC_BACK_ARROW_TWO_COLOR,
                   height: 24,
                   width: 24,
                   fit: BoxFit.fill,
                 ),
                 onTap: () {
                   if ( isSearch) {
                     setState(() {
                       isSearch = false;
                       searchcontroller.clear();
                       getShoppingLinklist();
                     });
                   }else{
                     return bloc.add(HomeScreenEvent());
                   }
                   // Navigator.pop(context);

                   // return bloc.add(SideMenu());
                 },
               ),
               SizedBox(
                 width: deviceWidth * 0.025,
               ),
               appBarHeader(
                 shoppinglinks,
                 fontSize: BUTTON_FONT_SIZE,
                 bold: false,
               ),
               Spacer(),
               Container(
                 width: deviceWidth * 0.21,
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: [
                     GestureDetector(
                       onTap: () {
                         setState(() {
                           isSearch = true;
                           searchFocusNode?.requestFocus();
                         });
                       },
                       child: Image.asset(
                         IC_SEARCH,
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
       child: Container(
         height: deviceHeight,
         width: deviceWidth,
         child: Column(
           children: [
             isSearch
                 ? Container(
               height: deviceHeight * 0.12,
               width: deviceWidth,
               decoration: BoxDecoration(
                 color: colorWhite,
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
                         color: colorMyrecieptHomeBackground,
                         border: Border.all(
                             color: colorgreyborder),
                         borderRadius: BorderRadius.all(
                           Radius.circular(10),
                         ),
                       ),
                       child: TextField(
                         controller: searchcontroller,
                         focusNode: searchFocusNode,
                         onChanged: (value) {
                           _debouncer.run(() {
                             _onSearchChanged(searchcontroller.text.trim());
                           });
                         },
                         decoration: InputDecoration(
                           prefixIcon: Image.asset(
                             IC_SEARCH,
                             height: 10,
                             width: 10,
                           ),
                           suffixIcon: GestureDetector(
                             onTap: () {
                               setState(() {
                                 isSearch = false;
                                 searchcontroller.clear();
                                 getShoppingLinklist();
                               });
                               // getShoppingLinklist();
                             },
                             child: Image.asset(
                               IC_CROSS,
                               height: 10,
                               width: 10,
                             ),
                           ),
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
                     //                   BorderRadius.all(
                     //                 Radius.circular(7),
                     //               ),
                     //             ),
                     //             child: Row(
                     //               mainAxisAlignment:
                     //                   MainAxisAlignment.start,
                     //               children: [
                     //                 Padding(
                     //                   padding:
                     //                       const EdgeInsets
                     //                               .only(
                     //                           left: 8,
                     //                           top: 8,
                     //                           bottom: 8),
                     //                   child: getSmallText(
                     //                       "Most Recent",
                     //                       weight:
                     //                           FontWeight.w400,
                     //                       align: TextAlign
                     //                           .center,
                     //                       fontSize:
                     //                           CAPTION_SMALLER_TEXT_FONT_SIZE),
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
                     //                       BoxDecoration(
                     //                     border: Border.all(
                     //                         color: colorGrey4,
                     //                         width: 1),
                     //                     // color: Colors.blue,
                     //                     borderRadius:
                     //                         BorderRadius
                     //                             .circular(
                     //                                 30.0),
                     //                   ),
                     //                   padding:
                     //                       const EdgeInsets
                     //                           .all(5.5),
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
                     Spacer(
                     )
                   ],
                 ),
               ),
             )
                 : SizedBox(),
             Expanded(
               child: RefreshIndicator(
                 onRefresh: (){
                   print("pulltorefresh");
                   setState(() {
                     isSearch = false;
                   });
                   return getShoppingLinklist();
                 },
                 child: Container(
                   child:
                       isStoreListingLoading ? loader(): shoppingLinkList.length <= 0 ||
                           shoppingLinkList.isEmpty
                       ? Center(
                     child: getSmallText("No shopping link available!",
                         bold: true,
                         isCenter: true,
                         fontSize: BUTTON_FONT_SIZE,
                         color: colorBlack,
                         weight: FontWeight.w500),
                   )
                       :
                   Padding(
                     padding: EdgeInsets.only(
                       right: HORIZONTAL_PADDING,
                       left: HORIZONTAL_PADDING,
                       top: VERTICAL_PADDING * 2,
                       bottom: VERTICAL_PADDING * 2,
                     ),
                     child: ListView.builder(
                         padding: EdgeInsets.only(
                             bottom: deviceHeight * 0.12),
                         scrollDirection: Axis.vertical,
                         physics: AlwaysScrollableScrollPhysics(),
                         clipBehavior: Clip.none,
                         primary: false,
                         itemCount: shoppingLinkList.length,
                         shrinkWrap: true,
                         itemBuilder: (context, index) {
                           return GestureDetector(
                             child: Padding(
                               padding: const EdgeInsets.all(4.0),
                               child: StoreCardListGridItem(
                                 shoppingLinkList[index].storeLogo ?? "",
                                 shoppingLinkList[index].storeName ??
                                     "",
                                 isstorelogoavailable:
                                     (shoppingLinkList[index].storeLogo ?? "")
                                         .isNotEmpty,
                               ),
                             ),
                             onTap: () {
                               if ((shoppingLinkList[index].link ?? "")
                                   .isNotEmpty) {
                                 Navigator.push(context, MaterialPageRoute(builder: (context){
                                   return ShoppingLinkWebview(link: shoppingLinkList[index].link ?? "",title: shoppingLinkList[index].storeName ?? "",);
                                 }));
                               }else{
                                 showMessage(
                                     'Something went wrong!', (){
                                   setState(() {
                                     isShowMessage = false;
                                   });
                                 });
                               }
                                
                             },
                           );
                         }),
                   ),
                 ),
               ),
             )
           ],
         )
       ),
     ),
   );
  }

  getShoppingLinklist() async {

    await bloc.userRepository
        .getShoppingListing()
        .then((value) {
      if (value.status == 1) {
        shoppingLinkList = value.data ?? [];
        print("shoppinglist =");
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

}
