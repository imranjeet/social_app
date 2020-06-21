import 'package:flutter/material.dart';
import 'package:social_app/widgets/HeaderWidget.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: header(context, strTitle: "Upload"),
      ),
      body: Center(child: Text("Here goes Upload Page.")),
    );
  }
}
