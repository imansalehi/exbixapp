import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/ui/features/auth/auth_widgets.dart';
import 'package:exbix_flutter/ui/features/auth/forgot_password/forgot_password_page.dart';
import 'package:exbix_flutter/ui/features/auth/sign_up/sign_up_screen.dart';
import 'package:exbix_flutter/ui/features/auth/social_login_view.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'sign_in_controller.dart';
import 'package:exbix_flutter/data/local/constants.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/text_field_util.dart';
import 'package:exbix_flutter/utils/text_util.dart';
import 'package:exbix_flutter/utils/recaptcha_widget.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  final _controller = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBarAuthView(title: "Sign Up".tr, onPress: () => Get.off(() => const SignUpScreen())),
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLargeDouble),
          children: [
            vSpacer20(),
            AuthTopTitleView(title: 'Sign In'.tr, subTitle: 'SignIn_description'.tr),
            vSpacer10(),
            textFieldWithSuffixIcon(
              labelText: 'Email'.tr,
              controller: _controller.emailEditController,
              hint: "Email".tr,
              type: TextInputType.emailAddress,
            ),
            vSpacer15(),
            Obx(() {
              return textFieldWithSuffixIcon(
                labelText: 'Password'.tr,
                controller: _controller.passEditController,
                hint: "Password".tr,
                type: TextInputType.visiblePassword,
                iconPath: _controller.isShowPassword.value
                    ? AssetConstants.icPasswordShow
                    : AssetConstants.icPasswordHide,
                isObscure: !_controller.isShowPassword.value,
                iconAction: () {
                  _controller.isShowPassword.value = !_controller.isShowPassword.value;
                },
              );
            }),
            vSpacer20(),
            RecaptchaWidget(
              controller: _controller.recaptchaController,
              onVerified: () => _controller.onRecaptchaVerified(),
              onError: _controller.onRecaptchaError,
            ),
            vSpacer20(),
            InkWell(
              onTap: () => Get.off(() => const ForgotPasswordPage()),
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: TextRobotoAutoNormal('Forgot Password'.tr, decoration: TextDecoration.underline),
            ),
            vSpacer30(),
            buttonRoundedMain(
              text: "Sign In".tr,
              onPress: () => _controller.isInPutDataValid(context),
            ),
            vSpacer20(),
            const SocialLoginView(),
          ],
        ),
      ),
    );
  }
}
