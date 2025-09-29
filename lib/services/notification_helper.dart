import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Instancia única del plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Inicializa el plugin, solicita permisos (Android 13+ / iOS) y crea el canal.
Future<void> initLocalNotifications() async {
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings settings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  await flutterLocalNotificationsPlugin.initialize(settings);

  // Android 13+ (POST_NOTIFICATIONS) en tiempo de ejecución
  final androidImpl = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await androidImpl?.requestNotificationsPermission();

  // Crear canal en Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'reservas_channel',
    'Reservas',
    description: 'Recordatorios de reservas próximas',
    importance: Importance.high,
  );
  await androidImpl?.createNotificationChannel(channel);
}

/// Muestra una notificación (usa el id de la reserva como id de notificación)
Future<void> showReservationNotification({
  required int id,
  required String area,
  required String fecha,
  required String hora,
}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'reservas_channel',
    'Reservas',
    channelDescription: 'Recordatorios de reservas próximas',
    importance: Importance.high,
    priority: Priority.high,
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

  const NotificationDetails details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    id,
    'Reserva próxima',
    'Tienes una reserva en $area el $fecha a las $hora',
    details,
  );
}
