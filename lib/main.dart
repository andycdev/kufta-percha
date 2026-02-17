import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kufta_percha/models/categories.dart';
import 'package:kufta_percha/pages/loading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 


void main() async {
  // Inicializa los widgets y Hive
  WidgetsFlutterBinding.ensureInitialized();
  // Obtenemos el directorio con getApplicationDocumentsDirectory() para inicializar Hive en una ubicación segura y accesible.
  final appDocDir = await getApplicationDocumentsDirectory();
  // Inicializamos Hive en ese directorio para asegurar que los datos se guarden correctamente y estén disponibles incluso después de cerrar la app.
  await Hive.initFlutter(appDocDir.path);
  // Hive con las configuraciones del usuario
  await Hive.openBox('userSettingsBox');
  // Hive con las categorias guardadas
  await Hive.openBox('categoriesBox');
  final categoriesBox = Hive.box('categoriesBox');
  if (categoriesBox.isEmpty) {
    final defaultCategories = [
      Categories(id: 0, name: "Todas"),
      Categories(id: 1, name: "Favoritos"),
    ];
    for (var category in defaultCategories) {
      categoriesBox.add(category.toMap());
    }
  }

  // Hive con las prendas guardadas
  await Hive.openBox('prendasBox');
  // Hive con las pintas guardadas
  await Hive.openBox('pintasBox');
  // await Hive.openBox('app_data');

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // await initializeDateFormatting();
  // // await initNotifications();
  // tz.initializeTimeZones();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = Hive.box('userSettingsBox');
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
            fontFamily: "Fredoka",
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
            fontFamily: "Fredoka",
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

          locale: const Locale('es'),

          supportedLocales: const [Locale('es'), Locale('en')],

          localizationsDelegates: [
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
