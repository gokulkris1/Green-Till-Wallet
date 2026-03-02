import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/models/responses/getreceiptlist_response.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:greentill/utils/strings.dart';

class TaxSummaryScreen extends BaseStatefulWidget {
  const TaxSummaryScreen({super.key});

  @override
  _TaxSummaryScreenState createState() => _TaxSummaryScreenState();
}

class _TaxSummaryScreenState extends BaseState<TaxSummaryScreen>
    with BasicScreen {
  final String userid = prefs.getString(SharedPrefHelper.USER_ID) ?? "0";
  bool isLoadingLocal = true;
  List<Datum> receiptList = [];

  double businessTotal = 0;
  double personalTotal = 0;
  double reclaimEstimate = 0;
  double underclaimEstimate = 0;
  final Map<String, double> categoryTotals = {};
  final List<Datum> missedClaimEntries = [];

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() {
      isLoadingLocal = true;
    });
    final response = await bloc.userRepository.getreceiptList(
      int.tryParse(userid) ?? 0,
      direction: "DESC",
      timezone: DateTime.now().timeZoneName.toString(),
    );
    if (!mounted) {
      return;
    }

    if (response.status == 1) {
      receiptList = response.data?.receiptList ?? [];
      _computeSummary();
      setState(() {
        isLoadingLocal = false;
      });
      return;
    }

    if (response.apiStatusCode == 401) {
      showMessage(response.message ?? "", () {
        if (mounted) {
          setState(() {
            isShowMessage = false;
            isLoadingLocal = false;
            logoutaccount();
            return bloc.add(Login());
          });
        }
      });
      return;
    }

    showMessage(response.message ?? "Unable to load tax summary", () {
      if (mounted) {
        setState(() {
          isShowMessage = false;
          isLoadingLocal = false;
        });
      }
    });
  }

  void _computeSummary() {
    businessTotal = 0;
    personalTotal = 0;
    reclaimEstimate = 0;
    underclaimEstimate = 0;
    categoryTotals.clear();
    missedClaimEntries.clear();

    for (final receipt in receiptList) {
      final amount = _parseAmount(receipt.amount);
      final tagType = (receipt.tagType ?? "PERSONAL").toUpperCase();
      final category = _inferCategory(receipt);
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;

      if (tagType == "BUSINESS") {
        businessTotal += amount;
        reclaimEstimate += _estimateVat(amount);
      } else {
        personalTotal += amount;
        if (_looksBusinessCandidate(receipt) && amount > 0) {
          missedClaimEntries.add(receipt);
          underclaimEstimate += _estimateVat(amount);
        }
      }
    }
  }

  double _parseAmount(dynamic raw) {
    if (raw == null) {
      return 0;
    }
    final text = raw.toString().replaceAll(RegExp(r"[^0-9\.\-]"), "");
    return double.tryParse(text) ?? 0;
  }

  double _estimateVat(double grossAmount) {
    if (grossAmount <= 0) {
      return 0;
    }
    return grossAmount * 0.23 / 1.23;
  }

  String _inferCategory(Datum receipt) {
    final merged =
        "${receipt.storeName ?? ""} ${receipt.description ?? ""}".toLowerCase();
    if (merged.contains("fuel") ||
        merged.contains("petrol") ||
        merged.contains("diesel") ||
        merged.contains("gas")) {
      return "Fuel";
    }
    if (merged.contains("tool") ||
        merged.contains("hardware") ||
        merged.contains("build") ||
        merged.contains("plumb") ||
        merged.contains("elect")) {
      return "Materials & Tools";
    }
    if (merged.contains("parking") ||
        merged.contains("train") ||
        merged.contains("taxi") ||
        merged.contains("travel")) {
      return "Travel";
    }
    if (merged.contains("coffee") ||
        merged.contains("cafe") ||
        merged.contains("food")) {
      return "Meals";
    }
    return "General";
  }

  bool _looksBusinessCandidate(Datum receipt) {
    final merged =
        "${receipt.storeName ?? ""} ${receipt.description ?? ""}".toLowerCase();
    return merged.contains("tool") ||
        merged.contains("hardware") ||
        merged.contains("build") ||
        merged.contains("plumb") ||
        merged.contains("elect") ||
        merged.contains("fuel") ||
        merged.contains("diesel") ||
        merged.contains("petrol") ||
        merged.contains("parking");
  }

  @override
  Widget buildBody(BuildContext context) {
    return Scaffold(
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
              bottomRight: Radius.circular(15),
            ),
            color: gpLight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HORIZONTAL_PADDING,
              vertical: VERTICAL_PADDING,
            ),
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
                    bloc.add(SideMenu());
                  },
                ),
                SizedBox(width: deviceWidth * 0.025),
                appBarHeader(
                  taxSummary,
                  fontSize: BUTTON_FONT_SIZE,
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadSummary,
                  icon: const Icon(Icons.refresh, color: gpTextSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoadingLocal
          ? loader()
          : RefreshIndicator(
              color: gpGreen,
              onRefresh: _loadSummary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(HORIZONTAL_PADDING),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: gpBorder),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getSmallText(vatReclaimSummary,
                              color: gpTextSecondary,
                              fontSize: CAPTION_TEXT_FONT_SIZE,
                              weight: FontWeight.w600),
                          const SizedBox(height: 6),
                          getTitle("EUR ${reclaimEstimate.toStringAsFixed(2)}",
                              color: gpGreen,
                              weight: FontWeight.w700,
                              fontSize: TITLE_TEXT_FONT_SIZE),
                          const SizedBox(height: 6),
                          getSmallText(
                              "Estimated VAT reclaim from business receipts",
                              color: gpTextSecondary,
                              fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _metricCard(
                            title: "Business Spend",
                            value: "EUR ${businessTotal.toStringAsFixed(2)}",
                            color: gpGreen,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _metricCard(
                            title: "Personal Spend",
                            value: "EUR ${personalTotal.toStringAsFixed(2)}",
                            color: gpInfo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _metricCard(
                      title: "You may be underclaiming",
                      value: "EUR ${underclaimEstimate.toStringAsFixed(2)}",
                      color: gpImpactOrange,
                    ),
                    const SizedBox(height: 16),
                    getTitle(categoryBreakdown,
                        weight: FontWeight.w700,
                        color: gpTextPrimary,
                        fontSize: SUBTITLE_FONT_SIZE),
                    const SizedBox(height: 8),
                    ..._buildCategoryList(),
                    const SizedBox(height: 16),
                    getTitle(missedClaimAlerts,
                        weight: FontWeight.w700,
                        color: gpTextPrimary,
                        fontSize: SUBTITLE_FONT_SIZE),
                    const SizedBox(height: 8),
                    ..._buildAlertList(),
                    SizedBox(height: deviceHeight * 0.03),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _metricCard(
      {required String title, required String value, required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gpBorder),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getSmallText(title,
              color: gpTextSecondary,
              fontSize: CAPTION_TEXT_FONT_SIZE,
              weight: FontWeight.w600),
          const SizedBox(height: 4),
          getTitle(value,
              color: color,
              fontSize: BUTTON_FONT_SIZE,
              weight: FontWeight.w700,
              lines: 1),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryList() {
    if (categoryTotals.isEmpty) {
      return [
        getSmallText("No category data yet",
            color: gpTextSecondary, fontSize: SUBTITLE_FONT_SIZE)
      ];
    }
    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries
        .take(5)
        .map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: gpBorder),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: getSmallText(entry.key,
                        color: gpTextPrimary,
                        fontSize: SUBTITLE_FONT_SIZE,
                        weight: FontWeight.w600),
                  ),
                  getSmallText("EUR ${entry.value.toStringAsFixed(2)}",
                      color: gpTextSecondary,
                      fontSize: SUBTITLE_FONT_SIZE,
                      weight: FontWeight.w600),
                ],
              ),
            ))
        .toList();
  }

  List<Widget> _buildAlertList() {
    if (missedClaimEntries.isEmpty) {
      return [
        getSmallText("No missed-claim alerts",
            color: gpTextSecondary, fontSize: SUBTITLE_FONT_SIZE)
      ];
    }
    return missedClaimEntries.take(5).map((item) {
      final amount = _parseAmount(item.amount);
      final store = (item.storeName ?? "Unknown store").toString();
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: gpBorder),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: getSmallText(store,
                  color: gpTextPrimary,
                  fontSize: SUBTITLE_FONT_SIZE,
                  weight: FontWeight.w600),
            ),
            getSmallText("EUR ${_estimateVat(amount).toStringAsFixed(2)}",
                color: gpImpactOrange,
                fontSize: SUBTITLE_FONT_SIZE,
                weight: FontWeight.w700),
          ],
        ),
      );
    }).toList();
  }
}
