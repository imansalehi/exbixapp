import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exbix_flutter/ui/features/auth/auth_widgets.dart';
import 'package:exbix_flutter/ui/features/auth/sign_in/sign_in_screen.dart';
import 'package:exbix_flutter/ui/features/auth/sign_up/sign_up_screen.dart';
import 'package:exbix_flutter/utils/button_util.dart';
import 'package:exbix_flutter/utils/dimens.dart';
import 'package:exbix_flutter/utils/text_field_util.dart';
import 'package:exbix_flutter/utils/spacers.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ForgotPasswordPageState createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _controller = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar:
          AppBarAuthView(title: "Sign Up".tr, onPress: () => Get.off(() => const SignUpScreen()), onBack: () => Get.off(() => const SignInPage())),
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLargeDouble),
          children: [
            vSpacer20(),
            AuthTopTitleView(title: 'Forget Password'.tr, subTitle: 'enter email address to request password reset'.tr),
            vSpacer10(),
            textFieldWithSuffixIcon(
                labelText: 'Email'.tr, controller: _controller.emailEditController, hint: "Email".tr, type: TextInputType.emailAddress),
            vSpacer30(),
            buttonRoundedMain(text: "Send".tr, onPress: () => _controller.isInPutDataValid(context)),
          ],
        ),
      ),
    );
  }
}
