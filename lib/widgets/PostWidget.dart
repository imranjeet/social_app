import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/pages/HomePage.dart';
import 'package:social_app/widgets/CImageWidget.dart';
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
      this.url});

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: <Widget>[
          createPostHead(),
          createPostPicture(),
          createPostFooter(),
        ],
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
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.url),
          ),
          title: GestureDetector(
            onTap: (){},
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
          trailing: isPostOwner ? IconButton(icon: Icon(Icons.more_vert), onPressed: () => print("Delete"),) : Text(""),
        );
      },
    );
  }

  createPostPicture(){
    return GestureDetector(
      onDoubleTap: (){},
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.network(url),
          
        ],
      ),
    );
  }

  createPostFooter(){
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left:20.0)),
            GestureDetector(
              onTap: (){},
              child: Icon(
                Icons.favorite,
              //  isLiked ? Icons.favorite : Icons.favorite_border,
              //  size: 28.0,
              //  color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: (){},
              child: Icon(
               Icons.chat_bubble_outline,
               size: 28.0,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left:20.0),
              child: Text(
                "$likeCount likes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text("$username ", style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(child: Text(discription)),
          ],
        ),
      ],
    );
  }
}
