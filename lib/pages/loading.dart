import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kufta_percha/pages/indexpage.dart';
import 'package:kufta_percha/utils/responsive.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Espera un mini tiempo para que la animación se vea fluida

    // Abre cajas Hive (si ya están abiertas, no pasa nada)
    await _openHiveBox("userSettingsBox");
    await _openHiveBox("prendasBox");
    await _openHiveBox("pintasBox");

    // await requestAllNotificationPermissions();
    // await mostrarNotificacionSoloUnaVez();

    // AQUÍ puedes cargar cosas extras si quieres:
    // await cargarImagenesInternas();
    // await precachePictures();
    // etc...

    // Luego navega al home
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 1500),
            pageBuilder: (_, _, _) => const IndexPages(),
            transitionsBuilder: (_, anim, _, child) {
              return FadeTransition(opacity: anim, child: child);
            },
          ),
        );
      }
    });
  }

  Future<void> _openHiveBox(String name) async {
    if (!Hive.isBoxOpen(name)) {
      try {
        await Hive.openBox(name);
      } catch (e) {
        debugPrint("⚠ Error abriendo box $name: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Theme.of(context).colorScheme.primary.withAlpha(180),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(),
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/img/icon.png",
                  width: r.wp(80),
                  fit: BoxFit.contain,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : null,
                  colorBlendMode: BlendMode.srcIn,
                ),

                Text(
                  "Cargando las perchas",
                  style: TextStyle(
                    fontSize: r.dp(2.2),
                    fontWeight: FontWeight.w600,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(230),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: r.dp(3)),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
