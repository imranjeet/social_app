import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:social_app/models/user.dart';
import 'package:social_app/pages/HomePage.dart';
import 'package:social_app/widgets/ProgressWidget.dart';

class EditProfilePage extends StatefulWidget {
  final String currentOnlineUserId;
  EditProfilePage({this.currentOnlineUserId});
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController profileNameTextEditingController =
      TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();

  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  User user;
  bool _profileNameVaild = true;
  bool _bioVaild = true;

  @override
  void initState() { 
    super.initState();
    getAndDisplayUserInformation();
  }

  getAndDisplayUserInformation() async {
    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot = await usersReference.document(widget.currentOnlineUserId).get();
    user = User.fromDocument(documentSnapshot);

    profileNameTextEditingController.text = user.profileName;
    bioTextEditingController.text = user.bio;

    setState(() {
      loading = false;
    });
  }

  updateUserData(){
    setState(() {
      profileNameTextEditingController.text.trim().length < 3 || profileNameTextEditingController.text.isEmpty ? _profileNameVaild = false : _profileNameVaild = true;
      bioTextEditingController.text.trim().length > 110 ? _bioVaild = false : _bioVaild = true;
    });

    if(_profileNameVaild && _bioVaild){
      usersReference.document(widget.currentOnlineUserId).updateData({
        "profileName": profileNameTextEditingController.text,
        "bio": bioTextEditingController.text,
      });
      SnackBar successSnackBar = SnackBar(content: Text("Profile has been updated successfully."));
      _scaffoldGlobalKey.currentState.showSnackBar(successSnackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGlobalKey,
      appBar: AppBar(
        title: Text("Edit Profile"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.done,
                size: 30.0,
              ),
              onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: loading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                    child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, bottom: 7.0),
                      child: CircleAvatar(
                        radius: 52.0,
                        backgroundImage: CachedNetworkImageProvider(user.url),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          createProfileNameTextFormField(),
                          createBioTextFormField(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0, left: 50.0, right: 50.0),
                      child: RaisedButton(
                        color: Colors.blue,
                        onPressed: updateUserData,
                        child: Text("Update", style: TextStyle(color: Colors.white, fontSize: 16.0),),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 40.0, left: 50.0, right: 50.0),
                      child: RaisedButton(
                        color: Colors.red,
                        onPressed: logOutUser,
                        child: Text("  Sign Out  ", style: TextStyle(color: Colors.white, fontSize: 20.0),),
                      ),
                    )
                  ],
                ))
              ],
            ),
    );
  }

  logOutUser() async {
    await gSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  Column createProfileNameTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text("Profile Name"),
        ),
        TextField(
          controller: profileNameTextEditingController,
          decoration: InputDecoration(
            hintText: "Write profile name here..",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            errorText: _profileNameVaild ? null : "Profile name is very short.",
          ),
        ),
      ],
    );
  }

  Column createBioTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text("Bio"),
        ),
        TextField(
          controller: bioTextEditingController,
          decoration: InputDecoration(
            hintText: "Write bio here..",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            errorText: _profileNameVaild ? null : "Bio is very long..",
          ),
        ),
      ],
    );
  }
}
