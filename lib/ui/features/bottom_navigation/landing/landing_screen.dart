import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/helper/app_helper.dart';
import 'package:exbix_flutter/ui/features/auth/sign_in/sign_in_screen.dart';
import 'package:exbix_flutter/utils/alert_util.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/decorations.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/extentions.dart';
import 'package:exbix_flutter/utils/image_util.dart';
import 'package:exbix_flutter/utils/shimmer_loading/shimmer_view.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_util.dart';
import 'package:exbix_flutter/utils/web_view.dart';

import '../../side_navigation/activity/activity_screen.dart';
import '../../side_navigation/blog/blog_screen.dart';
import '../../side_navigation/faq/faq_page.dart';
import '../../side_navigation/gift_cards/gift_cards_screen.dart';
import '../../side_navigation/profile/profile_screen.dart';
import '../../side_navigation/referrals/referrals_screen.dart';
import '../../side_navigation/staking/staking_screen.dart';
import '../../side_navigation/fiat/fiat_screen.dart';
import '../wallet/swap/swap_screen.dart';
import 'announcement_view.dart';
import 'landing_controller.dart';
import 'landing_market_view.dart';
import 'landing_widgets.dart';
import '../wallet_selection_page.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _controller = Get.put(LandingController());

  @override
  void initState() {
    super.initState();
    _controller.getLandingSettings();
    if (getSettingsLocal()?.blogNewsModule == 1) _controller.getLatestBlogList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const AppBarHomeView(),
      Expanded(child: Obx(() {
        final lData = _controller.landingData.value;
        return _controller.isLoading.value
            ? const ShimmerViewLanding()
            : ListView(
                shrinkWrap: true,
                children: [
                  if (lData.landingSecondSectionStatus == 1 && lData.bannerList.isValid) HomeBannerListView(bannerList: lData.bannerList!),
                  if (lData.announcementList.isValid) AnnouncementView(announcementList: lData.announcementList!),
                  _exploreView(),
                  if (lData.landingThirdSectionStatus == 1) const LandingMarketView(),
                  LandingTopView(lData: lData),
                  _getLandingAdvertisementView(),
                  _getLandingButtonView(),
                  _featureView(),
                  _latestBlogView()
                ],
              );
      })),
    ]);
  }

  _getLandingAdvertisementView() {
    final lData = _controller.landingData.value;
    if (lData.landingAdvertisementSectionStatus == 1 && lData.landingAdvertisementImage.isValid) {
      return showImageNetwork(
          imagePath: lData.landingAdvertisementImage,
          width: Get.width,
          boxFit: BoxFit.fitWidth,
          onPressCallback: () {
            if (lData.landingAdvertisementUrl.isValid) Get.to(() => WebViewPage(url: lData.landingAdvertisementUrl!));
          });
    }

    return vSpacer0();
  }

  _getLandingButtonView() {
    final hasUser = gUserRx.value.id > 0;
    final title = hasUser ? "Start Trading Now".tr : "Sign_Up_Sign_In".tr;
    return Padding(
        padding: const EdgeInsets.all(Dimens.paddingLargeExtra),
        child: buttonRoundedMain(
            text: title,
            buttonHeight: Dimens.btnHeightMid,
            textColor: Colors.white,
            onPress: () {
              hasUser ? getRootController().changeBottomNavIndex(AppBottomNavKey.trade) : Get.offAll(() => const SignInPage());
            }));
  }

  _featureView() {
    final lData = _controller.landingData.value;
    if (lData.landingSixSectionStatus == 1 && lData.featureList.isValid) {
      return Container(
          decoration: boxDecorationRoundCorner(color: context.theme.dialogBackgroundColor),
          padding: const EdgeInsets.all(Dimens.paddingMid),
          margin: const EdgeInsets.symmetric(vertical: Dimens.paddingMid),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (lData.landingFeatureTitle.isValid)
                Align(alignment: Alignment.centerLeft, child: TextRobotoAutoBold(lData.landingFeatureTitle ?? "")),
              vSpacer10(),
              Wrap(
                spacing: Dimens.paddingMid,
                runSpacing: Dimens.paddingMid,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                children: List.generate(lData.featureList!.length, (index) => LatestFeatureItemView(feature: lData.featureList![index])),
              )
            ],
          ));
    } else {
      return vSpacer0();
    }
  }

  _exploreView() {
    final settings = getSettingsLocal();
    final hasUser = gUserRx.value.id > 0;
    return Container(
      decoration: boxDecorationRoundCorner(context: context),
      padding: const EdgeInsets.all(Dimens.paddingMid),
      margin: const EdgeInsets.symmetric(vertical: Dimens.paddingMid),
      child: Wrap(
        spacing: Dimens.paddingMid,
        runSpacing: Dimens.paddingLargeExtra,
        crossAxisAlignment: WrapCrossAlignment.start,
        runAlignment: WrapAlignment.center,
        children: [
          ExploreItemView(title: "Deposit".tr, icon: Icons.file_download, onTap: () => checkLoggedInStatus(context, () => _openWalletListPage(true))),
          ExploreItemView(title: "Withdraw".tr, icon: Icons.file_upload, onTap: () => checkLoggedInStatus(context, () => _openWalletListPage(false))),
          if (settings?.swapStatus == 1)
            ExploreItemView(
                title: "Swap".tr,
                icon: Icons.swap_horizontal_circle,
                onTap: () => checkLoggedInStatus(context, () => Get.to(() => const SwapScreen()))),
          if (settings?.enableGiftCard == 1)
            ExploreItemView(title: "Gift Card".tr, icon: Icons.card_giftcard, onTap: () => Get.to(() => const GiftCardsScreen())),
          if (hasUser)
            ExploreItemView(
                title: "Wallet".tr,
                icon: Icons.wallet,
                onTap: () {
                  TemporaryData.changingPageId = 1;
                  getRootController().changeBottomNavIndex(AppBottomNavKey.wallet);
                }),
          if (settings?.enableStaking == 1)
            ExploreItemView(title: "Staking".tr, icon: Icons.punch_clock_outlined, onTap: () => Get.to(() => const StakingScreen())),

          if (hasUser) ExploreItemView(title: "Fiat".tr, icon: Icons.account_balance, onTap: () => Get.to(() => const FiatScreen())),
          if (hasUser) ExploreItemView(title: "Reports".tr, icon: Icons.history, onTap: () => Get.to(() => const ActivityScreen())),
          if (hasUser) ExploreItemView(title: "Profile".tr, icon: Icons.person, onTap: () => Get.to(() => const ProfileScreen())),

          if (settings?.blogNewsModule == 1) ExploreItemView(title: "Blog".tr, icon: Icons.rss_feed, onTap: () => Get.to(() => const BlogScreen())),
          ExploreItemView(title: "FAQ".tr, icon: Icons.help, onTap: () => Get.to(() => const FAQPage())),

          ///IF you have P2P addon, uncomment below section
          // if (settings?.p2pModule == 1)
          //   ExploreItemView(title: "P2P".tr, icon: Icons.people, onTap: () {
          //         TemporaryData.changingPageId = 1;
          //         getRootController().changeBottomNavIndex(AppBottomNavKey.trade);
          //   }),

          ///IF you have ICO addon, uncomment below section
          // if (settings?.navbar?["ico"]?.status == true)
          //   ExploreItemView(title: "ICO".tr, icon: Icons.local_atm, onTap: () => Get.to(() => const ICOScreen())),

          if (settings?.p2pModule == 1)
            ExploreItemView(
                title: "P2P".tr,
                icon: Icons.people,
                onTap: () {
                  TemporaryData.changingPageId = 1;
                  getRootController().changeBottomNavIndex(AppBottomNavKey.trade);
                }),


          Row(
            children: [
              Expanded(
                  child: ExploreItemViewLarge(
                      title: "Secure & Grow".tr,
                      subTitle: "Max your Holdings with Staking Rewards".tr,
                      icon: Icons.punch_clock_outlined,
                      onTap: () => Get.to(() => const StakingScreen()))),
              hSpacer10(),
              Expanded(
                  child: ExploreItemViewLarge(
                      title: "Refer & Earn",
                      subTitle: "Refer friend to earn rewards".tr,
                      icon: Icons.account_tree_rounded,
                      onTap: () => checkLoggedInStatus(context, () => Get.to(() => const ReferralsScreen())))),
            ],
          )
        ],
      ),
    );
  }

  void _openWalletListPage(bool isDeposit) {
    showBottomSheetFullScreen(context, WalletSelectionPage(fromKey: isDeposit ? FromKey.buy : FromKey.sell), title: "Select Wallet".tr);
  }

  _latestBlogView() {
    return Obx(() {
      final settings = getSettingsLocal();
      if (_controller.latestBlogList.isNotEmpty && settings?.blogNewsModule == 1) {
        return Container(
            decoration: boxDecorationRoundCorner(color: context.theme.dialogBackgroundColor),
            padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
            child: Column(
              children: [
                vSpacer10(),
                Row(
                  children: [
                    TextRobotoAutoBold(settings?.blogSectionHeading ?? "", maxLines: 2),
                    hSpacer5(),
                    const Spacer(),
                    buttonOnlyIcon(
                        iconData: Icons.arrow_forward_ios,
                        onPress: () => Get.to(() => const BlogScreen()),
                        visualDensity: minimumVisualDensity,
                        size: Dimens.iconSizeMin)
                  ],
                ),
                dividerHorizontal(),
                for (final blog in _controller.latestBlogList) LatestBlogItemView(blog: blog)
              ],
            ));
      } else {
        return vSpacer0();
      }
    });
  }
}
