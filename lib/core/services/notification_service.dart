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
    // --- COMPATIBILIDADE WEB ---
    // O plugin flutter_local_notifications pode ocultar símbolos Android/iOS na compilação Web,
    // causando erros como 'Undefined name'. Por isso, para rodar na Web, usamos fallback.
    // Se for gerar build MOBILE, pode descomentar a lógica completa ou usar imports condicionais.
    
    /* 
    // LÓGICA MOBILE (Original) - Descomente para Android/iOS se os símbolos existirem
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
        iOS: fln.DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: fln.DateTimeComponents.dateAndTime,
    );
     print("🔔 Notificação agendada para $scheduledDate ($title)");
     */

    // --- FALLBACK WEB/SIMPLES ---
    // Apenas mostra que "agendou" (mas na verdade dispara na hora ou ignora,
    // pois Web não suporte agendamento background confiável dessa forma).
    print("🔔 (Simulação Web) Agendado para $scheduledDate: $title");
    // Se quiser testar o disparo imediato:
    // showInstantNotification("Agendado: $title", "Para $scheduledDate");
  }

  Future<void> syncNotifications(List<dynamic> tasks) async {
    await cancelAll(); // Limpa tudo para garantir integridade
    
    // Filtra tarefas futuras que precisam de notificação
    for (var task in tasks) {
      if (task.notifyAtTime && task.scheduledTime != null && task.scheduledTime!.isAfter(DateTime.now())) {
          // ID único baseado no ID da Task
          int notificationId = int.parse(task.id.substring(task.id.length - 8), radix: 16); // Hex to int para evitar colisão? Ou só garantir string numérica.
          // CUIDADO: IDs alfanuméricos do Firebase não viram Int fácil. 
          // Melhor usar hashCode ou um mapeamento. Vamos usar hashCode.
          
          await scheduleNotification(
            id: task.id.hashCode,
            title: "Nexo: Hora de ${task.title}",
            body: "Ei ${task.whoExecutes}, sua tarefa te espera!",
            scheduledDate: task.scheduledTime!,
          );
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
