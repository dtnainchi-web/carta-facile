import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/app_state.dart';
import 'core/content.dart';
import 'core/theme.dart';
import 'screens/shell.dart';
import 'services/notification_service.dart';
import 'widgets/ad_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appState.load();
  await NotificationService.instance.init();
  await ContentRepository.instance.load();
  // Ads exist only on Android/iOS, free version (see widgets/ad_banner.dart).
  if (AdBanner.supported) MobileAds.instance.initialize();
  runApp(const CartaFacileApp());
}

class CartaFacileApp extends StatelessWidget {
  const CartaFacileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) => MaterialApp(
        title: 'Carta Facile',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        locale: Locale(appState.language),
        supportedLocales: const [
          Locale('ar'),
          Locale('fr'),
          Locale('it'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Shell(),
      ),
    );
  }
}
