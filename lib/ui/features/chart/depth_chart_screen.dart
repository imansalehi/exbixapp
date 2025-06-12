import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:k_chart_plus/chart_style.dart';
import 'package:k_chart_plus/depth_chart.dart';
import 'package:k_chart_plus/entity/depth_entity.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/data/models/exchange_order.dart';
import 'package:exbix_flutter/utils/decorations.dart';

class DepthChartScreen extends StatelessWidget {
  DepthChartScreen({super.key, required this.buyOrders, required this.sellOrders});

  final List<ExchangeOrder> buyOrders;
  final List<ExchangeOrder> sellOrders;

  final List<DepthEntity> _bids = [], _asks = [];
  final ChartColors chartColors = ChartColors();
  // final _controller = Get.find<SpotTradeController>();

  @override
  Widget build(BuildContext context) {
    chartColors.depthBuyColor = gBuyColor;
    chartColors.depthSellColor = gSellColor;
    chartColors.defaultTextColor = Theme.of(context).primaryColor;
    chartColors.selectFillColor = Theme.of(context).secondaryHeaderColor;
    chartColors.selectBorderColor = Theme.of(context).primaryColor;
    chartColors.infoWindowTitleColor = Colors.grey;
    chartColors.infoWindowNormalColor = Theme.of(context).primaryColor;

    return Container(
      decoration: boxDecorationTopRound(),
      height: context.width / 1.5,
      clipBehavior: Clip.hardEdge,
      child: Obx(() {
        /// setDemoData();
        // setData(_controller.buyExchangeOrder, _controller.sellExchangeOrder);
        setData(buyOrders, sellOrders);
        return DepthChart(_bids, _asks, chartColors, fixedLength: 3);
      }),
    );
  }

  void setDemoData() {
    final List<DepthEntity> bids = getDemoData().map<DepthEntity>((item) => DepthEntity(item[0] as double, item[1] as double)).toList();
    final List<DepthEntity> asks = getDemoData().map<DepthEntity>((item) => DepthEntity(item[0] as double, item[1] as double)).toList();
    _initDepth(bids, asks);
  }

  void setData(List<ExchangeOrder> buyOrderList, List<ExchangeOrder> sellOrderList) {
    final List<DepthEntity> bids = buyOrderList.map<DepthEntity>((item) => DepthEntity(item.price ?? 0, item.amount ?? 0)).toList();
    final List<DepthEntity> asks = sellOrderList.map<DepthEntity>((item) => DepthEntity(item.price ?? 0, item.amount ?? 0)).toList();
    _bids.clear();
    _asks.clear();
    _initDepth(bids, asks);
  }

  void _initDepth(List<DepthEntity>? bids, List<DepthEntity>? asks) {
    if (bids == null || asks == null || bids.isEmpty || asks.isEmpty) return;

    //Cumulative buy orders
    double cumulativeAmount = 0.0;
    bids.sort((left, right) => right.price.compareTo(left.price));
    for (var item in bids) {
      cumulativeAmount += item.vol;
      item.vol = cumulativeAmount;
      _bids.insert(0, item);
    }

    //Cumulative sell orders
    cumulativeAmount = 0.0;
    asks.sort((left, right) => left.price.compareTo(right.price));
    for (var item in asks) {
      cumulativeAmount += item.vol;
      item.vol = cumulativeAmount;
      _asks.add(item);
    }
  }
}

getDemoData() => [
      [9620.130000000000000000, 0.000146000000000000],
      [9620.190000000000000000, 0.062830000000000000],
      [9620.330000000000000000, 0.002323000000000000],
      [9620.440000000000000000, 0.459942000000000000],
      [9620.600000000000000000, 0.005600000000000000],
      [9620.680000000000000000, 0.010000000000000000],
      [9620.830000000000000000, 0.002400000000000000],
      [9620.850000000000000000, 0.750000000000000000],
      [9621.050000000000000000, 0.001200000000000000],
      [9621.230000000000000000, 0.000900000000000000],
      [9621.240000000000000000, 0.004200000000000000],
      [9621.310000000000000000, 0.004100000000000000]
    ];

