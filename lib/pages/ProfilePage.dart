import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/pages/EditProfilePage.dart';
import 'package:social_app/pages/HomePage.dart';
import 'package:social_app/widgets/HeaderWidget.dart';
import 'package:social_app/widgets/PostTileWidget.dart';
import 'package:social_app/widgets/PostWidget.dart';
import 'package:social_app/widgets/ProgressWidget.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;
  ProfilePage({this.userProfileId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnlineUserId = currentUser?.id;
  bool loading = false;
  int countPost = 0;
  List<Post> postsList = [];
  int postOrientation = 0;

  @override
  void initState() {
    super.initState();
    getAllProfilePosts();
  }

  createProfileTopView() {
    return FutureBuilder(
        future: usersReference.document(widget.userProfileId).get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(dataSnapshot.data);
          return Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 50.0,
                      backgroundColor: Colors.cyan,
                      backgroundImage: CachedNetworkImageProvider(user.url),
                    ),
                    SizedBox(height: 5.0),
                    Container(
                      alignment: Alignment.center,
                      child: Text(user.username),
                    ),
                    SizedBox(height: 5.0),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        user.profileName,
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Container(
                      alignment: Alignment.center,
                      child: Text(user.bio),
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        createColumn("posts", 0),
                        createColumn("followers", 0),
                        createColumn("following", 0),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        createButton(),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  Column createColumn(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300),
          ),
        )
      ],
    );
  }

  createButton() {
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if (ownProfile) {
      return createButtonTitleAndFunction(
        title: "Edit Profile",
        performFunction: editUserProfile,
      );
    }
  }

  Container createButtonTitleAndFunction(
      {String title, Function performFunction}) {
    return Container(
      padding: EdgeInsets.only(top: 3.0),
      child: FlatButton(
          onPressed: performFunction,
          child: Container(
            width: 245.0,
            height: 26.0,
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(6.0),
            ),
          )),
    );
  }

  editUserProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditProfilePage(currentOnlineUserId: currentOnlineUserId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: header(context, strTitle: "Profile"),
        ),
        body: ListView(
          children: <Widget>[
            createProfileTopView(),
            Divider(),
            createListGridPost(),
            Divider(
              height: 0.0,
            ),
            displayProfilePost(),
          ],
        ));
  }

  displayProfilePost() {
    if (loading) {
      return circularProgress();
    } else if (postsList.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Icon(
                Icons.photo_library,
                size: 200.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                "No Posts",
                style: TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (postOrientation == 0) {
      List<GridTile> gridTilesList = [];
      postsList.forEach((eachPost) {
        gridTilesList.add(GridTile(
          child: PostTile(eachPost),
        ));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTilesList,
      );
    } else if (postOrientation == 1) {
      return Column(
        children: postsList,
      );
    }
  }

  getAllProfilePosts() async {
    setState(() {
      loading = true;
    });

    QuerySnapshot querySnapshot = await postsReference
        .document(widget.userProfileId)
        .collection("usersPosts")
        .orderBy("timestamp", descending: true)
        .getDocuments();
    setState(() {
      loading = false;
      countPost = querySnapshot.documents.length;
      postsList = querySnapshot.documents
          .map((documentSnapshot) => Post.fromDocument(documentSnapshot))
          .toList();
    });
  }

  createListGridPost() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.grid_on), onPressed: () => setOrientation(0)),
        IconButton(
            icon: Icon(Icons.list), onPressed: () => setOrientation(1)),
      ],
    );
  }

  setOrientation(int orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }
}
