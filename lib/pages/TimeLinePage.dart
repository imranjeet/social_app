import 'package:flutter/material.dart';
import 'package:social_app/widgets/HeaderWidget.dart';
import 'package:social_app/widgets/ProgressWidget.dart';

class TimeLinePage extends StatefulWidget {
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: header(context, isAppTitle: true, )
      ),
      body: circularProgress(),
    );
  }
}
