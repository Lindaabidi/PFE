import 'dart:async';
import 'dart:convert';
import 'package:appkpi/screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  List<dynamic> data = [];

  Future<List<dynamic>> fetchData() async {
    final response =
    await http.get(Uri.parse('http://192.168.1.12/crud/fetch.php'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Impossible de charger les données');
    }
  }

  Future<void> showNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformDetails, payload: 'payload');
  }

  void checkData() {
    data.forEach((row) {
      if (row['TRS'] == '20' && row['TRG'] == '20' && row['TRE'] == '20') {
        showNotification('alerte', 'KPI egal a 20');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(
        message.notification?.title,
        message.notification?.body,
      );
    });

    // Call the fetchData() function periodically every 5 seconds
    Timer.periodic(Duration(seconds: 5), (timer) {
      fetchData().then((newData) {
        if (newData != data) {
          data = newData;
          checkData();
        }
      }).catchError((error) {
        print(error);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification App',
      home: LoginPage(),
    );
  }

  void startSendingNotifications(String deviceToken, String title, String body) {
    Timer.periodic(Duration(seconds: 5), (timer) {
      sendNotificationToServer(deviceToken, title, body);
    });
  }

  Future<void> sendNotificationToServer(
      String deviceToken, String title, String body) async {
    var url = 'http://192.168.1.12/crud/refresh.php'; // Replace with the actual URL of your PHP script

    var response = await http.post(
      Uri.parse(url),
      body: {
        'token': deviceToken,
        'title': title,
        'body': body,
      },
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully.');

      // Display the notification on the device
      showNotification(title, body);
    } else {
      print('Failed to send notification.');
    }
  }
}
