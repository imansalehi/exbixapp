import 'package:flutter/material.dart';
import 'package:flutter_recaptcha_v2_compat/flutter_recaptcha_v2_compat.dart';

class RecaptchaWidget extends StatefulWidget {
  final VoidCallback onVerified;
  final Function(String)? onError;

  const RecaptchaWidget({
    Key? key,
    required this.onVerified,
    this.onError,
  }) : super(key: key);

  @override
  State<RecaptchaWidget> createState() => _RecaptchaWidgetState();
}

class _RecaptchaWidgetState extends State<RecaptchaWidget> {
  late RecaptchaV2Controller _recaptchaV2Controller;

  @override
  void initState() {
    super.initState();
    _recaptchaV2Controller = RecaptchaV2Controller();
  }

  void _showCaptcha() {
    _recaptchaV2Controller.show();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _showCaptcha,
          child: const Text("I'm not a robot"),
        ),
        RecaptchaV2(
          apiKey: "YOUR_GOOGLE_RECAPTCHA_SITE_KEY",
          controller: _recaptchaV2Controller,
          onVerifiedSuccessfully: (success) {
            if (success == true) {
              widget.onVerified(); // بدون پارامتر چون فقط تأیید نیاز دارید
            } else {
              widget.onError?.call("Verification failed");
            }
          },
          onVerifiedError: (err) {
            widget.onError?.call(err);
          },
        ),
      ],
    );
  }
}
