import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/data/models/dashboard_data.dart';
import 'package:exbix_flutter/data/models/exchange_order.dart';
import 'package:exbix_flutter/helper/app_helper.dart';
import 'package:exbix_flutter/helper/app_widgets.dart';
import 'package:exbix_flutter/ui/features/auth/sign_in/sign_in_screen.dart';
import 'package:exbix_flutter/ui/features/charts_new/charts_screen_new.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/decorations.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/extentions.dart';
import 'package:exbix_flutter/utils/number_util.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_field_util.dart';
import 'package:exbix_flutter/utils/text_util.dart';
import 'package:decimal/decimal.dart';

final setSelectedPrice = ValueNotifier<double?>(null);

class TradePairTopView extends StatelessWidget {
  const TradePairTopView({super.key, required this.coinPair, this.onTap, this.total, this.onTapIcon});

  final CoinPair coinPair;
  final Total? total;
  final VoidCallback? onTap;
  final VoidCallback? onTapIcon;

  @override
  Widget build(BuildContext context) {
    final (sing, color) = getNumberData(total?.tradeWallet?.priceChange);
    return Row(
      children: [
        hSpacer5(),
        InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Icon(Icons.sync_alt, color: context.theme.primaryColor, size: Dimens.iconSizeMin),
              hSpacer2(),
              TextRobotoAutoBold(coinPair.getCoinPairName(), fontSize: Dimens.regularFontSizeLarge),
            ],
          ),
        ),
        hSpacer5(),
        buttonText("$sing${coinFormat(total?.tradeWallet?.priceChange, fixed: 2)}%",
            textColor: color, bgColor: color.withOpacity(0.2), visualDensity: VisualDensity.compact, radius: Dimens.radiusCorner),
        const Spacer(),
        InkWell(onTap: onTapIcon, child: const Padding(padding: EdgeInsets.all(Dimens.paddingMin), child: Icon(Icons.candlestick_chart_rounded))),
        hSpacer10(),
      ],
    );
  }
}

class TradeChartView extends StatelessWidget {
  const TradeChartView({super.key, required this.isShow, required this.onTap});

  final bool isShow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return isShow
        // ? ChartScreen(fromModal: true, onTapClose: onTap)
        ? ChartsScreenNew(fromModal: true, onTapClose: onTap)
        : InkWell(
            onTap: onTap,
            child: Row(
              children: [
                hSpacer10(),
                TextRobotoAutoNormal("Candlestick".tr),
                const Spacer(),
                TextRobotoAutoNormal("Expand".tr),
                buttonOnlyIcon(iconData: Icons.arrow_drop_down, iconColor: context.theme.primaryColorLight, visualDensity: minimumVisualDensity)
              ],
            ),
          );
  }
}

class BuySellToggleButton extends StatelessWidget {
  const BuySellToggleButton({super.key, required this.options, required this.selected, required this.onSelect});

  final List<String> options;
  final int selected;
  final Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    final color = selected == 0 ? gBuyColor : gSellColor;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth.floor() - 4) / 2;
        return SizedBox(
          height: 35,
          child: ToggleButtons(
            borderColor: context.theme.dividerColor,
            selectedBorderColor: color,
            borderWidth: 1,
            fillColor: color,
            borderRadius: BorderRadius.circular(15),
            constraints: BoxConstraints.tightFor(width: width.floorToDouble(), height: 35),
            onPressed: onSelect,
            isSelected: List.generate(options.length, (index) => index == selected),
            children: options.map((String label) {
              final isSelected = selected == options.indexOf(label);
              return TextRobotoAutoBold(label, color: isSelected ? Colors.white : context.theme.primaryColor);
            }).toList(),
          ),
        );
      },
    );
  }
}

class TradeTextFieldCalculate extends StatelessWidget {
  const TradeTextFieldCalculate(
      {super.key, this.controller, this.isEnable, this.onTextChange, this.sTitle, this.sSubtitle, this.text, this.hidePlusMinus});

  final TextEditingController? controller;
  final bool? isEnable;
  final Function(String)? onTextChange;
  final String? sTitle;
  final String? sSubtitle;
  final String? text;
  final bool? hidePlusMinus;

