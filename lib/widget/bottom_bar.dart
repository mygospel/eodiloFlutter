import 'package:flutter/material.dart';

class Bottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 255, 255, 255),
      child: Container(
        height: 50,
        child: TabBar(
          labelColor: Color.fromARGB(255, 9, 9, 9),
          unselectedLabelColor: Color.fromARGB(153, 96, 91, 91),
          indicatorColor: Colors.transparent,
          tabs: <Widget>[
            Tab(
              child: Text(
                '홈',
              ),
            ),
            Tab(
              child: Text(
                '매장찾기',
              ),
            ),
            Tab(
              child: Text(
                '찜목록',
              ),
            ),
            Tab(
              child: Text(
                '마이페이지',
              ),
            ),
            Tab(
              child: Text(
                '더보기',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
