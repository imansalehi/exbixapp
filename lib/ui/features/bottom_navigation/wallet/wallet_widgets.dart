import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/data/models/history.dart';
import 'package:exbix_flutter/data/models/wallet.dart';
import 'package:exbix_flutter/helper/app_helper.dart';
import 'package:exbix_flutter/helper/app_widgets.dart';
import 'package:exbix_flutter/ui/features/bottom_navigation/wallet/swap/swap_screen.dart';
import 'package:exbix_flutter/utils/alert_util.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/date_util.dart';
import 'package:exbix_flutter/utils/decorations.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/extentions.dart';
import 'package:exbix_flutter/utils/image_util.dart';
import 'package:exbix_flutter/utils/number_util.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_field_util.dart';
import 'package:exbix_flutter/utils/text_util.dart';

import '../wallet_selection_page.dart';
import 'wallet_controller.dart';
import 'wallet_deposit/currency_wallet_deposit_screen.dart';
import 'wallet_deposit/wallet_deposit_screen.dart';
import 'wallet_withdrawal/currency_wallet_withdrawal_page.dart';
import 'wallet_withdrawal/wallet_withdraw_screen.dart';

class WalletNameView extends StatelessWidget {
  const WalletNameView({super.key, required this.wallet, this.isExpanded = false, this.hideImage});

  final Wallet wallet;
  final bool isExpanded;
  final bool? hideImage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (hideImage != true) showImageNetwork(imagePath: wallet.coinIcon, width: Dimens.iconSizeMid, height: Dimens.iconSizeMid),
        if (hideImage != true) hSpacer10(),
        isExpanded ? Expanded(child: _nameView(context)) : _nameView(context),
      ],
    );
  }

  _nameView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextRobotoAutoBold(wallet.coinType ?? ""),
        TextRobotoAutoNormal(wallet.name ?? "", color: context.theme.primaryColor),
      ],
    );
  }
}

class CommonWalletItemView extends StatelessWidget {
  const CommonWalletItemView({super.key, required this.wallet, required this.fromType, required this.isHide});

