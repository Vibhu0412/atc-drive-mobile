import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification service
  static Future<void> init() async {
    if (await Permission.notification.request().isDenied) {
      return;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );
  }

  /// Show download completion notification
  static Future<void> showDownloadNotification(
      String fileName, String filePath) async {
    int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'download_channel',
      'File Downloads',
      channelDescription: 'Shows notifications when files are downloaded',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      notificationId,
      "Download Complete",
      "$fileName has been downloaded successfully.",
      platformDetails,
      payload: filePath,
    );
  }

  /// Handle notification tap to open the file
  static void _handleNotificationTap(String? filePath) {
    if (filePath != null) {
      OpenFilex.open(filePath);
    }
  }
}
