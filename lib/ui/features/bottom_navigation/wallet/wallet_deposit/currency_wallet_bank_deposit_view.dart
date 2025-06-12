import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/models/fiat_deposit.dart';
import 'package:exbix_flutter/helper/app_widgets.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/extentions.dart';
import 'package:exbix_flutter/utils/image_util.dart';
import 'package:exbix_flutter/utils/number_util.dart';
import 'package:exbix_flutter/utils/text_field_util.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_util.dart';
import 'wallet_deposit_controller.dart';

class CurrencyWalletBankDepositView extends StatefulWidget {
  const CurrencyWalletBankDepositView({super.key});

  @override
  State<CurrencyWalletBankDepositView> createState() => _CurrencyWalletBankDepositViewState();
}

class _CurrencyWalletBankDepositViewState extends State<CurrencyWalletBankDepositView> {
  final _controller = Get.find<WalletDepositController>();
  TextEditingController amountEditController = TextEditingController();
  RxInt selectedBankIndex = 0.obs;
  Rx<File> selectedFile = File("").obs;

  @override
  void initState() {
    selectedBankIndex.value = -1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TwoTextSpaceFixed("Enter amount".tr, _controller.wallet.coinType ?? "", color: context.theme.primaryColor),
        vSpacer5(),
        textFieldWithWidget(
          controller: amountEditController,
          type: const TextInputType.numberWithOptions(decimal: true),
          hint: "Enter amount".tr,
        ),
        vSpacer10(),
        TextRobotoAutoBold("Select Bank".tr),
        Obx(() => dropDownListIndex(_controller.getBankList(_controller.fiatDepositData.value), selectedBankIndex.value, "Select Bank".tr,
            (index) => selectedBankIndex.value = index,
            hMargin: 0, bgColor: Colors.transparent)),
        Obx(() {
          final bank = selectedBankIndex.value == -1 ? null : _controller.fiatDepositData.value.banks?[selectedBankIndex.value];
          return bank == null ? vSpacer0() : BankDetailsView(bank: bank);
        }),
        vSpacer10(),
        Row(
          children: [
            buttonText("Select document".tr,
                visualDensity: VisualDensity.compact,
                fontSize: Dimens.regularFontSizeSmall,
                onPress: () => showImageChooser(context, (chooseFile, isGallery) => selectedFile.value = chooseFile, isCrop: false)),
            Obx(() {
              final text = selectedFile.value.path.isEmpty ? "No document selected".tr : selectedFile.value.name;
              return Expanded(child: TextRobotoAutoNormal(text, maxLines: 2, textAlign: TextAlign.center));
            })
          ],
        ),
        vSpacer10(),
        buttonRoundedMain(text: "Deposit".tr, onPress: () => _checkInputData())
      ],
    );
  }

  void _checkInputData() {
    final amount = makeDouble(amountEditController.text.trim());
    if (amount <= 0) {
      showToast("Amount_less_then".trParams({"amount": "0"}));
      return;
    }
    if (selectedBankIndex.value == -1) {
      showToast("select your bank".tr);
      return;
    }
    if (selectedFile.value.path.isEmpty) {
      showToast("select bank document".tr);
      return;
    }

    final bank = _controller.fiatDepositData.value.banks?[selectedBankIndex.value];
    final currency = _controller.wallet.coinType ?? "";
    final deposit = CreateDeposit(walletId: _controller.wallet.id, amount: amount, bankId: bank?.id, file: selectedFile.value, currency: currency);
    _controller.walletCurrencyDeposit(deposit, () => _clearView());
  }

  void _clearView() {
    amountEditController.text = "";
    selectedBankIndex.value = -1;
    selectedFile.value = File("");
  }
}
