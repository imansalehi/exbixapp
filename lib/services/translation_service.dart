import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TranslationService extends Translations {
  static final locale = Locale('en');
  static final fallbackLocale = Locale('en');

  static Map<String, Map<String, String>> translations = {};

  static Future<void> init() async {
    final enJson = await rootBundle.loadString('assets/langs/en.json');
    translations['en'] = Map<String, String>.from(json.decode(enJson));

    try {
      final faJson = await rootBundle.loadString('assets/langs/fa.json');
      translations['fa'] = Map<String, String>.from(json.decode(faJson));
    } catch (e) {
      // اگر fa.json نبود مشکلی نیست
    }

    Get.addTranslations(translations);
  }

  @override
  Map<String, Map<String, String>> get keys => translations;
}
