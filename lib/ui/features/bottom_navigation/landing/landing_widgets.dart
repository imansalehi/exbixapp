import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/data/models/blog_news.dart';
import 'package:exbix_flutter/data/models/settings.dart';
import 'package:exbix_flutter/helper/app_helper.dart';
import 'package:exbix_flutter/ui/features/notifications/notifications_page.dart';
import 'package:exbix_flutter/ui/features/root/root_controller.dart';
import 'package:exbix_flutter/utils/alert_util.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/date_util.dart';
import 'package:exbix_flutter/utils/decorations.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/extentions.dart';
import 'package:exbix_flutter/utils/image_util.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_util.dart';
import 'package:exbix_flutter/utils/web_view.dart';

import '../../side_navigation/blog/blog_details_view.dart';
import '../../side_navigation/support/crisp_chat.dart';

class AppBarHomeView extends StatelessWidget implements PreferredSizeWidget {
  const AppBarHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Center(
        child: Container(
          decoration: boxDecorationRoundCorner(),
          width: Dimens.btnHeightMid,
          height: Dimens.btnHeightMid,
          alignment: Alignment.center,
          child: buttonOnlyIcon(
              visualDensity: minimumVisualDensity,
              iconData: Icons.widgets,
              size: Dimens.iconSizeMid,
              iconColor: context.theme.primaryColor,
              onPress: () => Scaffold.of(context).openDrawer()),
        ),
      ),
      actions: [
        if (gUserRx.value.id > 0 && getSettingsLocal()?.liveChatStatus == 1)
          InkWell(
            onTap: () => Get.to(() => const CrispChat()),
            child: buttonOnlyIcon(
                iconData: Icons.support_agent_outlined,
                iconColor: context.theme.primaryColor,
                size: Dimens.iconSizeMid,
                visualDensity: minimumVisualDensity),
          ),
        InkWell(
          onTap: () => Get.to(() => const NotificationsPage()),
          child: Stack(alignment: Alignment.center, children: [
            buttonOnlyIcon(
                iconData: Icons.notifications_none_outlined,
                iconColor: context.theme.primaryColor,
                size: Dimens.iconSizeMid,
                visualDensity: minimumVisualDensity),
            Obx(() {
              int count = Get.find<RootController>().notificationCount.value;
              return count > 0
                  ? Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: boxDecorationRoundCorner(color: context.theme.colorScheme.error, radius: 10),
                        height: 20,
                        width: 20,
                        padding: const EdgeInsets.all(2),
                        child: AutoSizeText(count.toString(),
                            minFontSize: 5, style: Get.textTheme.displaySmall!.copyWith(color: Colors.white), textAlign: TextAlign.center),
                      ),
                    )
                  : const SizedBox();
            }),
          ]),
        ),
        hSpacer10(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class LandingTopView extends StatelessWidget {
  const LandingTopView({super.key, this.lData});

  final LandingData? lData;

  @override
  Widget build(BuildContext context) {
    if (lData != null && lData!.landingFirstSectionStatus == 1) {
      return Padding(
        padding: const EdgeInsets.all(Dimens.paddingMid),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            vSpacer10(),
            Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(Dimens.radiusCorner),
                    child: showImageNetwork(
                        imagePath: lData?.landingBannerImage,
                        width: Dimens.iconSizeLargeExtra,
                        height: Dimens.iconSizeLargeExtra,
                        boxFit: BoxFit.contain)),
                hSpacer10(),
                Expanded(
                  child: TextRobotoAutoBold(lData?.landingTitle ?? "", maxLines: 3),
                ),
              ],
            ),
            if (lData!.landingDescription.isValid) vSpacer5(),
            if (lData!.landingDescription.isValid) TextRobotoAutoNormal(lData?.landingDescription ?? "", maxLines: 15),
            vSpacer10(),
          ],
        ),
      );
    } else {
      return vSpacer0();
    }
  }
}

double exploreItemWidth = 0;

class ExploreItemView extends StatelessWidget {
  const ExploreItemView({super.key, required this.title, required this.icon, required this.onTap, this.maxLine});

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final int? maxLine;

  @override
  Widget build(BuildContext context) {
    if (exploreItemWidth == 0) {
      exploreItemWidth = (context.width - 40) / 4;
      exploreItemWidth = exploreItemWidth - 10;
    }
    return InkWell(
      onTap: onTap,
      child: SizedBox(
          width: exploreItemWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: Dimens.iconSizeMid, color: context.theme.focusColor),
              vSpacer5(),
              TextRobotoAutoBold(title, maxLines: maxLine ?? 2, fontSize: Dimens.regularFontSizeExtraMid, color: context.theme.primaryColorLight)
            ],
          )),
    );
  }
}

class LatestBlogItemView extends StatelessWidget {
  const LatestBlogItemView({super.key, required this.blog});

  final Blog blog;

  @override
  Widget build(BuildContext context) {
    final imageSize = context.width / 4;
    return InkWell(
      onTap: () => showBottomSheetFullScreen(context, BlogDetailsView(blog: blog), title: "Blog Details".tr),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextRobotoAutoBold(blog.title ?? '', maxLines: 2),
                    vSpacer20(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextRobotoAutoNormal(blog.category ?? ''),
                        TextRobotoAutoNormal(formatDateForInbox(blog.publishAt)),
                      ],
                    )
                  ],
                ),
              ),
              if (blog.thumbnail.isValid) hSpacer10(),
              if (blog.thumbnail.isValid)
                ClipRRect(
                    borderRadius: BorderRadius.circular(Dimens.radiusCorner),
                    child: showImageNetwork(imagePath: blog.thumbnail, width: imageSize, height: imageSize - 20, boxFit: BoxFit.cover)),
            ],
          ),
          dividerHorizontal(height: Dimens.paddingLargeDouble)
        ],
      ),
    );
  }
}

class ExploreItemViewLarge extends StatelessWidget {
  const ExploreItemViewLarge({super.key, required this.title, required this.subTitle, required this.icon, required this.onTap});

  final String title;
  final String subTitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationRoundCorner(color: context.theme.dialogBackgroundColor),
      padding: const EdgeInsets.symmetric(vertical: Dimens.paddingMid),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            hSpacer10(),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TextRobotoAutoBold(title, maxLines: 1),
                TextRobotoAutoNormal(subTitle, maxLines: 2),
              ]),
            ),
            showImageAsset(icon: icon, iconSize: Dimens.iconSizeLarge, color: context.theme.primaryColor)
          ],
        ),
      ),
    );
  }
}

class LatestFeatureItemView extends StatelessWidget {
  const LatestFeatureItemView({super.key, required this.feature});

  final LandingFeature feature;

  @override
  Widget build(BuildContext context) {
    final cSize = (context.width - 50) / 2;
    return InkWell(
      onTap: () {
        if (feature.featureUrl.isValid) Get.to(() => WebViewPage(url: feature.featureUrl!));
      },
      child: Container(
        decoration: boxDecorationRoundBorder(),
        padding: const EdgeInsets.all(Dimens.paddingMid),
        width: cSize,
        child: Column(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.radiusCornerSmall),
                child: showImageNetwork(
                    imagePath: feature.featureIcon, height: Dimens.iconSizeLarge, width: Dimens.iconSizeLarge, boxFit: BoxFit.cover)),
            TextRobotoAutoBold(feature.featureTitle ?? '', maxLines: 1),
            TextRobotoAutoNormal(feature.description ?? '', maxLines: 3, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
