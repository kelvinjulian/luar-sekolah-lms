import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

// --- TIMEZONE ---
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🔔 BACKGROUND MSG: ${message.messageId}");
}

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final AndroidNotificationChannel _androidChannel =
      const AndroidNotificationChannel(
        'todo_channel_id',
        'Todo Notifications',
        description: 'Notifikasi untuk Todo App',
        importance: Importance.max,
      );

  Future<void> init() async {
    try {
      tz.initializeTimeZones();
      try {
        var jakarta = tz.getLocation('Asia/Jakarta');
        tz.setLocalLocation(jakarta);
      } catch (e) {
        print("Gagal set lokasi timezone: $e");
      }

      await _requestPermission();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      final InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
          );

      await _localNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print("🔔 Notifikasi diklik: ${response.payload}");
        },
      );

      final platform = _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await platform?.createNotificationChannel(_androidChannel);

      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          showLocalNotification(
            title: notification.title ?? 'Notifikasi',
            body: notification.body ?? 'Pesan baru',
          );
        }
      });

      // GET TOKEN SAAT INIT
      await getDeviceToken();

      // LISTENER TOKEN BARU
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print("♻️ TOKEN BARU: $newToken");
        // jika mau update token ke backend, lakukan di sini
      });
    } catch (e) {
      print("🔔 ERROR NOTIFICATION INIT: $e");
    }
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      final platform = _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await platform?.requestNotificationsPermission();
    }

    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  // FUNCTION GET TOKEN
  Future<String?> getDeviceToken() async {
    try {
      final token = await _messaging.getToken();
      print("📌 FCM TOKEN: $token");

      return token;
    } catch (e) {
      print("❌ ERROR GET TOKEN: $e");
      return null;
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final now = DateTime.now();
      final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);

      print("🕵️ [DEBUG] Waktu Sekarang (App): $now");
      print("🕵️ [DEBUG] Waktu Jadwal (Input): $scheduledDate");
      print("🕵️ [DEBUG] Waktu Konversi Timezone: $tzScheduled");

      if (scheduledDate.isBefore(now)) {
        print(
          "❌ [ERROR] Waktu jadwal sudah LEWAT! Notifikasi tidak akan muncul.",
        );
        return;
      }

      await _localNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      final List<PendingNotificationRequest> pendingNotifications =
          await _localNotificationsPlugin.pendingNotificationRequests();

      print(
        "🕵️ [DEBUG] Jumlah Antrian Pending: ${pendingNotifications.length}",
      );

      final isQueued = pendingNotifications.any((n) => n.id == id);
      if (isQueued) {
        print(
          "🎉 [SUKSES] Notifikasi ID $id DITEMUKAN dalam daftar antrian Android!",
        );
      } else {
        print("💀 [GAGAL] Notifikasi ID $id TIDAK ADA di antrian.");
      }
    } catch (e) {
      print("❌ [ERROR CRITICAL] Gagal menjadwalkan: $e");
    }
  }
}
