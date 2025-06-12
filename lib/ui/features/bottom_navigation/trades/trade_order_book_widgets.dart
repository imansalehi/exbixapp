import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/data/models/dashboard_data.dart';
import 'package:exbix_flutter/data/models/exchange_order.dart';
import 'package:exbix_flutter/helper/app_widgets.dart';
import 'package:exbix_flutter/utils/alert_util.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/extentions.dart';
import 'package:exbix_flutter/utils/image_util.dart';
import 'package:exbix_flutter/utils/number_util.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_util.dart';

import 'trade_widgets.dart';

class OderBookFixedView extends StatelessWidget {
  const OderBookFixedView(this.selectedOrderSort,
      {super.key,
      required this.order,
      this.prices,
      required this.buyList,
      required this.sellList,
      required this.onShortChange,
      required this.selectedHeaderIndex,
      required this.onHeaderChange});

  final String selectedOrderSort;
  final OrderData? order;
  final List<PriceData>? prices;
  final List<ExchangeOrder> buyList;
  final List<ExchangeOrder> sellList;
  final Function(String) onShortChange;
  final int selectedHeaderIndex;
  final Function(int) onHeaderChange;

  @override
  Widget build(BuildContext context) {
    List<ExchangeOrder> bList = [], sList = [];
    if (selectedOrderSort != FromKey.buy) {
      final listLength = getListLength(sellList);
      sList = sellList.sublist(sellList.length - listLength);
    }
    if (selectedOrderSort != FromKey.sell) {
      final listLength = getListLength(buyList);
      bList = buyList.take(listLength).toList();
    }

    final total = order?.total;
    PriceData? lastPData = prices.isValid ? prices?.first : PriceData();
    final isUp = (lastPData?.price ?? 0) >= (lastPData?.lastPrice ?? 0);
    final color = isUp ? gBuyColor : gSellColor;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextRobotoAutoNormal("${"Price".tr}\n(${total?.baseWallet?.coinType ?? ""})", fontSize: Dimens.regularFontSizeMin, maxLines: 2),
            InkWell(
              onTap: () => _onArrowTap(context),
              child: Text.rich(
                TextSpan(
                  text: selectedHeaderIndex == 1 ? "Total".tr : "Amount".tr,
                  style: Get.theme.textTheme.displaySmall!.copyWith(fontSize: Dimens.regularFontSizeMin),
                  children: [
                    WidgetSpan(child: Icon(Icons.arrow_drop_down, size: Dimens.iconSizeMinExtra, color: context.theme.primaryColorLight)),
                    TextSpan(
                        text: "\n(${total?.tradeWallet?.coinType ?? ""})",
                        style: Get.theme.textTheme.displaySmall!.copyWith(fontSize: Dimens.regularFontSizeMin)),
                  ],
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
        vSpacer5(),
        selectedOrderSort == FromKey.buy
            ? vSpacer0()
            : ConstrainedBox(
                constraints: const BoxConstraints(minHeight: Dimens.menuHeightSettings),
                child: Column(
                  children: List.generate(sList.length, (index) {
                    return OderBookItemMinView(sList[index], FromKey.sell, selectedHeaderIndex == 1);
                  }),
                )),
        vSpacer5(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(child: TextRobotoAutoBold(coinFormat(lastPData?.price), fontSize: Dimens.regularFontSizeMid, color: color, maxLines: 1)),
                Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward, color: color, size: Dimens.iconSizeMinExtra),
              ],
            ),
            TextRobotoAutoBold("= ${currencyFormat(lastPData?.lastPrice)}(${order?.baseCoin ?? ""})",
                fontSize: Dimens.regularFontSizeSmall, color: context.theme.primaryColorLight),
          ],
        ),
        vSpacer5(),
        selectedOrderSort == FromKey.sell
            ? vSpacer0()
            : ConstrainedBox(
                constraints: const BoxConstraints(minHeight: Dimens.menuHeightSettings),
                child: Column(
                  children: List.generate(bList.length, (index) {
                    return OderBookItemMinView(bList[index], FromKey.buy, selectedHeaderIndex == 1);
                  }),
                )),
        vSpacer5(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OrderBookIcon(FromKey.all, selectedOrderSort, () => onShortChange(FromKey.all)),
            hSpacer10(),
            OrderBookIcon(FromKey.buy, selectedOrderSort, () => onShortChange(FromKey.buy)),
            hSpacer10(),
            OrderBookIcon(FromKey.sell, selectedOrderSort, () => onShortChange(FromKey.sell)),
          ],
        ),
      ],
    );
  }

  _onArrowTap(BuildContext context) {
    final list = ["Amount".tr, "Total".tr];
    final view = Column(
      children: List.generate(
        list.length,
        (index) {
          return ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
            title: TextRobotoAutoBold(list[index], fontSize: Dimens.regularFontSizeMid),
            trailing: index == selectedHeaderIndex ? Icon(Icons.done, color: context.theme.focusColor, size: Dimens.iconSizeMin) : null,
            onTap: () {
              Navigator.pop(context);
              onHeaderChange(index);
            },
          );
        },
      ),
    );
    showBottomSheetDynamic(context, view, title: "Choose".tr);
  }

  int getListLength(List<ExchangeOrder> list) {
    int length = selectedOrderSort == FromKey.all ? DefaultValue.listLimitOrderBook ~/ 2 : DefaultValue.listLimitOrderBook;
    length = list.length < length ? list.length : length;
    return length;
  }
}

