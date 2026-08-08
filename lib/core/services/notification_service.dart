// import 'dart:developer';
// import 'package:firebase_messaging/firebase_messaging.dart';

// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   log("Handling a background message: ${message.messageId}");
// }

// class NotificationService {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   Future<void> init() async {
//     // Request permission
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//       announcement: false,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       log('User granted permission');
//     } else if (settings.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//       log('User granted provisional permission');
//     } else {
//       log('User declined or has not accepted permission');
//     }

//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       log('Got a message whilst in the foreground!');
//       log('Message data: ${message.data}');

//       if (message.notification != null) {
//         log(
//           'Message also contained a notification: ${message.notification?.title}',
//         );
//       }
//     });

//     // Handle when app is opened from a notification
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       log('A new onMessageOpenedApp event was published!');
//     });
//   }

//   Future<String?> getToken() async {
//     try {
//       String? token = await _firebaseMessaging.getToken();
//       log("FCM Token: $token");
//       return token;
//     } catch (e) {
//       log("Error getting FCM token: $e");
//       return null;
//     }
//   }

//   Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;

//   Future<bool> isNotificationEnabled() async {
//     final settings = await _firebaseMessaging.getNotificationSettings();
//     return settings.authorizationStatus == AuthorizationStatus.authorized ||
//         settings.authorizationStatus == AuthorizationStatus.provisional;
//   }

//   Future<bool> requestPermission() async {
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//       announcement: false,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//     );
//     return settings.authorizationStatus == AuthorizationStatus.authorized ||
//         settings.authorizationStatus == AuthorizationStatus.provisional;
//   }

//   Future<void> deleteToken() async {
//     await _firebaseMessaging.deleteToken();
//   }
// }
