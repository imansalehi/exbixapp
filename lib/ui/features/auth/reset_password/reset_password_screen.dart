import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/ui/features/auth/auth_widgets.dart';
import 'package:exbix_flutter/ui/features/auth/sign_in/sign_in_screen.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/text_field_util.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'reset_password_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String registrationId;

  const ResetPasswordScreen({super.key, required this.registrationId});

  @override
  ResetPasswordScreenState createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _controller = Get.put(ResetPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBarAuthView(title: "Sign In".tr, onPress: () => Get.off(() => const SignInPage()), hideBack: true),
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLargeDouble),
          children: [
            vSpacer20(),
            AuthTopTitleView(title: 'Recovery or reset Password'.tr, subTitle: "${'reset_password_message'.tr} ${widget.registrationId}"),
            vSpacer10(),
            textFieldWithSuffixIcon(
                controller: _controller.codeEditController,
                labelText: "Reset Code".tr,
                hint: "Reset Code".tr,
                type: TextInputType.emailAddress),
            vSpacer15(),
            Obx(() {
              return textFieldWithSuffixIcon(
                  controller: _controller.passEditController,
                  labelText: "New Password".tr,
                  hint: "New Password".tr,
                  type: TextInputType.visiblePassword,
                  iconPath: _controller.isShowPassword.value ? AssetConstants.icPasswordShow : AssetConstants.icPasswordHide,
                  isObscure: !_controller.isShowPassword.value,
                  iconAction: () => _controller.isShowPassword.value = !_controller.isShowPassword.value);
            }),
            vSpacer15(),
            Obx(() {
              return textFieldWithSuffixIcon(
                  controller: _controller.confirmPassEditController,
                  labelText: "Confirm New Password".tr,
                  hint: "Confirm New Password".tr,
                  type: TextInputType.visiblePassword,
                  iconPath: _controller.isShowPassword.value ? AssetConstants.icPasswordShow : AssetConstants.icPasswordHide,
                  isObscure: !_controller.isShowPassword.value,
                  iconAction: () => _controller.isShowPassword.value = !_controller.isShowPassword.value);
            }),
            vSpacer30(),
            buttonRoundedMain(
                text: "Reset password".tr, onPress: () => _controller.isInPutDataValid(context, widget.registrationId)),
            vSpacer10(),
          ],
        ),
      ),
    );
  }
}
