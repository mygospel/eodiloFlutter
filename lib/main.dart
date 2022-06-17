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

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:http/http.dart' as http;
//import 'package:device_info/device_info.dart';

/// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
///
///
///
late AndroidNotificationChannel channel;

Future _showNotification2(message) async {
  String title, body;

  // AOS, iOS에 따라 message 오는 구조가 다르다. (직접 파베 찍어보면 확인 가능)
  if (Platform.isAndroid) {
    title = message['title'] ?? "";
    body = message['body'] ?? "";
    print("AOS ${title} ${body}");
  }
  if (Platform.isIOS) {
    //title = message['aps']['alert']['title'];
    //body = message['aps']['alert']['body'];
    print("IOS ========");
    inspect(message);
    print("IOS ========");
  }
  /* 여기서 바로 처리도 가능
  var android = AndroidNotificationDetails('id', '제목은 이렇구요',
      channelDescription: "내용은 이래요..",
      importance: Importance.max,
      priority: Priority.max);
  var ios = IOSNotificationDetails();
  var detail = NotificationDetails(android: android, iOS: ios);

  await flutterLocalNotificationsPlugin.show(
    0,
    '단일 Notification',
    '단일 Notification 내용',
    detail,
    payload: 'Hello Flutter',
  );
  */
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('background 푸쉬받음 ==== ${message}');
  print('Message data: ${message.data}');

  // if (message.notification != null) {
  //   print('Message also contained a notification: ${message.notification}');
  // }

  //_showNotification(message);
  print('Message======================');
  inspect(message);
  print('Message======================');
  //_showNotification2(message);
}

// Future _showNotification(message) async {
//   String title, body;

//   // AOS, iOS에 따라 message 오는 구조가 다르다. (직접 파베 찍어보면 확인 가능)
//   if (Platform.isAndroid) {
//     title = message['title'] ?? "";
//     body = message['body'] ?? "";
//   }
//   if (Platform.isIOS) {
//     title = message['aps']['alert']['title'];
//     body = message['aps']['alert']['body'];
//   }

//   // AOS, iOS 별로 notification 표시 설정
//   var androidNotiDetails = AndroidNotificationDetails(
//       'dexterous.com.flutter.local_notifications', title, body,
//       importance: Importance.max, priority: Priority.max);
//   var iOSNotiDetails = IOSNotificationDetails();

//   var details =
//       NotificationDetails(android: androidNotiDetails, iOS: iOSNotiDetails);

//   await flutterLocalNotificationsPlugin.show(
//     0,
//     title,
//     body,
//     details,
//     payload: 'Hello Flutter',
//   );
//   // 0은 notification id 값을 넣으면 된다.
// }

Future<void> _firebaseMessagingForgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('포그라운드 메세지 핸들링  ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications

// channel = const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   'high_importance_channel', // id
//   'High Importance Notifications', // title
//   //'This channel is used for important notifications.', // description
//   importance: Importance.max,
// );

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

//void main() => runApp(MaterialApp(home: WebViewExample()));
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());

  /// 요렇게 바꿈.
}

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

String localToken = "";
String loginToken = "";
String pushToken = "";
String rURL = "";
String firstWebPage = "http://mobile.eodilo.com/login/autoLogin";

late double pos_latitude = 0;
late double pos_longitude = 0;

late WebViewController _myController;

class App extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

Future<void> getMyCurrentLocation() async {
  var requestStatus = await Permission.location.request();
  var status = await Permission.location.status;
  if (requestStatus.isGranted || status.isLimited) {
    // isLimited - 제한적 동의 (ios 14 < )
    // 요청 동의됨
    if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
      // 요청 동의 + gps 켜짐
      var position = await Geolocator.getCurrentPosition();
      pos_latitude = position.latitude;
      pos_longitude = position.longitude;

      print("==> 현재좌표 = ${position.toString()}");
    } else {
      // 요청 동의 + gps 꺼짐
      print("==> 권한이 없습니다.");

      pos_latitude = 0;
      pos_longitude = 0;
    }
  } else if (requestStatus.isPermanentlyDenied || status.isPermanentlyDenied) {
    // 권한 요청 거부, 해당 권한에 대한 요청에 대해 다시 묻지 않음 선택하여 설정화면에서 변경해야함. android
    print("==> 위치정보조회 권한이 없습니다.");
    openAppSettings();
    pos_latitude = 0;
    pos_longitude = 0;
  } else if (status.isRestricted) {
    // 권한 요청 거부, 해당 권한에 대한 요청을 표시하지 않도록 선택하여 설정화면에서 변경해야함. ios
    print("==> 위치정보조회 권한이 없습니다.");
    openAppSettings();
    pos_latitude = 0;
    pos_longitude = 0;
  } else if (status.isDenied) {
    // 권한 요청 거절
    print("==> 위치정보조회 권한이 거절되었습니다.");
    pos_latitude = 0;
    pos_longitude = 0;
  } else {
    print("==> 이도저도 아님");
  }

  // print("==> 권한요청상태 ${requestStatus.name}");
  // print("==> 상태 ${status.name}");

  // // 위치권한을 가지고 있는지 확인
  // var status_position = await Permission.location.status;
  // print("위치 정보 시작");
  // if (status_position.isGranted) {
  //   // 1-2. 권한이 있는 경우 위치정보를 받아와서 변수에 저장합니다.
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);

  //   pos_latitude = position.latitude;
  //   pos_longitude = position.longitude;
  // } else {
  //   // 1-3. 권한이 없는 경우
  //   print("위치 권한이 필요합니다.");
  // }
}

