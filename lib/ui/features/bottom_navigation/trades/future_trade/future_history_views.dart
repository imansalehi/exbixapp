import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/data/models/future_data.dart';
import 'package:exbix_flutter/helper/app_helper.dart';
import 'package:exbix_flutter/ui/features/auth/sign_in/sign_in_screen.dart';
import 'package:exbix_flutter/utils/alert_util.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/date_util.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/extentions.dart';
import 'package:exbix_flutter/utils/number_util.dart';
import 'package:exbix_flutter/utils/text_field_util.dart';
import 'package:exbix_flutter/utils/text_util.dart';
import 'package:exbix_flutter/helper/app_widgets.dart';
import 'package:exbix_flutter/utils/appbar_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'future_trade_controller.dart';

class FutureHistoryViews extends StatefulWidget {
  final String? fromPage;

  const FutureHistoryViews({super.key, this.fromPage});

  @override
  FutureHistoryViewsState createState() => FutureHistoryViewsState();
}

class FutureHistoryViewsState extends State<FutureHistoryViews> with SingleTickerProviderStateMixin {
  final _controller = Get.find<FutureTradeController>();
  TabController? orderTabController;

  @override
  void initState() {
    orderTabController = TabController(vsync: this, length: 5);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        tabBarUnderline(["Position".tr, "Open Orders".tr, "Order History".tr, "Trade History".tr, "Transaction History".tr], orderTabController,
            isScrollable: true, fontSize: Dimens.regularFontSizeMid, onTap: (index) {
          _controller.selectedHistoryTabIndex.value = index;
          _controller.getFutureTradeHistoryList(_controller.selectedHistoryTabIndex.value);
        }),
        dividerHorizontal(height: 0),
        vSpacer10(),
        Obx(() => gUserRx.value.id == 0
            ? Padding(
                padding: const EdgeInsets.all(Dimens.paddingMid),
                child: textSpanWithAction("Want to trade".tr, "Login".tr, onTap: () => Get.to(() => const SignInPage())),
              )
            : _listView())
      ],
    );
  }

  _listView() {
    return Obx(() {
      return _controller.tradeHistoryList.isEmpty
          ? handleEmptyViewWithLoading(_controller.isHistoryLoading.value)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_controller.selectedHistoryTabIndex.value == 0)
                  buttonText("Close All Positions".tr,
                      bgColor: Colors.transparent, textColor: Get.theme.focusColor, visualDensity: minimumVisualDensity, onPress: () {
                    alertForAction(context,
                        title: "Close All Positions".tr,
                        subTitle: "Want to close all current orders on the list".tr,
                        buttonTitle: "Close All",
                        onOkAction: () => _controller.closeLongShortAllOrders());
                  }),
                Column(
                    children: List.generate(_controller.tradeHistoryList.length, (index) {
                  final item = _controller.tradeHistoryList[index];
                  if (item is FutureTransaction) {
                    return FutureTransactionItemView(trade: item);
                  } else {
                    if (_controller.selectedHistoryTabIndex.value == 0) {
                      return PositionItemView(
                        trade: item,
                        onIsMarketChange: (isMarket) {
                          _controller.tradeHistoryList[index].isLimitLocal = isMarket;
                          _controller.tradeHistoryList.refresh();
                        },
                        onTextChange: (text) {
                          _controller.tradeHistoryList[index].profitLossCalculation?.marketPrice = makeDouble(text);
                        },
                      );
                    } else {
                      return FutureTradeItemView(trade: item, selectedTab: _controller.selectedHistoryTabIndex.value);
                    }
                  }
                })),
              ],
            );
    });
  }
}

class PositionItemView extends StatelessWidget {
  const PositionItemView({super.key, required this.trade, required this.onIsMarketChange, required this.onTextChange});

  final FutureTrade trade;
  final Function(int) onIsMarketChange;
  final Function(String) onTextChange;

