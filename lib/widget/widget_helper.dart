import 'package:flutter/material.dart';

Widget loadingWidget() {
  return Center(
    child: Container(
      height: 70.0,
      width: 70.0,
      child: CircularProgressIndicator(
        backgroundColor: Colors.blue,
      ),
    ),
  );
}
