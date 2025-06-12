import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/data/models/fiat_deposit.dart';
import 'package:exbix_flutter/data/models/wallet.dart';
import 'package:exbix_flutter/utils/appbar_util.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/extentions.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_util.dart';

import '../../../side_navigation/activity/activity_screen.dart';
import 'currency_wallet_withdraw_views.dart';
import 'wallet_withdrawal_controller.dart';

class CurrencyWalletWithdrawalScreen extends StatefulWidget {
  const CurrencyWalletWithdrawalScreen({super.key, required this.wallet});

  final Wallet wallet;

  @override
  CurrencyWalletWithdrawalScreenState createState() => CurrencyWalletWithdrawalScreenState();
}

class CurrencyWalletWithdrawalScreenState extends State<CurrencyWalletWithdrawalScreen> {
  final _controller = Get.put(WalletWithdrawalController());

  @override
  void initState() {
    _controller.wallet = widget.wallet;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (gUserRx.value.id > 0) _controller.getFiatWithdrawal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarBackWithActions(
          title: "Fiat Withdraw".tr,
          actionIcons: [Icons.history],
          onPress: (i) {
            TemporaryData.activityType = HistoryType.withdraw;
            Get.to(() => const ActivityScreen());
          }),
      body: SafeArea(child: Obx(() {
        final methodList = _controller.getMethodList(_controller.fiatWithdrawalData.value);
        PaymentMethod? method;
        if (methodList.isValid) method = _controller.fiatWithdrawalData.value.paymentMethodList?[_controller.selectedMethodIndex.value];
        return _controller.isLoading.value
            ? showLoading()
            : methodList.isEmpty
                ? showEmptyView(message: "Payment methods not available".tr, height: Dimens.mainContendGapTop)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      vSpacer10(),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid), child: TextRobotoAutoBold("Select Method".tr)),
                      dropDownListIndex(methodList, _controller.selectedMethodIndex.value, "Select Method".tr,
                          (value) => _controller.selectedMethodIndex.value = value,
                          bgColor: Colors.transparent),
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(Dimens.paddingMid),
                          children: [
                            CurrencyWalletWithdrawViews(paymentType: method?.paymentMethod),
                            vSpacer20(),
                          ],
                        ),
                      )
                    ],
                  );
      })),
    );
  }
}
