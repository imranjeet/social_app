import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/widgets/PostWidget.dart';
import 'package:social_app/widgets/ProgressWidget.dart';
import 'HomePage.dart';

class TimeLinePage extends StatefulWidget {
  final User gCurrentUser;

  TimeLinePage({this.gCurrentUser});
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  List<Post> posts;
  List<String> followingsList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;

  retrieveTimeLine() async {
    setState(() {
      loading = true;
    });
    QuerySnapshot querySnapshot = await timelineReference
        .document(widget.gCurrentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    List<Post> allPosts = querySnapshot.documents
        .map((document) => Post.fromDocument(document))
        .toList();

    setState(() {
      loading = false;
      this.posts = allPosts;
    });
  }

  retrieveFollowings() async {
    setState(() {
      loading = true;
    });

    QuerySnapshot querySnapshot = await followingsReference
        .document(currentUser.id)
        .collection('userFollowing')
        .getDocuments();

    setState(() {
      followingsList = querySnapshot.documents
          .map((document) => document.documentID)
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();

    retrieveTimeLine();
    retrieveFollowings();
  }

  createUserTimeLine() {
    if (loading) {
      return Center(child: circularProgress());
    } else if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(
                Icons.photo_library,
                size: 80.0,
              ),
            ),
            Text(
              "No Posts",
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return ListView(
        children: posts,
      );
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Social App",
          style: TextStyle(
            fontSize: 40.0,
            fontFamily: "Signatra",
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: Colors.black,
        child: Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: createUserTimeLine()
          ),
        onRefresh: () => retrieveTimeLine(),
      ),
    );
  }
}
