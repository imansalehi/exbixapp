import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/api_constants.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/data/models/list_response.dart';
import 'package:exbix_flutter/data/models/market_date.dart';
import 'package:exbix_flutter/data/remote/api_repository.dart';
import 'package:exbix_flutter/data/remote/socket_provider.dart';
import 'package:exbix_flutter/utils/common_utils.dart';

import '../market_widgets.dart';

class MarketSpotController extends GetxController implements SocketListener {
  RxBool isLoading = true.obs;
  RxInt selectedTab = 0.obs;
  RxList<MarketCoin> marketList = <MarketCoin>[].obs;
  List<MarketCoin> marketFullList = <MarketCoin>[];
  Rx<MarketSort> marketSort = MarketSort().obs;
  final searchController = TextEditingController();
  int loadedPage = 0;
  bool hasMoreData = false;
  Timer? _searchTimer;

  Map<int, String> getTypeMap() {
    var map = {1: "All Crypto".tr, 2: "Spot Markets".tr, 3: "New Listing".tr};
    return map;
  }

  void changeTab(int key) {
    selectedTab.value = key;
    getMarketOverviewTopCoinList(false);
  }

  void onTextChanged(String text) {
    if (_searchTimer?.isActive ?? false) _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(seconds: 1), () => getMarketOverviewTopCoinList(false));
  }

  void onSortChanged(MarketSort sort) {
    marketSort.value = sort;
    marketSort.refresh();
    sortMarketList();
  }

  Future<void> getMarketOverviewTopCoinList(bool isLoadMore) async {
    if (!isLoadMore) {
      loadedPage = 0;
      hasMoreData = true;
      marketFullList.clear();
      marketList.clear();
    }
    isLoading.value = true;
    loadedPage++;
    final type = getTypeMap().keys.toList()[selectedTab.value];
    final query = searchController.text.trim();
    APIRepository().getMarketOverviewTopCoinList(loadedPage, DefaultValue.currency, type, search: query).then((resp) {
      isLoading.value = false;
      if (resp.success) {
        final listResp = ListResponse.fromJson(resp.data);
        hasMoreData = listResp.nextPageUrl != null;
        final list = List<MarketCoin>.from(listResp.data.map((x) => MarketCoin.fromJson(x)));
        marketFullList.addAll(list);
        sortMarketList();
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      isLoading.value = false;
      showToast(err.toString());
    });
  }

  void sortMarketList() {
    final List<MarketCoin> currentList = List.from(marketFullList);
    if (marketSort.value.pair != null) {
      if (marketSort.value.pair == true) {
        currentList.sort((a, b) => (a.coinType ?? '').compareTo(b.coinType ?? ''));
      } else {
        currentList.sort((a, b) => (b.coinType ?? '').compareTo(a.coinType ?? ''));
      }
    } else if (marketSort.value.volume != null) {
      if (marketSort.value.volume == true) {
        currentList.sort((a, b) => (a.volume ?? 0).compareTo(b.volume ?? 0));
      } else {
        currentList.sort((a, b) => (b.volume ?? 0).compareTo(a.volume ?? 0));
      }
    } else if (marketSort.value.price != null) {
      if (marketSort.value.price == true) {
        currentList.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
      } else {
        currentList.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
      }
    } else if (marketSort.value.capital != null) {
      if (marketSort.value.capital == true) {
        currentList.sort((a, b) => (a.totalBalance ?? 0).compareTo(b.totalBalance ?? 0));
      } else {
        currentList.sort((a, b) => (b.totalBalance ?? 0).compareTo(a.totalBalance ?? 0));
      }
    } else if (marketSort.value.change != null) {
      if (marketSort.value.change == true) {
        currentList.sort((a, b) => (a.change ?? 0).compareTo(b.change ?? 0));
      } else {
        currentList.sort((a, b) => (b.change ?? 0).compareTo(a.change ?? 0));
      }
    }

    marketList.value = currentList;
  }

  @override
  void onDataGet(channel, event, data) {
    if (channel == SocketConstants.channelMarketOverviewTopCoinListData && event == SocketConstants.eventMarketOverviewTopCoinList) {
      if (data is Map<String, dynamic>) {
        final details = data[APIKeyConstants.coinPairDetails];
        if (details is Map<String, dynamic>) {
          final coin = MarketCoin.fromJson(data[APIKeyConstants.coinPairDetails]);
          findAndUpdateListData(coin);
        }
      }
    }
  }

  void subscribeSocketChannels() {
    APIRepository().subscribeEvent(SocketConstants.channelMarketOverviewTopCoinListData, this);
  }

  void unSubscribeChannel() {
    APIRepository().unSubscribeEvent(SocketConstants.channelMarketOverviewTopCoinListData, this);
  }

  void findAndUpdateListData(MarketCoin? coin) {
    if (coin == null) return;
    if (marketFullList.isNotEmpty) {
      final index = marketFullList.indexWhere((element) => element.coinId == coin.id);

      if (index != -1) {
        coin.baseCoinType = marketFullList[index].baseCoinType;
        marketFullList[index] = coin;
        sortMarketList();
      }
    }
  }
}

