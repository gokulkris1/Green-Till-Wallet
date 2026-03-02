import 'package:flutter/material.dart';
import 'package:greentill/models/common/globals.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/strings.dart';

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Green Till Preview',
      theme: ThemeData(
        primaryColor: gpGreen,
        scaffoldBackgroundColor: gpLight,
        dividerColor: gpBorder,
        colorScheme: const ColorScheme.light(
          primary: gpGreen,
          onPrimary: gpLight,
          secondary: gpImpactOrange,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: gpTextPrimary,
          error: gpError,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: gpLight,
          foregroundColor: gpTextPrimary,
          elevation: 0,
        ),
      ),
      home: const PreviewHome(),
    );
  }
}

class PreviewHome extends StatelessWidget {
  const PreviewHome({super.key});

  @override
  Widget build(BuildContext context) {
    Globals.globalContext = context;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: HORIZONTAL_PADDING,
          vertical: VERTICAL_PADDING,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getSmallText('Home (Receipts first)',
                weight: FontWeight.w700,
                color: gpTextPrimary,
                fontSize: SUBTITLE_FONT_SIZE),
            const SizedBox(height: 8),
            CoinsAvailableWidget("128", points: "42", currency: "€"),
            const SizedBox(height: 12),
            HomeScreenTabRow(() {}, () {}, () {}, () {}, () {}, () {}),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: gpBorder, width: 0),
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: gpLight,
                  border: Border.all(color: gpBorder),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 16.0,
                      offset: Offset(0.0, 0.05),
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: HORIZONTAL_PADDING,
                  vertical: VERTICAL_PADDING * 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeaderViewAll(receipt, () {}, isEmpty: false),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: MyreceiptGridItem(
                            '',
                            'B&Q Hardware',
                            '12 Feb 2026',
                            isstorelogoavailable: false,
                            inprogress: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MyreceiptGridItem(
                            '',
                            'Toolstation',
                            '05 Feb 2026',
                            isstorelogoavailable: false,
                            isDuplicate: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MyreceiptGridItem(
                            '',
                            'Screwfix',
                            '02 Feb 2026',
                            isstorelogoavailable: false,
                            inprogress: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            getSmallText('Side Menu',
                weight: FontWeight.w700,
                color: gpTextPrimary,
                fontSize: SUBTITLE_FONT_SIZE),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: gpLight,
                border: Border.all(color: gpBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SidemenuWidget(IC_RECEIPT, receipt, () {}),
                  const SizedBox(height: 10),
                  SidemenuWidget(IC_HEADPHONE, 'Contact & Support', () {}),
                  const SizedBox(height: 10),
                  SidemenuWidget(IC_PRIVACY_POLICY, 'Privacy Policy', () {}),
                  const SizedBox(height: 10),
                  SidemenuWidget(IC_LOCK, 'Change Password', () {}),
                ],
              ),
            ),
            const SizedBox(height: 20),
            getSmallText('Receipts',
                weight: FontWeight.w700,
                color: gpTextPrimary,
                fontSize: SUBTITLE_FONT_SIZE),
            const SizedBox(height: 8),
            CustomItemList(
              false,
              'GT',
              'B&Q Hardware',
              '12 Feb 2026',
              '126.40',
              '0',
              currency: '€',
              isstorelogoavailable: false,
              isLatest: true,
              tagType: "BUSINESS",
            ),
            CustomItemList(
              false,
              'GT',
              'Screwfix',
              '05 Feb 2026',
              '42.10',
              '0',
              currency: '€',
              isstorelogoavailable: false,
              tagType: "PERSONAL",
            ),
            const SizedBox(height: 20),
            getSmallText('Home Cards',
                weight: FontWeight.w700,
                color: gpTextPrimary,
                fontSize: SUBTITLE_FONT_SIZE),
            const SizedBox(height: 8),
            Row(
              children: [
                StoreCardListHome('', 'B&Q', isstorelogoavailable: false),
                const SizedBox(width: 12),
                LatestCouponListHome('', '10% Off',
                    offerpercent: '10%', isstorelogoavailable: false),
              ],
            ),
            const SizedBox(height: 20),
            getSmallText('Receipt Grid',
                weight: FontWeight.w700,
                color: gpTextPrimary,
                fontSize: SUBTITLE_FONT_SIZE),
            const SizedBox(height: 8),
            Row(
              children: [
                MyreceiptGridItem('', 'Toolstation', '22 Jan 2026',
                    isstorelogoavailable: false),
                const SizedBox(width: 12),
                MyreceiptGridItem('', 'Wickes', '18 Jan 2026',
                    isstorelogoavailable: false),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
