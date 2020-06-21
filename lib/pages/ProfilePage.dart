import 'package:flutter/material.dart';
import 'package:social_app/widgets/HeaderWidget.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: header(context, strTitle: "Profile"),
      ),
      body: Center(child: Text("Profile Page goes here.")),
    );
  }
}
