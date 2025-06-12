import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/ui/features/auth/auth_widgets.dart';
import 'package:exbix_flutter/ui/features/auth/sign_in/sign_in_screen.dart';
import 'package:exbix_flutter/ui/features/auth/social_login_view.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/common_widgets.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'package:exbix_flutter/utils/text_field_util.dart';
import 'package:exbix_flutter/utils/text_util.dart';
import 'sign_up_controller.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _controller = Get.put(SignUpController());

  @override
  void initState() {
    super.initState();
    _controller.phoneEditController.text = _controller.selectedPhone.value.phoneCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBarAuthView(title: "Sign In".tr, onPress: () => Get.off(() => const SignInPage())),
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLargeDouble),
          children: [
            vSpacer20(),
            AuthTopTitleView(title: 'Sign up'.tr, subTitle: 'Create your own account'.tr),
            vSpacer10(),
            textFieldWithSuffixIcon(
                controller: _controller.firstNameEditController, labelText: "First Name".tr, hint: "First Name".tr, type: TextInputType.name),
            vSpacer15(),
            textFieldWithSuffixIcon(
                controller: _controller.lastNameEditController, labelText: "Last Name".tr, hint: "Last Name".tr, type: TextInputType.name),
            vSpacer15(),
            textFieldWithSuffixIcon(
                controller: _controller.emailEditController, labelText: "Email".tr, hint: "Email".tr, type: TextInputType.emailAddress),
            vSpacer10(),
            TextRobotoAutoNormal("Optional".tr),
            vSpacer5(),
            Obx(() => textFieldWithWidget(
                controller: _controller.phoneEditController,
                type: TextInputType.phone,
                prefixWidget: countryPickerView(context, _controller.selectedPhone.value, (value) {
                  _controller.selectedPhone.value = value;
                  _controller.phoneEditController.text = value.phoneCode;
                }, showPhoneCode: true))),
            TextRobotoAutoNormal("add phone number message".tr, maxLines: 2, fontSize: Dimens.regularFontSizeMin),
            vSpacer15(),
            Obx(() {
              return textFieldWithSuffixIcon(
                  controller: _controller.passEditController,
                  labelText: "Password".tr,
                  hint: "Password".tr,
                  type: TextInputType.visiblePassword,
                  iconPath: _controller.isShowPassword.value ? AssetConstants.icPasswordShow : AssetConstants.icPasswordHide,
                  isObscure: !_controller.isShowPassword.value,
                  iconAction: () => _controller.isShowPassword.value = !_controller.isShowPassword.value);
            }),
            vSpacer15(),
            Obx(() {
              return textFieldWithSuffixIcon(
                  controller: _controller.confirmPassEditController,
                  labelText: "Confirm Password".tr,
                  hint: "Confirm Password".tr,
                  type: TextInputType.visiblePassword,
                  iconPath: _controller.isShowPassword.value ? AssetConstants.icPasswordShow : AssetConstants.icPasswordHide,
                  isObscure: !_controller.isShowPassword.value,
                  iconAction: () => _controller.isShowPassword.value = !_controller.isShowPassword.value);
            }),
            vSpacer30(),
            buttonRoundedMain(text: "Sign Up".tr, onPress: () => _controller.isInPutDataValid(context)),
            vSpacer20(),
            const SocialLoginView(),
          ],
        ),
      ),
    );
  }
}
