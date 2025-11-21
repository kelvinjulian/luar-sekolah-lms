import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

// --- TAMBAHAN IMPORT TIMEZONE ---
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
      // 1. INIT TIMEZONE DATA
      tz.initializeTimeZones();

      // --- WAJIB ADA: PAKSA SET LOKASI ---
      try {
        // Memaksa sistem notifikasi menggunakan waktu Jakarta
        // meskipun emulator settingannya UTC/Amerika.
        var jakarta = tz.getLocation('Asia/Jakarta');
        tz.setLocalLocation(jakarta);
      } catch (e) {
        print("Gagal set lokasi timezone: $e");
      }
      // -----------------------------------

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

  // --- FUNGSI BARU: JADWALKAN NOTIFIKASI ---
  // --- FUNGSI DEBUG SCHEDULE ---
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      // 1. CEK WAKTU SEKARANG VS JADWAL
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

      // 2. LAKUKAN PENJADWALAN
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
            importance: Importance.max, // Pastikan Max
            priority: Priority.high, // Pastikan High
            icon: '@mipmap/ic_launcher',
            // Tambahkan ini biar suara default keluar
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      print("✅ [DEBUG] Perintah zonedSchedule berhasil dikirim ke plugin.");

      // 3. CEK APAKAH BENAR-BENAR MASUK ANTRIAN?
      final List<PendingNotificationRequest> pendingNotifications =
          await _localNotificationsPlugin.pendingNotificationRequests();

      print(
        "🕵️ [DEBUG] Jumlah Antrian Pending: ${pendingNotifications.length}",
      );

      // Cari notifikasi kita di antrian
      final isQueued = pendingNotifications.any((n) => n.id == id);
      if (isQueued) {
        print(
          "🎉 [SUKSES] Notifikasi ID $id DITEMUKAN dalam daftar antrian Android!",
        );
      } else {
        print(
          "💀 [GAGAL] Notifikasi ID $id TIDAK ADA di antrian. Kemungkinan ditolak OS atau Timezone salah.",
        );
      }
    } catch (e) {
      print("❌ [ERROR CRITICAL] Gagal menjadwalkan: $e");
    }
  }
}
