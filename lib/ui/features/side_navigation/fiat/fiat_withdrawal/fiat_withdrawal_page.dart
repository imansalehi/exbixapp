import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/data/models/fiat_deposit.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/extentions.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_util.dart';
import 'fiat_withdraw_bank_view.dart';
import 'fiat_withdrawal_controller.dart';

class FiatWithdrawalPage extends StatefulWidget {
  const FiatWithdrawalPage({super.key});

  @override
  FiatWithdrawalPageState createState() => FiatWithdrawalPageState();
}

class FiatWithdrawalPageState extends State<FiatWithdrawalPage> {
  final _controller = Get.put(FiatWithdrawalController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (gUserRx.value.id > 0) _controller.getFiatWithdrawal();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final methodList = _controller.getMethodList(_controller.fiatWithdrawalData.value);
      PaymentMethod? method;
      if (methodList.isValid) method = _controller.fiatWithdrawalData.value.paymentMethodList?[_controller.selectedMethodIndex.value];
      return _controller.isLoading.value
          ? showLoading()
          : methodList.isEmpty
              ? showEmptyView(message: "Payment methods not available".tr, height: Dimens.mainContendGapTop)
              : Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
                          child: TextRobotoAutoBold("Select Method".tr)),
                      dropDownListIndex(methodList, _controller.selectedMethodIndex.value, "Select Method".tr,
                          (value) => _controller.selectedMethodIndex.value = value,  bgColor: Colors.transparent),
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(Dimens.paddingMid),
                          children: [
                            FiatWithdrawBankPage(paymentType: method?.paymentMethod),
                            vSpacer10(),
                          ],
                        ),
                      )
                    ],
                  ),
                );
    });
  }
}
