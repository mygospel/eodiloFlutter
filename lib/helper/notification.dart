import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
//import 'package:eodilo/widget/bottom_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info/device_info.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  // if (message.notification != null) {
  //   print('Message also contained a notification: ${message.notification}');
  // }
}

const AndroidNotificationChannel channel2 = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', //description
  importance: Importance.high,
);
