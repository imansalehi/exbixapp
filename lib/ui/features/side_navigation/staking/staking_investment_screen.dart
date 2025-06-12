import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/data/models/staking.dart';
import 'package:exbix_flutter/helper/app_helper.dart';
import 'package:exbix_flutter/helper/app_widgets.dart';
import 'package:exbix_flutter/utils/alert_util.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/date_util.dart';
import 'package:exbix_flutter/utils/decorations.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/number_util.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_util.dart';

import 'staking_controller.dart';

class StakingInvestmentScreen extends StatefulWidget {
  const StakingInvestmentScreen({super.key});

  @override
  State<StakingInvestmentScreen> createState() => _StakingInvestmentScreenState();
}

class _StakingInvestmentScreenState extends State<StakingInvestmentScreen> {
  bool isLoading = true;
  final _controller = Get.find<StakingController>();
  RxList<Investment> investmentList = <Investment>[].obs;
  bool hasMoreData = true;
  int loadedPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => getInvestmentList(false));
  }

  void getInvestmentList(bool loadMore) async {
    if (!loadMore) {
      loadedPage = 0;
      hasMoreData = true;
      investmentList.clear();
    }
    isLoading = true;
    loadedPage++;
    _controller.getStakingInvestmentList(loadedPage, (listResponse) {
      isLoading = false;
      loadedPage = listResponse.currentPage ?? 0;
      hasMoreData = listResponse.nextPageUrl != null;
      final list = List<Investment>.from(listResponse.data!.map((x) => Investment.fromJson(x)));
      investmentList.addAll(list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return investmentList.isEmpty
          ? handleEmptyViewWithLoading(isLoading)
          : Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(Dimens.paddingMid),
                  itemCount: investmentList.length,
                  itemBuilder: (context, index) {
                    if (hasMoreData && index == investmentList.length - 1) getInvestmentList(true);
                    return StakingInvestmentItemView(investment: investmentList[index], onCancel: () => getInvestmentList(false));
                  }),
            );
    });
  }
}

class StakingInvestmentItemView extends StatelessWidget {
  const StakingInvestmentItemView({super.key, required this.investment, required this.onCancel});

  final Investment investment;
  final Function() onCancel;

  @override
  Widget build(BuildContext context) {
    final statusData = getStakingStatusData(investment.status);
    final color = Get.theme.primaryColorLight;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(Dimens.radiusCorner)),
        onTap: () => showBottomSheetDynamic(context, StakingInvestmentDetailsView(investment: investment), title: "Investment Details".tr),
        child: Container(
          decoration: boxDecorationRoundCorner(),
          padding: const EdgeInsets.all(Dimens.paddingMid),
          margin: const EdgeInsets.only(bottom: Dimens.paddingMid),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              twoTextSpaceFixed(investment.coinType ?? "", "${investment.minimumMaturityPeriod ?? 0} ${"Days".tr}", flex: 6),
              twoTextSpaceFixed("Status".tr, statusData.first, subColor: statusData.last, color: color, flex: 5),
              twoTextSpaceFixed("Daily Earning".tr, "${coinFormat(investment.earnDailyBonus)} ${investment.coinType ?? ""}", color: color, flex: 5),
              twoTextSpaceFixed("Investment Amount".tr, "${coinFormat(investment.investmentAmount)} ${investment.coinType ?? ""}",
                  color: color, flex: 5),
              twoTextSpaceFixed("Estimated Interest".tr, "${coinFormat(investment.totalBonus)} ${investment.coinType ?? ""}", color: color, flex: 5),
              if (investment.status == StakingInvestmentStatus.running)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    hSpacer20(),
                    buttonText("Cancel".tr,
                        onPress: () => _cancelMyInvestment(context), bgColor: context.theme.colorScheme.error, visualDensity: minimumVisualDensity)
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _cancelMyInvestment(BuildContext context) {
    alertForAction(
      context,
      title: "Cancel Investment".tr,
      subTitle: "Do you want to cancel your Investment".tr,
      buttonTitle: "Cancel".tr,
      buttonColor: Colors.red,
      onOkAction: () {
        Get.find<StakingController>().investmentCanceled(investment.uid ?? "", () {
          Get.back();
          onCancel();
        });
      },
    );
  }
}

class StakingInvestmentDetailsView extends StatelessWidget {
  const StakingInvestmentDetailsView({super.key, required this.investment});

  final Investment investment;

  @override
  Widget build(BuildContext context) {
    final statusData = getStakingStatusData(investment.status);
    final typeData = getStakingTermsData(investment.termsType);
    final color = Get.theme.primaryColorLight;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
      children: [
        twoTextSpaceFixed("Coin Type".tr, investment.coinType ?? "", color: color),
        twoTextSpaceFixed("Type".tr, typeData.first, subColor: typeData.last, color: color),
        twoTextSpaceFixed("Stake Date".tr, formatDate(investment.createdAt, format: dateTimeFormatDdMMMMYyyyHhMm), color: color, subMaxLine: 2),
        twoTextSpaceFixed("Daily Interest".tr, "${coinFormat(investment.earnDailyBonus)} ${investment.coinType ?? ""}", color: color, flex: 4),
        twoTextSpaceFixed("End Date".tr, formatDate(investment.endDate, format: dateTimeFormatDdMMMMYyyyHhMm), color: color, subMaxLine: 2),
        twoTextSpaceFixed("Minimum Maturity Period".tr, "${investment.minimumMaturityPeriod ?? 0} ${"Days".tr}", color: color, flex: 10),
        twoTextSpaceFixed("Remain Interest Day".tr, "${investment.remainInterestDay ?? 0} ${"Days".tr}", color: color, flex: 10),
        twoTextSpaceFixed("Offer Percentage".tr, "${coinFormat(investment.offerPercentage)}%", color: color, flex: 5),
        twoTextSpaceFixed("Invested Amount".tr, "${coinFormat(investment.investmentAmount)} ${investment.coinType ?? ""}", color: color, flex: 5),
        twoTextSpaceFixed("Total Bonus".tr, "${coinFormat(investment.totalBonus)} ${investment.coinType ?? ""}", color: color),
        twoTextSpaceFixed("Auto Renew".tr, investment.autoRenewStatus == 2 ? "Enabled".tr : "Disabled".tr, color: color),
        twoTextSpaceFixed("Status".tr, statusData.first, subColor: statusData.last, color: color),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextRobotoAutoBold("Est. APR".tr, fontSize: Dimens.regularFontSizeLarge),
            TextRobotoAutoBold("${coinFormat(investment.offerPercentage)}%", color: Colors.green),
          ],
        ),
      ],
    );
  }
}
