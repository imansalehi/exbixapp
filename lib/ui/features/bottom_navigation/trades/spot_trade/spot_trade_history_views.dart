import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/data/models/exchange_order.dart';
import 'package:exbix_flutter/ui/features/auth/sign_in/sign_in_screen.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/date_util.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/number_util.dart';
import 'package:exbix_flutter/utils/text_util.dart';
import 'package:exbix_flutter/helper/app_widgets.dart';
import 'package:exbix_flutter/utils/appbar_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'spot_trade_controller.dart';

class SpotTradeHistoryView extends StatefulWidget {
  final String? fromPage;

  const SpotTradeHistoryView({super.key, this.fromPage});

  @override
  SpotTradeHistoryViewState createState() => SpotTradeHistoryViewState();
}

class SpotTradeHistoryViewState extends State<SpotTradeHistoryView> with SingleTickerProviderStateMixin {
  final _controller = Get.find<SpotTradeController>();
  RxInt selectedTabIndex = 0.obs;
  RxInt selectedSubTabIndex = 0.obs;
  TabController? orderTabController;

  @override
  void initState() {
    orderTabController = TabController(vsync: this, length: 3);
    super.initState();
  }

  void getData() {
    if (selectedTabIndex.value == 0) {
      _controller.getTradeHistoryList(FromKey.buySell);
    } else if (selectedTabIndex.value == 1) {
      _controller.getTradeHistoryList(selectedSubTabIndex.value == 0 ? FromKey.buy : FromKey.sell);
    } else {
      _controller.getTradeHistoryList(FromKey.trade);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        tabBarUnderline(["Open Orders".tr, "Order History".tr, "Trade History".tr], orderTabController,
            indicator: tabCustomIndicator(context), isScrollable: true, fontSize: Dimens.regularFontSizeMid, onTap: (index) {
          selectedTabIndex.value = index;
          getData();
        }),
        dividerHorizontal(height: 0),
        vSpacer10(),
        Obx(() {
          final color = selectedSubTabIndex.value == 0 ? gBuyColor : gSellColor;
          return selectedTabIndex.value == 1
              ? Padding(
                  padding: const EdgeInsets.only(left: Dimens.paddingMid, right: Dimens.paddingMid, bottom: Dimens.paddingMid),
                  child: tabBarText(["Buy".tr, "Sell".tr], selectedSubTabIndex.value, selectedColor: color, (index) {
                    selectedSubTabIndex.value = index;
                    getData();
                  }),
                )
              : vSpacer0();
        }),
        Obx(() => gUserRx.value.id == 0
            ? Padding(
                padding: const EdgeInsets.all(Dimens.paddingMid),
                child: textSpanWithAction("Want to trade".tr, "Login".tr, onTap: () => Get.to(() => const SignInPage())),
              )
            : _listView())
      ],
    );
  }

  Widget _listView() {
    return Obx(() {
      return _controller.tradeHistoryList.isEmpty
          ? handleEmptyViewWithLoading(_controller.isHistoryLoading.value)
          : Column(
              children: List.generate(_controller.tradeHistoryList.length, (index) => _historyItemView(_controller.tradeHistoryList[index])),
            );
    });
  }

  Widget _historyItemView(Trade trade) {
    final color = trade.type == FromKey.buy ? gBuyColor : gSellColor;
    final tradeCoin = _controller.dashboardData.value.orderData?.tradeCoin ?? "";
    final baseCoin = _controller.dashboardData.value.orderData?.baseCoin ?? "";
    final pcl = context.theme.primaryColorLight;
    return Column(
      children: [
        if (selectedTabIndex.value != 2)
          Row(
            children: [
              buttonTextBordered((trade.type ?? "").toUpperCase(), true, color: color, visualDensity: minimumVisualDensity),
              const Spacer(),
              if (selectedTabIndex.value == 0)
                buttonText("Cancel".tr, visualDensity: minimumVisualDensity, onPress: () => _controller.cancelOpenOrderApp(trade)),
              if (selectedTabIndex.value == 1) TextRobotoAutoBold("$tradeCoin/$baseCoin"),
            ],
          ),
        twoTextSpaceFixed("${"Amount".tr}: ", "${coinFormat(trade.amount)} $tradeCoin", color: pcl, fontSize: Dimens.regularFontSizeSmall),
        twoTextSpaceFixed("${"Fees".tr}: ", "${coinFormat(trade.fees)} $baseCoin", color: pcl, fontSize: Dimens.regularFontSizeSmall),
        twoTextSpaceFixed("${"Price".tr}: ", "${coinFormat(trade.price)} $baseCoin", color: pcl, fontSize: Dimens.regularFontSizeSmall),
        if (selectedTabIndex.value != 1)
          twoTextSpaceFixed("${"Processed".tr}: ", "${coinFormat(trade.processed)} $tradeCoin", color: pcl, fontSize: Dimens.regularFontSizeSmall),
        if (selectedTabIndex.value != 2)
          twoTextSpaceFixed("${"Total".tr}: ", "${coinFormat(trade.total)} $baseCoin", color: pcl, fontSize: Dimens.regularFontSizeSmall),
        twoTextSpaceFixed("${"Created At".tr}: ", formatDate(trade.createdAt, format: dateTimeFormatDdMMMMYyyyHhMm),
            color: pcl, fontSize: Dimens.regularFontSizeSmall),
        if (selectedTabIndex.value == 2) textWithCopyView(trade.transactionId ?? "", mainAxisAlign: MainAxisAlignment.end),
        dividerHorizontal()
      ],
    );
  }
}
