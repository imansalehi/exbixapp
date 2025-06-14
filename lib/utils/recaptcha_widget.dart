 import 'package:flutter/material.dart';
import 'package:flutter_recaptcha_v2_compat/flutter_recaptcha_v2_compat.dart';

class RecaptchaWidget extends StatelessWidget {
  final RecaptchaV2Controller controller;
  final Function(bool) onVerified;
  final Function(String) onError;

  const RecaptchaWidget({
    Key? key,
    required this.controller,
    required this.onVerified,
    required this.onError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RecaptchaV2(
      apiKey: "YOUR_SITE_KEY", // کلید سایت reCAPTCHA را اینجا قرار دهید
      apiSecret: "YOUR_SECRET_KEY", // کلید سکرت reCAPTCHA را اینجا قرار دهید
      controller: controller,
      onVerifiedError: onError,
      onVerifiedSuccessfully: onVerified,
    );
  }
}