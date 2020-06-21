import 'package:flutter/material.dart';
import 'package:social_app/widgets/HeaderWidget.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: header(context, strTitle: "Notification"),
      ),
      body: Center(child: Text('Activity Feed Item goes here')),
    );
  }
}
