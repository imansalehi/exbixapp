import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:exbix_flutter/ui/features/root/root_screen.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_util.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  OnBoardingScreenState createState() => OnBoardingScreenState();
}

class OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < 3; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
      height: Dimens.paddingMid,
      width: Dimens.paddingMid,
      decoration: BoxDecoration(
          color: isActive ? context.theme.focusColor : Get.theme.primaryColorLight.withOpacity(0.5),
          border: Border.all(color: Get.theme.primaryColor, width: 1),
          borderRadius: const BorderRadius.all(Radius.elliptical(10, 10))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: PageView(
        physics: const ClampingScrollPhysics(),
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() => _currentPage = page);
        },
        children: [
          buildOnBoardingPage(AssetConstants.onBoarding0, "kOnBoardingTitle_0".tr, "kOnBoardingDescription_0".tr, _currentPage),
          buildOnBoardingPage(AssetConstants.onBoarding1, "kOnBoardingTitle_1".tr, "kOnBoardingDescription_1".tr, _currentPage),
          buildOnBoardingPage(AssetConstants.onBoarding2, "kOnBoardingTitle_2".tr, "kOnBoardingDescription_2".tr, _currentPage),
        ],
      ),
    );
  }

  Widget buildOnBoardingPage(String onBoardingLogo, String title, String description, int page) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: Dimens.paddingLargeExtra),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => finishOnBoarding(),
                      child: TextRobotoAutoBold(page == 2 ? '' : 'Skip'.tr),
                    ),
                  ),
                ),
                Image.asset(onBoardingLogo, width: Get.width / 1.40, height: Get.width / 1.40, fit: BoxFit.cover),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextRobotoAutoBold(title, textAlign: TextAlign.center),
                vSpacer15(),
                TextRobotoAutoNormal(description, maxLines: 5, textAlign: TextAlign.center),
                vSpacer15(),
                Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: _buildPageIndicator()),
                vSpacer20(),
                buttonRoundedMain(
                    text: "Next".tr,
                    onPress: () {
                      _pageController.animateToPage(_currentPage + 1, duration: const Duration(milliseconds: 500), curve: Curves.linear);
                      if (_currentPage == 2) finishOnBoarding();
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void finishOnBoarding() {
    GetStorage().write(PreferenceKey.isOnBoardingDone, true);
    Get.off(() => const RootScreen(), transition: Transition.leftToRightWithFade);
  }
}