class OrderBookIcon extends StatelessWidget {
  const OrderBookIcon(this.fromKey, this.selectedKey, this.onTap, {super.key});

  final String fromKey;
  final String selectedKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedKey == fromKey;
    double opacity = isSelected ? 1 : 0.5;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 15,
          height: 15,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              fromKey == FromKey.all
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(color: gBuyColor.withOpacity(opacity), height: 7, width: 7),
                        Container(color: gSellColor.withOpacity(opacity), height: 7, width: 7),
                      ],
                    )
                  : Container(color: fromKey == FromKey.buy ? gBuyColor.withOpacity(opacity) : gSellColor.withOpacity(opacity), height: 15, width: 7),
              showImageAsset(imagePath: AssetConstants.icBoxFilterAll, width: 7, height: 15, color: Colors.grey.withOpacity(opacity))
            ],
          ),
        ),
      ),
    );
  }
}

class OderBookItemMinView extends StatelessWidget {
  const OderBookItemMinView(this.order, this.type, this.isTotal, {super.key});

  final ExchangeOrder order;
  final String type;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final color = type == FromKey.buy ? gBuyColor : gSellColor;
    final percent = getPercentageValue(1, order.percentage);
    final value = isTotal ? numberFormatCompact(order.total, decimals: 2) : coinFormat(order.amount);
    return Stack(children: [
      RotatedBox(
          quarterTurns: -2,
          child: LinearProgressIndicator(value: percent, minHeight: 18, color: color.withOpacity(0.25), backgroundColor: Colors.transparent)),
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setSelectedPrice.value = order.price,
          child: Row(
            children: [
              Expanded(
                  child:
                      TextRobotoAutoBold(coinFormat(order.price), color: color, fontSize: Dimens.regularFontSizeSmall, textAlign: TextAlign.start, maxLines: 1)),
              Expanded(
                  child: TextRobotoAutoBold(value,
                      color: Theme.of(context).primaryColor, fontSize: Dimens.regularFontSizeSmall, textAlign: TextAlign.end, maxLines: 1)),
            ],
          ),
        ),
      )
    ]);
  }
}

class DetailsOrderBookView extends StatelessWidget {
  const DetailsOrderBookView({super.key, this.total, required this.buyExchangeOrder, required this.sellExchangeOrder});

  final Total? total;
  final List<ExchangeOrder> buyExchangeOrder;
  final List<ExchangeOrder> sellExchangeOrder;

  @override
  Widget build(BuildContext context) {
    int listLength = min(buyExchangeOrder.length, sellExchangeOrder.length);
    listLength = min(listLength, 30);
    return Column(
      children: [
        listHeaderView("${"Amount".tr} (${total?.baseWallet?.coinType ?? ''})", "${"Price".tr} (${total?.tradeWallet?.coinType ?? ''})",
            "${"Amount".tr} (${total?.baseWallet?.coinType ?? ''})"),
        vSpacer5(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _getListView(buyExchangeOrder, true, listLength)),
            hSpacer10(),
            Expanded(child: _getListView(sellExchangeOrder, false, listLength))
          ],
        ),
      ],
    );
  }

  _getListView(List<ExchangeOrder> list, bool isBuy, int listLength) {
    final color = isBuy ? gBuyColor : gSellColor;
    return list.isEmpty
        ? showEmptyView(message: "No Orders Available".tr)
        : Column(
            // children: List.generate(list.length, (index) {
            children: List.generate(listLength, (index) {
            final order = list[index];
            final fText = isBuy ? coinFormat(order.amount) : currencyFormat(order.price);
            final sText = isBuy ? currencyFormat(order.price) : coinFormat(order.amount);
            final percent = getPercentageValue(1, order.percentage);
            return InkWell(
              onTap: () => setSelectedPrice.value = order.price,
              child: Stack(
                children: [
                  RotatedBox(
                    quarterTurns: -2,
                    child:
                        LinearProgressIndicator(value: percent, minHeight: 20, color: color.withOpacity(0.15), backgroundColor: Colors.transparent),
                  ),
                  Row(
                    children: [
                      Expanded(child: TextRobotoAutoNormal(fText, color: isBuy ? null : color)),
                      Expanded(child: TextRobotoAutoNormal(sText, textAlign: TextAlign.end, color: isBuy ? color : null)),
                    ],
                  )
                ],
              ),
            );
          }));
  }
}
