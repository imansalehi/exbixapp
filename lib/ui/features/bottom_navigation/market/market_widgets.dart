import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/data/models/dashboard_data.dart';
import 'package:exbix_flutter/helper/favorite_helper.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/image_util.dart';
import 'package:exbix_flutter/utils/number_util.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_util.dart';

import 'package:exbix_flutter/helper/app_helper.dart';
import '../../currency_pair_details/currency_pair_details_screen.dart';

class MarketSort {
  bool? price;
  bool? volume;
  bool? pair;
  bool? change;
  bool? capital;

  MarketSort({this.price, this.volume, this.pair, this.change, this.capital});
}

class SpotMarketHeaderView extends StatelessWidget {
  const SpotMarketHeaderView({super.key, required this.sort, required this.onTap, this.hideCap});

  final MarketSort sort;
  final Function(MarketSort) onTap;
  final bool? hideCap;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                flex: 3,
                child: Row(
                  children: [
                    _getUpDownView("Pair".tr, sort.pair, () => _updateValue(SortKey.pair), MainAxisAlignment.start),
                    _getUpDownView(" / ${"Vol".tr}", sort.volume, () => _updateValue(SortKey.volume), MainAxisAlignment.start),
                  ],
                )),
            Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _getUpDownView("Price".tr, sort.price, () => _updateValue(SortKey.price), MainAxisAlignment.end),
                    if (hideCap != true) _getUpDownView(" / ${"Cap".tr}", sort.capital, () => _updateValue(SortKey.capital), MainAxisAlignment.end)
                  ],
                )),
            hSpacer10(),
            Expanded(flex: 2, child: _getUpDownView("24h change".tr, sort.change, () => _updateValue(SortKey.change), MainAxisAlignment.end)),
          ],
        ),
      ),
    );
  }

  _clearOtherSort(int type) {
    if (type != SortKey.pair) sort.pair = null;
    if (type != SortKey.price) sort.price = null;
    if (type != SortKey.volume) sort.volume = null;
    if (type != SortKey.change) sort.change = null;
    if (type != SortKey.capital) sort.capital = null;
  }

  _updateValue(int type) {
    if (type == SortKey.pair) sort.pair = _updateCurrentValue(sort.pair);
    if (type == SortKey.volume) sort.volume = _updateCurrentValue(sort.volume);
    if (type == SortKey.price) sort.price = _updateCurrentValue(sort.price);
    if (type == SortKey.capital) sort.capital = _updateCurrentValue(sort.capital);
    if (type == SortKey.change) sort.change = _updateCurrentValue(sort.change);
    _clearOtherSort(type);
    onTap(sort);
  }

  _updateCurrentValue(bool? current) => current == null ? false : (current == false ? true : null);

  _getUpDownView(String title, bool? value, VoidCallback onTap, MainAxisAlignment alignment) {
    final colorUp = value == true ? Get.theme.focusColor : Get.theme.primaryColor;
    final colorDown = value == false ? Get.theme.focusColor : Get.theme.primaryColor;

    return SizedBox(
      height: Dimens.btnHeightMid,
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: alignment,
          children: [
            TextRobotoAutoNormal(title, fontSize: Dimens.regularFontSizeSmall),
            hSpacer3(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(AssetConstants.icArrowDropUp, colorFilter: getColorFilter(colorUp), width: 10),
                vSpacer3(),
                SvgPicture.asset(AssetConstants.icArrowDropDown, colorFilter: getColorFilter(colorDown), width: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MarketCoinPairItemView extends StatelessWidget {
  const MarketCoinPairItemView({super.key, required this.pair, this.onFavChange, this.fromKey});

  final CoinPair pair;
  final Function(String?)? onFavChange;
  final String? fromKey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => CurrencyPairDetailsScreen(pair: pair.setCoinPairKey(), fromKey: fromKey, onFavChange: onFavChange)),
      onLongPressStart: (lpDetails) =>
          FavoriteHelper.showFavoritePopup(context, lpDetails.globalPosition, pair.setCoinPairKey(), fromKey, onFavChange),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Dimens.paddingMin),
        color: Colors.transparent,
        child: Row(children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextRobotoAutoBold(pair.childCoinName ?? "", maxLines: 1),
                    TextRobotoAutoNormal("/${pair.parentCoinName}", fontSize: Dimens.regularFontSizeSmall),
                  ],
                ),
                TextRobotoAutoNormal("${"Vol".tr} ${numberFormatCompact(pair.volume, decimals: 2, symbol: "\$")}"),
              ],
            ),
          ),
          hSpacer5(),
          Expanded(
            flex: 3,
            child: TextRobotoAutoBold(currencyFormat(pair.lastPrice), textAlign: TextAlign.end),
          ),
          hSpacer10(),
          Expanded(
            flex: 2,
            child: buttonText("${coinFormat(pair.priceChange, fixed: 2)}%",
                textColor: Colors.white,
                radius: Dimens.radiusCorner,
                bgColor: getNumberColor(pair.priceChange),
                visualDensity: VisualDensity.compact),
          )
        ]),
      ),
    );
  }
}
