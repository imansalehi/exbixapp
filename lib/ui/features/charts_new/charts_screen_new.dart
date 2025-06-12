import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:k_chart_plus/chart_style.dart';
import 'package:k_chart_plus/k_chart_widget.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_util.dart';

import 'chart_screen_depth.dart';
import 'charts_controller_new.dart';

class ChartsScreenNew extends StatefulWidget {
  final bool fromModal;
  final VoidCallback? onTapClose;

  const ChartsScreenNew({super.key, required this.fromModal, this.onTapClose});

  @override
  State<ChartsScreenNew> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreenNew> {
  final _controller = Get.find<ChartsControllerNew>();
  final ChartStyle chartStyle = ChartStyle();
  final ChartColors chartColors = ChartColors();
  final List<SecondaryState> _secondaryStateLi = [];

  // final RxInt _chartIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    chartColors.bgColor = Get.theme.secondaryHeaderColor;
    chartColors.upColor = gBuyColor;
    chartColors.dColor = gSellColor;
    chartColors.gridColor = Colors.transparent;
    chartColors.defaultTextColor = Get.theme.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.fromModal) _secondaryStateLi.add(SecondaryState.MACD);
    final height = widget.fromModal ? (Get.width / 2) : (Get.width * 0.75);
    double width = (context.width - (widget.fromModal ? 50 : 80));

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() => Row(
              children: [
                InkWell(
                    onTap: () => _controller.intervalIndex.value = -1,
                    child: TextRobotoAutoBold("Depth".tr, color: _controller.intervalIndex.value == -1 ? null : context.theme.primaryColorLight)),
                hSpacer10(),
                TimeSelectionView(
                    intervalMap: _controller.getIntervalMap(),
                    selected: _controller.intervalIndex.value,
                    width: width,
                    onSelected: (index) {
                      // _chartIndex.value = 0;
                      _controller.intervalIndex.value = index;
                      _controller.getChartData();
                    }),
                if (widget.fromModal) const Spacer(),
                if (widget.fromModal)
                  InkWell(
                      onTap: widget.onTapClose, child: Icon(Icons.arrow_drop_up, size: Dimens.iconSizeMin, color: context.theme.primaryColorLight))
              ],
            )),
        // Obx(() => Row(
        //       children: [
        //         TimeSelectionView(
        //             intervalMap: _controller.getIntervalMap(),
        //             selected: _controller.intervalIndex.value,
        //             width: width,
        //             onSelected: (index) {
        //               // _chartIndex.value = 0;
        //               _controller.intervalIndex.value = index;
        //               _controller.getChartData();
        //             }),
        //         const Spacer(),
        //         widget.fromModal
        //             ? InkWell(
        //                 onTap: widget.onTapClose, child: Icon(Icons.arrow_drop_up, size: Dimens.iconSizeMin, color: context.theme.primaryColorLight))
        //             : InkWell(
        //                 onTap: () => _controller.intervalIndex.value = -1,
        //                 child: TextRobotoAutoBold("Depth".tr, color: _controller.intervalIndex.value == -1 ? null : context.theme.primaryColorLight))
        //       ],
        //     )),
        Obx(() {
          return _controller.intervalIndex.value == -1
              ? ChartScreenDepth(fromModal: widget.fromModal, buyOrders: _controller.buyOrders.toList(), sellOrders: _controller.sellOrders.toList())
              : Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    KChartWidget(
                      _controller.candles.toList(),
                      chartStyle,
                      chartColors,
                      mBaseHeight: height,
                      isTrendLine: false,
                      mainState: MainState.MA,
                      volHidden: widget.fromModal,
                      secondaryStateLi: _secondaryStateLi.toSet(),
                      fixedLength: 3,
                      timeFormat: TimeFormat.YEAR_MONTH_DAY_WITH_HOUR,
                    ),
                    if (_controller.candles.isEmpty) handleEmptyViewWithLoading(_controller.isLoading.value),
                  ],
                );
        }),
      ],
    );
  }
}

class TimeSelectionView extends StatelessWidget {
  const TimeSelectionView({super.key, required this.intervalMap, required this.selected, required this.onSelected, required this.width});

  final Map<int, String> intervalMap;
  final int selected;
  final Function(int) onSelected;
  final double width;

  @override
  Widget build(BuildContext context) {
    final list = intervalMap.values.toList();
    // double width = (context.width - (onTapClose != null ? 60 : 30));
    double rWidth = (35 * list.length) + (5 * (list.length - 1));
    rWidth = width >= rWidth ? rWidth : width;
    return Row(
      children: [
        SizedBox(
          width: rWidth,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                list.length,
                (index) {
                  final color = index == selected ? null : context.theme.primaryColorLight;
                  return InkWell(onTap: () => onSelected(index), child: TextRobotoAutoBold(list[index], color: color));
                },
              )),
        ),
      ],
    );
  }
}

// class TimeSelectionView extends StatelessWidget {
//   const TimeSelectionView({super.key, required this.intervalMap, required this.selected, required this.onSelected, this.onTapClose});
//
//   final Map<int, String> intervalMap;
//   final int selected;
//   final Function(int) onSelected;
//   final VoidCallback? onTapClose;
//
//   @override
//   Widget build(BuildContext context) {
//     final list = intervalMap.values.toList();
//     double width = (context.width - (onTapClose != null ? 60 : 30));
//     double rWidth = (35 * list.length) + (5 * (list.length - 1));
//     width = width >= rWidth ? rWidth : width;
//     return Row(
//       children: [
//         SizedBox(
//           width: width,
//           child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: List.generate(
//                 list.length,
//                 (index) {
//                   final color = index == selected ? null : context.theme.primaryColorLight;
//                   return InkWell(onTap: () => onSelected(index), child: TextRobotoAutoBold(list[index], color: color));
//                 },
//               )),
//         ),
//         const Spacer(),
//         if (onTapClose != null)
//           InkWell(onTap: onTapClose, child: Icon(Icons.arrow_drop_up, size: Dimens.iconSizeMin, color: context.theme.primaryColorLight)),
//       ],
//     );
//   }
// }

// _chartView() {
//   final height = widget.fromModal ? (Get.width / 2) : Get.width /2;
//   return Obx(() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         TimeSelectionView(
//             intervalMap: _controller.getIntervalMap(),
//             selected: _controller.intervalIndex.value,
//             onTapClose: widget.onTapClose,
//             onSelected: (index) {
//               _controller.intervalIndex.value = index;
//               _controller.getChartData();
//             }),
//         Stack(
//           alignment: Alignment.center,
//           children: <Widget>[
//             Container(
//               color: Colors.red,
//               padding: const EdgeInsets.all(2),
//               child: KChartWidget(
//                 _controller.candles,
//                 chartStyle,
//                 chartColors,
//                 mBaseHeight: height,
//                 isTrendLine: false,
//                 mainState: MainState.MA,
//                 volHidden: widget.fromModal,
//                 secondaryStateLi: _secondaryStateLi.toSet(),
//                 fixedLength: 3,
//                 timeFormat: TimeFormat.YEAR_MONTH_DAY_WITH_HOUR,
//               ),
//             ),
//             if (_controller.candles.isEmpty) handleEmptyViewWithLoading(_controller.isLoading.value),
//           ],
//         ),
//       ],
//     );
//   });
// }
