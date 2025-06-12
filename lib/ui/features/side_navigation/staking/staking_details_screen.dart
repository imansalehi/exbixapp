import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/data/models/staking.dart';
import 'package:exbix_flutter/helper/app_helper.dart';
import 'package:exbix_flutter/helper/app_widgets.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/date_util.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/image_util.dart';
import 'package:exbix_flutter/utils/number_util.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_field_util.dart';
import 'package:exbix_flutter/utils/text_util.dart';

import 'staking_controller.dart';

class StakingDetailsScreen extends StatefulWidget {
  const StakingDetailsScreen({super.key, required this.stakingOffer});

  final StakingOffer stakingOffer;

  @override
  State<StakingDetailsScreen> createState() => _StakingDetailsScreenState();
}

class _StakingDetailsScreenState extends State<StakingDetailsScreen> {
  final _controller = Get.find<StakingController>();
  final _amountEditController = TextEditingController();
  StakingDetailsData? _stakingDetailsData;
  RxBool isLoading = true.obs;
  RxDouble estimatedInterest = 0.0.obs;
  RxBool autoStaking = false.obs;
  RxBool termsCheck = false.obs;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => getOfferDetails(widget.stakingOffer.uid ?? ""));
  }

  void getOfferDetails(String uid) async {
    isLoading.value = true;
    _controller.getStakingOfferDetails(uid, (p0) {
      _stakingDetailsData = p0;
      isLoading.value = false;
    });
  }

  void _onTextChanged(String amount) {
    if (_timer?.isActive ?? false) _timer?.cancel();
    _timer = Timer(const Duration(seconds: 1), () => _getBonus());
  }

  @override
  Widget build(BuildContext context) {
    final pcl = context.theme.primaryColorLight;
    return Expanded(
      child: Obx(() {
        final offer = _stakingDetailsData?.offerDetails;
        final typeData = getStakingTermsData(offer?.termsType);
        return isLoading.value
            ? showLoading()
            : ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(Dimens.paddingMid),
                children: [
                  Row(
                    children: [
                      showImageNetwork(imagePath: offer?.coinIcon, width: Dimens.iconSizeMid, height: Dimens.iconSizeMid),
                      hSpacer5(),
                      TextRobotoAutoBold(offer?.coinType ?? ""),
                      const Spacer(),
                      TextRobotoAutoBold(typeData.first, color: typeData.last),
                    ],
                  ),
                  vSpacer10(),
                  twoTextSpaceFixed("Stake Date".tr, formatDate(offer?.stakeDate, format: dateTimeFormatDdMMMYyyyHhMm), color: pcl),
                  twoTextSpaceFixed("Value Date".tr, formatDate(offer?.valueDate, format: dateTimeFormatDdMMMYyyyHhMm), color: pcl),
                  twoTextSpaceFixed("Interest Period".tr, "${offer?.interestPeriod ?? 0} ${"Days".tr}", flex: 4, color: pcl),
                  twoTextSpaceFixed("Interest End".tr, formatDate(offer?.interestEndDate, format: dateTimeFormatDdMMMYyyyHhMm), flex: 4, color: pcl),
                  if (offer?.termsType == StakingTermsType.flexible)
                    twoTextSpaceFixed("Min Maturity Period".tr, "${offer?.minimumMaturityPeriod ?? 0} ${"Days".tr}", flex: 5, color: pcl),
                  twoTextSpaceFixed("Minimum Amount".tr, coinFormat(offer?.minimumInvestment), flex: 4, color: pcl),
                  twoTextSpaceFixed("Available Amount".tr, coinFormat((offer?.maximumInvestment ?? 0) - (offer?.totalInvestmentAmount ?? 0)),
                      flex: 4, color: pcl),
                  Obx(() => twoTextSpaceFixed("Estimated Interest".tr, coinFormat(estimatedInterest.value), flex: 4, color: pcl)),
                  vSpacer10(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextRobotoAutoBold("Duration".tr, color: pcl),
                      Expanded(
                        child: Wrap(
                            alignment: WrapAlignment.end,
                            runSpacing: Dimens.paddingMid,
                            spacing: Dimens.paddingMid,
                            children: List.generate(_stakingDetailsData?.offerList?.length ?? 0, (index) {
                              final cOffer = _stakingDetailsData?.offerList?[index];
                              final isSelected = cOffer?.uid == offer?.uid;
                              return buttonTextBordered("${cOffer?.period} ${"Days".tr}", isSelected,
                                  visualDensity: minimumVisualDensity, onPress: () => getOfferDetails(cOffer?.uid ?? ""));
                            })),
                      )
                    ],
                  ),
                  vSpacer10(),
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextRobotoAutoBold("Enable Auto Staking".tr),
                          toggleSwitch(selectedValue: autoStaking.value, onChange: (value) => autoStaking.value = value)
                        ],
                      )),
                  TextRobotoAutoNormal("earn staking rewards automatically".tr, maxLines: 3),
                  vSpacer10(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextRobotoAutoBold("Est. APR".tr),
                      TextRobotoAutoBold("${coinFormat(offer?.offerPercentage)}%", color: Colors.green),
                    ],
                  ),
                  vSpacer10(),
                  TextRobotoAutoBold("Lock Amount".tr),
                  vSpacer5(),
                  textFieldWithPrefixSuffixText(
                      controller: _amountEditController,
                      suffixText: offer?.coinType ?? "",
                      suffixColor: Get.theme.primaryColor,
                      textAlign: TextAlign.start,
                      onTextChange: _onTextChanged),
                  vSpacer20(),
                  TextRobotoAutoBold("Terms and Conditions".tr),
                  vSpacer5(),
                  if ((offer?.userMinimumHoldingAmount ?? 0) > 0)
                    _termsView("staking_holding_amount_terms".trParams({"value": "${offer?.userMinimumHoldingAmount} ${offer?.coinType}"})),
                  if ((offer?.registrationBefore ?? 0) > 0)
                    _termsView("staking_registered_before_terms".trParams({"value": "${offer?.registrationBefore} ${"Days".tr.toLowerCase()}"})),
                  if ((offer?.phoneVerification ?? 0) == 1) _termsView("staking_verified_phone_terms".tr),
                  if ((offer?.kycVerification ?? 0) == 1) _termsView("staking_verified_kyc_terms".tr),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
                    child: HtmlWidget(offer?.termsCondition ?? "", onLoadingBuilder: (context, element, loadingProgress) => showLoadingSmall()),
                  ),
                  vSpacer15(),
                  Obx(() => Row(
                        children: [
                          Checkbox(value: termsCheck.value, onChanged: (v) => termsCheck.value = v ?? false, visualDensity: minimumVisualDensity),
                          TextRobotoAutoNormal("I agree to the terms and conditions".tr),
                        ],
                      )),
                  vSpacer10(),
                  buttonRoundedMain(text: "Confirm".tr, onPress: () => _confirmStaking())
                ],
              );
      }),
    );
  }

  _termsView(String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextRobotoAutoBold("\u2022 "),
          Expanded(child: TextRobotoAutoNormal(text, fontSize: Dimens.regularFontSizeMid, maxLines: 2)),
        ],
      );

  void _getBonus() async {
    final amount = makeDouble(_amountEditController.text.trim());
    if (amount == 0) {
      estimatedInterest.value = amount;
    } else {
      _controller.totalInvestmentBonus(_stakingDetailsData?.offerDetails?.uid ?? "", amount, (p0) => estimatedInterest.value = p0);
    }
  }

  void _confirmStaking() {
    final amount = makeDouble(_amountEditController.text.trim());
    if (amount <= 0) {
      showToast("amount_must_greater_than_0".tr, context: context);
      return;
    }

    if (!termsCheck.value) {
      showToast("Accept the terms and conditions".tr, context: context);
      return;
    }
    hideKeyboard(context: context);
    _controller.investmentSubmit(context, _stakingDetailsData?.offerDetails?.uid ?? "", amount, autoStaking.value);
  }
}
