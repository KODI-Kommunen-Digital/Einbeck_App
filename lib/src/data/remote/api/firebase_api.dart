import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:heidi/src/data/remote/api/api.dart';
import 'package:heidi/src/data/repository/list_repository.dart';
import 'package:heidi/src/utils/configs/preferences.dart';
import 'package:heidi/src/utils/configs/routes.dart';
import 'package:heidi/src/utils/logging/loggy_exp.dart';

Future<void> handleBackgroundMessage(RemoteMessage? message) async {}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> navigatorKey;
  final Preferences prefs;

  FirebaseApi(this.navigatorKey, this.prefs);

  Future<void> handleMessageOnUserInteraction(RemoteMessage? message) async {
    if (message != null) {
      if (message.data["forumId"] != null) {
        final int cityId = int.parse(message.data["cityId"]);

        navigatorKey.currentState?.pushNamed(
          Routes.listGroups,
          arguments: {'id': cityId, 'title': 'Gruppen'},
        );
      } else {
        final item = await ListRepository.loadProduct(
            int.parse(message.data["cityId"]), int.parse(message.data["id"]));
        if (item != null) {
          navigatorKey.currentState
              ?.pushNamed(Routes.productDetail, arguments: item);
        }
      }
    }
  }

  Future<void> handleForegroundNotification(RemoteMessage message) async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );
  }

  Future<void> initNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      prefs.setKeyValue(Preferences.pushNotificationsPermission, "authorized");
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      prefs.setKeyValue(Preferences.pushNotificationsPermission, "denied");
    }

    final pushNotificationsPermission =
        await prefs.getKeyValue(Preferences.pushNotificationsPermission, "0");
    final receiveNotification =
        await prefs.getKeyValue(Preferences.receiveNotification, "true");

    if (pushNotificationsPermission == "authorized" &&
        receiveNotification == "true") {
      await _subscribeToAllForumChats();
      await _firebaseMessaging.subscribeToTopic("warnings");
    } else {
      await _unsubscribeFromAllForumChats();
      await _firebaseMessaging.unsubscribeFromTopic("warnings");
    }

    int uId = await getLoggedUserId();
    if (uId > 0) {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) uploadToken(uId, token);
    }

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: false, badge: false, sound: false);

    _firebaseMessaging.getInitialMessage().then(handleMessageOnUserInteraction);
    FirebaseMessaging.onMessage.listen(handleForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessageOnUserInteraction);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  Future<void> refreshNotifications() async {
    final pushNotificationsPermission =
        await prefs.getKeyValue(Preferences.pushNotificationsPermission, "0");
    final receiveNotification =
        await prefs.getKeyValue(Preferences.receiveNotification, "true");

    if (pushNotificationsPermission == "authorized" &&
        receiveNotification == "true") {
      await _subscribeToAllForumChats();
      await _firebaseMessaging.subscribeToTopic("warnings");
    } else {
      await _unsubscribeFromAllForumChats();
      await _firebaseMessaging.unsubscribeFromTopic("warnings");
    }
  }

  Future<void> _unsubscribeFromAllForumChats() async {
    final List<String> forumChatTopics = await _getForumChatTopics();
    for (String topic in forumChatTopics) {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      logInfo("Unsubscribed from forum chat topic: $topic");
    }
  }

  Future<void> _subscribeToAllForumChats() async {
    final List<String> forumChatTopics = await _getForumChatTopics();
    for (String topic in forumChatTopics) {
      await _firebaseMessaging.subscribeToTopic(topic);
      logInfo("Subscribed to forum chat topic: $topic");
    }
  }

  Future<List<String>> _getForumChatTopics() async {
    final prefs = await Preferences.openBox();
    final List<String>? forumChatTopics =
        prefs.getKeyValue(Preferences.forumChatTopics, <String>[]);
    return forumChatTopics ?? <String>[];
  }

  Future<void> uploadToken(int userId, String token) async {
    final response = await Api.uploadToken(userId, {"firebaseToken": token});
    logInfo("FCM token upload success: ${response.success}");
  }

  Future<int> getLoggedUserId() async {
    final prefs = await Preferences.openBox();
    final userId = prefs.getKeyValue(Preferences.userId, 0);
    return userId;
  }
}
