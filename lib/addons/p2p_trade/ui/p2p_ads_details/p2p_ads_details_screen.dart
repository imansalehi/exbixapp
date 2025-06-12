import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/addons/p2p_trade/models/p2p_ads.dart';
import 'package:exbix_flutter/addons/p2p_trade/ui/p2p_common_widgets.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/helper/app_widgets.dart';
import 'package:exbix_flutter/utils/appbar_util.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/extentions.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_field_util.dart';
import 'package:exbix_flutter/utils/text_util.dart';

import 'p2p_ads_details_controller.dart';

class P2pAdsDetailsScreen extends StatefulWidget {
  const P2pAdsDetailsScreen({super.key, required this.p2pAds, required this.adsType});

  final P2PAds p2pAds;
  final int adsType;

  @override
  P2pAdsDetailsScreenState createState() => P2pAdsDetailsScreenState();
}

class P2pAdsDetailsScreenState extends State<P2pAdsDetailsScreen> {
  final _controller = Get.put(P2pAdsDetailsController());
  String adUid = '';

  @override
  void initState() {
    adUid = widget.p2pAds.uid ?? '';
    super.initState();
    _controller.selectedPaymentM.value = -1;
    _controller.fromKey = "";
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getAdsDetails(adUid, widget.adsType));
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.adsType == 1 ? "Buy".tr : "Sell".tr;

    return Scaffold(
      appBar: appBarBackWithActions(title: "$title ${widget.p2pAds.coinType ?? ''}"),
      body: SafeArea(child: Obx(() {
        final aDetails = _controller.adsDetails;
        final currency = aDetails.ads?.currency ?? "";
        return _controller.isDataLoading.value
            ? showLoading()
            : ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(Dimens.paddingMid),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      P2pUserView(user: aDetails.ads?.user),
                      coinDetailsItemView(
                          "${aDetails.orders ?? 0} ${"Orders".tr.toLowerCase()}", "${aDetails.completion ?? 0}% ${"Completion".tr.toLowerCase()}",
                          isSwap: true, crossAlignment: CrossAxisAlignment.end)
                    ],
                  ),
                  vSpacer10(),
                  TwoTextSpaceFixed("Price".tr, "${aDetails.price ?? 0} $currency"),
                  TwoTextSpaceFixed("Available".tr, "${aDetails.available ?? 0} ${aDetails.ads?.coinType ?? ""}"),
                  TwoTextSpaceFixed("Pay Time Limit".tr, "${aDetails.ads?.paymentTimes ?? 0} ${"minutes".tr}", flex: 4),
                  vSpacer10(),
                  titleAndDescView("Terms and Conditions".tr, aDetails.ads?.terms ?? ""),
                  vSpacer10(),
                  TextRobotoAutoBold("I want to pay".tr),
                  vSpacer5(),
                  textFieldWithWidget(
                      controller: _controller.priceEditController,
                      suffixWidget: _textFieldText(currency),
                      type: TextInputType.number,
                      onTextChange: (text) => _controller.onTextChanged(adUid, widget.adsType, FromKey.up)),
                  vSpacer2(),
                  TextRobotoAutoNormal(
                      "${"Min price".tr} ${aDetails.minimumPrice ?? 0} $currency - ${"Max price".tr} ${aDetails.maximumPrice ?? 0} $currency"),
                  vSpacer20(),
                  TextRobotoAutoBold("I will receive".tr),
                  vSpacer5(),
                  textFieldWithWidget(
                      controller: _controller.amountEditController,
                      suffixWidget: _textFieldText(aDetails.ads?.coinType ?? ""),
                      type: TextInputType.number,
                      onTextChange: (text) => _controller.onTextChanged(adUid, widget.adsType, FromKey.down)),
                  vSpacer5(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: buttonTextBordered("Get all balance".tr, true, onPress: () {
                      hideKeyboard(context: context);
                      _controller.adsAvailableBalance(adUid, aDetails.ads?.coinType ?? "", widget.adsType);
                    }, visualDensity: minimumVisualDensity),
                  ),
                  vSpacer10(),
                  TextRobotoAutoBold("Select Payment Method".tr.toCapitalizeFirst()),
                  Obx(() => dropDownListIndex(
                      _controller.getPaymentNameList(),
                      _controller.selectedPaymentM.value,
                      "Select".tr,
                      hMargin: 0,
                      bgColor: Colors.transparent,
                      (index) => _controller.selectedPaymentM.value = index)),
                  vSpacer10(),
                  buttonRoundedMain(
                      bgColor: widget.adsType == 1 ? gBuyColor : gSellColor,
                      text: title,
                      onPress: () => _controller.checkAndPlaceOrder(context, widget.adsType, adUid))
                ],
              );
      })),
    );
  }

  _textFieldText(String text) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Row(
        children: [hSpacer5(), Text(text, style: context.textTheme.labelMedium), hSpacer10()],
      ),
    );
  }
}
