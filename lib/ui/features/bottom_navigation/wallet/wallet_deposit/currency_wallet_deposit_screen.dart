import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/data/models/wallet.dart';
import 'package:exbix_flutter/utils/appbar_util.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_util.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';

import '../../../side_navigation/activity/activity_screen.dart';
import 'currency_wallet_bank_deposit_view.dart';
import 'currency_wallet_card_deposit_view.dart';
import 'currency_wallet_paystack_deposit_view.dart';
import 'wallet_deposit_controller.dart';
import 'currency_wallet_paypal_deposit_view.dart';

class CurrencyWalletDepositScreen extends StatefulWidget {
  const CurrencyWalletDepositScreen({super.key, required this.wallet});

  final Wallet wallet;

  @override
  CurrencyWalletDepositScreenState createState() => CurrencyWalletDepositScreenState();
}

class CurrencyWalletDepositScreenState extends State<CurrencyWalletDepositScreen> with TickerProviderStateMixin {
  final _controller = Get.put(WalletDepositController());

  @override
  void initState() {
    _controller.wallet = widget.wallet;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getFiatDepositData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarBackWithActions(title: "Fiat Deposit".tr,
          actionIcons: [Icons.history],
          onPress: (i) {
            TemporaryData.activityType = HistoryType.deposit;
            Get.to(() => const ActivityScreen());
          }),
      body: SafeArea(child: Obx(() {
        final methodList = _controller.getMethodList(_controller.fiatDepositData.value);
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
                            _openPaymentView(_controller.selectedMethodIndex.value),
                            vSpacer20(),
                          ],
                        ),
                      )
                    ],
                  );
      })),
    );
  }

  Widget _openPaymentView(int selected) {
    final methods = _controller.fiatDepositData.value.paymentMethods?[selected];
    switch (methods?.paymentMethod) {
      case PaymentMethodType.bank:
        return const CurrencyWalletBankDepositView();
      case PaymentMethodType.card:
        return const CurrencyWalletCardDepositView();
      case PaymentMethodType.paypal:
        return const CurrencyWalletPaypalDepositView();
      case PaymentMethodType.payStack:
        return const CurrencyWalletPaystackDepositView();
      default:
        return Container();
    }
  }
}
