import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:exbix_flutter/data/remote/socket_provider.dart';
import 'package:exbix_flutter/ui/features/on_boarding/on_boarding_screen.dart';
import 'package:exbix_flutter/ui/features/root/root_screen.dart';
import 'package:exbix_flutter/utils/common_utils.dart';
import 'package:exbix_flutter/utils/language_util.dart';
import 'package:exbix_flutter/utils/network_util.dart';
import 'package:exbix_flutter/utils/theme.dart';
import 'data/local/api_constants.dart';
import 'data/local/constants.dart';
import 'data/local/strings.dart';
import 'data/remote/api_provider.dart';
import 'data/remote/api_repository.dart';
import 'helper/app_helper.dart';
import 'package:exbix_flutter/services/translation_service.dart';

void main() async {
  await dotenv.load(fileName: EnvKeyValue.kEnvFile);
  await GetStorage.init();
  await _setDefaultValues();
  WidgetsFlutterBinding.ensureInitialized();
  gIsDarkMode = ThemeService().loadThemeFromBox();
  Get.put(APIProvider());
  Get.put(SocketProvider());
  initBuySellColor();
getCommonSettings().then((value) {
  if (value) {
    TranslationService.init().then((_) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
          .then((_) => runApp(const MyApp()));
    });
  }
});

}

Future<void> _setDefaultValues() async {
  GetStorage().writeIfNull(PreferenceKey.isDark, systemThemIsDark());
  GetStorage().writeIfNull(PreferenceKey.isLoggedIn, false);
  GetStorage().writeIfNull(PreferenceKey.isOnBoardingDone, false);
  GetStorage().writeIfNull(PreferenceKey.languageKey, LanguageUtil.defaultLangKey);
  GetStorage().writeIfNull(PreferenceKey.buySellColorIndex, 0);
  GetStorage().writeIfNull(PreferenceKey.buySellUpDown, 0);
}

Future<bool> getCommonSettings() async {
  gUserAgent = await getUserAgent();
  final isOnline = await NetworkCheck.isOnline();
  if (isOnline) {
    final resp = await APIRepository().getCommonSettings();
    if (resp.success && resp.data != null && resp.data is Map<String, dynamic>) {
      final settings = resp.data[APIKeyConstants.commonSettings];
      if (settings != null && settings is Map<String, dynamic>) {
        GetStorage().write(PreferenceKey.settingsObject, settings);
      }
      final media = resp.data[APIKeyConstants.landingSettings]["media_list"];
      if (media != null && media is List) {
        GetStorage().write(PreferenceKey.mediaList, media);
      }
      return true;
    }
  }
  return false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: ThemeService().getBrightness()));
    final isOnBoarding = GetStorage().read(PreferenceKey.isOnBoardingDone);
    final screen = isOnBoarding ? const RootScreen() : const OnBoardingScreen();

    return Directionality(
      textDirection: LanguageUtil.getTextDirection(),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        defaultTransition: Transition.rightToLeftWithFade,
        theme: Themes.light,
        darkTheme: Themes.dark,
        themeMode: ThemeService().theme,
        translations: TranslationService(),
        locale: LanguageUtil.getCurrentLocal(),
        fallbackLocale: LanguageUtil.locales.first.local,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          CountryLocalizations.delegate,
        ],
        initialRoute: "/",
        builder: (context, child) {
          final scale = MediaQuery.of(context).textScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 1.3);
          return MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: scale), child: child!);
        },
        home: screen,
      ),
    );
  }
}