  @override
  Widget build(BuildContext context) {
    if (controller != null && text != null && text!.isNotEmpty) controller!.text = text!;
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLines: 1,
        cursorColor: context.theme.focusColor,
        enabled: isEnable,
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        style: context.theme.textTheme.labelMedium,
        onChanged: (value) => onTextChange == null ? null : onTextChange!(value),
        decoration: InputDecoration(
            filled: false,
            isDense: true,
            labelText: "${sTitle ?? ''}(${sSubtitle ?? ''})",
            labelStyle: context.theme.textTheme.displaySmall,
            contentPadding: const EdgeInsets.all(Dimens.paddingMid),
            enabledBorder: textFieldBorder(borderRadius: Dimens.radiusCornerSmall),
            disabledBorder: textFieldBorder(borderRadius: Dimens.radiusCornerSmall),
            focusedBorder: textFieldBorder(isFocus: true, borderRadius: Dimens.radiusCornerSmall),
            suffixIcon: hidePlusMinus == true
                ? null
                : isEnable == false
                    ? null
                    : _plusMinusButtonView(context)),
      ),
    );
  }

  _plusMinusButtonView(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: Dimens.paddingMid),
        child: Row(
          children: [
            InkWell(
                onTap: () => _plusMinusButtonAction(false),
                child: Icon(Icons.remove, color: context.theme.primaryColorLight, size: Dimens.iconSizeMin)),
            dividerVertical(height: 20),
            InkWell(
                onTap: () => _plusMinusButtonAction(true), child: Icon(Icons.add, color: context.theme.primaryColorLight, size: Dimens.iconSizeMin)),
          ],
        ),
      ),
    );
  }

  _plusMinusButtonAction(bool isPlus) {
    if (controller == null) return;
    if (controller!.text.trim().isEmpty && !isPlus) return;
    if (isPlus) {
      final text = controller!.text.trim().isEmpty ? "0" : controller!.text.trim();
      final value = Decimal.parse(text) + Decimal.parse('0.01');
      controller!.text = value.toString();
    } else {
      Decimal value = Decimal.parse(controller!.text.trim()) - Decimal.parse('0.01');
      if (value.toDouble().isNegative) value = Decimal.parse('0');
      controller!.text = value.toDouble().toString();
    }
    if (onTextChange != null) onTextChange!(controller!.text);
  }
}

class TradeTextField extends StatelessWidget {
  const TradeTextField({super.key, this.controller, this.isEnable, this.onTextChange, this.sTitle, this.sSubtitle, this.text, this.suffix});

  final TextEditingController? controller;
  final bool? isEnable;
  final Function(String)? onTextChange;
  final String? sTitle;
  final String? sSubtitle;
  final String? text;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    if (controller != null && text != null && text!.isNotEmpty) controller!.text = text!;

    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLines: 1,
        cursorColor: context.theme.primaryColor,
        enabled: isEnable,
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        style: context.theme.textTheme.displaySmall?.copyWith(color: context.theme.primaryColor),
        onChanged: (value) => onTextChange == null ? null : onTextChange!(value),
        decoration: InputDecoration(
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid, vertical: 2),
            enabledBorder: textFieldBorder(borderRadius: Dimens.radiusCorner),
            disabledBorder: textFieldBorder(borderRadius: Dimens.radiusCorner),
            focusedBorder: textFieldBorder(isFocus: true, borderRadius: Dimens.radiusCorner),
            suffixIcon: suffix ?? ((sTitle.isValid || sSubtitle.isValid) ? _textFieldTwoText(context) : null)),
      ),
    );
  }

  _textFieldTwoText(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: Dimens.paddingMid),
        child: Column(
          children: [
            if (sTitle.isValid)
              Text(sTitle!, style: context.theme.textTheme.labelMedium?.copyWith(fontSize: Dimens.regularFontSizeExtraMid, height: 1)),
            if (sTitle.isValid && sSubtitle.isValid) vSpacer2(),
            if (sSubtitle.isValid)
              Text(sSubtitle!, style: context.theme.textTheme.displaySmall?.copyWith(fontSize: Dimens.regularFontSizeMin, height: 1)),
          ],
        ),
      ),
    );
  }
}

