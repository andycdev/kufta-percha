import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kufta_percha/pages/loading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void myBackgroundHandler(NotificationResponse response) {
}

final FlutterLocalNotificationsPlugin noti = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Bogota'));

  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
  );

  await noti.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (response) {
    },
    onDidReceiveBackgroundNotificationResponse: myBackgroundHandler,
  );
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);
  await Hive.openBox('pintasBox');
  await Hive.openBox('settingsBox');
  await Hive.openBox('prendasBox');

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await initializeDateFormatting();
  await initNotifications();
  tz.initializeTimeZones();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = Hive.box('settingsBox');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ValueListenableBuilder(
      valueListenable: settings.listenable(keys: ['primaryColor', 'themeMode']),
      builder: (context, box, _) {
        final storedColor = box.get('primaryColor', defaultValue: 0xff057a7b);
        final modeIndex = box.get('themeMode', defaultValue: 0);
        final themeMode = switch (modeIndex) {
          0 => ThemeMode.system,
          1 => ThemeMode.light,
          2 => ThemeMode.dark,
          _ => ThemeMode.system,
        };

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Kufta percha',
          themeMode: themeMode, // ← AQUÍ CAMBIA EL TEMA
          theme: ThemeData(
            fontFamily: "ComicNeue",
            brightness: Brightness.light,
            colorScheme:
                ColorScheme.fromSeed(
                  seedColor: Color(storedColor),
                  surface: const Color(0xfff5f5f5),
                  brightness: Brightness.light,
                ).copyWith(
                  primary: Color(storedColor), // ← NUNCA CAMBIA
                  primaryContainer: Color(storedColor), // ← TAMPOCO CAMBIA
                ),
          ),
          darkTheme: ThemeData(
            fontFamily: "ComicNeue",
            brightness: Brightness.dark,
            colorScheme:
                ColorScheme.fromSeed(
                  seedColor: Color(storedColor),
                  surface: const Color(0xff121212),
                  brightness: Brightness.dark,
                ).copyWith(
                  primary: Color(storedColor), // ← FIJO EN MODO OSCURO
                  primaryContainer: Color(storedColor), // ← FIJO TAMBIÉN
                ),
          ),
          locale: WidgetsBinding
              .instance
              .window
              .locale, // toma el idioma del celular
          supportedLocales: const [
            Locale('es', 'CO'), // español Colombia
            Locale('es'), // español genérico
            Locale('en', 'US'), // inglés EEUU
            Locale('en'), // inglés genérico
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const LoadingScreen(),
        );
      },
    );
  }
}