// RxInt selectedCurrency = 0.obs;
// RxList<Currency> currencyList = <Currency>[].obs;
// Rx<MarketData> marketData = MarketData().obs;

// Map<int, String> getTypeMap() {
//   var map = {1: "All Crypto".tr, 2: "Spot Markets".tr};
//   /// if (getSettingsLocal()?.enableFutureTrade == 1) map[3] = "Future Markets".tr;
//   map[4] = "New Listing".tr;
//   return map;
// }
// final currency = selectedCurrency.value == -1 ? DefaultValue.currency : currencyList[selectedCurrency.value].value;

// @override
// void onDataGet(channel, event, data) {
//   if (channel == SocketConstants.channelMarketOverviewCoinStatisticListData && event == SocketConstants.eventMarketOverviewCoinStatisticList) {
//     if (data is Map<String, dynamic>) marketData.value = MarketData.fromJson(data);
//   } else if (channel == SocketConstants.channelMarketOverviewTopCoinListData && event == SocketConstants.eventMarketOverviewTopCoinList) {
//     if (data is Map<String, dynamic>) {
//       final details = data[APIKeyConstants.coinPairDetails];
//       if (details is Map<String, dynamic>) {
//         final coin = MarketCoin.fromJson(data[APIKeyConstants.coinPairDetails]);
//         findAndUpdateListData(coin);
//       }
//     }
//   }
// }
//
// void subscribeSocketChannels() {
//   /// APIRepository().subscribeEvent(SocketConstants.channelMarketOverviewCoinStatisticListData, this);
//   APIRepository().subscribeEvent(SocketConstants.channelMarketOverviewTopCoinListData, this);
// }
//
// void unSubscribeChannel() {
//   /// APIRepository().unSubscribeEvent(SocketConstants.channelMarketOverviewCoinStatisticListData, this);
//   APIRepository().unSubscribeEvent(SocketConstants.channelMarketOverviewTopCoinListData, this);
// }
//
// void findAndUpdateListData(MarketCoin? coin) {
//   if (coin == null) return;
//   if (marketList.isNotEmpty) {
//     final index = marketList.indexWhere((element) => element.coinType == coin.coinType);
//     if (index != 1) {
//       marketList[index] = coin;
//       marketList.refresh();
//     }
//   }
// }

// void changeCurrency(int index) { selectedCurrency.value = index; getMarketOverviewCoinStatisticList();
// getMarketOverviewTopCoinList(false); }
// Future<void> getCurrencyList() async {
//   APIRepository().getCurrencyList().then((resp) {
//     if (resp.success) {
//       currencyList.value = List<Currency>.from(resp.data.map((x) => Currency.fromJson(x)));
//       selectedCurrency.value = currencyList.indexWhere((element) => element.value == DefaultValue.currency);
//     } else {
//       showToast(resp.message);
//     }
//   }, onError: (err) {
//     isLoading.value = false;
//     showToast(err.toString());
//   });
// }

// Future<void> getMarketOverviewCoinStatisticList() async {
//   final currency = selectedCurrency.value == -1 ? DefaultValue.currency : currencyList[selectedCurrency.value].value;
//   APIRepository().getMarketOverviewCoinStatisticList(currency ?? "").then((resp) {
//     if (resp.success) {
//       marketData.value = MarketData.fromJson(resp.data);
//     } else {
//       showToast(resp.message);
//     }
//   }, onError: (err) {
//     showToast(err.toString());
//   });
// }