Future<void> onSelectNotification(BuildContext context, String payload) async {
  debugPrint("$payload");
  showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Text('Notification Payload'),
            content: Text('Payload: $payload'),
          ));
}

class _AppState extends State<App> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  //final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  //메시지 클릭 시 이벤트

  String? token;

  Future<bool> _initialization() async {
    await Firebase.initializeApp();
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    if (Platform.isIOS) {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    token = await messaging.getToken();

    messaging.getToken().then((token) async {
      pushToken = token ?? "";

      final SharedPreferences prefs = await _prefs;
      prefs.setString("PT", pushToken);
      pushToken = prefs.getString('PT') ?? "";
      print('푸쉬토큰 ==== $pushToken');
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 포그라운드 알람 초기화 (iOS Configuration)
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('forground 푸쉬받음 ==== ${message}');
      print('Message data: ${message.data}');

      // if (message.notification != null) {
      //   print('Message also contained a notification: ${message.notification}');
      // }
      print('Message======================');
      inspect(message);
      print('Message======================');
      _showNotification2(message);

      if (message.data != null) {
        if (message.data['page'] != "") {
          rURL = message.data['page'];
          print("page ${message.data['page']}");
          _myController.loadUrl(rURL);
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('메세지를 클릭했을때 여기에 옴...======================');
      inspect(message);
      if (message.data.containsKey("notificationType")) {
        if (message.data["notificationType"] == "Message") {
          // if (userRoll == "5") {
          //   conttroller.changeTabIndex(2);
          // } else {
          //   conttroller.changeTabIndex(1);
          // }
        } else {
          //conttroller.changeTabIndex(0);
        }
      }
    });
    return true;
  }

  void putPosition2(WebViewController controller, BuildContext context) async {
    await controller
        .evaluateJavascript("appPos('$pos_latitude $pos_longitude')");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          //return SomethingWentWrong();  1업애고
          return const CircularProgressIndicator();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            home: WebViewExample(),
            debugShowCheckedModeBanner: false,
          ); // 여기이동
        }

        // Otherwise, show something whilst waiting for initialization to complete
        //return Loading(); 3 없애고
        return const CircularProgressIndicator();
      },
    );
  }
}

Future getWebview<WebViewController>(
    WebViewController webViewController) async {}

Map LoginResult = {};

Future<void> Alogin() async {}

const String kNavigationExamplePage = '''
<!DOCTYPE html><html>
<head><title>Navigation Delegate Example</title></head>
<body>
<p>
The navigation delegate is set to block navigation to the youtube website.
</p>
<ul>
</ul>
</body>
</html>
''';

