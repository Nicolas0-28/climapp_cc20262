// lib/src/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  // Instância singleton para acesso global
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initialize() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Permissão concedida pelo usuário.');

      //  o FCM Token na inicialização
      String? token = await _fcm.getToken();
      debugPrint('====================================');
      debugPrint('FCM TOKEN DO DISPOSITIVO: $token');
      debugPrint('====================================');

      _fcm.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token atualizado: $newToken');
      });

      //Configurar os listeners de eventos
      _setupMessageHandlers();
    } else {
      debugPrint('Permissão negada ou não configurada.');
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        'Mensagem recebida em Foreground: ${message.notification?.title}',
      );

      final notification = message.notification;
      if (notification != null) {
        final context = navigatorKey.currentContext;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${notification.title}\n${notification.body}'),
              backgroundColor: Colors.blueAccent,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Toque na notificação (Background): ${message.data}');
      _handleDeepLink(message);
    });

    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App inicializado a partir de notificação: ${message.data}');
        _handleDeepLink(message);
      }
    });
  }

  void _handleDeepLink(RemoteMessage message) {
    final city = message.data['city'];
    if (city != null) {
      navigatorKey.currentState?.pushNamed('/weather', arguments: city);
    }
  }
}
