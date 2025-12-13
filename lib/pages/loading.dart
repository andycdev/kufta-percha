import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:kufta_percha/main.dart';
import 'package:kufta_percha/pages/indexpage.dart';
import 'package:kufta_percha/utils/notificaction.dart';
import 'package:kufta_percha/utils/responsive.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _initApp();
  }

  bool _pidiendoPermisos = false;

  Future<void> requestAllNotificationPermissions() async {
    if (_pidiendoPermisos) return;
    _pidiendoPermisos = true;

    try {
      final android = noti
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      // 1. Notificaciones normales
      await android?.requestNotificationsPermission();

      // 2. Exact alarms si aplica
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt >= 31) {
        await android?.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint("Error pidiendo permisos: $e");
    } finally {
      _pidiendoPermisos = false;
    }
  }

  void actualizarUltimaActividad() async {
    final box = await Hive.openBox('app_data');
    box.put('ultima_actividad', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _initApp() async {
    // Espera un mini tiempo para que la animación se vea fluida
    await Future.delayed(const Duration(milliseconds: 500));

    // Abre cajas Hive (si ya están abiertas, no pasa nada)
    await _openHiveBox("settingsBox");
    await _openHiveBox("prendasBox");
    await _openHiveBox("pintasBox");

    await requestAllNotificationPermissions();
    await mostrarNotificacionSoloUnaVez();

    // AQUÍ puedes cargar cosas extras si quieres:
    // await cargarImagenesInternas();
    // await precachePictures();
    // etc...

    // Luego navega al home
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, _, _) => const IndexPages(),
          transitionsBuilder: (_, anim, _, child) {
            return FadeTransition(opacity: anim, child: child);
          },
        ),
      );
    }
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
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Fondo con blur para mantener estilo de La Percha Mor
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withAlpha(180),
                  Theme.of(context).colorScheme.surface.withAlpha(180),
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
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, _) {
                final scale = 1 + (_anim.value * 0.1);
                return Transform.scale(
                  scale: scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/img/kufta_icon_reverted.png",
                        height: r.hp(35),
                       color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : null,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                      SizedBox(height: r.dp(2)),
                      Text(
                        "Cargando las perchas.",
                        style: TextStyle(
                          fontSize: r.dp(2.2),
                          fontWeight: FontWeight.w600,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(230),
                        ),
                      ),
                      SizedBox(height: r.dp(1)),
                      Text(
                        "Aguante un poquito mor...",
                        style: TextStyle(
                          fontSize: r.dp(1.5),
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
