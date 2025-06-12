import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:k_chart_plus/chart_style.dart';
import 'package:k_chart_plus/k_chart_widget.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/ui/features/chart/chart_controller.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/decorations.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/text_util.dart';


class ChartScreen extends StatefulWidget {
  final bool fromModal;
  final VoidCallback? onTapClose;

  const ChartScreen({super.key, required this.fromModal, this.onTapClose});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final _controller = Get.find<ChartController>();
  final ChartStyle chartStyle = ChartStyle();
  final ChartColors chartColors = ChartColors();
  final List<SecondaryState> _secondaryStateLi = [];

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
    if (widget.fromModal) {
      return _chartView();
    } else {
      _secondaryStateLi.add(SecondaryState.MACD);
      return _chartView();
    }
  }

  _chartView() {
    final height = widget.fromModal ? (Get.width / 2) : (Get.height / 2);
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(Dimens.paddingMid),
        decoration: boxDecorationRoundCorner(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            TimeSelectionView(
                intervalMap: _controller.getIntervalMap(),
                selected: _controller.intervalIndex.value,
                onTapClose: widget.onTapClose,
                onSelected: (index) {
                  _controller.intervalIndex.value = index;
                  _controller.getChartData();
                }),
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                KChartWidget(
                  _controller.candles,
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
            ),
          ],
        ),
      );
    });
  }

// void _chooseIntervalView(BuildContext context, List<String> list, Function(int) onTap) {
//   showModalSheetFullScreen(
//       context,
//       Column(
//         children: [
//           textAutoSizeKarla("Select Interval".tr, fontSize: Dimens.regularFontSizeLarge),
//           dividerHorizontal(),
//           vSpacer10(),
//           Wrap(
//             direction: Axis.horizontal,
//             spacing: Dimens.paddingMid,
//             runSpacing: Dimens.paddingMid,
//             children: List.generate(
//                 list.length,
//                 (index) => InkWell(
//                     onTap: () {
//                       Get.back();
//                       onTap(index);
//                     },
//                     child: _intervalItem(list[index], _controller.intervalIndex.value == index))),
//           ),
//           vSpacer20()
//         ],
//       ));
// }
//
// _intervalItem(String text, bool isSelected) {
//   return Container(
//     padding: const EdgeInsets.all(Dimens.paddingMid),
//     decoration: boxDecorationRoundCorner(color: isSelected ? Get.theme.focusColor : null),
//     child: TextRobotoBoldAuto(text, fontSize: Dimens.regularFontSizeMid),
//   );
// }
}

class TimeSelectionView extends StatelessWidget {
  const TimeSelectionView({super.key, required this.intervalMap, required this.selected, required this.onSelected, this.onTapClose});

  final Map<int, String> intervalMap;
  final int selected;
  final Function(int) onSelected;
  final VoidCallback? onTapClose;

  @override
  Widget build(BuildContext context) {
    final list = intervalMap.values.toList();
    double width = (context.width - (onTapClose != null ? 60 : 30));
    double rWidth = (35 * list.length) + (5 * (list.length - 1));
    width = width >= rWidth ? rWidth : width;
    return Row(
      children: [
        SizedBox(
          width: width,
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
        const Spacer(),
        if (onTapClose != null)
          InkWell(onTap: onTapClose, child: Icon(Icons.arrow_drop_up, size: Dimens.iconSizeMin, color: context.theme.primaryColorLight)),
      ],
    );
  }
}

// class _ChartScreenState extends State<ChartScreen> {
//   final _controller = Get.find<ChartController>();
//   final ChartStyle chartStyle = ChartStyle();
//   final ChartColors chartColors = ChartColors();
//   final List<SecondaryState> _secondaryStateLi = [];
//
//   @override
//   void initState() {
//     super.initState();
//     chartColors.bgColor = Get.theme.secondaryHeaderColor;
//     chartColors.upColor = gBuyColor;
//     chartColors.dColor = gSellColor;
//     chartColors.gridColor = Colors.transparent;
//     chartColors.defaultTextColor = Get.theme.primaryColor;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.fromModal) {
//       return _chartView();
//     } else {
//       _secondaryStateLi.add(SecondaryState.MACD);
//       return Scaffold(
//         appBar: appBarBackWithActions(title: "${_controller.selectedCoinPair.value.getCoinPairName()} ${"Chart".tr}"),
//         body: SafeArea(child: _chartView()),
//       );
//     }
//   }
//
//   _chartView() {
//     final height = widget.fromModal
//         ? (Get.width / 2)
//         : (getContentHeight(context: context, withSafeArea: true, withToolbar: true) - (Dimens.paddingMainViewTop + 200));
//     return Obx(() {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             color: context.theme.secondaryHeaderColor,
//             padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 InkWell(
//                     onTap: () {
//                       _chooseIntervalView(context, _controller.getIntervalMap().values.toList(), (index) {
//                         _controller.intervalIndex.value = index;
//                         _controller.getChartData();
//                       });
//                     },
//                     child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: Dimens.paddingMid),
//                         child: textAutoSizeKarla(_controller.getIntervalMap().values.toList()[_controller.intervalIndex.value],
//                             fontSize: Dimens.regularFontSizeMid))),
//                 const Spacer(),
//                 if (widget.fromModal)
//                   InkWell(
//                     onTap: () {
//                       Get.back();
//                       Get.to(() => const ChartScreen(fromModal: false));
//                     },
//                     child: Icon(Icons.fullscreen, size: Dimens.iconSizeMin, color: context.theme.primaryColor),
//                   ),
//                 if (widget.fromModal)
//                   InkWell(
//                     onTap: () => Navigator.pop(context),
//                     child: Icon(Icons.arrow_drop_down, size: Dimens.iconSizeMin, color: context.theme.primaryColor),
//                   ),
//               ],
//             ),
//           ),
//           Stack(
//             alignment: Alignment.center,
//             children: <Widget>[
//               KChartWidget(
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
//               if (_controller.candles.isEmpty) handleEmptyViewWithLoading(_controller.isLoading.value),
//             ],
//           ),
//         ],
//       );
//     });
//   }
//
//   void _chooseIntervalView(BuildContext context, List<String> list, Function(int) onTap) {
//     showModalSheetFullScreen(
//         context,
//         Column(
//           children: [
//             textAutoSizeKarla("Select Interval".tr, fontSize: Dimens.regularFontSizeLarge),
//             dividerHorizontal(),
//             vSpacer10(),
//             Wrap(
//               direction: Axis.horizontal,
//               spacing: Dimens.paddingMid,
//               runSpacing: Dimens.paddingMid,
//               children: List.generate(
//                   list.length,
//                       (index) => InkWell(
//                       onTap: () {
//                         Get.back();
//                         onTap(index);
//                       },
//                       child: _intervalItem(list[index], _controller.intervalIndex.value == index))),
//             ),
//             vSpacer20()
//           ],
//         ));
//   }
//
//   _intervalItem(String text, bool isSelected) {
//     return Container(
//       padding: const EdgeInsets.all(Dimens.paddingMid),
//       decoration: boxDecorationRoundCorner(color: isSelected ? Get.theme.focusColor : null),
//       child: textAutoSizeKarla(text, fontSize: Dimens.regularFontSizeMid, fontWeight: FontWeight.bold),
//     );
//   }
// }
