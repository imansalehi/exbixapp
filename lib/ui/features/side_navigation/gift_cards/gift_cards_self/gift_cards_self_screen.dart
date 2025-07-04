import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/utils/appbar_util.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/extentions.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_util.dart';

import '../gift_cards_widgets.dart';
import 'gift_cards_self_controller.dart';

class GiftCardSelfScreen extends StatefulWidget {
  const GiftCardSelfScreen({super.key});

  @override
  GiftCardSelfScreenState createState() => GiftCardSelfScreenState();
}

class GiftCardSelfScreenState extends State<GiftCardSelfScreen> {
  final _controller = Get.put(GiftCardSelfController());
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.getGiftCardMyPageData(() => setState(() {}));
      _scrollController.addListener(() {
        if (_scrollController.position.maxScrollExtent == _scrollController.offset) {
          if (_controller.hasMoreData) _controller.getGiftCardMyCardList(true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 3;

    return Scaffold(
      appBar: appBarBackWithActions(title: "My Cards".tr),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            if ((_controller.giftCardsData?.header.isValid ?? false) || (_controller.giftCardsData?.description.isValid ?? false))
              SliverAppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                expandedHeight: width,
                collapsedHeight: width,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
                  child: GiftCardTitleView(
                      title: _controller.giftCardsData?.header,
                      subTitle: _controller.giftCardsData?.description,
                      image: _controller.giftCardsData?.banner),
                ),
              ),
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Get.theme.scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              toolbarHeight: Dimens.menuHeight,
              pinned: true,
              flexibleSpace: Row(
                children: [
                  hSpacer10(),
                  TextRobotoAutoBold("${"Status".tr}:"),
                  Expanded(
                    child: Obx(() {
                      return dropDownListIndex(_controller.getStatusList(), _controller.selectedStatus.value, "", (index) {
                        _controller.selectedStatus.value = index;
                        _controller.getGiftCardMyCardList(false);
                      }, height: Dimens.btnHeightMid);
                    }),
                  ),
                ],
              ),
            ),
            Obx(() {
              return _controller.myCardList.isEmpty
                  ? SliverFillRemaining(child: handleEmptyViewWithLoading(_controller.isLoading.value))
                  : SliverPadding(
                      padding: const EdgeInsets.all(10),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: Dimens.paddingMin,
                        crossAxisSpacing: Dimens.paddingMin,
                        childCount: _controller.myCardList.length,
                        itemBuilder: (context, index) => GiftCardItemView(gCard:_controller.myCardList[index], from:''),
                      )
              );
            }),
          ],
        ),
      ),
    );
  }
}