  @override
  Widget build(BuildContext context) {
    final pColorL = context.theme.primaryColorLight;
    final plc = trade.profitLossCalculation;
    return InkWell(
      focusColor: Colors.transparent,
      onTap: () {
        hideKeyboard();
        showBottomSheetDynamic(context, PositionItemDetailsView(trade: trade));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid, vertical: Dimens.paddingMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextRobotoAutoBold("${plc?.symbol ?? ""} (${"Perpetual".tr})"),
                buttonOnlyIcon(
                    iconData: Icons.drive_file_rename_outline,
                    iconColor: pColorL,
                    size: Dimens.iconSizeMin,
                    visualDensity: minimumVisualDensity,
                    onPress: () => showBottomSheetFullScreen(context, PositionItemEditView(trade: trade),
                        title: "TP/SL for entire position".tr, isScrollControlled: false))
              ],
            ),
            twoTextSpaceFixed("${"Size".tr}: ", "${coinFormat(trade.amountInTradeCoin)} ${plc?.tradeCoinType ?? ''}", color: pColorL),
            Wrap(
              children: [
                TextRobotoAutoBold("${"PNL(ROE%)".tr}: ", color: pColorL),
                TextRobotoAutoBold("${coinFormat(plc?.pnl, fixed: 4)} ${plc?.baseCoinType ?? ""}",
                    color: getNumberColor(plc?.pnl), textAlign: TextAlign.end),
                hSpacer5(),
                TextRobotoAutoBold("(${coinFormat(plc?.roe, fixed: 4)}%)", color: getNumberColor(plc?.roe), textAlign: TextAlign.end),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                tabBarText(["Market".tr, "Limit".tr], trade.isLimitLocal ?? 0, onIsMarketChange, selectedColor: context.theme.focusColor),
                SizedBox(
                    height: Dimens.iconSizeMid,
                    width: 120,
                    child: TextFieldNoBorder(
                      hint: "0",
                      controller: TextEditingController(text: coinFormat(plc?.marketPrice)),
                      inputType: const TextInputType.numberWithOptions(decimal: true),
                      onTextChange: onTextChange,
                    )),
              ],
            ),
            dividerHorizontal()
          ],
        ),
      ),
    );
  }
}

class PositionItemDetailsView extends StatelessWidget {
  const PositionItemDetailsView({super.key, required this.trade});

  final FutureTrade trade;

  @override
  Widget build(BuildContext context) {
    final pColorL = context.theme.primaryColorLight;
    final baseCoin = trade.profitLossCalculation?.baseCoinType ?? "";
    return Column(
      children: [
        twoTextSpaceFixed("${"Symbol".tr}: ", "${trade.profitLossCalculation?.symbol ?? ""} (${"Perpetual".tr})", color: pColorL),
        twoTextSpace("${"Size".tr}: ", coinFormat(trade.amountInTradeCoin)),
        twoTextSpace("${"Entry Price".tr}: ", coinFormat(trade.entryPrice)),
        twoTextSpace("${"Mark Price".tr}: ", coinFormat(trade.currentMarketPrice)),
        twoTextSpace("${"Liq Price".tr}: ", coinFormat(trade.liquidationPrice)),
        twoTextSpace("${"Margin".tr}: ", "${coinFormat(trade.margin)} $baseCoin"),
        twoTextSpace("${"Margin Ratio".tr}: ", (trade.profitLossCalculation?.marginRatio ?? 0).toString()),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextRobotoAutoBold("${"PNL(ROE%)".tr}: ", color: pColorL),
            const Spacer(),
            TextRobotoAutoBold("${coinFormat(trade.profitLossCalculation?.pnl, fixed: 4)} $baseCoin",
                color: getNumberColor(trade.profitLossCalculation?.pnl), textAlign: TextAlign.end),
            hSpacer5(),
            TextRobotoAutoBold("(${coinFormat(trade.profitLossCalculation?.roe, fixed: 4)}%)",
                color: getNumberColor(trade.profitLossCalculation?.roe), textAlign: TextAlign.end),
          ],
        ),
      ],
    );
  }
}

class PositionItemEditView extends StatelessWidget {
  const PositionItemEditView({super.key, required this.trade});

  final FutureTrade trade;

