import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/pages/HomePage.dart';
import 'package:social_app/widgets/ProgressWidget.dart';
import 'package:timeago/timeago.dart' as tAgo;

import 'ProfilePage.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool loading = false;

  retriveNotifications() async {

    setState(() {
      loading = true;
    });

    QuerySnapshot querySnapshot = await activityFeedReference
        .document(currentUser.id)
        .collection("feedItems")
        .orderBy("timestamp", descending: true)
        .limit(60)
        .getDocuments();

    List<NotificationsItem> notificationsItems = [];

    querySnapshot.documents.forEach((document) {
      notificationsItems.add(NotificationsItem.fromDocument(document));
    });

    return notificationsItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Notifications"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: retriveNotifications(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          return ListView(
            children: dataSnapshot.data,
          );
        },
      ),
    );
  }
}

String notificationsItemText;
Widget mediaPreview;

class NotificationsItem extends StatelessWidget {
  final String username;
  final String type;
  final String commentData;
  final String postId;
  final String userId;
  final String userProfileImg;
  final String url;
  final Timestamp timestamp;

  NotificationsItem(
      {this.username,
      this.type,
      this.commentData,
      this.postId,
      this.userId,
      this.userProfileImg,
      this.url,
      this.timestamp});

  factory NotificationsItem.fromDocument(DocumentSnapshot documentSnapshot) {
    return NotificationsItem(
      username: documentSnapshot['username'],
      type: documentSnapshot['type'],
      commentData: documentSnapshot['commentData'],
      postId: documentSnapshot['postId'],
      userId: documentSnapshot['userId'],
      userProfileImg: documentSnapshot['userProfileImg'],
      url: documentSnapshot['url'],
      timestamp: documentSnapshot['timestamp'],
    );
  }

  displayUserProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(userProfileId: userProfileId)));
  }

  displayOwneProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(userProfileId: userProfileId)));
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Container(
        child: GestureDetector(
          onTap: () => displayUserProfile(context, userProfileId: userId),
          child: ListTile(
            title: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(fontSize: 14.0, color: Colors.black),
                  children: [
                    TextSpan(
                      text: username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: " $notificationsItemText")
                  ]),
            ),
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfileImg),
            ),
            subtitle: Text(
              tAgo.format(timestamp.toDate()),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: mediaPreview,
          ),
        ),
      ),
    );
  }

  configureMediaPreview(BuildContext context) {
    if (type == 'comment' || type == 'like') {
      mediaPreview = GestureDetector(
        onTap: () => displayOwneProfile(context, userProfileId: currentUser.id),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(url),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text("");
    }

    if (type == 'like') {
      notificationsItemText = "liked your post.";
    } else if (type == 'comment') {
      notificationsItemText = "replied: $commentData";
    } else if (type == 'follow') {
      notificationsItemText = "started following you.";
    } else {
      notificationsItemText = "Error, unknown type: $type";
    }
  }
}
