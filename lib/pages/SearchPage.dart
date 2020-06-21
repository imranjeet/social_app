import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/pages/HomePage.dart';
import 'package:social_app/widgets/ProgressWidget.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin<SearchPage> {
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;

  emptyTheTextFormField() {
    searchTextEditingController.clear();
  }

  controlSearching(String str) {
    Future<QuerySnapshot> allUsers = usersReference
        .where("profileName", isGreaterThanOrEqualTo: str)
        .getDocuments();
    setState(() {
      futureSearchResults = allUsers;
    });
  }

  AppBar searchPageHeader() {
    return AppBar(
      title: TextFormField(
        style: TextStyle(fontSize: 18.0, color: Colors.black),
        controller: searchTextEditingController,
        decoration: InputDecoration(
          hintText: "Search here....",
          hintStyle: TextStyle(color: Colors.grey),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          filled: true,
          prefix: Icon(
            Icons.person_pin,
            size: 30.0,
          ),
          suffix: IconButton(
            icon: Icon(Icons.clear),
            onPressed: emptyTheTextFormField,
          ),
        ),
        onFieldSubmitted: controlSearching,
      ),
    );
  }

  Container displayNoSearchResultScreen() {
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(
              Icons.group,
              size: 200.0,
            ),
            Text(
              "Search User",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 65.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  displayUserFoundScreen() {
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchUsersResult = [];
        dataSnapshot.data.documents.forEach((document) {
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser);
          searchUsersResult.add(userResult);
        });

        return ListView(children: searchUsersResult);
      },
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: searchPageHeader(),
      body: futureSearchResults == null
          ? displayNoSearchResultScreen()
          : displayUserFoundScreen(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User eachUser;

  UserResult(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {},
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: CachedNetworkImageProvider(eachUser.url),
                ),
                title: Text(
                  eachUser.profileName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  eachUser.username,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
