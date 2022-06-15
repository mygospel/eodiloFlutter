// ignore_for_file: unnecessary_null_comparison, duplicate_ignore, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:device_info/device_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import './widget/bottom_bar.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:http/http.dart' as http;
//import 'package:device_info/device_info.dart';

/// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

//void main() => runApp(MaterialApp(home: WebViewExample()));
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(App());

  /// 요렇게 바꿈.
}

String localToken = "";
String loginToken = "";
String pushToken = "";

class App extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  //final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  Future<bool> _initialization() async {
    await Firebase.initializeApp();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    if (Platform.isIOS) {
      // ignore: unused_local_variable
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }
    messaging.getToken().then((token) {
      pushToken = token ?? "";
      print('token ==== $token');
    });

    return true;
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
  late WebViewController _myController;

  // 디바이스에 의한 TOP설정을 위한 변수
  double marginTop = -60.0;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();

    //getMyCurrentLocation();

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    //Size screenSize = MediaQuery.of(context).size;
    //double width = screenSize.width;
    //double height = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 12,
        title: Text("가정교회모바일"),
        backgroundColor: Color.fromARGB(111, 31, 130, 228),
        actions: <Widget>[
          NavigationControls(_controller.future),
          //DefaultMenu(_controller.future),
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        // OS 확인
        try {
          if (Platform.isAndroid) {
            marginTop = 0.0;
          } else if (Platform.isIOS) {
            marginTop = 0.0;
          }
        } catch (error) {}

        return Container(

            // Even Margin On All Sides
            margin: EdgeInsets.fromLTRB(0, marginTop, 0, 0),
            child: WebView(
              //initialUrl: 'https://house.ilsansarang.org/mobile',
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

                await webViewController.loadUrl(
                    'https://house.ilsansarang.org/mobile/member_autologin.html',
                    headers: {
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
                _myController.evaluateJavascript("hideTopNav()");

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
          var messageFromWeb = message.message;
          print('Toast message  $messageFromWeb');
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(messageFromWeb)),
          );
        });
  }

  // 웹로그인후 토큰을 받아 저장
  JavascriptChannel _loginWeb2saveTokenJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'LoginControl',
        onMessageReceived: (JavascriptMessage message) async {
          final SharedPreferences prefs = await _prefs;
          print("로그인을 했습니다." + message.message);
          prefs.setString("LT", message.message);
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text("로그인을 했습니다.")),
          );
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
          } else if (message.message == "get_position_for_voucher") {
            //showToast('==> 위치정보를 요청받았습니다.');

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

class DefaultMenu extends StatelessWidget {
  DefaultMenu(this.controller);

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
    await controller.evaluateJavascript('login_app_token("자 가지 여기이제 화이팅...")');
  }

  Widget _getCookieList(String cookies) {
    // ignore: unnecessary_null_comparison
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
            // IconButton(
            //   icon: const Icon(Icons.menu),
            //   onPressed: !webViewReady
            //       ? null
            //       : () {
            //           //controller.reload();
            //           controller.evaluateJavascript('open_menu()');
            //         },
            // ),
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