class CurrencyPairDetailsView extends StatelessWidget {
  const CurrencyPairDetailsView({super.key, required this.prices, required this.order});

  final List<PriceData>? prices;
  final OrderData? order;

  @override
  Widget build(BuildContext context) {
    PriceData lastPData = prices.isValid ? prices!.first : PriceData();
    final isUp = (lastPData.price ?? 0) >= (lastPData.lastPrice ?? 0);
    final total = order?.total;
    final baseVolume = (total?.tradeWallet?.volume ?? 0) * (total?.tradeWallet?.lastPrice ?? 0);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 2,
            child: coinDetailsItemView(
                currencyFormat(lastPData.price), "${currencyFormat(lastPData.lastPrice)}(${total?.baseWallet?.coinType ?? ""})",
                isSwap: true, fromKey: isUp ? FromKey.up : FromKey.down)),
        hSpacer10(),
        Expanded(
            flex: 4,
            child: Column(
              children: [
                _hlTextView("24h high".tr, currencyFormat(total?.tradeWallet?.high)),
                _hlTextView("24h low".tr, currencyFormat(total?.tradeWallet?.low)),
                _hlTextView("24h volume".tr, "${currencyFormat(total?.tradeWallet?.volume)} ${total?.tradeWallet?.coinType ?? ""}"),
                _hlTextView("", "${currencyFormat(baseVolume)} ${total?.baseWallet?.coinType ?? ""}"),
              ],
            )),
      ],
    );
  }

  _hlTextView(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(flex: 2, child: TextRobotoAutoNormal(title, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeMin)),
        Expanded(flex: 4, child: TextRobotoAutoBold(value, textAlign: TextAlign.end, fontSize: Dimens.regularFontSizeSmall)),
      ],
    );
  }
}

class CoinPairItemView extends StatelessWidget {
  const CoinPairItemView({super.key, required this.coinPair, required this.onTap});

  final CoinPair coinPair;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimens.paddingMid),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(child: TextRobotoAutoNormal(coinPair.coinPairName ?? "", color: context.theme.primaryColor)),
            Expanded(child: TextRobotoAutoNormal(coinFormat(coinPair.lastPrice), color: context.theme.primaryColor, textAlign: TextAlign.center)),
            Expanded(
                child: TextRobotoAutoNormal("${coinFormat(coinPair.priceChange)}%",
                    textAlign: TextAlign.end, color: getNumberColor(coinPair.priceChange))),
          ],
        ),
      ),
    );
  }
}

class TradeLoginButton extends StatelessWidget {
  const TradeLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return buttonRoundedMain(
        text: "Login".tr,
        bgColor: Colors.red,
        textColor: Colors.white,
        buttonHeight: Dimens.btnHeightMid,
        borderRadius: Dimens.radiusCornerLarge,
        onPress: () => Get.offAll(() => const SignInPage()));
  }
}

class TradeCurrencyPairSelectionView extends StatelessWidget {
  const TradeCurrencyPairSelectionView({
    super.key,
    required this.searchEditController,
    required this.onTextChange,
    required this.coinPairs,
    required this.onSelect,
    required this.title,
  });

  final String title;
  final TextEditingController searchEditController;
  final Function(String) onTextChange;
  final List<CoinPair> coinPairs;
  final Function(CoinPair) onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
          margin: const EdgeInsets.symmetric(vertical: Dimens.paddingLarge),
          decoration: boxDecorationRightRound(color: context.theme.dialogBackgroundColor, radius: Dimens.radiusCornerLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              vSpacer20(),
              Row(
                children: [
                  TextRobotoAutoBold(title),
                  const Spacer(),
                  buttonOnlyIcon(iconData: Icons.cancel_outlined, visualDensity: minimumVisualDensity, onPress: () => Navigator.pop(context))
                ],
              ),
              vSpacer10(),
              textFieldSearch(controller: searchEditController, height: Dimens.btnHeightMid, margin: 0, onTextChange: onTextChange),
              vSpacer10(),
              listHeaderView("Coin".tr, "Last".tr, "Change".tr),
              dividerHorizontal(),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: List.generate(coinPairs.length, (index) {
                    return CoinPairItemView(
                        coinPair: coinPairs[index],
                        onTap: () {
                          Get.back();
                          onSelect(coinPairs[index]);
                        });
                  }),
                ),
              )
            ],
          )),
    );
  }
}