Future Gcontroller = "" as Future;

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  /*  위치정보관련 변수 */
  static const String _kLocationServicesDisabledMessage =
      'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage =
      'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';
  /*  위치정보관련 변수 */

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  // 디바이스에 의한 TOP설정을 위한 변수
  double marginTop = 0.0;

  @override
  void initState() {
    super.initState();

    _localNotiSetting();

    getMyCurrentLocation();

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    double width = screenSize.width;
    double height = screenSize.height;

    return Scaffold(
      // 앱바사용안함.
      // appBar: AppBar(
      //   centerTitle: false,
      //   titleSpacing: 0.0,
      //   title: Transform(
      //     // you can forcefully translate values left side using Transform
      //     transform: Matrix4.translationValues(10.0, 0.0, 0.0),
      //     child: Text(
      //       "어디로",
      //       style: TextStyle(
      //         color: Colors.white,
      //       ),
      //     ),
      //   ),

      //   // // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
      //   // backgroundColor: Color(0x70007538),
      //   // actions: <Widget>[
      //   //   NavigationControls(_controller.future),
      //   //   //SampleMenu(_controller.future),
      //   // ],
      // ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {
        // OS 확인
        try {
          if (Platform.isAndroid) {
            marginTop = 25.0;
          } else if (Platform.isIOS) {
            marginTop = 50.0;
          }
        } catch (error) {}

        return Container(

            // Even Margin On All Sides
            margin: EdgeInsets.fromLTRB(0, marginTop, 0, 0),
            child: WebView(
              initialUrl: 'http://mobile.eodilo.com',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) async {
                //setState(() {
                //  _controller = webViewController;
                //});

                _myController = webViewController; // 외부연결을 위해 추가함?

                _controller.complete(webViewController);
                //_controller.evaluateJavascript('hide_top()');

                SharedPreferences prefs = await SharedPreferences.getInstance();
                pushToken = prefs.getString('PT') ?? "";
                localToken = prefs.getString('LT') ?? "";

                await webViewController.loadUrl(firstWebPage, headers: {
                  'pushToken': pushToken,
                  'localToken': localToken
                });
                print({'pushToken': pushToken, 'localToken': localToken});
              },
              onProgress: (int progress) {
                print("WebView is loading first (progress : $progress%)");
              },
              javascriptChannels: <JavascriptChannel>{
                _toasterJavascriptChannel(context),
                _loginWeb2saveTokenJavascriptChannel(context),
                _loginAutoJavascriptChannel(context),
                _alertJavascriptChannel(context),
              },
              onPageFinished: (String url) async {
                //await _controller.evaluateJavascript('hide_top()');
              },
              gestureNavigationEnabled: true,
            ));
      }),
      //bottomNavigationBar: Bottom(),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          var aa = message.message;
          print('Toast message  $aa');
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  // 웹로그인후 토큰을 받아 저장
  JavascriptChannel _loginWeb2saveTokenJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'LoginControl',
        onMessageReceived: (JavascriptMessage message) async {
          final SharedPreferences prefs = await _prefs;
          prefs.setString("LT", message.message);
        });
  }

  // 앱의 로그인여부를 확인하고 토큰을 웹에서 확인
  JavascriptChannel _loginAutoJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'AppLoginControl',
        onMessageReceived: (JavascriptMessage message) async {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  JavascriptChannel _alertJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'AlertControl',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: avoid_print
          print(message.message);

          if (message.message == "get_position") {
            //showToast('==> 위치정보를 요청받았습니다.');

            getMyCurrentLocation();

            if (pos_latitude != 0) {
              print("==> 위치정보를 결과를 받았습니다.");

              //_myController.evaluateJavascript("appPos2(126.79635 , 37.71806)");
              _myController
                  .evaluateJavascript("appPos($pos_longitude, $pos_latitude)");

              Scaffold.of(context).showSnackBar(
                SnackBar(content: Text("위치 정보 조회")),
              );
            }
          } else if (message.message == "get_position_for_voucher") {
            //showToast('==> 위치정보를 요청받았습니다.');

            getMyCurrentLocation();

            if (pos_latitude != 0) {
              print("==> 위치정보를 결과를 받았습니다.");

              //_myController.evaluateJavascript("appPos2(126.79635 , 37.71806)");
              _myController.evaluateJavascript(
                  "get_position_for_voucher($pos_longitude, $pos_latitude)");
            }
          } else if (message.message == "open_app_setting") {
            openAppSettings();
          } else {
            Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(message.message)),
            );
          }

          // Toast.show(message.message, context,
          //     duration: Toast.LENGTH_LONG,
          //     gravity: Toast.CENTER,
          //     backgroundColor: Colors.black38,
          //     backgroundRadius: 5);
        });
  }
}

enum MenuOptions {
  showUserAgent,
  listCookies,
  clearCookies,
  addToCache,
  listCache,
  clearCache,
  navigationDelegate,
}

class SampleMenu extends StatelessWidget {
  SampleMenu(this.controller);