  final Wallet wallet;
  final int fromType;
  final bool isHide;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationRoundCorner(),
      padding: const EdgeInsets.all(Dimens.paddingMid),
      margin: const EdgeInsets.only(bottom: Dimens.paddingMid),
      child: Row(
        children: [
          Expanded(child: WalletNameView(wallet: wallet, isExpanded: true)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isHide
                    ? const TextRobotoAutoBold("******", fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.end)
                    : TextRobotoAutoBold(coinFormat(wallet.balance)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    buttonOnlyIcon(
                        iconData: Icons.send_outlined,
                        size: Dimens.iconSizeMin,
                        visualDensity: minimumVisualDensity,
                        iconColor: context.theme.primaryColor,
                        onPress: () => _showTransferView(context, true)),
                    buttonOnlyIcon(
                        iconData: Icons.wallet_outlined,
                        size: Dimens.iconSizeMin,
                        visualDensity: minimumVisualDensity,
                        iconColor: context.theme.primaryColor,
                        onPress: () => _showTransferView(context, false))
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  _showTransferView(BuildContext context, bool isSend) {
    showModalSheetFullScreen(
      context,
      WalletTransferView(
          isSend: isSend,
          fromType: fromType,
          coinType: wallet.coinType ?? '',
          onSubmit: (amount) => Get.find<WalletController>().transferWalletAmount(wallet, fromType, amount, isSend)),
    );
  }
}

class WalletTransferView extends StatelessWidget {
  const WalletTransferView({super.key, required this.isSend, required this.fromType, required this.coinType, required this.onSubmit});

  final bool isSend;
  final int fromType;
  final String coinType;
  final Function(double) onSubmit;

  @override
  Widget build(BuildContext context) {
    final title = isSend ? "Send Balance".tr : "Receive Balance".tr;
    final name = fromType == WalletViewType.p2p ? "P2P" : "Future";
    final subtitle = isSend
        ? "sent_coin_to_spot_wallet".trParams({"coin": coinType, "name": name})
        : "receive_coin_from_spot_wallet".trParams({"coin": coinType, "name": name});
    final amountEditController = TextEditingController();
    RxString error = "".obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        vSpacer15(),
        TextRobotoAutoBold(title),
        vSpacer5(),
        TextRobotoAutoNormal(subtitle, maxLines: 2),
        vSpacer20(),
        textFieldWithSuffixIcon(
            controller: amountEditController,
            labelText: "Amount".tr,
            hint: "Your amount".tr,
            type: const TextInputType.numberWithOptions(decimal: true),
            onTextChange: (text) => error.value = ""),
        Obx(() => error.value.isValid ? TextRobotoAutoNormal(error.value, color: Colors.red, textAlign: TextAlign.center) : vSpacer0()),
        vSpacer20(),
        buttonRoundedMain(
            text: "Exchange".tr,
            onPress: () {
              final amount = makeDouble(amountEditController.text.trim());
              if (amount <= 0) {
                error.value = "amount_must_greater_than_0".tr;
                return;
              }
              hideKeyboard(context: context);
              onSubmit(amount);
            }),
        vSpacer15(),
      ],
    );
  }
}

class SpotWalletItemView extends StatelessWidget {
  const SpotWalletItemView({super.key, required this.wallet, this.onTap, required this.isHide});

  final Wallet wallet;
  final VoidCallback? onTap;
  final bool isHide;

  @override
  Widget build(BuildContext context) {
    String currencyName = getSettingsLocal()?.currency ?? DefaultValue.currency;
    return Padding(
      padding: const EdgeInsets.all(Dimens.paddingMid),
      child: InkWell(
        onTap: onTap ??
            () {
              hideKeyboard();
              showBottomSheetDynamic(context, SpotWalletDetailsView(wallet: wallet), title: "Wallet Details".tr);
            },
        child: Row(
          children: [
            Expanded(child: WalletNameView(wallet: wallet, isExpanded: true)),
            Expanded(
              child: isHide
                  ? const TextRobotoAutoBold("******", fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.end)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextRobotoAutoBold(coinFormat(wallet.availableBalance)),
                        TextRobotoAutoNormal(currencyFormat(wallet.availableBalanceUsd, name: currencyName)),
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class SpotWalletDetailsView extends StatelessWidget {
  SpotWalletDetailsView({super.key, required this.wallet});

  final Wallet wallet;

  final _controller = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    final pairList = _controller.getCoinPairList(wallet.coinType ?? "");
    final isSwapActive = getSettingsLocal()?.swapStatus == 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          vSpacer10(),
          WalletNameView(wallet: wallet),
          vSpacer20(),
          WalletBalanceView(title: 'Total Balance'.tr, coin: wallet.total, currency: wallet.totalBalanceUsd),
          dividerHorizontal(),
          WalletBalanceView(title: 'On Order'.tr, coin: wallet.onOrder, currency: wallet.onOrderUsd),
          dividerHorizontal(),
          WalletBalanceView(title: 'Available Balance'.tr, coin: wallet.availableBalance, currency: wallet.availableBalanceUsd),
          dividerHorizontal(),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (wallet.isDeposit == 1)
                _btnWalletDetails("Deposit".tr, true, onTap: () {
                  if (wallet.currencyType == CurrencyType.crypto) {
                    Get.to(() => WalletDepositScreen(wallet: wallet));
                  } else if (wallet.currencyType == CurrencyType.fiat) {
                    Get.to(() => CurrencyWalletDepositScreen(wallet: wallet));
                  }
                }),
              if (wallet.isWithdrawal == 1)
                _btnWalletDetails("Withdraw".tr, false, onTap: () {
                  if (wallet.currencyType == CurrencyType.crypto) {
                    Get.to(() => WalletWithdrawScreen(wallet: wallet));
                  } else if (wallet.currencyType == CurrencyType.fiat) {
                    Get.to(() => CurrencyWalletWithdrawalScreen(wallet: wallet));
                  }
                }),
              if (wallet.tradeStatus == 1 && pairList.isNotEmpty)
                PopupMenuView(pairList,
                    child: _btnWalletDetails(
                      "Trade".tr,
                      false,
                    ), onSelected: (selected) {
                  Get.back();
                  final pair = _controller.coinPairs.firstWhere((element) => element.coinPairName == selected);
                  getDashboardController().selectedCoinPair.value = pair;
                  getRootController().changeBottomNavIndex(AppBottomNavKey.trade);
                }),
              if (isSwapActive)
                _btnWalletDetails("Swap".tr, false, onTap: () {
                  Get.to(() => SwapScreen(preWallet: wallet));
                }),
            ],
          ),
          vSpacer10(),
        ],
      ),
    );
  }

  _btnWalletDetails(String title, bool isDeposit, {VoidCallback? onTap}) {
    final color = isDeposit ? null : Get.theme.dialogBackgroundColor;
    return buttonText(title,
        bgColor: color,
        fontSize: Dimens.regularFontSizeExtraMid,
        visualDensity: VisualDensity.compact,
        onPress: onTap == null
            ? null
            : () {
                Get.back();
                onTap();
              });
  }
}

class WalletBalanceView extends StatelessWidget {
  const WalletBalanceView({super.key, required this.title, this.coin, this.currency});

  final String title;
  final double? coin;
  final double? currency;

  @override
  Widget build(BuildContext context) {
    String currencyName = getSettingsLocal()?.currency ?? DefaultValue.currency;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(flex: 2, child: TextRobotoAutoBold(title, maxLines: 1, color: context.theme.primaryColorLight)),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextRobotoAutoBold(coinFormat(coin)),
              TextRobotoAutoNormal(currencyFormat(currency, name: currencyName)),
            ],
          ),
        ),
      ],
    );
  }
}

