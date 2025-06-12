import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:k_chart_plus/entity/k_line_entity.dart';
import 'package:k_chart_plus/utils/data_util.dart';
import 'package:exbix_flutter/data/models/dashboard_data.dart';
import 'package:exbix_flutter/data/models/exchange_order.dart';
import 'package:exbix_flutter/data/models/trade_info_socket.dart';
import 'package:exbix_flutter/data/remote/api_repository.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/date_util.dart';
import 'package:exbix_flutter/utils/number_util.dart';

class ChartsControllerNew extends GetxController {
  Map<int, String> getIntervalMap() => {5: "5m".tr, 15: "15m".tr, 30: "30m".tr, 120: "1h".tr, 240: '4h'.tr, 1440: '1d'.tr};
  RxList<KLineEntity> candles = <KLineEntity>[].obs;
  RxList<ExchangeOrder> buyOrders = <ExchangeOrder>[].obs;
  RxList<ExchangeOrder> sellOrders = <ExchangeOrder>[].obs;
  RxInt intervalIndex = 1.obs;
  Rx<CoinPair> selectedCoinPair = CoinPair().obs;
  RxBool isLoading = false.obs;

  void updateChart(SocketTradeInfo infoSocket) {
    if (infoSocket.orderData?.exchangePair == selectedCoinPair.value.getCoinPairKey()) updateFullScreenChart(infoSocket);
  }

  void setCoinPair(CoinPair coinPair) {
    selectedCoinPair.value = coinPair;
    intervalIndex.value = 1;
    getChartData();
  }

  void getChartData() {
    isLoading.value = true;
    final interval = getIntervalMap().keys.toList()[intervalIndex.value];
    candles.value = [];
    APIRepository().getExchangeChartDataApp(selectedCoinPair.value.parentCoinId ?? 0, selectedCoinPair.value.childCoinId ?? 0, interval).then((resp) {
      isLoading.value = false;
      if (resp.success) {
        final list = List<KLineEntity>.from(resp.data.map((x) => _getCandles(x)));
        candles.value = list;
        DataUtil.calcMA(candles, const [5, 10, 20]);
        DataUtil.calcMACD(candles);
      }
    }, onError: (err) {
      isLoading.value = false;
      showToast(err.toString());
    });
  }

  void updateFullScreenChart(SocketTradeInfo infoSocket) {
    if (candles.isEmpty) return;
    if (intervalIndex.value == -1) return;
    final date = getDateUtcWithOnlyTime(infoSocket.lastTrade?.time)?.millisecondsSinceEpoch;
    if (date == null) return;
    final price = makeDouble(infoSocket.lastTrade?.price);
    final total = makeDouble(infoSocket.lastTrade?.total);
    final lastBar = candles.last;
    final differ = timeDifferenceInMinutes(lastBar.time, date);
    final interval = getIntervalMap().keys.toList()[intervalIndex.value];
    if (differ < interval) {
      var newBar = KLineEntity.fromCustom(
          time: lastBar.time,
          high: math.max(lastBar.high, price),
          low: math.max(lastBar.low, price),
          open: lastBar.open,
          close: price,
          vol: (lastBar.vol + total));
      candles.last = newBar;
    } else {
      var newBar = KLineEntity.fromCustom(time: date, high: price, low: price, open: price, close: price, vol: total);
      candles.add(newBar);
    }
  }

  KLineEntity _getCandles(Map<String, dynamic> json) {
    final entity = KLineEntity.fromCustom(
        open: makeDouble(json["open"]),
        close: makeDouble(json["close"]),
        high: makeDouble(json["high"]),
        low: makeDouble(json["low"]),
        vol: makeDouble(json["volume"]),
        time: 0);
    int time = makeInt(json["time"]);
    entity.time = (time * 1000);
    return entity;
  }
}