class TradeListView extends StatelessWidget {
  const TradeListView({super.key, this.total, required this.exchangeTrades});

  final Total? total;
  final List<ExchangeTrade> exchangeTrades;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: TextRobotoAutoNormal("${"Price".tr}(${total?.baseWallet?.coinType ?? ""})")),
            Expanded(child: TextRobotoAutoNormal("${"Amount".tr}(${total?.tradeWallet?.coinType ?? ""})", textAlign: TextAlign.center)),
            Expanded(child: TextRobotoAutoNormal("Time".tr, textAlign: TextAlign.end)),
          ],
        ),
        dividerHorizontal(height: Dimens.paddingMid),
        exchangeTrades.isEmpty
            ? showEmptyView()
            : Column(
                children: List.generate(exchangeTrades.length, (index) {
                  return TradeItemView(exchangeTrade: exchangeTrades[index]);
                }),
              )
      ],
    );
  }
}

class TradeItemView extends StatelessWidget {
  const TradeItemView({super.key, required this.exchangeTrade});

  final ExchangeTrade exchangeTrade;

  @override
  Widget build(BuildContext context) {
    final color = (exchangeTrade.price ?? 0) > (exchangeTrade.lastPrice ?? 0)
        ? gBuyColor
        : ((exchangeTrade.price ?? 0) < (exchangeTrade.lastPrice ?? 0) ? gSellColor : context.theme.primaryColor);
    return InkWell(
      onTap: () => setSelectedPrice.value = exchangeTrade.price,
      child: Row(
        children: [
          Expanded(child: TextRobotoAutoNormal(currencyFormat(exchangeTrade.price), color: color)),
          Expanded(child: TextRobotoAutoNormal(coinFormat(exchangeTrade.amount), textAlign: TextAlign.center, color: context.theme.primaryColor)),
          Expanded(child: TextRobotoAutoNormal(exchangeTrade.time ?? "", textAlign: TextAlign.end, color: context.theme.primaryColor)),
        ],
      ),
    );
  }
}

class TradeBottomButtonsView extends StatelessWidget {
  const TradeBottomButtonsView({super.key, required this.buyStr, required this.sellStr, required this.onTap});

  final String buyStr;
  final String sellStr;
  final Function(bool) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
      decoration: boxDecorationTopRound(color: Theme.of(context).secondaryHeaderColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              buttonText(buyStr, bgColor: gBuyColor, visualDensity: VisualDensity.compact, onPress: () {
                Navigator.pop(context);
                onTap(true);
              }, textColor: Colors.white),
              hSpacer10(),
              buttonText(sellStr, bgColor: gSellColor, visualDensity: VisualDensity.compact, onPress: () {
                Navigator.pop(context);
                onTap(false);
              }, textColor: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}

class TradePercentView extends StatelessWidget {
  const TradePercentView({super.key, required this.onTap});

  final Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 30) / 4;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            ListConstants.percents.length,
            (index) {
              final item = ListConstants.percents[index];
              return InkWell(onTap: () => onTap(item), child: _percentItemView(item, width));
            },
          ),
        );
      },
    );
  }

  _percentItemView(String item, double width) {
    return Container(
        height: Dimens.btnHeightMin,
        width: width,
        alignment: Alignment.center,
        decoration: boxDecorationRoundBorder(),
        child: TextRobotoAutoNormal("$item%"));
  }
}

class TradeBalanceView extends StatelessWidget {
  const TradeBalanceView({super.key, this.balance, this.coinType, required this.onTap});

  final double? balance;
  final String? coinType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextRobotoAutoNormal("Avail".tr),
        hSpacer5(),
        Expanded(
            child: TextRobotoAutoBold("${coinFormat(balance, fixed: DefaultValue.cryptoDecimal)} ${coinType ?? ""}",
                textAlign: TextAlign.end, maxLines: 1, fontSize: Dimens.regularFontSizeMid)),
        InkWell(onTap: onTap, child: Icon(Icons.add_circle_outline, color: context.theme.focusColor, size: Dimens.iconSizeMin))
      ],
    );
  }
}
