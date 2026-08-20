import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );

    _isInitialized = true;
  }

  Future<void> scheduleClassReminder(String className, DateTime startTime) async {
    // Remind 30 minutes before
    final reminderTime = startTime.subtract(const Duration(minutes: 30));
    if (reminderTime.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      className.hashCode,
      'Upcoming Class: $className',
      'Your class starts in 30 minutes. Get ready!',
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'cosarc_gym_channel',
          'Gym Reminders',
          channelDescription: 'Notifications for classes and sessions',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleTrainerSessionReminder(String trainerName, DateTime startTime) async {
    // Remind 1 hour before
    final reminderTime = startTime.subtract(const Duration(hours: 1));
    if (reminderTime.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      trainerName.hashCode,
      'Trainer Session with $trainerName',
      'Your personal training session starts in 1 hour.',
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'cosarc_gym_channel',
          'Gym Reminders',
          channelDescription: 'Notifications for classes and sessions',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showMembershipExpiryAlert(int daysLeft) async {
    if (daysLeft > 7) return; // Only alert if <= 7 days

    await flutterLocalNotificationsPlugin.show(
      'membership_expiry'.hashCode,
      'Membership Expiring Soon',
      'Your Cosarc Premium membership expires in $daysLeft days.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'cosarc_alerts_channel',
          'Account Alerts',
          channelDescription: 'Notifications for account status',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
  
  Future<void> cancelClassReminder(String className) async {
    await flutterLocalNotificationsPlugin.cancel(className.hashCode);
  }
  
  Future<void> cancelTrainerReminder(String trainerName) async {
    await flutterLocalNotificationsPlugin.cancel(trainerName.hashCode);
  }
}
