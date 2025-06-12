import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/models/fiat_deposit.dart';
import 'package:exbix_flutter/helper/app_widgets.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/number_util.dart';
import 'package:exbix_flutter/utils/paystack_util.dart';
import 'package:exbix_flutter/utils/text_field_util.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_util.dart';
import 'wallet_deposit_controller.dart';

class CurrencyWalletPaystackDepositView extends StatefulWidget {
  const CurrencyWalletPaystackDepositView({super.key});

  @override
  State<CurrencyWalletPaystackDepositView> createState() => _CurrencyWalletPaystackDepositViewState();
}

class _CurrencyWalletPaystackDepositViewState extends State<CurrencyWalletPaystackDepositView> {
  final _controller = Get.find<WalletDepositController>();
  final amountEditController = TextEditingController();
  final emailEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        vSpacer10(),
        TwoTextSpaceFixed("Enter amount".tr, "USD", color: context.theme.primaryColor),
        vSpacer5(),
        textFieldWithWidget(controller: amountEditController, hint: "Enter amount".tr, type: const TextInputType.numberWithOptions(decimal: true)),
        vSpacer10(),
        TextRobotoAutoBold("Email address".tr),
        vSpacer5(),
        textFieldWithWidget(controller: emailEditController, hint: "Enter Email".tr.capitalizeFirst),
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
    final email = emailEditController.text.trim();
    if (!GetUtils.isEmail(email)) {
      showToast("Input a valid Email".tr);
      return;
    }
    hideKeyboard();
    _controller.paystackPaymentUrlGet(amount, email, (pData) {
      Get.to(() => PaystackPaymentPage(
          paystackData: pData,
          onFinish: (trxData) {
            final deposit = CreateDeposit(walletId: _controller.wallet.id, amount: amount, transactionId: trxData.trxId, currency: "USD");
            _controller.walletCurrencyDeposit(deposit, () => _clearView());
          }));
    });
  }

  void _clearView() {
    amountEditController.text = "";
    emailEditController.text = "";
  }
}
