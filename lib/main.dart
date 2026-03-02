import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:greentill/config/runtime_config.dart';
import 'package:greentill/navigation/navigation_page.dart';
import 'package:greentill/preview/preview_app.dart';
import 'package:greentill/ui/res/app_localizations.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/utils/firebase_messaging_service.dart';
import 'package:greentill/utils/shared_pref_helper.dart';

import 'bloc/main_bloc.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  await SharedPrefHelper.createInstance();
  print(message.data.toString());
  print(message.notification?.title);
  print('Handling a background message ${message.messageId}');
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool isNotificationArrives = false;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    runApp(const PreviewApp());
    return;
  }

  // SharedPreference initialization
  await SharedPrefHelper.createInstance();
  debugPrint("GreenTill API base: ${RuntimeConfig.apiBaseUrl}");
  if (!kIsWeb) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  if (!kIsWeb) {
    FirebaseMessagingService().init();
    await FlutterDownloader.initialize(
        debug:
            true, // optional: set to false to disable printing logs to console (default: true)
        ignoreSsl:
            true // option: set to false to disable working with http links (default: false)
        );
  }
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<MainBloc>(
        create: (BuildContext context) => MainBloc(),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!kIsWeb) {
      FirebaseMessagingService().init();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: gpLight,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Green Till',
      supportedLocales: const [
        Locale('en', ''),
      ],

      localizationsDelegates: const [
        // THIS CLASS WILL BE ADDED LATER
        // A class which loads the translations from JSON files
        AppLocalizations.delegate,
        // Built-in localization of basic text for Material widgets
        GlobalMaterialLocalizations.delegate,
        // Built-in localization for text direction LTR/RTL
        GlobalWidgetsLocalizations.delegate,
      ],
      // Returns a locale which will be used by the app
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => NavigationPage(),

        // When navigating to the "/second" route, build the SecondScreen widget.
      },
      navigatorKey: navigatorKey,

      theme: ThemeData(
        primaryColor: gpGreen,
        scaffoldBackgroundColor: gpLight,
        dividerColor: gpBorder,
        colorScheme: const ColorScheme.light(
          primary: gpGreen,
          onPrimary: gpLight,
          secondary: gpImpactOrange,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: gpTextPrimary,
          error: gpError,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: gpLight,
          foregroundColor: gpTextPrimary,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: gpLight,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: gpTextPrimary,
              displayColor: gpTextPrimary,
            ),
        fontFamily: "Avenir",
      ),
      // theme: ThemeData(
      //     primarySwatch: Colors.lightBlue,
      //     primaryColor: colorBackgroundButton,
      //     backgroundColor: Colors.white,
      //     visualDensity: VisualDensity.adaptivePlatformDensity,
      //     fontFamily: "Proxima Nova"),
      //
      // home: NavigationPage(),
      initialRoute: '/',
    );
  }
}
