import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:greentill/navigation/navigation_page.dart';
import 'package:greentill/ui/res/app_localizations.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/screens/login/login_screen.dart';
import 'package:greentill/ui/screens/signup/signup_screen.dart';
import 'package:greentill/utils/shared_pref_helper.dart';

import 'bloc/main_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreference initialization
  await SharedPrefHelper.createInstance();
  //await Firebase.initializeApp();
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  //FirebaseMessagingService().init();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<MainBloc>(
        create: (BuildContext context) => MainBloc(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.dark,
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

      theme: ThemeData(
        // primarySwatch: colortheme,
        primaryColor: colortheme,
        backgroundColor: colorWhite
      ),
      // theme: ThemeData(
      //     primarySwatch: Colors.lightBlue,
      //     primaryColor: colorBackgroundButton,
      //     backgroundColor: Colors.white,
      //     visualDensity: VisualDensity.adaptivePlatformDensity,
      //     fontFamily: "Proxima Nova"),
      //
      home:  SignUpScreen(),
    );
  }
}

