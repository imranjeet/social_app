import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/pages/HomePage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: HomePage(),
      routes: {'/home': (context) => HomePage()},
    );
  }
}

// class NoInternetScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("Home"),
//           centerTitle: true,
//         ),
//         body: Center(
//             child:
//                 Text("Unable to connect. Please Check Internet Connection")));
//   }
// }

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => new _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   startTime() async {
//     var _duration = new Duration(seconds: 3);
//     return new Timer(_duration, navigationPage);
//   }

//   void navigationPage() {
//     return checkConnectation();
//   }

//   checkConnectation() async {
//     var connectivityResult = await (Connectivity().checkConnectivity());
//     if (connectivityResult == ConnectivityResult.mobile ||
//         connectivityResult == ConnectivityResult.wifi) {
//       return Navigator.of(context).pushReplacementNamed('/home');
//     } else {
//       Scaffold(
//           appBar: AppBar(
//             title: Text("Home"),
//             centerTitle: true,
//           ),
//           body: Center(
//               child:
//                   Text("Unable to connect. Please Check Internet Connection")));
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     startTime();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         child: Center(
//           child: CircleAvatar(
//             radius: 100,
//             backgroundImage: AssetImage(
//               'assets/images/splash.png',
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
