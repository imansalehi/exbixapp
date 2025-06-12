import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/utils/appbar_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/decorations.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_field_util.dart';

import '../market_widgets.dart';
import 'market_spot_controller.dart';
import 'market_spot_widgets.dart';

class MarketSpotScreen extends StatefulWidget {
  const MarketSpotScreen({super.key});

  @override
  MarketSpotState createState() => MarketSpotState();
}

class MarketSpotState extends State<MarketSpotScreen> with SingleTickerProviderStateMixin {
  final _controller = Get.put(MarketSpotController());
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: _controller.getTypeMap().values.length, vsync: this);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.getMarketOverviewTopCoinList(false);
      _controller.subscribeSocketChannels();
    });
  }

  @override
  void dispose() {
    _controller.unSubscribeChannel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: boxDecorationTopRound(color: context.theme.dialogBackgroundColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tabBarUnderline(_controller.getTypeMap().values.toList(), _tabController,
                indicator: tabCustomIndicator(context, padding: Dimens.paddingLargeExtra),
                isScrollable: true,
                fontSize: Dimens.regularFontSizeMid,
                onTap: (index) => _controller.changeTab(index)),
            dividerHorizontal(height: 0),
            vSpacer10(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
              child: textFieldSearch(
                  controller: _controller.searchController,
                  height: Dimens.btnHeightSmall,
                  margin: 0,
                  borderRadius: Dimens.radiusCornerMid,
                  onTextChange: _controller.onTextChanged),
            ),
            Obx(() => SpotMarketHeaderView(sort: _controller.marketSort.value, onTap: (sort) => _controller.onSortChanged(sort))),
            Obx(() {
              return _controller.marketList.isEmpty
                  ? handleEmptyViewWithLoading(_controller.isLoading.value)
                  : Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(Dimens.paddingMid),
                        separatorBuilder: (context, index) => dividerHorizontal(),
                        itemCount: _controller.marketList.length,
                        itemBuilder: (context, index) {
                          if (_controller.hasMoreData && index == _controller.marketList.length - 1) {
                            WidgetsBinding.instance.addPostFrameCallback((t) => _controller.getMarketOverviewTopCoinList(true));
                          }
                          return MarketCoinItemViewBottom(
                              coin: _controller.marketList[index], onFavChange: (message) => showToast(message, isError: false));
                        },
                      ),
                    );
            }),
          ],
        ),
      ),
    );
  }
}

// class MarketSpotState extends State<MarketSpotScreen> with SingleTickerProviderStateMixin {
//   final _controller = Get.put(MarketController());
//   late final TabController _tabController;
//
//   @override
//   void initState() {
//     _tabController = TabController(length: _controller.getTypeMap().values.length, vsync: this);
//     _controller.selectedCurrency.value = -1;
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       _controller.getMarketOverviewCoinStatisticList();
//       _controller.getMarketOverviewTopCoinList(false);
//       _controller.subscribeSocketChannels();
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.unSubscribeChannel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: CustomScrollView(
//         slivers: [
//           Obx(() {
//             final mData = _controller.marketData.value;
//             final topViewHeight = _getTopViewHeight();
//             return SliverAppBar(
//               backgroundColor: Colors.transparent,
//               automaticallyImplyLeading: false,
//               toolbarHeight: topViewHeight,
//               flexibleSpace: Padding(
//                 padding: const EdgeInsets.all(Dimens.paddingMin),
//                 child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//                   Wrap(
//                     runSpacing: Dimens.paddingMid,
//                     spacing: Dimens.paddingMid,
//                     alignment: WrapAlignment.center,
//                     runAlignment: WrapAlignment.center,
//                     children: [
//                       if (mData.highlightCoin.isValid) MarketTopItemView(title: "Highlight Coin".tr, list: mData.highlightCoin!),
//                       if (mData.newListing.isValid) MarketTopItemView(title: "New Listing".tr, list: mData.newListing!),
//                       if (mData.topGainerCoin.isValid) MarketTopItemView(title: "Top Gainer Coin".tr, list: mData.topGainerCoin!),
//                       if (mData.topVolumeCoin.isValid) MarketTopItemView(title: "Top Volume Coin".tr, list: mData.topVolumeCoin!),
//                     ],
//                   ),
//                   vSpacer5(),
//                   Align(alignment: Alignment.centerRight, child: TextRobotoAutoNormal("${"All price information is in".tr} USD")),
//                 ]),
//               ),
//             );
//           }),
//           SliverAppBar(
//             backgroundColor: context.theme.scaffoldBackgroundColor,
//             surfaceTintColor: Colors.transparent,
//             automaticallyImplyLeading: false,
//             pinned: true,
//             elevation: 0,
//             toolbarHeight: isTextScaleGetterThanOne(context) ? 162 : 152,
//             flexibleSpace: Column(
//               children: [
//                 TabBarPlain(
//                     titles: _controller.getTypeMap().values.toList(),
//                     controller: _tabController,
//                     isScrollable: true,
//                     onTap: (index) => _controller.changeTab(index)),
//                 vSpacer10(),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
//                   child: textFieldSearch(
//                       controller: _controller.searchController,
//                       height: Dimens.btnHeightMid,
//                       margin: 0,
//                       borderRadius: Dimens.radiusCornerMid,
//                       onTextChange: _controller.onTextChanged),
//                 ),
//                 vSpacer10(),
//                 Row(children: [
//                   hSpacer10(),
//                   Expanded(flex: 3, child: TextRobotoAutoNormal("${"Market".tr} /\n${"Market Cap".tr}",  maxLines: 2)),
//                   hSpacer5(),
//                   Expanded(flex: 3, child: TextRobotoAutoNormal("${"Price".tr} /\n${"Volume".tr}", maxLines: 2, textAlign: TextAlign.end)),
//                   hSpacer5(),
//                   Expanded(flex: 2, child: TextRobotoAutoNormal("Change (24h)".tr, maxLines: 1, textAlign: TextAlign.end)),
//                   hSpacer10(),
//                 ]),
//                 dividerHorizontal(height: 5),
//               ],
//             ),
//           ),
//           Obx(() {
//             return _controller.marketCoinList.isEmpty
//                 ? SliverFillRemaining(child: handleEmptyViewWithLoading(_controller.isLoading.value))
//                 : SliverPadding(
//                     padding: const EdgeInsets.all(Dimens.paddingMid),
//                     sliver: SliverList(
//                       delegate: SliverChildBuilderDelegate((context, index) => MarketCoinItemViewBottom(coin: _controller.marketCoinList[index]),
//                           childCount: _controller.marketCoinList.length),
//                     ));
//           })
//         ],
//       ),
//     );
//   }
//
//   double _getTopViewHeight() {
//     double height = getHeightForTextScaler(context, Dimens.marketTopItemHeight, [1, 2, 3]);
//     int count = 0;
//     final mData = _controller.marketData.value;
//     if (mData.highlightCoin.isValid) count += 1;
//     if (mData.newListing.isValid) count += 1;
//     if (mData.topGainerCoin.isValid) count += 1;
//     if (mData.topVolumeCoin.isValid) count += 1;
//     if (count > 2) {
//       height = (height * 6) + 25 + (25 * 2) + 15 + 25;
//       height = getHeightForTextScaler(context, height, [10, 15, 25]);
//     } else if (count > 0) {
//       height = (height * 3) + 23 + 25 + 25;
//       height = getHeightForTextScaler(context, height, [5, 7, 15]);
//     }
//     if (height < kToolbarHeight) height = kToolbarHeight;
//     return height;
//   }
// }