// class DepthChartScreen extends StatelessWidget {
//   DepthChartScreen({super.key});
//
//   final List<DepthEntity> _bids = [], _asks = [];
//   final ChartColors chartColors = ChartColors();
//   final _controller = Get.find<SpotTradeController>();
//
//   @override
//   Widget build(BuildContext context) {
//     chartColors.depthBuyColor = gBuyColor;
//     chartColors.depthSellColor = gSellColor;
//     chartColors.defaultTextColor = Theme.of(context).primaryColor;
//     chartColors.selectFillColor = Theme.of(context).secondaryHeaderColor;
//     chartColors.selectBorderColor = Theme.of(context).primaryColor;
//     chartColors.infoWindowTitleColor = Colors.grey;
//     chartColors.infoWindowNormalColor = Theme.of(context).primaryColor;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         buttonText("Close".tr, visualDensity: minimumVisualDensity, bgColor: Colors.black, onPressCallback: () => Get.back()),
//         Container(
//           decoration: boxDecorationTopRound(),
//           height: context.width / 1.5,
//           clipBehavior: Clip.hardEdge,
//           child: Obx(() {
//             /// setDemoData();
//             setData(_controller.buyExchangeOrder, _controller.sellExchangeOrder);
//             return DepthChart(_bids, _asks, chartColors, fixedLength: 3);
//           }),
//         )
//       ],
//     );
//   }
//
//   void setDemoData() {
//     final List<DepthEntity> bids = getDemoData().map<DepthEntity>((item) => DepthEntity(item[0] as double, item[1] as double)).toList();
//     final List<DepthEntity> asks = getDemoData().map<DepthEntity>((item) => DepthEntity(item[0] as double, item[1] as double)).toList();
//     _initDepth(bids, asks);
//   }
//
//   void setData(List<ExchangeOrder> buyOrderList, List<ExchangeOrder> sellOrderList) {
//     final List<DepthEntity> bids = buyOrderList.map<DepthEntity>((item) => DepthEntity(item.price ?? 0, item.amount ?? 0)).toList();
//     final List<DepthEntity> asks = sellOrderList.map<DepthEntity>((item) => DepthEntity(item.price ?? 0, item.amount ?? 0)).toList();
//     _bids.clear();
//     _asks.clear();
//     _initDepth(bids, asks);
//   }
//
//   void _initDepth(List<DepthEntity>? bids, List<DepthEntity>? asks) {
//     if (bids == null || asks == null || bids.isEmpty || asks.isEmpty) return;
//
//     //Cumulative buy orders
//     double cumulativeAmount = 0.0;
//     bids.sort((left, right) => right.price.compareTo(left.price));
//     for (var item in bids) {
//       cumulativeAmount += item.vol;
//       item.vol = cumulativeAmount;
//       _bids.insert(0, item);
//     }
//
//     //Cumulative sell orders
//     cumulativeAmount = 0.0;
//     asks.sort((left, right) => left.price.compareTo(right.price));
//     for (var item in asks) {
//       cumulativeAmount += item.vol;
//       item.vol = cumulativeAmount;
//       _asks.add(item);
//     }
//   }
// }
//
// getDemoData() => [
//   [9620.130000000000000000, 0.000146000000000000],
//   [9620.190000000000000000, 0.062830000000000000],
//   [9620.330000000000000000, 0.002323000000000000],
//   [9620.440000000000000000, 0.459942000000000000],
//   [9620.600000000000000000, 0.005600000000000000],
//   [9620.680000000000000000, 0.010000000000000000],
//   [9620.830000000000000000, 0.002400000000000000],
//   [9620.850000000000000000, 0.750000000000000000],
//   [9621.050000000000000000, 0.001200000000000000],
//   [9621.230000000000000000, 0.000900000000000000],
//   [9621.240000000000000000, 0.004200000000000000],
//   [9621.310000000000000000, 0.004100000000000000]
// ];
