import 'package:flutter_recaptcha_v2_compat/flutter_recaptcha_v2_compat.dart';
import 'package:flutter/material.dart';

class RecaptchaWidget extends StatelessWidget {
  final RecaptchaV2Controller controller;
  final Function(String) onVerified;
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
      controller: controller,
      onVerifiedError: onError,
      onVerifiedSuccessfully: (success) {
        if (success) {
          // گوگل ریکپچا موفق بود، حالا توکن را از کنترلر بگیر
          controller.getVerificationToken().then((token) {
            if (token != null) {
              onVerified(token);
            } else {
              onError?.call("Failed to retrieve token.");
            }
          });
        } else {
          onError?.call("Recaptcha verification failed.");
        }
      },
    );
  }
}
