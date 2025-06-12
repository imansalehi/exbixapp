import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/models/dashboard_data.dart';
import 'package:exbix_flutter/helper/app_helper.dart';
import 'package:exbix_flutter/utils/appbar_util.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/decorations.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/extentions.dart';
import 'package:exbix_flutter/utils/image_util.dart';
import 'package:exbix_flutter/utils/number_util.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_util.dart';

import '../../currency_pair_details/currency_pair_details_screen.dart';
import 'landing_controller.dart';

class LandingMarketView extends StatefulWidget {
  const LandingMarketView({super.key});

  @override
  State<LandingMarketView> createState() => _LandingMarketViewState();
}

class _LandingMarketViewState extends State<LandingMarketView> with SingleTickerProviderStateMixin {
  final _controller = Get.find<LandingController>();
  late final TabController _tabController;
  RxBool isExpand = false.obs;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationRoundCorner(context: context, radius: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tabBarUnderline(["Core Assets".tr, "24H Gainer".tr, "New Listing".tr], _tabController,
              onTap: (index) => _controller.selectedTab.value = index,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: tabCustomIndicator(context, padding: 0),
              fontSize: Dimens.regularFontSizeMid,
              isScrollable: true),
          dividerHorizontal(height: 0),
          vSpacer10(),
          Row(children: [
            hSpacer10(),
            Expanded(flex: 2, child: TextRobotoAutoNormal("Pair".tr)),
            hSpacer5(),
            Expanded(flex: 3, child: TextRobotoAutoNormal("Price".tr, textAlign: TextAlign.end)),
            hSpacer5(),
            Expanded(flex: 2, child: TextRobotoAutoNormal("24h Change".tr, textAlign: TextAlign.end)),
            hSpacer10(),
          ]),
          vSpacer5(),
          Obx(
            () {
              final lData = _controller.landingData.value;
              final list = _controller.selectedTab.value == 0
                  ? lData.assetCoinPairs
                  : (_controller.selectedTab.value == 1 ? lData.hourlyCoinPairs : lData.latestCoinPairs);
              return list.isValid
                  ? ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) => MarketTrendItemView(coin: list![index]),
                      separatorBuilder: (context, index) => dividerHorizontal(height: Dimens.paddingMid),
                      itemCount: list?.length ?? 0,
                      physics: const NeverScrollableScrollPhysics(),
                    )
                  // ? Column(children: List.generate(getListLength(list?.length ?? 0), (index) => MarketTrendItemView(coin: list![index])))
                  : showEmptyView();
            },
          ),
        ],
      ),
    );
  }

  int getListLength(int listLength) {
    final length = isExpand.value ? 10 : 5;

    return listLength > length ? length : listLength;
  }
}

// class _LandingMarketViewState extends State<LandingMarketView> with SingleTickerProviderStateMixin {
//   final _controller = Get.find<LandingController>();
//   late final TabController _tabController;
//   RxBool isExpand = false.obs;
//
//   @override
//   void initState() {
//     _tabController = TabController(length: 3, vsync: this);
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: boxDecorationRoundBorder(context: context),
//       child: Column(
//         children: [
//           SizedBox(
//             height: Dimens.btnHeightMid,
//             child: TabBarPlain(
//                 titles: ["Core Assets".tr, "24H Gainer".tr, "New Listing".tr],
//                 controller: _tabController,
//                 onTap: (index) => _controller.selectedTab.value = index,
//                 isScrollable: true),
//           ),
//           dividerHorizontal(height: 0),
//           vSpacer10(),
//           Row(children: [
//             hSpacer10(),
//             Expanded(flex: 2, child: TextRobotoAutoNormal("Coin".tr)),
//             hSpacer5(),
//             Expanded(flex: 3, child: TextRobotoAutoNormal("Price".tr, textAlign: TextAlign.end)),
//             hSpacer5(),
//             Expanded(flex: 2, child: TextRobotoAutoNormal("24h Change".tr, textAlign: TextAlign.end)),
//             hSpacer10(),
//           ]),
//           vSpacer5(),
//           Obx(
//             () {
//               final lData = _controller.landingData.value;
//               final list = _controller.selectedTab.value == 0
//                   ? lData.assetCoinPairs
//                   : (_controller.selectedTab.value == 1 ? lData.hourlyCoinPairs : lData.latestCoinPairs);
//               return list.isValid
//                   ? Column(children: List.generate(getListLength(list?.length ?? 0), (index) => MarketTrendItemView(coin: list![index])))
//                   : showEmptyView();
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   int getListLength(int listLength) {
//     final length = isExpand.value ? 10 : 5;
//
//     return listLength > length ? length : listLength;
//   }
// }

class MarketTrendItemView extends StatelessWidget {
  const MarketTrendItemView({super.key, required this.coin});

  final CoinPair coin;

  @override
  Widget build(BuildContext context) {
    final (sign, color) = getNumberData(coin.priceChange);
    return InkWell(
      onTap: () {
        coin.coinPair = coin.getCoinPairKey();
        coin.coinPairName = coin.getCoinPairName();
        // getDashboardController().selectedCoinPair.value = coin;
        // getRootController().changeBottomNavIndex(AppBottomNavKey.trade);
        Get.to(() => CurrencyPairDetailsScreen(pair: coin));
      },
      child: Row(children: [
        hSpacer10(),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              showImageNetwork(imagePath: coin.icon, width: Dimens.iconSizeMin, height: Dimens.iconSizeMin, bgColor: Colors.transparent),
              hSpacer5(),
              TextRobotoAutoBold(coin.childCoinName ?? '', fontSize: Dimens.regularFontSizeExtraMid),
              TextRobotoAutoNormal("/${coin.parentCoinName ?? ''}", fontSize: Dimens.regularFontSizeSmall),
            ],
          ),
        ),
        hSpacer5(),
        Expanded(flex: 3, child: TextRobotoAutoBold(coinFormat(coin.lastPrice), maxLines: 1, textAlign: TextAlign.end)),
        hSpacer5(),
        Expanded(
          flex: 2,
          child: buttonText("$sign${coinFormat(coin.priceChange, fixed: 2)}%",
              radius: Dimens.radiusCorner, bgColor: color, textColor: Colors.white, visualDensity: VisualDensity.compact),
        ),
        hSpacer10(),
      ]),
    );
  }
}
