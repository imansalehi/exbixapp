import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/helper/app_helper.dart';
import 'package:exbix_flutter/utils/appbar_util.dart';
import 'package:exbix_flutter/utils/dimens.dart';

import 'favorites_pair/favorites_pair_screen.dart';
import 'market_future/market_future_screen.dart';
import 'market_spot/market_spot_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  RxInt selectedTab = 0.obs;

  @override
  void initState() {
    _tabController = TabController(length: getMarketTabs().length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBarPlain(
            titles: getMarketTabs(),
            controller: _tabController,
            isScrollable: true,
            fontSize: Dimens.regularFontSizeLarge,
            onTap: (index) => selectedTab.value = index),
        Obx(() => _getBody(selectedTab.value))
      ],
    );
  }

  _getBody(int index) {
    switch (index) {
      case 0:
        return const FavoritesPairScreen();
      case 1:
        return const MarketSpotScreen();
      case 2:
        return const MarketFutureScreen();
      default:
        return Container();
    }
  }

  List<String> getMarketTabs() {
    List<String> list = ["Favorites".tr, 'Spot'.tr];
    if (getSettingsLocal()?.enableFutureTrade == 1) list.add('Futures'.tr);
    return list;
  }
}
