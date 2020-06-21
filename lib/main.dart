import 'package:flutter/material.dart';
import 'package:social_app/pages/HomePage.dart';

void main()
{
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData
      (
        primarySwatch: Colors.yellow,
      ),
      home: HomePage(),
    );
  }
}