class TotalBalanceView extends StatelessWidget {
  const TotalBalanceView(this.isHide, this.totalBalance,
      {super.key, this.onHide, this.title, this.totalUsd, this.onHistoryTap, this.coins, this.selectedCoin, this.onSelectCoin});

  final bool isHide;
  final double? totalBalance;
  final double? totalUsd;
  final Function(bool)? onHide;
  final VoidCallback? onHistoryTap;
  final String? title;
  final List<String>? coins;
  final String? selectedCoin;
  final Function(String)? onSelectCoin;

  @override
  Widget build(BuildContext context) {
    String currencyName = getSettingsLocal()?.currency ?? DefaultValue.currency;
    final iconData = isHide ? Icons.visibility_off_outlined : Icons.visibility_outlined;
    final titleL = title ?? 'Total Balance'.tr;
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TextRobotoAutoNormal(titleL),
                buttonOnlyIcon(
                    iconData: iconData,
                    visualDensity: minimumVisualDensity,
                    onPress: () {
                      GetStorage().write(PreferenceKey.isBalanceHide, !isHide);
                      gIsBalanceHide.value = !isHide;
                      if (onHide != null) onHide!(!isHide);
                    })
              ],
            ),
            isHide
                ? TextRobotoAutoNormal("Balance_hidden".tr)
                : Row(
                    children: [
                      TextRobotoAutoBold(coinFormat(totalBalance), fontSize: Dimens.regularFontSizeLarge),
                      hSpacer5(),
                      if (coins.isValid || selectedCoin.isValid)
                        PopupMenuView(coins ?? [],
                            child: _coinNameView(selectedCoin, coins.isValid),
                            onSelected: (selected) => onSelectCoin == null ? null : onSelectCoin!(selected)),
                    ],
                  ),
            if (!isHide) vSpacer2(),
            if (!isHide) TextRobotoAutoNormal("= ${currencyFormat(totalUsd)} $currencyName")
          ],
        ),
        const Spacer(),
        if (onHistoryTap != null) buttonOnlyIcon(iconData: Icons.history, visualDensity: minimumVisualDensity, onPress: onHistoryTap)
      ],
    );
  }

  _coinNameView(String? coinType, bool showIcon) {
    return Row(children: [
      TextRobotoAutoBold(coinType ?? "", fontSize: Dimens.regularFontSizeExtraMid),
      if (showIcon) Icon(Icons.expand_more, size: Dimens.iconSizeMin, color: Get.theme.primaryColor)
    ]);
  }
}

class WalletTopButtonsView extends StatelessWidget {
  const WalletTopButtonsView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = (context.width - 50) / 3;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: width,
          child: buttonText("Deposit".tr, textColor: Colors.white, onPress: () => _openWalletListPage(context, true)),
        ),
        SizedBox(
          width: width,
          child: buttonText("Withdraw".tr, bgColor: context.theme.dialogBackgroundColor, onPress: () => _openWalletListPage(context, false)),
        ),
        getSettingsLocal()?.swapStatus == 1
            ? SizedBox(
                width: width,
                child: buttonText("Swap".tr, bgColor: context.theme.dialogBackgroundColor, onPress: () => Get.to(() => const SwapScreen())),
              )
            : hSpacer50(),
      ],
    );
  }

  void _openWalletListPage(BuildContext context, bool isDeposit) {
    showBottomSheetFullScreen(context, WalletSelectionPage(fromKey: isDeposit ? FromKey.buy : FromKey.sell), title: "Select Wallet".tr);
  }
}

class WalletRecentTransactionItemView extends StatelessWidget {
  const WalletRecentTransactionItemView({super.key, required this.history, required this.type});

  final History history;
  final String type;

  @override
  Widget build(BuildContext context) {
    final statusData = getStatusData(history.status ?? 0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimens.paddingMid, horizontal: Dimens.paddingMid),
      child: Column(
        children: [
          TwoTextSpaceFixed(history.coinType ?? "", statusData.first, subColor: statusData.last, color: context.theme.primaryColor),
          TwoTextSpaceFixed('Amount'.tr, coinFormat(history.amount)),
          TwoTextSpaceFixed('Fees'.tr, coinFormat(history.fees)),
          TwoTextSpaceFixed('Address'.tr, history.address ?? "", color: context.theme.primaryColorLight),
          TwoTextSpaceFixed('Created At'.tr, formatDate(history.createdAt, format: dateTimeFormatDdMMMYyyyHhMm)),
          dividerHorizontal()
        ],
      ),
    );
  }
}

class WalletBalanceViewWithBg extends StatelessWidget {
  const WalletBalanceViewWithBg({super.key, this.balance});

  final double? balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.paddingMid),
      decoration: boxDecorationRoundCorner(color: context.theme.dialogBackgroundColor),
      child: Row(
        children: [
          TextRobotoAutoBold("Balance".tr),
          hSpacer10(),
          Expanded(child: TextRobotoAutoBold(coinFormat(balance), textAlign: TextAlign.end, fontSize: Dimens.regularFontSizeLarge)),
        ],
      ),
    );
  }
}
