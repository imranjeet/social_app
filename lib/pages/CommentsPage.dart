import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/pages/HomePage.dart';
import 'package:social_app/widgets/HeaderWidget.dart';
import 'package:social_app/widgets/ProgressWidget.dart';

import 'package:timeago/timeago.dart' as tAgo;

class CommentsPage extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postImageUrl;

  CommentsPage({this.postId, this.postOwnerId, this.postImageUrl});

  @override
  CommentsPageState createState() => CommentsPageState(
        postId: postId,
        postOwnerId: postOwnerId,
        postImageUrl: postImageUrl,
      );
}

class CommentsPageState extends State<CommentsPage> {
  final String postId;
  final String postOwnerId;
  final String postImageUrl;

  TextEditingController commentTextEditingController = TextEditingController();

  CommentsPageState({this.postId, this.postOwnerId, this.postImageUrl});

  retrieveComments() {
    return StreamBuilder(
      stream: commentsReference
          .document(postId)
          .collection("comments")
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];
        dataSnapshot.data.documents.forEach((document) {
          comments.add(Comment.fromDocument(document));
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  publishComment() {
    commentsReference.document(postId).collection("comments").add({
      "username": currentUser.username,
      "comment": commentTextEditingController.text,
      "timestamp": DateTime.now(),
      "url": currentUser.url,
      "userId": currentUser.id,
    });

    bool isNotPostOwner = postOwnerId != currentUser.id;
    if (isNotPostOwner) {
      activityFeedReference.document(postOwnerId).collection("feedItems").add({
        "type": "comment",
        "commentDate": timestamp,
        "postId": postId,
        "userId": currentUser.id,
        "username": currentUser.username,
        "userProfileImg": currentUser.url,
        "url": postImageUrl,
      });
    }
    commentTextEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Comments"),
      body: Column(
        children: <Widget>[
          Expanded(child: retrieveComments()),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentTextEditingController,
              decoration: InputDecoration(
                labelText: "Write comment here...",
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            trailing: OutlineButton(
              borderSide: BorderSide.none,
              child: Text(
                "Publish",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: publishComment,
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;

  Comment({this.username, this.userId, this.url, this.comment, this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot documentSnapshot) {
    return Comment(
      username: documentSnapshot["username"],
      userId: documentSnapshot["userId"],
      url: documentSnapshot["url"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Container(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Row(
                children: <Widget>[
                  Text(
                    username,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 5.0),
                  Expanded(
                    child: Text(
                      comment,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(url),
              ),
              subtitle: Text(
                tAgo.format(timestamp.toDate()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
