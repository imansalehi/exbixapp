import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/models/fiat_deposit.dart';
import 'package:exbix_flutter/helper/app_widgets.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/number_util.dart';
import 'package:exbix_flutter/utils/paypal_util/paypal_payment.dart';
import 'package:exbix_flutter/utils/text_field_util.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'wallet_deposit_controller.dart';

class CurrencyWalletPaypalDepositView extends StatefulWidget {
  const CurrencyWalletPaypalDepositView({super.key});

  @override
  State<CurrencyWalletPaypalDepositView> createState() => _CurrencyWalletPaypalDepositViewState();
}

class _CurrencyWalletPaypalDepositViewState extends State<CurrencyWalletPaypalDepositView> {
  final _controller = Get.find<WalletDepositController>();
  TextEditingController amountEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        vSpacer10(),
        TwoTextSpaceFixed("Enter amount".tr, "USD", color: context.theme.primaryColor),
        vSpacer5(),
        textFieldWithWidget(controller: amountEditController, hint: "Enter amount".tr, type: const TextInputType.numberWithOptions(decimal: true)),
        vSpacer20(),
        buttonRoundedMain(text: "Next".tr, onPress: () => _checkInputData())
      ],
    );
  }

  void _checkInputData() {
    final amount = makeDouble(amountEditController.text.trim());
    if (amount <= 0) {
      showToast("Amount_less_then".trParams({"amount": "0"}));
      return;
    }
    Get.to(() => PaypalPayment(
        totalAmount: amount,
        onFinish: (token) {
          Future.delayed(const Duration(seconds: 1), () {
            final deposit = CreateDeposit(walletId: _controller.wallet.id, amount: amount, currency: "USD", paypalToken: token);
            _controller.walletCurrencyDeposit(deposit, () => _clearView());
          });
        }));
  }

  void _clearView() {
    amountEditController.text = "";
  }
}
