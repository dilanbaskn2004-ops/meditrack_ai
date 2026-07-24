import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin notifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("Bildirim tıklandı: ${response.payload}");
      },
    );

    tz.initializeTimeZones();

    final currentTimeZone = await FlutterTimezone.getLocalTimezone();

    debugPrint("TimeZone: $currentTimeZone");

    tz.setLocalLocation(
      tz.getLocation(currentTimeZone),
    );

    final androidPlugin =
    notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    debugPrint("NotificationService hazır.");
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'medicine_channel',
        'Medicine Reminder',
        channelDescription: 'İlaç hatırlatma bildirimleri',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await notifications.show(
      0,
      title,
      body,
      details,
    );
  }

  Future<void> scheduleDailyMedicineNotification({
    required int id,
    required String medicineName,
    required int hour,
    required int minute,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);

      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      debugPrint("Şu an: $now");
      debugPrint("Planlanan: $scheduledDate");

      await notifications.zonedSchedule(
        id,
        "İlaç Hatırlatma",
        "$medicineName ilacını alma zamanı geldi 💊",
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medicine_channel',
            'Medicine Reminder',
            channelDescription: 'İlaç hatırlatma bildirimleri',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      final pending = await notifications.pendingNotificationRequests();

      debugPrint("Bekleyen bildirim sayısı: ${pending.length}");

      for (final item in pending) {
        debugPrint("ID: ${item.id} - ${item.title}");
      }
    } catch (e, s) {
      debugPrint("HATA: $e");
      debugPrint(s.toString());
    }
  }

  Future<void> cancelNotification(int id) async {
    await notifications.cancel(id);
    debugPrint("Bildirim iptal edildi. ID: $id");
  }

  Future<void> cancelAllNotifications() async {
    await notifications.cancelAll();
    debugPrint("Tüm bildirimler iptal edildi.");
  }
}