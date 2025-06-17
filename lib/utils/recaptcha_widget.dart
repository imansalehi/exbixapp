import 'package:flutter_recaptcha_v2_compat/flutter_recaptcha_v2_compat.dart';
import 'package:flutter/material.dart';
import 'package:exbix_flutter/data/local/api_constants.dart';
import 'package:exbix_flutter/data/remote/api_repository.dart';

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
    return FutureBuilder<Map<String, dynamic>>(
      future: APIRepository().getRecaptchaConfig(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('خطا در دریافت تنظیمات reCAPTCHA: ${snapshot.error}'));
        }

        final config = snapshot.data;
        if (config == null || !config['enabled']) {
          return const SizedBox.shrink();
        }

        return RecaptchaV2(
          apiKey: config['site_key'] ?? '',
          apiSecret: config['secret_key'] ?? '',
          onVerified: onVerified,
          onVerifiedError: onError,
          controller: controller,
          onExpired: () {
            if (onError != null) {
              onError!('reCAPTCHA منقضی شده است');
            }
          },
        );
      },
    );
  }
}