  @override
  Widget build(BuildContext context) {
    final baseCoin = trade.profitLossCalculation?.baseCoinType ?? "";
    final profitEditController = TextEditingController();
    final lossEditController = TextEditingController();
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(Dimens.paddingMid),
        children: [
          vSpacer10(),
          twoTextSpaceFixed("${"Symbol".tr}: ", trade.profitLossCalculation?.symbol ?? ""),
          vSpacer5(),
          twoTextSpaceFixed("${"Entry Price".tr}: ", "${coinFormat(trade.entryPrice)} $baseCoin"),
          vSpacer5(),
          twoTextSpaceFixed("${"Mark Price".tr}: ", "${coinFormat(trade.currentMarketPrice)} $baseCoin"),
          vSpacer10(),
          textFieldWithPrefixSuffixText(
              controller: profitEditController, hint: "0", prefixText: "Take Profit".tr, suffixText: "Mark".tr, textAlign: TextAlign.center),
          vSpacer10(),
          textFieldWithPrefixSuffixText(
              controller: lossEditController, hint: "0", prefixText: "Stop Loss".tr, suffixText: "Mark".tr, textAlign: TextAlign.center),
          vSpacer15(),
          buttonRoundedMain(
              text: "Confirm".tr,
              buttonHeight: Dimens.btnHeightMid,
              onPress: () {
                final takeProfit = makeDouble(profitEditController.text.trim());
                if (takeProfit <= 0) {
                  showToast("take_profit_must_greater_than_0".tr);
                  return;
                }
                final stopLoss = makeDouble(lossEditController.text.trim());
                if (stopLoss <= 0) {
                  showToast("stop_loss_must_greater_than_0".tr);
                  return;
                }
                hideKeyboard(context: context);
                Get.find<FutureTradeController>().updateProfitLossLongShortOrder(trade, takeProfit, stopLoss);
              }),
          vSpacer10(),
        ],
      ),
    );
  }
}
//Take profit price must be greater than 0!

class FutureTradeItemView extends StatelessWidget {
  const FutureTradeItemView({super.key, required this.trade, required this.selectedTab});

  final FutureTrade trade;
  final int selectedTab;

  @override
  Widget build(BuildContext context) {
    final tradeCoin = trade.profitLossCalculation?.tradeCoinType ?? "";
    final baseCoin = trade.profitLossCalculation?.baseCoinType ?? "";
    final sideData = getFutureTradeSideData(trade.tradeType, trade.side);
    final feeData = getFutureTradeFeeData(trade.tradeType, trade.isMarket);
    final pColorL = context.theme.primaryColorLight;
    final tCondition = _getConditionTex(trade);
    final fontSize = isTextScaleGetterThanOne(context) ? Dimens.regularFontSizeExtraMid : Dimens.regularFontSizeMid;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TextRobotoAutoBold(trade.profitLossCalculation?.symbol ?? "", fontSize: fontSize),
            TextRobotoAutoBold(sideData.first, fontSize: fontSize, color: sideData.last),
            TextRobotoAutoBold(feeData.first, fontSize: fontSize),
          ]),
          twoTextSpaceFixed("${"Price".tr}: ", "${coinFormat(trade.price)} $baseCoin", color: pColorL),
          twoTextSpaceFixed("${(selectedTab == 3) ? "Quantity".tr : "Amount".tr}: ", "${coinFormat(trade.amountInTradeCoin)} $tradeCoin",
              color: pColorL),
          if (selectedTab == 3)
            twoTextSpaceFixed("${"Profit".tr}: ", "${trade.profitLossCalculation?.pnl ?? 0} $baseCoin", color: pColorL)
          else if (tCondition.isNotEmpty)
            twoTextSpaceFixed("${"Conditions".tr}: ", _getConditionTex(trade), color: pColorL),
          twoTextSpaceFixed("${"Time".tr}: ", formatDate(trade.createdAt, format: dateTimeFormatDdMMMMYyyyHhMm), color: pColorL, subMaxLine: 2),
          if (selectedTab == 3)
            twoTextSpaceFixed("${"Role".tr}: ", "Taker".tr, fontSize: Dimens.regularFontSizeMid, color: pColorL, subColor: Colors.red),
          if (selectedTab == 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                buttonText("Cancel".tr, visualDensity: minimumVisualDensity, onPress: () {
                  alertForAction(
                    context,
                    title: "Want to cancel the order".tr,
                    buttonTitle: "Cancel".tr,
                    onOkAction: () => Get.find<FutureTradeController>().canceledLongShortOrder(trade),
                  );
                }),
                if ((trade.takeProfitPrice ?? 0) > 0 || (trade.stopLossPrice ?? 0) > 0)
                  buttonOnlyIcon(
                      iconData: Icons.source_outlined,
                      size: Dimens.iconSizeMin,
                      iconColor: pColorL,
                      visualDensity: minimumVisualDensity,
                      onPress: () => showBottomSheetFullScreen(context, TakeProfitStopLossView(trade: trade), title: "Take Profit and Stop Loss".tr))
              ],
            ),
          dividerHorizontal()
        ],
      ),
    );
  }

  String _getConditionTex(FutureTrade item) {
    if (item.side == 1) {
      if ((item.takeProfitPrice ?? 0) > 0) {
        return "${"Mark Price".tr} >= ${item.takeProfitPrice}";
      } else if ((item.stopLossPrice ?? 0) > 0) {
        return "${"Mark Price".tr} <= ${item.stopLossPrice}";
      } else if ((item.stopPrice ?? 0) > 0) {
        return "${"Mark Price".tr} >= ${item.stopPrice}";
      }
    } else {
      if ((item.takeProfitPrice ?? 0) > 0) {
        return "${"Mark Price".tr} <= ${item.takeProfitPrice}";
      } else if ((item.stopLossPrice ?? 0) > 0) {
        return "${"Mark Price".tr} >= ${item.stopLossPrice}";
      } else if ((item.stopPrice ?? 0) > 0) {
        return "${"Mark Price".tr} <= ${item.stopPrice}";
      }
    }
    return "";
  }
}

