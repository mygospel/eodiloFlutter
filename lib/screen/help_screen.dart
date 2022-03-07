//import 'dart:html';

import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  _HelpScreenState createState() => _HelpScreenState();
}


class _HelpScreenState extends State<HelpScreen> {
@override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '게임설명',
      home: Scaffold(
        appBar: AppBar(
          title: Text('게임설명'),
        ),
        body: Conthelp(),
      ),
    );
  }
}


class Conthelp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: SingleChildScrollView(
          child:Column(

            crossAxisAlignment: CrossAxisAlignment.stretch,

            children:[
                Text("카드 3장으로 15 또는 20을!!",
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,)
                ),
                Text("1. 카드를 선택하면 카드의 색이 바뀝니다.",
                  textDirection: TextDirection.ltr,

                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,)
                ),
                Image.asset(
                  'images/card_help_01.png',
                  fit: BoxFit.contain,
                ),
                Text("2. 3장을 선택하면 3장의 합이 15나 20이 되는지 확인하고 맞다면 점수가 올라갑니다.",
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,)
                  ),

                Image.asset(
                  'images/card_help_01.png',
                  fit: BoxFit.contain,
                ),
                Text("3. 15나 20이 맞지 않다면 변화가 없습니다. 이때 빨리 카드를 다시 선택하면 선택이 해제되며 다른 카드를 선택할 수 있습니다.",
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,)
                  )
            ]
            
          ),
          ),
      
    );
  }
}
