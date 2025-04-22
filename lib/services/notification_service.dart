import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/event.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const String _notificationsKey = 'event_notifications_enabled';

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    // Android initialization
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // For iOS we already request permissions in the initialization settings
  }

  Future<void> scheduleNotificationsForEvents(
      List<Event> upcomingEvents) async {
    for (var event in upcomingEvents) {
      // Check if notifications are enabled for this event
      final isEnabled = await isEventNotificationEnabled(event.id);
      if (!isEnabled) continue;

      await _notificationsPlugin.zonedSchedule(
        event.id.hashCode, // Use event ID as unique notification ID
        event.title,
        event.description,
        tz.TZDateTime.from(
            event.startTime.subtract(const Duration(minutes: 30)),
            tz.local), // 30 minutes before event
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'event_reminders',
            'Event Reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<bool> isEventNotificationEnabled(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_notificationsKey}_$eventId') ?? false;
  }

  Future<void> toggleEventNotification(Event event, bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_notificationsKey}_${event.id}', isEnabled);

    // If turned off, cancel any existing notifications
    if (!isEnabled) {
      await _notificationsPlugin.cancel(event.id.hashCode);
    } else {
      // If turned on, schedule notification for this event
      if (event.isUpcoming) {
        await _notificationsPlugin.zonedSchedule(
          event.id.hashCode,
          event.title,
          event.description,
          tz.TZDateTime.from(
              event.startTime.subtract(const Duration(minutes: 30)), tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'event_reminders',
              'Event Reminders',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
