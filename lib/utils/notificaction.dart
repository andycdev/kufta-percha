import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:kufta_percha/main.dart';
import 'package:kufta_percha/models/pinta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> mostrarNotificacionSoloUnaVez() async {
  final settings = Hive.box('settingsBox');

  // Ya se mostró antes → no hacer nada
  if (settings.get('welcome_shown', defaultValue: false) == true) {
    return;
  }

  // Mostrarla la primera vez
  await showWelcomeNotification();

  // Marcarla como mostrada
  await settings.put('welcome_shown', true);
}

Future<void> showWelcomeNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'inicio_channel',
    'Notificaciones de inicio',
    channelDescription: 'Notificación cuando la app inicia',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
  );

  await noti.show(
    1, // ID
    'La Percha Mor',
    'Qué más, mor. Tu closet digital ya despertó 😎',
    platformDetails,
  );
}

Future<bool> requestNotificationPermission() async {
  // Verifica y solicita permiso
  final status = await Permission.notification.status;

  if (status.isDenied || status.isRestricted) {
    final result = await Permission.notification.request();
    return result.isGranted;
  }

  return status.isGranted;
}

Future<void> programarNotificacionPinta(Pinta pinta, DateTime fecha) async {
  // Convertir la fecha de la pinta a TZDateTime local
  final scheduled = tz.TZDateTime(
    tz.local,
    fecha.year,
    fecha.month,
    fecha.day - 1,
    18,
    0,
    0,
  );

  if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
    return;
  }

  final androidDetails = AndroidNotificationDetails(
    'pintas_channel',
    'Recordatorios de Pintas',
    channelDescription: 'Notificación para recordar la pinta del día siguiente',
    importance: Importance.max,
    priority: Priority.high,
    largeIcon: FilePathAndroidBitmap(pinta.arriba.path),
  );

  final NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
  );

  final id = pinta.nombre.hashCode ^ fecha.millisecondsSinceEpoch.hashCode;

  // await noti.show(
  await noti.zonedSchedule(
    id,
    'La Percha Mor',
    'Recuerda preparar tu pinta "${pinta.nombre}" para mañana mor',
    scheduled,
    platformDetails,
    androidScheduleMode: AndroidScheduleMode.exact,
  );
}

Future<void> programarNotificacionInactividad() async {
  final box = await Hive.openBox('app_data');
  final ultima = box.get('ultima_actividad');

  if (ultima == null) return; // nunca abrió la app

  final ultimaActividad = DateTime.fromMillisecondsSinceEpoch(ultima);
  final ahora = DateTime.now();
  final diferencia = ahora.difference(ultimaActividad).inDays;

  if (diferencia >= 3) {
    const androidDetails = AndroidNotificationDetails(
      'inactividad_channel',
      'Recordatorios de Inactividad',
      channelDescription: 'Notificación si no hay actividad en la app',
      importance: Importance.max,
      priority: Priority.high,
    );

    final platformDetails = NotificationDetails(android: androidDetails);

    await noti.show(
      999999, // id fijo para la notificación de inactividad
      '¡Te extrañamos!',
      'Hace más de 3 días que no usas La Percha Mor, vuelve a crear tu pinta',
      platformDetails,
    );
  }
}
