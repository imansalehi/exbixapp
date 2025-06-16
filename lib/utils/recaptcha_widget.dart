import 'package:flutter/material.dart';
import 'package:flutter_recaptcha_v2_compat/flutter_recaptcha_v2_compat.dart';

class RecaptchaWidget extends StatelessWidget {
  final RecaptchaV2Controller controller;
  final Function(String token) onVerified;
  final Function(String)? onError;

  const RecaptchaWidget({
    Key? key,
    required this.controller,
    required this.onVerified,
    this.onError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RecaptchaV2(
      apiKey: "6LdTYUArAAAAAMkFByy8UJnvCgot8Th-K-lirX7Z",
      apiSecret: "6LdTYUArAAAAANOWObr2lH8XVe9gNoInHq-mjqA2",
      pluginURL: "https://recaptcha-flutter-plugin.firebaseapp.com/",
      controller: controller,
      onVerifiedError: (err) {
        onError?.call(err);
      },
      onVerifiedSuccessfully: (token) {
        if (token != null && token.isNotEmpty) {
          onVerified(token); // ارسال توکن معتبر
        } else {
          onError?.call("Recaptcha verification failed.");
        }
      },
    );
  }
}