  final Future<WebViewController> controller;
  final CookieManager cookieManager = CookieManager();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: controller,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        return PopupMenuButton<MenuOptions>(
          onSelected: (MenuOptions value) {
            switch (value) {
              case MenuOptions.showUserAgent:
                _onShowUserAgent(controller.data!, context);
                break;
              case MenuOptions.listCookies:
                _onListCookies(controller.data!, context);
                break;
              case MenuOptions.clearCookies:
                _onClearCookies(context);
                break;
              case MenuOptions.addToCache:
                _onAddToCache(controller.data!, context);
                break;
              case MenuOptions.listCache:
                _onListCache(controller.data!, context);
                break;
              case MenuOptions.clearCache:
                _onClearCache(controller.data!, context);
                break;
              case MenuOptions.navigationDelegate:
                _onNavigationDelegateExample(controller.data!, context);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
            PopupMenuItem<MenuOptions>(
              value: MenuOptions.showUserAgent,
              child: const Text('Show user agent'),
              enabled: controller.hasData,
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.listCookies,
              child: Text('List cookies'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.clearCookies,
              child: Text('Clear cookies'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.addToCache,
              child: Text('Add to cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.listCache,
              child: Text('List cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.clearCache,
              child: Text('Clear cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.navigationDelegate,
              child: Text('Navigation Delegate example'),
            ),
          ],
        );
      },
    );
  }

  void _onShowUserAgent(
      WebViewController controller, BuildContext context) async {
    // Send a message with the user agent string to the Toaster JavaScript channel we registered
    // with the WebView.
    await controller.evaluateJavascript(
        'Toaster.postMessage("User Agent: " + navigator.userAgent);');
  }

  void _onListCookies(
      WebViewController controller, BuildContext context) async {
    final String cookies =
        await controller.evaluateJavascript('document.cookie');
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Cookies:'),
          _getCookieList(cookies),
        ],
      ),
    ));
  }

  void _onAddToCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript(
        'caches.open("test_caches_entry"); localStorage["test_localStorage"] = "dummy_entry";');
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text('Added a test entry to cache.'),
    ));
  }

  void _onListCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript('caches.keys()'
        '.then((cacheKeys) => JSON.stringify({"cacheKeys" : cacheKeys, "localStorage" : localStorage}))'
        '.then((caches) => Toaster.postMessage(caches))');
  }

  void _onClearCache(WebViewController controller, BuildContext context) async {
    await controller.clearCache();
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text("Cache cleared."),
    ));
  }

  void _onClearCookies(BuildContext context) async {
    final bool hadCookies = await cookieManager.clearCookies();
    String message = 'There were cookies. Now, they are gone!';
    if (!hadCookies) {
      message = 'There are no cookies.';
    }
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void _onNavigationDelegateExample(
      WebViewController controller, BuildContext context) async {
    final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(kNavigationExamplePage));
    await controller.loadUrl('data:text/html;base64,$contentBase64');
  }

  void _goWeb(WebViewController controller, BuildContext context) async {
    // 자바스크립트 실행
    // await controller.evaluateJavascript('');
  }

  Widget _getCookieList(String cookies) {
    if (cookies == null || cookies == '""') {
      return Container();
    }
    final List<String> cookieList = cookies.split(';');
    final Iterable<Text> cookieWidgets =
        cookieList.map((String cookie) => Text(cookie));
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: cookieWidgets.toList(),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data!;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoBack()) {
                        await controller.goBack();
                      } else {
                        // ignore: deprecated_member_use
                        Scaffold.of(context).showSnackBar(
                          const SnackBar(content: Text("이전페이지가 존재하지 않습니다.")),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoForward()) {
                        await controller.goForward();
                      } else {
                        // ignore: deprecated_member_use
                        Scaffold.of(context).showSnackBar(
                          const SnackBar(content: Text("다음페이지가 존재하지 않습니다.")),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: !webViewReady
                  ? null
                  : () {
                      //controller.reload();
                      controller.evaluateJavascript('open_menu()');
                    },
            ),
          ],
        );
      },
    );
  }
}

void showToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM);
}

void _localNotiSetting() async {
  var androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  // 안드로이드 알림 올 때 앱 아이콘 설정

  var iOSInitializationSettings = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true);
  // iOS 알림, 뱃지, 사운드 권한 셋팅
  // 만약에 사용자에게 앱 권한을 안 물어봤을 경우 이 셋팅으로 인해 permission check 함

  var initsetting = InitializationSettings(
      android: androidInitializationSettings, iOS: iOSInitializationSettings);

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin.initialize(initsetting);
  //await flutterLocalNotificationsPlugin.initialize(initsetting,      onSelectNotification: onSelectNotification);

  // FirebaseMessaging.configure(
  //   onMessage: (Map<String, dynamic> message) async {
  //     showNotification(
  //         message['notification']['title'], message['notification']['body']);
  //     print("onMessage: $message");
  //   },
  //   onLaunch: (Map<String, dynamic> message) async {
  //     print("onLaunch: $message");
  //     Navigator.pushNamed(context, '/notify');
  //   },
  //   onResume: (Map<String, dynamic> message) async {
  //     print("onResume: $message");
  //   },
  // );
}

// Future onSelectNotification3(String payload) async {
//   showDialog(
//     context: context,
//     builder: (_) {
//       return new AlertDialog(
//         title: Text("PayLoad"),
//         content: Text("Payload : $payload"),
//       );
//     },
//   );
// }

Future<void> onSelectNotification2(
    BuildContext context, String? payload) async {
  //debugPrint("$payload");
  showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Text('Notification Payload'),
            content: Text('Payload: $payload'),
          ));
}
