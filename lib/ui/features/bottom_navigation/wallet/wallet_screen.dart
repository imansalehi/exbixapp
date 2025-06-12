import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/helper/app_widgets.dart';
import 'package:exbix_flutter/utils/appbar_util.dart';
import 'package:exbix_flutter/utils/decorations.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'check_deposit_page.dart';
import 'wallet_controller.dart';
import 'wallet_list_page.dart';
import 'wallet_overview_page.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  final _controller = Get.put(WalletController());

  @override
  void initState() {
    _controller.tabController = TabController(length: _controller.getTypeMap().length, vsync: this);
    if (TemporaryData.changingPageId != null) {
      _controller.selectedTypeIndex.value = TemporaryData.changingPageId!;
      TemporaryData.changingPageId = null;
      _controller.tabController?.animateTo(_controller.selectedTypeIndex.value);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBarPlain(
            titles: _controller.getTypeMap().values.toList(),
            controller: _controller.tabController!,
            isScrollable: true,
            onTap: (value) => _controller.selectedTypeIndex.value = value),
        Expanded(
          child: Container(
            decoration: boxDecorationTopRoundBorder(radius: Dimens.radiusCornerMid),
            alignment: Alignment.topCenter,
            child: Obx(() => gUserRx.value.id == 0 ? signInNeedView() : _getBodyPage(_controller.selectedTypeIndex.value)),
          ),
        ),
      ],
    );
  }

  _getBodyPage(int index) {
    int key = _controller.getTypeMap().keys.toList()[index];
    switch (key) {
      case WalletViewType.overview:
        return const WalletOverviewPage();
      case WalletViewType.spot:
      case WalletViewType.future:
      case WalletViewType.p2p:
        return WalletListView(fromType: key);
      case WalletViewType.checkDeposit:
        return const CheckDepositPage();
      default:
        return Container();
    }
  }
}
