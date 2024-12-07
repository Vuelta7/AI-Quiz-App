import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String customChannelId = 'custom_sound_channel_id';

  // Initialization method
  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('logo_icon');

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    // Initialize plugin
    try {
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      );

      // Create notification channel
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

  // Method to show notifications
  static Future<void> showInstantNotification(
    String title,
    String body,
  ) async {
    const platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        customChannelId,
        'Custom Sound Notifications',
        sound: RawResourceAndroidNotificationSound('notification'),
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    try {
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
