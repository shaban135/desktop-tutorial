
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/bindings/login_binding.dart';
import 'package:mepco_esafety_app/controllers/notifications_controller.dart';
import 'package:mepco_esafety_app/routes/app_pages.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/utils/snackbar_helper.dart';
import 'constants/app_colors.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Local Notifications
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// ---------------------------------------------------------------------------
/// GLOBALS
/// ---------------------------------------------------------------------------

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel notificationChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'Used for important notifications.',
  importance: Importance.max,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('mepco_notification_sound'),
);

/// ---------------------------------------------------------------------------
/// HANDLER FUNCTIONS
/// ---------------------------------------------------------------------------

void handleNotificationClick(Map<String, dynamic> data) {
  final type = data['type'];
  final c = Get.find<NotificationsController>();
  c.fetchNotifications();

  if (type == 'ptw') {
    final ptwId = int.tryParse(data['ptw_id'] ?? '');
    final role = data['role'] ?? '';
    if (ptwId != null) {
      Get.toNamed(
        AppRoutes.ptwReviewSdo,
        arguments: {'ptw_id': ptwId, 'role': role},
      );
    }
  } else if (type == 'notification') {
    Get.toNamed(AppRoutes.notifications);
  }
}

// Future<void> initializeLocalNotifications() async {
//   const AndroidInitializationSettings androidSettings =
//   AndroidInitializationSettings('@mipmap/ic_launcher');

//   const InitializationSettings settings =
//   InitializationSettings(android: androidSettings);

//   await flutterLocalNotificationsPlugin.initialize(
//     settings,
//     onDidReceiveNotificationResponse: (NotificationResponse response) {
//       final payload = response.payload;
//       if (payload != null) {
//         handleNotificationClick(jsonDecode(payload));
//       }
//     },
//   );

//   final androidPlugin = flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//       AndroidFlutterLocalNotificationsPlugin>();

//   await androidPlugin?.createNotificationChannel(notificationChannel);
// }
Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  // ← YE ADD KARO
  const DarwinInitializationSettings iosSettings =
  DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final payload = response.payload;
      if (payload != null) {
        handleNotificationClick(jsonDecode(payload));
      }
    },
  );

  final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  await androidPlugin?.createNotificationChannel(notificationChannel);
}

Future<void> showLocalNotification(RemoteMessage message) async {
  debugPrint('🔔 showLocalNotification called: ${message.notification?.title}');
  final notification = message.notification;
  if (notification == null) return;

  final androidDetails = AndroidNotificationDetails(
    notificationChannel.id,
    notificationChannel.name,
    channelDescription: notificationChannel.description,
    icon: '@mipmap/ic_launcher',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    sound: const RawResourceAndroidNotificationSound('mepco_notification_sound'),
  );

  const darwinDetails = DarwinNotificationDetails(
    presentSound: true,
    sound: 'mepco_notification_sound.wav',
  );

  try {
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title,
      notification.body,
      NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      ),
      payload: jsonEncode(message.data),
    );
    debugPrint('✅ Notification shown successfully');
  } catch (e) {
    debugPrint('❌ Error showing notification: $e');
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await showLocalNotification(message);

  if (!Get.isRegistered<NotificationsController>()) {
    Get.put(NotificationsController(), permanent: true);
  }
  Get.find<NotificationsController>().fetchNotifications();
}

/// ---------------------------------------------------------------------------
/// MAIN
/// ---------------------------------------------------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Flutter Error Catcher
  FlutterError.onError = (details) {
    // Suppress NetworkImageLoadException, 404 errors, and Tile loading issues
    final errorStr = details.exception.toString();
    if (errorStr.contains('NetworkImageLoadException') ||
        errorStr.contains('statusCode: 404') ||
        errorStr.contains('Image resource service') ||
        errorStr.contains('ClientException') ||
        errorStr.contains('tile.openstreetmap.org')) {
      debugPrint('Ignored image/tile load error in global handler: $errorStr');
      return;
    }

    FlutterError.presentError(details);
    SnackbarHelper.showError(
      title: 'App Error',
      message: details.exceptionAsString(),
    );
  };

  // Global Platform Error Catcher (Async errors)
  PlatformDispatcher.instance.onError = (error, stack) {
    final errorStr = error.toString();
    if (errorStr.contains('NetworkImageLoadException') ||
        errorStr.contains('statusCode: 404') ||
        errorStr.contains('ClientException') ||
        errorStr.contains('tile.openstreetmap.org') ||
        errorStr.contains('apns-token-not-set')) { // ← YE ADD KARO
      debugPrint('Ignored error: $errorStr');
      return true;
    }

    SnackbarHelper.showError(
      title: 'Unexpected Error',
      message: error.toString(),
    );
    return true;
  };

  // SYSTEM NAV BAR AUTO-HIDE (IMMERSIVE MODE)
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);
  try {
    String? token = await messaging.getToken();
    debugPrint('FCM Token: $token');
  } catch (e) {
    debugPrint('FCM Token error (ignored on iOS Ad Hoc): $e');
  }
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  LoginBinding().dependencies();
  await initializeLocalNotifications();

  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null && message.data.isNotEmpty) {
      handleNotificationClick(message.data);
    }
  });

  if (!Get.isRegistered<NotificationsController>()) {
    Get.put(NotificationsController(), permanent: true);
  }

  runApp(const MyApp());
}

/// ---------------------------------------------------------------------------
/// APP ROOT
/// ---------------------------------------------------------------------------

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showLocalNotification(message);
      Get.find<NotificationsController>().fetchNotifications();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        handleNotificationClick(message.data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: AppRoutes.initial,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          selectionHandleColor: AppColors.primaryBlue,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryBlue,
            fontFamilyFallback: ['Jameel Noori Nastaleeq'],
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: AppColors.primaryGrey,
            fontFamilyFallback: ['Jameel Noori Nastaleeq'],
          ),
          bodySmall: TextStyle(
            fontSize: 14,
            fontFamilyFallback: ['Jameel Noori Nastaleeq'],
          ),
        ),
      ),
    );
  }
}
