import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RankScreen extends StatefulWidget {
  _RankScreenState createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  List rankList;
  String rankHTML = '';
  var deviceId = "";
  var pt = 0;

  void initState() {
    super.initState();
    viewPoints(pt);
  }

  @override
  Widget build(BuildContext context) {
    final title = '랭킹';

    return MaterialApp(
        title: title,
        home: Scaffold(
          appBar: AppBar(title: Text(title)),

          body: new ListView.builder(
            shrinkWrap: true, //just set this property
            padding: const EdgeInsets.all(20.0),
            itemCount: rankList == null ? 0 : rankList.length,

            itemBuilder: (BuildContext context, int index) {
              String aa = "Rank " +
                  (index + 1).toString() +
                  ". " +
                  rankList[index]["pt"];
              return ListTile(
                title: Text(aa),
                subtitle: Text(rankList[index]["rdate"]),
              );
            },
          ),

          //body: Text(rankHTML),
        ));
  }

  void viewPoints(pt) async {
    final response = await http.post(
      'https://mygospel.net/quiz/card/ajax_card_rank.php',
      body: jsonEncode(
        {'device_id': deviceId, 'pt': pt},
      ),
      headers: {'Content-Type': "application/json"},
    );
/*
    if (response.statusCode == 200) {
      rankJson = jsonDecode(response.body);
    } else {
      print('A network error occurred');
    }
*/
    // 화면에 반영
    setState(() {
      rankHTML = response.body;
      rankList = jsonDecode(response.body);
    });
  }
}
