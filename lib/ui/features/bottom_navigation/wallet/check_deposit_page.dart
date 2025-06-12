import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/models/gift_card.dart';
import 'package:exbix_flutter/data/models/wallet.dart';
import 'package:exbix_flutter/helper/app_widgets.dart';
import 'package:exbix_flutter/utils/alert_util.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_field_util.dart';
import 'package:exbix_flutter/utils/text_util.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'wallet_controller.dart';

class CheckDepositPage extends StatefulWidget {
  const CheckDepositPage({super.key});

  @override
  State<CheckDepositPage> createState() => _CheckDepositPageState();
}

class _CheckDepositPageState extends State<CheckDepositPage> {
  final _controller = Get.find<WalletController>();
  final _tranController = TextEditingController();
  RxList<Network> networkList = <Network>[].obs;
  RxList<Coin> coinList = <Coin>[].obs;
  RxInt selectedNetwork = 0.obs;
  RxInt selectedCoin = 0.obs;

  @override
  void initState() {
    super.initState();
    selectedNetwork.value = -1;
    selectedCoin.value = -1;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.getNetworksList((list) => networkList.value = list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final netList = networkList.map((element) => element.networkName ?? '').toList();
      final cList = coinList.map((element) => "${element.name ?? ''} (${element.coinType ?? ''})").toList();

      return ListView(
        padding: const EdgeInsets.all(Dimens.paddingMid),
        shrinkWrap: true,
        children: [
          TextRobotoAutoBold("Network".tr),
          dropDownListIndex(netList, selectedNetwork.value, "Select Network".tr, (value) {
            selectedNetwork.value = value;
            _getCoinList();
          }, hMargin: 0),
          vSpacer10(),
          TextRobotoAutoBold("Coin".tr),
          dropDownListIndex(cList, selectedCoin.value, "Select Coin".tr, (value) => selectedCoin.value = value, hMargin: 0),
          vSpacer10(),
          TextRobotoAutoBold("Transaction ID".tr),
          vSpacer5(),
          textFieldWithSuffixIcon(controller: _tranController, hint: "Enter transaction id".tr),
          vSpacer20(),
          buttonRoundedMain(text: "Submit".tr, onPress: () => _onCheckDeposit()),
          vSpacer10()
        ],
      );
    });
  }

  void _getCoinList() {
    if (selectedNetwork.value == -1) return;
    selectedCoin.value = -1;
    coinList.clear();
    final netId = networkList[selectedNetwork.value].id;
    _controller.getCoinsByNetwork(netId, (list) => coinList.value = list);
  }

  void _onCheckDeposit() {
    if (selectedNetwork.value == -1) {
      showToast("select network".tr);
      return;
    }
    if (selectedCoin.value == -1) {
      showToast("select your coin".tr);
      return;
    }
    final transaction = _tranController.text.trim();
    if (transaction.isEmpty) {
      showToast("enter transaction id".tr);
      return;
    }
    hideKeyboard();
    final netId = networkList[selectedNetwork.value].id;
    final coinId = coinList[selectedCoin.value].id ?? 0;
    _controller.checkCoinTransaction(netId, coinId, transaction, (deposit) {
      showModalSheetFullScreen(context, CheckDepositDetailsView(deposit: deposit));
    });
  }
}

class CheckDepositDetailsView extends StatelessWidget {
  const CheckDepositDetailsView({super.key, required this.deposit});

  final CheckDeposit deposit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextRobotoAutoBold("Deposit Info".tr),
        dividerHorizontal(),
        vSpacer10(),
        twoTextSpaceFixed("Network".tr, deposit.network ?? '', subMaxLine: 2),
        vSpacer5(),
        twoTextSpaceFixed("Amount".tr, (deposit.amount ?? 0).toString(), subMaxLine: 2),
        vSpacer10(),
        TextRobotoAutoBold("Address".tr, fontSize: Dimens.regularFontSizeMid),
        vSpacer2(),
        TextRobotoAutoNormal(deposit.address ?? '', maxLines: 2, color: context.theme.primaryColor),
        vSpacer10(),
        TextRobotoAutoBold("From Address".tr, fontSize: Dimens.regularFontSizeMid),
        vSpacer2(),
        TextRobotoAutoNormal(deposit.fromAddress ?? '', maxLines: 2, color: context.theme.primaryColor),
        vSpacer10(),
        TextRobotoAutoBold("Transaction ID".tr, fontSize: Dimens.regularFontSizeMid),
        vSpacer2(),
        TextRobotoAutoNormal(deposit.txId ?? '', maxLines: 2, color: context.theme.primaryColor),
        vSpacer10(),
        dividerHorizontal(),
        TextRobotoAutoBold(deposit.message ?? '', maxLines: 2, fontSize: Dimens.regularFontSizeMid),
        vSpacer10(),
      ],
    );
  }
}
