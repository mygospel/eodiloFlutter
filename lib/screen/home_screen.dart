import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';

/*import 'package:audioplayers/audio_cache.dart';*/
/*import 'package:audioplayers/audioplayers.dart';*/

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> 
  with AutomaticKeepAliveClientMixin {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> deviceData = <String, dynamic>{};

  /*
  final AudioCache player = AudioCache(prefix: "audio/" );
  final AudioCache player2 = AudioCache(prefix: "audio/" );
  */

  var cards = [
    {
        'num':0,
        'kind':'A',
        'status':FabFloatOffsetY
    },
    {
        'num':0,
        'kind':'A',
        'status':FabFloatOffsetY
    },
    {
        'num':0,
        'kind':'A',
        'status':FabFloatOffsetY
    },
    {
        'num':0,
        'kind':'A',
        'status':FabFloatOffsetY
    },
    {
        'num':0,
        'kind':'A',
        'status':true
    },
  ]; 

  var imgUrl = '';
  String cardTop = 'images/card_top.png';
  String cardImgOff = 'images/card_off.png';
  String cardImgOn = '';
  String cardImg1 = '';
  String cardImg2 = '';
  String cardImg3 = '';
  String cardImg4 = '';
  String cardImg5 = '';
  //Map userMap = jsonDecode(jsonString);
  Map userMap =  {}; 
  // ignore: non_constant_identifier_names
  Map Rankings =  {}; 

  Timer _timer;
  var _title = "안녕~ 난 엘로야.\n친구들을 모으고 있어.\n함께 친구들을 찾아보자.";
  var _time = 60;
  double _timeProgress = 1;
  //var _permChange = 5;
  var _isPlaying = false;

  // 현재 선택한 카드 갯수
  var countChoise = 0;

  // 현재 선택한 카드합
  var sumChoise = 0;

  var _sumCard = 0;
  var totalPoint = 0;

  var deviceId = "";


  @override
  bool get wantKeepAlive => true;
  
  void initState(){
    fetchPosts();
    initCard();

    super.initState();
    initPlatformState();

  }

Future<void> initPlatformState() async {

    Map<String, dynamic> deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        deviceId = deviceData['androidId'];
        print(deviceData['androidId']);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        deviceId = deviceData['identifierForVendor'];
        print(deviceData['identifierForVendor']);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  void _start(){
    if( _isPlaying == false ) {

        //player.play('card_bgm.mp3', volume: 90);

        _sumCard = 0;
        totalPoint = 0;  
        //_permChange = 5;
        _isPlaying = true;
        _timer = Timer.periodic(Duration(milliseconds:1000),(timer){
          setState((){
            _time--;
            if ( _time < 0  ) _time = 0;

            if( _time > 60 ) _timeProgress = 1.0;
            else _timeProgress =  double.parse(( _time/60).toStringAsPrecision(8) );

            // 남은 시간이 0이면 종료
            if( _time <= 0 ) {
              _end();
            }

            countChoise = 0;
            sumChoise = 0;
            for (var card in cards) {
              if( card['status'] == true ) {
                countChoise++;
                sumChoise += card['num'];
              }
            }
            
            if( countChoise ==  3 && (sumChoise==15||sumChoise==20) ) {
              //player2.play('card_game_clear.mp3',mode: PlayerMode.LOW_LATENCY, volume: 50);
              checkCard();
            }

          });
        });

        setState((){
          _title = "게임을 시작합니다.";
          resetCard();
         _time = 60;
        });

    } 
  }

  void fetchPosts() async {
    /* 타이틀 이미지에 텍스트를 서버에서 가져오기 위해
      final response = await http.get('https://mygospel.net/quiz/card/ajax_card_title.php');
      // ignore: non_constant_identifier_names
      var GameInfo = jsonDecode(response.body);

      setState(() {
        _title = GameInfo['title'];
      });
    */
  }

  void recordPoints(pt) async {

      final response = await http.post('https://mygospel.net/quiz/card/ajax_card_record.php',
            body: jsonEncode(
                {
                  'device_id': deviceId,
                  'pt': pt
                },
            ),
            headers: {'Content-Type': "application/json"},
      );

      if (response.statusCode == 200) {
          print(response.body);
      } else {
        print('A network error occurred');
      }      

      Rankings = jsonDecode(response.body);

      String jsonString = jsonEncode(Rankings);


      print('종료후 서버에서 얻은 정보 '+jsonString);

  }

/*
  void _pause() {
    _isPlaying = false;    
    _timer?.cancel();
  }
*/
  void _end(){
    _isPlaying = false;   
    _timer?.cancel();

    initCard();
    setState(() {
        _title =  "게임종료 $totalPoint 획득!";
    });
    
    // 서버에 저장
    recordPoints(totalPoint);
    //player2.play('card_game_end.mp3',mode: PlayerMode.LOW_LATENCY, volume: 50);

  }



  String cardImgName(cardObj){
    var num = cardObj["num"];
    var status = cardObj["status"] ? "on" : "off";
    var imgsrc = 'images/card_${num}_$status.png';
    //print("이미지 $imgsrc");
    return imgsrc;
  }

  void choiceCard( int num ) {

    if( _isPlaying == false ) {
      return;
    }

    // 선택한 카드 상태 변경
    if( cards[num-1]['status'] == false ) {
      cards[num-1]['status'] = true;
      countChoise += 1;
      sumChoise += cards[num-1]['num'];

    } else {
      cards[num-1]['status'] = false;
      countChoise -= 1;
      sumChoise -= cards[num-1]['num'];
    }

    // 화면에 반영
    setState(() {
      _sumCard = sumChoise;
      if( num == 1 ) {
       cardImg1 = cardImgName(cards[0]);
      }
      if( num == 2 ) {
        cardImg2 = cardImgName(cards[1]);
      }
      if( num == 3 ) {
        cardImg3 = cardImgName(cards[2]);
      }
      if( num == 4 ) {
        cardImg4 = cardImgName(cards[3]);
      }
      if( num == 5 ) {
        cardImg5 = cardImgName(cards[4]);
      }

    });  

  }

  void checkCard() {

        setState(() {

        });  

        //print("이후선택한 카드 수 $countChoise / 카드의 합 $sumChoise " );   

        setState(() {
            totalPoint += sumChoise;
            _title = "$sumChoise 성공!";
            //print("총 점수 $totalPoint ");

            changeCard();
        //  여기서 숫자의 합을 계산
        });  
  }

  void viewCard() {
    setState(() {

    });     
  }

  void changeCard() {
    var rng = new Random();

    setState(() {
        for (var i=0;i<=4;i++) {
          if( cards[i]['status'] == true ) {
            cards[i]['status'] = false;
            cards[i]['num'] = rng.nextInt(9)+1;
          }
        }

        cardImg1 = cardImgName(cards[0]);
        cardImg2 = cardImgName(cards[1]);
        cardImg3 = cardImgName(cards[2]);
        cardImg4 = cardImgName(cards[3]);
        cardImg5 = cardImgName(cards[4]);

        _sumCard = 0;
        _time += 5; 
    });  
  
  }

  void initCard() {

    setState(() {
        _sumCard = 0;
        cardImg1 = cardImgOff;
        cardImg2 = cardImgOff;
        cardImg3 = cardImgOff;
        cardImg4 = cardImgOff;
        cardImg5 = cardImgOff;
    }); 

    //print("카드변경..");

  }

  void resetCard() {

    if( _isPlaying == false ) {
      return;
    }

    var rng = new Random();

    for (var card in cards) {
      card['num'] = rng.nextInt(10)+1;
      card['status'] = false;
    }

    setState(() {
        countChoise = 0;
        sumChoise = 0;

        _sumCard = 0;
        cardImg1 = cardImgName(cards[0]);
        cardImg2 = cardImgName(cards[1]);
        cardImg3 = cardImgName(cards[2]);
        cardImg4 = cardImgName(cards[3]);
        cardImg5 = cardImgName(cards[4]);

        _time -= 5; 
    }); 
    //print("카드변경..");

  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("엘로의 카드")),
      body: Center(
          child:Column(
            verticalDirection: VerticalDirection.down,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:[
                Container(
                  
                  margin: const EdgeInsets.only( left:10.0, right:10.0 ),
                    child: Stack(
                      children: [
                          Image.asset(
                            cardTop,
                            fit: BoxFit.contain,
                          ),

                          Container(

                            margin: EdgeInsets.only( top: 12.0, left: 100.0 ),
                            child: Row(
                              children: [
                                Text('$_title', style:TextStyle(color:Colors.black, fontSize:17.0)), 
                              ]
                            )
                          ),
                                          
                      ],
                    )
                ),  

                Container(
                  margin: const EdgeInsets.only( top: 10.0, left:10.0, right:10.0 ),
                    child: Row(
                      
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[ 
                          Text('남은시간'),   


                          Text('$_time',
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              )
                            ), 

                            Container(
                              margin: const EdgeInsets.only( right:0.0 ),
                              child: 
                              // ignore: deprecated_member_use
                              RaisedButton(
                                child: Text('게임시작',),
                                textColor:_isPlaying ? Colors.white70 : Colors.white, // 글씨 색상
                                color: _isPlaying ?  Colors.black26: Colors.orange, // 배경 색상
                                onPressed: () { _start(); },
                              ),
                            ),
                      ],     
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only( top: 10.0, left:10.0, right:10.0, bottom:20.0 ),
                    height: 20,
                    child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: 
                          LinearProgressIndicator(
                            backgroundColor: Colors.grey,
                            value: _timeProgress,
                          ),   
                    ),
                ),

                Container(
                  margin: const EdgeInsets.only( bottom: 10.0, left:10.0, right:10.0 ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                      children: [
                          Text('카드의 합'),   
                          Text('$_sumCard',
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,)
                          ),           
                          Text('나의 점수'),          
                          Text('$totalPoint',
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,)
                          ),               

                      ],

                      
                    )
                ),  

                Container(
                  margin: const EdgeInsets.only( top: 10.0, left:10.0, right:10.0 ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:<Widget>[
                    GestureDetector(
                      onTap: (){choiceCard(1);} ,
                      child: Image.asset(
                        cardImg1,
                        fit: BoxFit.contain,
                        height: 100,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){choiceCard(2);} ,
                      child: Image.asset(
                        cardImg2,
                        fit: BoxFit.contain,
                        height: 100,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){choiceCard(3);} ,
                      child: Image.asset(
                        cardImg3,
                        fit: BoxFit.contain,
                        height: 100,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){choiceCard(4);} ,
                      child: Image.asset(
                        cardImg4,
                        fit: BoxFit.contain,
                        height: 100,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){choiceCard(5);} ,
                      child: Image.asset(
                        cardImg5,
                        fit: BoxFit.contain,
                        height: 100,
                      ),
                    ),
                  ],
                  
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 15.0, left:10.0, right:10.0),
                  height: 60.0,
                  child:
                  // ignore: deprecated_member_use
                  RaisedButton(
                    child: Text('카드변경'),
                    textColor: _isPlaying ? Colors.white : Colors.white60 , // 글씨 색상
                    color: _isPlaying ? Colors.orange : Colors.black26, // 배경 색상
                    onPressed: () { resetCard(); },
                  ),
                ),

            ]
          )
        )
      
    );
  }
}