//ignore: must_be_immutable
class TakeProfitStopLossView extends StatelessWidget {
  TakeProfitStopLossView({super.key, required this.trade});

  FutureTrade trade;
  RxBool isLoading = true.obs;

  @override
  Widget build(BuildContext context) {
    Get.find<FutureTradeController>().getFutureTradeTakeProfitStopLossDetails(trade, (newTrade) {
      trade = newTrade;
      isLoading.value = false;
    });

    return Obx(() {
      final childrenOne = trade.children.isValid ? trade.children!.first : null;
      final childrenTwo = trade.children.isValid && trade.children!.length > 1 ? trade.children![1] : null;
      final price = (trade.stopPrice ?? 0) > 0 ? trade.stopPrice : trade.price;
      final priceOne = (childrenOne?.takeProfitPrice ?? 0) > 0 ? childrenOne?.takeProfitPrice : childrenOne?.stopLossPrice;
      final priceTwo = (childrenTwo?.takeProfitPrice ?? 0) > 0 ? childrenTwo?.takeProfitPrice : childrenTwo?.stopLossPrice;

      return Expanded(
          child: isLoading.value
              ? showLoading()
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: Dimens.paddingMid, horizontal: Dimens.paddingLarge),
                  children: [
                    _commonInfoView(trade, "False".tr, price, trade.side == TradeType.buy),
                    if (childrenOne != null) vSpacer20(),
                    if (childrenOne != null)
                      _commonInfoView(childrenOne, "True".tr, priceOne, childrenOne.side == TradeType.sell, title: "If Order B Is Filled Fully".tr),
                    if (childrenTwo != null) vSpacer20(),
                    if (childrenTwo != null)
                      _commonInfoView(childrenTwo, "True".tr, priceTwo, childrenTwo.side == TradeType.sell, title: "If Order C Is Filled Fully".tr),
                  ],
                ));
    });
  }

  _commonInfoView(FutureTrade trade, String reduce, double? price, bool isBuy, {String? title}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (title.isValid) TextRobotoAutoBold(title ?? "",  maxLines: 3),
      if (title.isValid) vSpacer5(),
      twoTextSpace("Side".tr, isBuy ? "Buy".tr : "Sell".tr, subColor: isBuy ? Colors.green : Colors.red),
      vSpacer5(),
      twoTextSpace("Amount".tr, "${coinFormat(trade.amountInTradeCoin)} ${trade.tradeCoinType ?? ""}"),
      vSpacer5(),
      twoTextSpace("Stop Price".tr, coinFormat(price)),
      vSpacer5(),
      twoTextSpace("Trigger".tr, "Mark Price".tr),
      vSpacer5(),
      twoTextSpace("Reduce Only".tr, reduce),
    ]);
  }
}

class FutureTransactionItemView extends StatelessWidget {
  const FutureTransactionItemView({super.key, required this.trade});

  final FutureTransaction trade;

  @override
  Widget build(BuildContext context) {
    final typeData = getFutureTradeTransactionTypeData(trade.type);
    final colorPL = Get.theme.primaryColorLight;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
      child: Column(
        children: [
          Row(children: [
            TextRobotoAutoBold("${"Asset".tr}: ", color: colorPL),
            TextRobotoAutoBold(trade.coinType ?? ""),
            const Spacer(),
            TextRobotoAutoBold("${"Symbol".tr}: ", color: colorPL),
            TextRobotoAutoBold(trade.symbol ?? ""),
          ]),
          vSpacer5(),
          twoTextSpace("${"Amount".tr}: ", coinFormat(trade.amount)),
          twoTextSpace("${"Type".tr}: ", typeData.first.toString().toUpperCase()),
          twoTextSpaceFixed("${"Time".tr}: ", formatDate(trade.createdAt, format: dateTimeFormatDdMMMMYyyyHhMm), subMaxLine: 2, color: colorPL),
          dividerHorizontal()
        ],
      ),
    );
  }
}
