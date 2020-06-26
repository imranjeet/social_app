import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/pages/CommentsPage.dart';
import 'package:social_app/pages/HomePage.dart';
import 'package:social_app/pages/ProfilePage.dart';
import 'package:social_app/widgets/ProgressWidget.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final dynamic likes;
  final String username;
  final String discription;
  final String location;
  final String url;

  Post(
      {this.postId,
      this.ownerId,
      this.likes,
      this.username,
      this.discription,
      this.location,
      this.url, });

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postId: documentSnapshot['postId'],
      ownerId: documentSnapshot['ownerId'],
      likes: documentSnapshot['likes'],
      username: documentSnapshot['username'],
      discription: documentSnapshot['discription'],
      location: documentSnapshot['location'],
      url: documentSnapshot['url'],
    );
  }

  int getTotleLikes(likes) {
    if (likes == null) {
      return 0;
    }

    int counter = 0;
    likes.values.forEach((eachValue) {
      if (eachValue == true) {
        counter = counter + 1;
      }
    });
    return counter;
  }

  
  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        likes: this.likes,
        username: this.username,
        discription: this.discription,
        location: this.location,
        url: this.url,
        likeCount: getTotleLikes(this.likes),
      );
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  Map likes;
  final String username;
  final String discription;
  final String location;
  final String url;
  int likeCount;
  int commentCount;
  bool isLiked;
  bool showHeart = false;
  final String currentOnlineUserId = currentUser?.id;

  _PostState({
    this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.discription,
    this.location,
    this.url,
    this.likeCount,
  });

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentOnlineUserId] == true);
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, right: 10, left: 10),
      child: Card(
        // borderOnForeground: ,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        // elevation: 1.0,
        child: Column(
          children: <Widget>[
            createPostHead(),
            createPostPicture(),
            createPostFooter(),
          ],
        ),
      ),
    );
  }

  createPostHead() {
    return FutureBuilder(
      future: usersReference.document(ownerId).get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(dataSnapshot.data);
        bool isPostOwner = currentOnlineUserId == ownerId;
        return ListTile(
          leading: GestureDetector(
            onTap: () => displayUserProfile(context, userProfileId: user.id),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.url),
            ),
          ),
          title: GestureDetector(
            onTap: () => displayUserProfile(context, userProfileId: user.id),
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(
            location,
          ),
          trailing: isPostOwner
              ? IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () => controlPostDelete(context),
                )
              : Text(""),
        );
      },
    );
  }

  controlPostDelete(BuildContext mContext) {
    return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("What do you want?"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  "Delete",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  removeUserPost();
                },
              ),
              SimpleDialogOption(
                child: Text(
                  "Cancel",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  removeUserPost() async {
    postsReference
        .document(ownerId)
        .collection('usersPosts')
        .document(postId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    storageReference.child("post_$postId.jpg").delete();

    QuerySnapshot querySnapshot = await activityFeedReference
        .document(ownerId)
        .collection("feedItems")
        .where("postId", isEqualTo: postId)
        .getDocuments();

    querySnapshot.documents.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    QuerySnapshot commentQuerySnapshot = await commentsReference
        .document(postId)
        .collection("comments")
        .getDocuments();

    commentQuerySnapshot.documents.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
  }

  displayUserProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(userProfileId: userProfileId)));
  }

  removeLike() {
    bool isNotPostOwner = currentOnlineUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedReference
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((document) {
        if (document.exists) {
          document.reference.delete();
        }
      });
    }
  }

  addLike() {
    bool isNotPostOwner = currentOnlineUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedReference
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "timestamp": DateTime.now(),
        "url": url,
        "postId": postId,
        "userProfileImg": currentUser.url,
      });
    }
  }

  controlUserLikePost() {
    bool _liked = likes[currentOnlineUserId] == true;
    if (_liked) {
      postsReference
          .document(ownerId)
          .collection("usersPosts")
          .document(postId)
          .updateData({"likes.$currentOnlineUserId": false});
      removeLike();
      setState(() {
        likeCount = likeCount - 1;
        isLiked = false;
        likes[currentOnlineUserId] = false;
      });
    } else if (!_liked) {
      postsReference
          .document(ownerId)
          .collection("usersPosts")
          .document(postId)
          .updateData({"likes.$currentOnlineUserId": true});
      addLike();
      setState(() {
        likeCount = likeCount + 1;
        isLiked = true;
        likes[currentOnlineUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 800), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  createPostPicture() {
    return GestureDetector(
      onDoubleTap: () => controlUserLikePost,
      child: Stack(
        children: <Widget>[
          Image.network(
            url,
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.9,
            fit: BoxFit.cover,
          ),
          // showHeart
          //     ? Icon(
          //         Icons.favorite,
          //         size: 100,
          //         color: Colors.pink,
          //       )
          //     : Text(""),
        ],
      ),
    );
  }

  createPostFooter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: GestureDetector(
                onTap: () => controlUserLikePost(),
                child: isLiked
                    ? Icon(
                        Icons.thumb_up,
                        size: 30.0,
                        color: Colors.pink,
                      )
                    : Icon(Icons.thumb_up, size: 30.0, color: Colors.black54,),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: GestureDetector(
                onTap: () => displayComment(context,
                    postId: postId, ownerId: ownerId, url: url),
                child: Icon(
                  Icons.comment,
                  size: 30.0,
                  color: Colors.black54
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              child: Text(
                "$likeCount likes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              child: Text(
                "",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8,),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                  "$username ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              
              Text(discription, overflow: TextOverflow.ellipsis,),
            ],
          ),
        ),
      ],
    );
  }

  displayComment(BuildContext context,
      {String postId, String ownerId, String url}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CommentsPage(
          postId: postId, postOwnerId: ownerId, postImageUrl: url);
    }));
  }
}
