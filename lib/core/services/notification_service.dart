import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final fln.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      fln.FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuração para iOS (básica)
    const fln.DarwinInitializationSettings initializationSettingsDarwin =
        fln.DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const fln.InitializationSettings initializationSettings =
        fln.InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (fln.NotificationResponse response) async {
        // Lógica ao clicar na notificação
      },
    );
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            fln.IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> showInstantNotification(String title, String body) async {
    const fln.AndroidNotificationDetails androidNotificationDetails =
        fln.AndroidNotificationDetails(
      'nexo_channel_id',
      'Nexo Notifications',
      channelDescription: 'Canal principal de notificações do Nexo',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
    );

    const fln.NotificationDetails notificationDetails =
        fln.NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // NOTA: O Chrome/Web NÃO suporta zonedSchedule com esses parâmetros.
    // Para evitar erros de compilação na Web, vamos usar uma notificação simples por enquanto.
    // Se for rodar no Android/Windows, descomente o código abaixo e comente o show().
    
    /* 
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'nexo_reminders_id',
          'Lembretes de Tarefas',
          channelDescription: 'Lembretes agendados para tarefas domésticas',
          importance: fln.Importance.max,
          priority: fln.Priority.high,
        ),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
    );
    */

    // Fallback para Web/Teste: Mostra instantâneo (só para validar o fluxo)
    showInstantNotification("Agendado: $title", "Lembrete definido para $scheduledDate");
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
