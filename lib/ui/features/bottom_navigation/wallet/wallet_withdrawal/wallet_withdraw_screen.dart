import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/api_constants.dart';
import 'package:exbix_flutter/data/models/faq.dart';
import 'package:exbix_flutter/data/models/history.dart';
import 'package:exbix_flutter/data/models/wallet.dart';
import 'package:exbix_flutter/helper/app_helper.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/extentions.dart';
import 'package:exbix_flutter/utils/text_field_util.dart';
import 'package:exbix_flutter/utils/text_util.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/helper/app_widgets.dart';
import 'package:exbix_flutter/utils/alert_util.dart';
import 'package:exbix_flutter/utils/appbar_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/number_util.dart';
import 'package:exbix_flutter/utils/spacers.dart';

import '../../../side_navigation/activity/activity_screen.dart';
import '../../../side_navigation/faq/faq_page.dart';
import '../wallet_widgets.dart';
import 'wallet_withdrawal_controller.dart';

class WalletWithdrawScreen extends StatefulWidget {
  const WalletWithdrawScreen({super.key, required this.wallet});

  final Wallet wallet;

  @override
  State<WalletWithdrawScreen> createState() => _WalletWithdrawScreenState();
}

class _WalletWithdrawScreenState extends State<WalletWithdrawScreen> {
  final _controller = Get.put(WalletWithdrawalController());
  final _addressEditController = TextEditingController();
  final _amountEditController = TextEditingController();
  final _memoEditController = TextEditingController();
  Rx<Wallet> walletRx = Wallet(id: 0).obs;
  RxList<Network> networkList = <Network>[].obs;
  Rx<Network> selectedNetwork = Network(id: 0).obs;
  Rx<PreWithdraw> preWithdraw = PreWithdraw().obs;
  bool isWithdraw2FActive = false;
  RxList<History> historyList = <History>[].obs;
  RxList<FAQ> faqList = <FAQ>[].obs;
  Timer? _feeTimer;
  RxInt baseNetworkType = 0.obs;

