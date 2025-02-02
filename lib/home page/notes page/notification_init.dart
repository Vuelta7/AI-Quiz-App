import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String customChannelId = 'custom_sound_channel_id';

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('logo');

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    try {
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      const customSoundChannel = AndroidNotificationChannel(
        customChannelId,
        'Custom Sound Notifications',
        description: 'Channel for custom sound notifications',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('notification'),
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(customSoundChannel);

      print("Notifications initialized successfully!");
    } catch (e) {
      print("Notification initialization error: $e");
    }
  }

  static Future<void> showInstantNotification(String title, String body) async {
    try {
      const platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
          customChannelId,
          'Custom Sound Notifications',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('notification'),
        ),
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: 'instant_notification',
      );

      print("Notification sent!");
    } catch (e) {
      print("Failed to show notification: $e");
    }
  }
}
