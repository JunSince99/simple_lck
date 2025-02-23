import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Android 알림 채널 설정
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // 채널 ID
  'High Importance Notifications', // 채널 이름
  description: 'This channel is used for important notifications.', // 설명
  importance: Importance.high, // 중요도 설정
);

// 로컬 알림 플러그인 인스턴스 생성
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 백그라운드에서 수신된 메시지 처리 핸들러
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase는 main.dart에서 초기화됨, 여기서는 추가 작업 없음
}

class FcmService {
  // FCM 초기화 및 설정
  static Future<void> initialize() async {
    // 백그라운드 메시지 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Android 알림 채널 생성 (iOS에서는 필요 없음)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 포그라운드 알림 표시 옵션 설정 (iOS 전용)
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // 알림 표시
      badge: true, // 배지 표시
      sound: true, // 소리 재생
    );

    // 'lck-live' 토픽 구독
    await FirebaseMessaging.instance.subscribeToTopic('lck-live');

    // 포그라운드 메시지 수신 리스너 설정
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        // 로컬 알림 표시
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
      }
    });

    // 백그라운드에서 알림 클릭 시 앱 열기 (기본 동작만 수행)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // 추가 로직 없음: 앱만 열림
    });
  }

  // 토픽 구독 해제 (옵션)
  static Future<void> unsubscribeFromLckLive() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('lck-live');
  }
}