  @override
  void initState() {
    walletRx.value = widget.wallet;
    isWithdraw2FActive = getSettingsLocal()?.twoFactorWithdraw == "1";
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.getWalletWithdrawal(widget.wallet, (data) {
        _setViewData(data);
        _controller.getHistoryListData(HistoryType.withdraw, (list) => historyList.value = list);
        _controller.getFAQList(FAQType.withdrawn, (list) => faqList.value = list);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarBackWithActions(
          title: "Withdraw".tr,
          actionIcons: [Icons.history],
          onPress: (i) {
            TemporaryData.activityType = HistoryType.withdraw;
            Get.to(() => const ActivityScreen());
          }),
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(Dimens.paddingMid),
          children: [
            Padding(
              padding: const EdgeInsets.all(Dimens.paddingMid),
              child: WalletNameView(wallet: walletRx.value),
            ),
            Obx(() => WalletBalanceViewWithBg(balance: walletRx.value.balance)),
            _networkView(),
            vSpacer10(),
            textFieldWithSuffixIcon(controller: _addressEditController, hint: "Address".tr, labelText: "Address".tr, onTextChange: _onTextChanged),
            TextRobotoAutoNormal("only_enter_valid_address_withdraw".trParams({"coin": walletRx.value.coinType ?? ""}),
                color: context.theme.colorScheme.error, maxLines: 2),
            vSpacer10(),
            textFieldWithSuffixIcon(
                controller: _amountEditController,
                hint: "Amount to withdraw".tr,
                labelText: "Amount".tr,
                type: const TextInputType.numberWithOptions(decimal: true),
                onTextChange: _onTextChanged),
            Obx(() {
              final fee = preWithdraw.value.fees;
              return fee != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextRobotoAutoNormal(
                            "withdraw_fee_charged_amount_text".trParams({"amount": coinFormat(fee), "coin": preWithdraw.value.coinType ?? ""}),
                            maxLines: 2,
                            color: context.theme.primaryColor,
                            fontSize: Dimens.regularFontSizeMin),
                        vSpacer5(),
                      ],
                    )
                  : vSpacer0();
            }),
            Obx(() {
              final wallet = walletRx.value;
              return TextRobotoAutoNormal(
                  "withdraw_Max_min_fees".trParams({
                    "fee": coinFormat(wallet.withdrawalFees),
                    "sign": wallet.withdrawalFeesType == 2 ? "%" : "",
                    "min": coinFormat(wallet.minimumWithdrawal),
                    "max": coinFormat(wallet.maximumWithdrawal),
                  }),
                  maxLines: 2);
            }),
            vSpacer10(),
            textFieldWithSuffixIcon(controller: _memoEditController, hint: "Memo if needed".tr, labelText: "Memo (optional)".tr),
            TextRobotoAutoNormal("ensure_memo_correct".tr, maxLines: 2),
            vSpacer10(),
            Obx(() {
              final secret = gUserRx.value.google2FaSecret;
              return (isWithdraw2FActive && !secret.isValid)
                  ? textWithBackground("Google 2FA is not enabled".tr, bgColor: Colors.red.withOpacity(0.25), textColor: context.theme.primaryColor)
                  : vSpacer0();
            }),
            vSpacer20(),
            buttonRoundedMain(text: "Withdraw".tr, onPress: () => _checkInputData()),
            vSpacer30(),
            _historyListView(),
            Obx(() => FAQRelatedView(faqList.toList())),
          ],
        ),
      ),
    );
  }

  void _setViewData(Map data) {
    if (data.containsKey(APIKeyConstants.wallet)) {
      final newWallet = Wallet.fromJson(data[APIKeyConstants.wallet]);
      walletRx.value.balance = newWallet.balance;
      walletRx.value.availableBalance = newWallet.availableBalance;
      walletRx.value.minimumWithdrawal = newWallet.minimumWithdrawal;
      walletRx.value.maximumWithdrawal = newWallet.maximumWithdrawal;
      walletRx.value.withdrawalFees = newWallet.withdrawalFees;
      walletRx.value.withdrawalFeesType = newWallet.withdrawalFeesType;
      walletRx.value.network = newWallet.network;
      walletRx.value.networkName = newWallet.networkName;
      walletRx.value.networkId = newWallet.networkId;
    }
    if (getSettingsLocal()?.isEvmWallet ?? false) {
      final netData = data[APIKeyConstants.data];
      if (netData != null && netData is Map) {
        baseNetworkType.value = makeInt(netData[APIKeyConstants.baseType]);
        if (NetworkType.coinPayment == baseNetworkType.value && (walletRx.value.coinType ?? '').toLowerCase() == "usdt") {
          final nList = netData[APIKeyConstants.coinPaymentNetworks] ?? [];
          networkList.value = List<Network>.from(nList.map((x) => Network.fromJson(x)));
        } else if ([NetworkType.trc20Token, NetworkType.evmBaseCoin, NetworkType.evmSolana].contains(baseNetworkType.value)) {
          final nList = netData[APIKeyConstants.networks] ?? [];
          networkList.value = List<Network>.from(nList.map((x) => Network.fromJson(x)));
        } else {
          selectedNetwork.value = Network(id: walletRx.value.networkId ?? 0, baseType: baseNetworkType.value);
        }
      }
    } else {
      final dataList = data[APIKeyConstants.data];
      if (dataList != null) {
        networkList.value = List<Network>.from(dataList.map((x) => Network.fromJson(x)));
      }
      if (networkList.isNotEmpty) {
        final net = networkList.firstWhereOrNull((element) => element.id == walletRx.value.network);
        if (net != null) selectedNetwork.value = net;
      }
    }
  }

  _networkView() {
    return Obx(() => networkList.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              vSpacer10(),
              TextRobotoAutoBold("Select Network".tr),
              dropDownNetworks(networkList, selectedNetwork.value, "Select".tr, onChange: (value) {
                selectedNetwork.value = value;
                _getPreWithdrawDate();
              })
            ],
          )
        : vSpacer0());
  }

  _historyListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextRobotoAutoBold("Recent Withdrawals".tr),
        Obx(() => historyList.isEmpty
            ? showEmptyView(height: 50)
            : Column(
                children: List.generate(historyList.length, (index) {
                return WalletRecentTransactionItemView(history: historyList[index], type: HistoryType.deposit);
              })))
      ],
    );
  }

  void _onTextChanged(String text) {
    if (_feeTimer?.isActive ?? false) _feeTimer?.cancel();
    _feeTimer = Timer(const Duration(seconds: 1), () => _getPreWithdrawDate());
  }

  void _getPreWithdrawDate() {
    final address = _addressEditController.text.trim();
    final amount = makeDouble(_amountEditController.text.trim());
    if (address.isEmpty || amount <= 0) {
      preWithdraw.value = PreWithdraw();
      return;
    }
    if (getSettingsLocal()?.isEvmWallet ?? false) {
      _controller.preWithdrawalProcessEvm(address, amount, widget.wallet.id, selectedNetwork.value, (data) => preWithdraw.value = data);
    } else {
      _controller.preWithdrawalProcess(
          address, amount, widget.wallet.id, network: selectedNetwork.value.networkType, (data) => preWithdraw.value = data);
    }
  }

  void _checkInputData() {
    if (networkList.isNotEmpty && selectedNetwork.value.id == 0) {
      showToast("select network".tr);
      return;
    }
    final address = _addressEditController.text.trim();
    if (address.isEmpty) {
      showToast("Address can not be empty".tr);
      return;
    }
    final amount = makeDouble(_amountEditController.text.trim());
    final minAmount = widget.wallet.minimumWithdrawal ?? 0;
    if (amount < minAmount) {
      showToast("Amount_less_then".trParams({"amount": minAmount.toString()}));
      return;
    }
    final maxAmount = widget.wallet.maximumWithdrawal ?? 0;
    if (amount > maxAmount) {
      showToast("Amount_greater_then".trParams({"amount": maxAmount.toString()}));
      return;
    }
    if (isWithdraw2FActive && !gUserRx.value.google2FaSecret.isValid) {
      showToast("Please setup your google 2FA".tr);
      return;
    }
    showModalSheetFullScreen(context, _withdrawConfirmView(address, amount));
  }

  Widget _withdrawConfirmView(String address, double amount) {
    final subTitle = "${"You will withdrawal".tr} $amount ${widget.wallet.coinType ?? ""} ${"to this address".tr} $address";
    final codeEditController = TextEditingController();
    return Column(
      children: [
        vSpacer10(),
        TextRobotoAutoBold("Withdrawal Coin".tr, fontSize: Dimens.regularFontSizeLarge),
        vSpacer10(),
        TextRobotoAutoBold(subTitle, maxLines: 3),
        vSpacer10(),
        if (isWithdraw2FActive) textFieldWithSuffixIcon(controller: codeEditController, hint: "Input 2FA code".tr, labelText: "2FA code".tr),
        vSpacer15(),
        buttonRoundedMain(
            text: "Withdraw".tr,
            onPress: () {
              if (isWithdraw2FActive && codeEditController.text.trim().length < DefaultValue.codeLength) {
                showToast("Code length must be".trParams({"count": DefaultValue.codeLength.toString()}));
                return;
              }
              hideKeyboard(context: context);
              final memo = _memoEditController.text.trim();
              if (getSettingsLocal()?.isEvmWallet ?? false) {
                selectedNetwork.value.baseType = baseNetworkType.value;
                _controller.withdrawProcessEvm(widget.wallet, address, amount, codeEditController.text.trim(), selectedNetwork.value, memo);
              } else {
                _controller.withdrawProcess(
                    widget.wallet, address, amount, selectedNetwork.value.networkType ?? "", codeEditController.text.trim(), memo);
              }
            }),
        vSpacer10(),
      ],
    );
  }
}
