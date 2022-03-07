import 'package:flutter/material.dart';

class Bottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Container(
        height: 50,
        child: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.transparent,
          tabs: <Widget>[
            Tab(
              child: Text(
                '게임',
              ),
            ),
            Tab(
              child: Text(
                '순위',
              ),
            ),
            Tab(
              child: Text(
                '도움말',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
