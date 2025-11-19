import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

// Handler Background (Tetap sama)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🔔 BACKGROUND MSG: ${message.messageId}");
}

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Definisi Channel Android agar Prioritas Tinggi (Heads-up)
  final AndroidNotificationChannel _androidChannel =
      const AndroidNotificationChannel(
        'todo_channel_id', // ID harus konsisten
        'Todo Notifications', // Nama Channel
        description: 'Notifikasi untuk Todo App',
        importance: Importance.max, // PENTING: Agar muncul pop-up banner
      );

  Future<void> init() async {
    try {
      // 1. Request Permission (FCM)
      await _requestPermission();

      // 2. Setup Local Notifications
      // Inisialisasi icon (pastikan icon ada di android/app/src/main/res/drawable)
      // Menggunakan @mipmap/ic_launcher adalah opsi paling aman default Flutter
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

      // --- BAGIAN PENTING UNTUK ANDROID ---
      // Membuat Channel secara eksplisit di sistem Android
      // Ini memastikan setting 'Importance.max' diterapkan
      final platform = _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await platform?.createNotificationChannel(_androidChannel);
      // -------------------------------------

      // 3. Konfigurasi FCM agar 'Alert' diperbolehkan saat Foreground (Khusus iOS/Android 12+)
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 4. Listeners
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Listener Foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('🔔 FOREGROUND MSG: ${message.notification?.title}');

        // PENTING: Ambil notifikasi dari pesan FCM
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        // Jika notifikasi ada, dan aplikasi sedang di Android -> Tampilkan Local Notification
        if (notification != null && android != null) {
          showLocalNotification(
            title: notification.title ?? 'Notifikasi',
            body: notification.body ?? 'Pesan baru',
          );
        }
      });

      // 5. Ambil Token
      String? token = await _messaging.getToken();
      print("🔔 FCM TOKEN: $token");
    } catch (e) {
      print("🔔 ERROR NOTIFICATION INIT: $e");
    }
  }

  Future<void> _requestPermission() async {
    // Request Permission untuk Android 13+
    if (Platform.isAndroid) {
      final platform = _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await platform?.requestNotificationsPermission();
    }

    // Request Permission untuk FCM
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('🔔 Status Izin Notifikasi: ${settings.authorizationStatus}');
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    // Gunakan detail dari Channel yang sudah kita buat di atas
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          showWhen: true,
          icon: '@mipmap/ic_launcher', // Pastikan icon sesuai
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
}
