import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle notification tap - could navigate to specific project
  }

  Future<void> scheduleRFIReminder(String projectId) async {
    try {
      // For now, just show an immediate notification
      // In a production app, you would use a proper scheduling mechanism
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'rfi_reminders',
        'RFI Reminders',
        channelDescription: 'Notifications for pending RFI items',
        importance: Importance.high,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _localNotifications.show(
        projectId.hashCode,
        'RFI Reminder',
        'You have pending RFI items that need attention',
        notificationDetails,
        payload: projectId,
      );

      print('RFI reminder sent for project: $projectId');
    } catch (e) {
      print('Error sending RFI reminder: $e');
    }
  }

  Future<void> cancelRFIReminder(String projectId) async {
    try {
      await _localNotifications.cancel(projectId.hashCode);
      print('RFI reminder cancelled for project: $projectId');
    } catch (e) {
      print('Error cancelling RFI reminder: $e');
    }
  }
}
