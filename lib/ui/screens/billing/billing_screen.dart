import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:greentill/utils/strings.dart';

class BillingScreen extends BaseStatefulWidget {
  const BillingScreen({super.key});

  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends BaseState<BillingScreen> with BasicScreen {
  static const int _defaultTrialDays = 30;
  bool isProActive = false;
  bool isTrialUsed = false;
  bool isTrialActive = false;
  int daysRemaining = 0;
  DateTime? trialEndDate;

  @override
  void initState() {
    super.initState();
    _reloadBillingState();
  }

  void _reloadBillingState() {
    final trialStartedMs =
        prefs.getInt(SharedPrefHelper.BILLING_TRIAL_STARTED_AT_MS);
    final trialDays = prefs.getInt(SharedPrefHelper.BILLING_TRIAL_DAYS,
        defaultValue: _defaultTrialDays);
    isProActive = prefs.getBool(SharedPrefHelper.BILLING_PRO_ACTIVE);
    isTrialUsed = prefs.getBool(SharedPrefHelper.BILLING_TRIAL_USED);

    if (trialStartedMs > 0) {
      final startedAt = DateTime.fromMillisecondsSinceEpoch(trialStartedMs);
      trialEndDate = startedAt.add(Duration(days: trialDays));
      final remaining = trialEndDate!.difference(DateTime.now()).inDays + 1;
      daysRemaining = remaining > 0 ? remaining : 0;
      isTrialActive = daysRemaining > 0;
    } else {
      trialEndDate = null;
      daysRemaining = 0;
      isTrialActive = false;
    }
    setState(() {});
  }

  void _startTrial() {
    prefs.putInt(SharedPrefHelper.BILLING_TRIAL_STARTED_AT_MS,
        DateTime.now().millisecondsSinceEpoch);
    prefs.putInt(SharedPrefHelper.BILLING_TRIAL_DAYS, _defaultTrialDays);
    prefs.putBool(SharedPrefHelper.BILLING_TRIAL_USED, true);
    _reloadBillingState();
  }

  void _activatePro() {
    prefs.putBool(SharedPrefHelper.BILLING_PRO_ACTIVE, true);
    _reloadBillingState();
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
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
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
                  billingAndSubscription,
                  fontSize: BUTTON_FONT_SIZE,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(HORIZONTAL_PADDING),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: gpBorder),
                borderRadius: BorderRadius.circular(14),
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
                  getSmallText("Current status",
                      color: gpTextSecondary,
                      fontSize: CAPTION_TEXT_FONT_SIZE,
                      weight: FontWeight.w600),
                  const SizedBox(height: 6),
                  getTitle(
                    isProActive
                        ? "Pro Active"
                        : isTrialActive
                            ? "Trial Active"
                            : "Free Plan",
                    color:
                        isProActive || isTrialActive ? gpGreen : gpTextPrimary,
                    fontSize: TITLE_TEXT_FONT_SIZE,
                    weight: FontWeight.w700,
                  ),
                  if (isTrialActive && trialEndDate != null) ...[
                    const SizedBox(height: 6),
                    getSmallText(
                        "$daysRemaining day(s) left · Ends ${formattedDate(trialEndDate.toString())}",
                        color: gpTextSecondary,
                        fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _featureTile("Monthly accounting-ready report export"),
            _featureTile("Receipt archive bundle for audit"),
            _featureTile("VAT reclaim insights and missed-claim alerts"),
            const SizedBox(height: 16),
            if (!isTrialActive && !isTrialUsed && !isProActive)
              getButton(startFreeTrial, _startTrial, width: deviceWidth * 0.9),
            if (!isProActive) ...[
              const SizedBox(height: 12),
              getButton(upgradeToPro, _activatePro, width: deviceWidth * 0.9),
            ],
            const SizedBox(height: 12),
            getButton(
              restorePurchase,
              _activatePro,
              width: deviceWidth * 0.9,
              color: gpLight,
              textColor: gpGreen,
            ),
            const SizedBox(height: 12),
            if (!isTrialActive && isTrialUsed && !isProActive)
              getSmallText(
                  "Trial expired. Upgrade to continue generating report exports.",
                  color: gpError,
                  fontSize: CAPTION_TEXT_FONT_SIZE,
                  weight: FontWeight.w600),
            SizedBox(height: deviceHeight * 0.03),
          ],
        ),
      ),
    );
  }

  Widget _featureTile(String title) {
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
          const Icon(Icons.check_circle, size: 18, color: gpGreen),
          const SizedBox(width: 8),
          Expanded(
            child: getSmallText(title,
                color: gpTextPrimary,
                fontSize: SUBTITLE_FONT_SIZE,
                weight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
