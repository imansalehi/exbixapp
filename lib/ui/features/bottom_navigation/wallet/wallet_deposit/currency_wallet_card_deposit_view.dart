import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/data/models/fiat_deposit.dart';
import 'package:exbix_flutter/helper/app_widgets.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/decorations.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/extentions.dart';
import 'package:exbix_flutter/utils/number_util.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_field_util.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'wallet_deposit_controller.dart';

class CurrencyWalletCardDepositView extends StatefulWidget {
  const CurrencyWalletCardDepositView({super.key});

  @override
  State<CurrencyWalletCardDepositView> createState() => _CurrencyWalletCardDepositViewState();
}

class _CurrencyWalletCardDepositViewState extends State<CurrencyWalletCardDepositView> {
  final _controller = Get.find<WalletDepositController>();
  CardFieldInputDetails? _cardFieldInputDetails;
  RxString stripToken = "".obs;
  TextEditingController amountEditController = TextEditingController();
  RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    initStripe();
  }

  initStripe() async {
    try {
      final stKey = dotenv.env[EnvKeyValue.kStripKey];
      if (stKey.isValid) {
        Stripe.publishableKey = stKey!;
        await Stripe.instance.applySettings();
      } else {
        showToast("Stripe key not found");
      }
      isLoading.value = false;
    } catch (e) {
      showToast(e.toString(), isLong: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => isLoading.value
        ? showLoading()
        : Column(
            children: [
              vSpacer10(),
              Obx(() => stripToken.value.isEmpty ? _cardInputView() : _amountInputView()),
              vSpacer20(),
              buttonRoundedMain(text: "Deposit".tr, onPress: () => _checkInputData())
            ],
          ));
  }

  _cardInputView() {
    return Container(
      alignment: Alignment.center,
      decoration: boxDecorationRoundCorner(color: context.theme.dialogBackgroundColor),
      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid, vertical: Dimens.paddingLarge),
      child: CardField(
        enablePostalCode: true,
        style: context.textTheme.labelMedium,
        onCardChanged: (cDetails) => _cardFieldInputDetails = cDetails,
        decoration: InputDecoration(
            labelText: 'Card Field'.tr,
            focusColor: context.theme.focusColor,
            labelStyle: context.textTheme.labelMedium?.copyWith(fontSize: Dimens.regularFontSizeLarge)),
      ),
    );
  }

  _amountInputView() {
    return Column(
      children: [
        TwoTextSpaceFixed("Enter amount".tr, "USD", color: context.theme.primaryColor),
        vSpacer5(),
        textFieldWithWidget(controller: amountEditController, hint: "Enter amount".tr, type: const TextInputType.numberWithOptions(decimal: true)),
      ],
    );
  }

  Future<void> _checkInputData() async {
    if (stripToken.value.isEmpty) {
      try {
        if (!Stripe.publishableKey.isValid || Stripe.publishableKey == EnvKeyValue.kStripKey) {
          showToast("Invalid Strip key".tr);
          return;
        }
      } catch (error) {
        showToast(error is StripeConfigException ? error.message : error.toString());
      }

      if (_cardFieldInputDetails != null &&
          _cardFieldInputDetails!.complete &&
          _cardFieldInputDetails!.validNumber == CardValidationState.Valid &&
          _cardFieldInputDetails!.validExpiryDate == CardValidationState.Valid &&
          _cardFieldInputDetails!.validCVC == CardValidationState.Valid) {
        try {
          final paymentMethod = await Stripe.instance.createToken(const CreateTokenParams.card(params: CardTokenParams(type: TokenType.Card)));
          stripToken.value = paymentMethod.id;
        } catch (error) {
          showToast(error is StripeException ? (error.error.localizedMessage ?? "") : error.toString());
        }
      } else {
        showToast("Please input valid card details".tr);
      }
    } else {
      final amount = makeDouble(amountEditController.text.trim());
      if (amount <= 0) {
        showToast("Amount_less_then".trParams({"amount": "0"}));
        return;
      }
      final deposit = CreateDeposit(walletId: _controller.wallet.id, amount: amount, currency: "USD", stripeToken: stripToken.value);
      _controller.walletCurrencyDeposit(deposit, () => _clearView());
    }
  }

  void _clearView() {
    amountEditController.text = "";
    stripToken.value = "";
  }
}
