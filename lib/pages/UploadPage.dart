import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/widgets/ProgressWidget.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as ImD;

import 'HomePage.dart';

class UploadPage extends StatefulWidget {
  final User gCurrentUser;
  UploadPage({this.gCurrentUser});
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with AutomaticKeepAliveClientMixin<UploadPage> {
  File _image;
  File _video;

  bool uploading = false;
  String postId = Uuid().v4();

  TextEditingController discriptionTextEditingController =
      TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

  final picker = ImagePicker();

  Future captureImageWithCamera() async {
    Navigator.pop(context);
    final imageFile = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: 680,
      maxWidth: 970,
    );
    setState(() {
      _image = File(imageFile.path);
    });
  }

  Future imageFromGallery() async {
    Navigator.pop(context);
    final imageFile = await picker.getImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _image = File(imageFile.path);
    });
  }

  captureVideoWithCamera() async {
    Navigator.pop(context);
    final videoFile = await picker.getVideo(
      source: ImageSource.camera,
    );
    setState(() {
      _video = File(videoFile.path);
    });
  }

  videoFromGallery() async {
    Navigator.pop(context);
    final videoFile = await picker.getVideo(
      source: ImageSource.gallery,
    );
    setState(() {
      _video = File(videoFile.path);
    });
  }

  takeImage(mContext) {
    return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            title:
                Text("New Post", style: TextStyle(fontWeight: FontWeight.bold)),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  "Take a picture",
                  style: TextStyle(),
                ),
                onPressed: captureImageWithCamera,
              ),
              SimpleDialogOption(
                child: Text(
                  "Select from gallery",
                  style: TextStyle(),
                ),
                onPressed: imageFromGallery,
              ),
              SimpleDialogOption(
                child: Text(
                  "Cancel",
                  style: TextStyle(),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  takeVideo(mContext) {
    return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            title:
                Text("New Post", style: TextStyle(fontWeight: FontWeight.bold)),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  "Take a short video",
                  style: TextStyle(),
                ),
                onPressed: captureVideoWithCamera,
              ),
              SimpleDialogOption(
                child: Text(
                  "Select short video from gallery",
                  style: TextStyle(),
                ),
                onPressed: videoFromGallery,
              ),
              SimpleDialogOption(
                child: Text(
                  "Cancel",
                  style: TextStyle(),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  displayUploadScreen() {
    return Center(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.add_photo_alternate,
                  size: 100.0,
                  color: Colors.red,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9.0),
                    ),
                    child: Text(
                      "Upload Image",
                      style: TextStyle(fontSize: 15.0),
                    ),
                    onPressed: () => takeImage(context),
                  ),
                ),
              ],
            ),
            SizedBox(width: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.video_call,
                  size: 100.0,
                  color: Colors.red,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9.0),
                    ),
                    child: Text(
                      "Upload Video",
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                    onPressed: () => takeVideo(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  clearPostInfo() {
    locationTextEditingController.clear();
    discriptionTextEditingController.clear();

    setState(() {
      _image = null;
      uploading = false;
      postId = Uuid().v4();
    });
  }

  getCurrentLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark mPlacemark = placemark[0];
    String completeAddressInfo =
        '${mPlacemark.subThoroughfare} ${mPlacemark.thoroughfare}, ${mPlacemark.subLocality} ${mPlacemark.locality}, ${mPlacemark.subAdministrativeArea} ${mPlacemark.administrativeArea}, ${mPlacemark.postalCode} ${mPlacemark.country},';
    String specificAddress = '${mPlacemark.locality}, ${mPlacemark.country}';
    locationTextEditingController.text = specificAddress;
  }

  compressingPhoto() async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage(_image.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 60));
    setState(() {
      _image = compressedImageFile;
    });
  }

  controlUpload() async {
    setState(() {
      uploading = true;
    });
    await compressingPhoto();
    String downloadUrl = await uploadImage(_image);
    savePostIntoFireStore(
        url: downloadUrl,
        location: locationTextEditingController.text,
        discription: discriptionTextEditingController.text);

    locationTextEditingController.clear();
    discriptionTextEditingController.clear();

    setState(() {
      _image = null;
      uploading = false;
      postId = Uuid().v4();
    });
  }

  savePostIntoFireStore({String url, String location, String discription}) {
    postsReference
        .document(widget.gCurrentUser.id)
        .collection("usersPosts")
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.gCurrentUser.id,
      "timestamp": timestamp,
      "likes": {},
      "username": widget.gCurrentUser.username,
      "discription": discription,
      "location": location,
      "url": url,
    });
  }

  Future<String> uploadImage(mImage) async {
    StorageUploadTask mStorageUploadTask =
        storageReference.child("post_$postId.jpg").putFile(mImage);
    StorageTaskSnapshot storageTaskSnapshot =
        await mStorageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  displayUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        leading:
            IconButton(icon: Icon(Icons.arrow_back), onPressed: clearPostInfo),
        title: Text(
          "New Post",
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: uploading ? null : () => controlUpload(),
            child: Text(
              "Share",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          uploading ? linearProgress() : Text(""),
          Container(
            height: 230.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: FileImage(_image),
                    fit: BoxFit.cover,
                  )),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 12.0)),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.gCurrentUser.url),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.black),
                controller: discriptionTextEditingController,
                decoration: InputDecoration(
                  hintText: "Say something about image..",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.person_pin_circle,
              size: 36.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.black),
                controller: locationTextEditingController,
                decoration: InputDecoration(
                  hintText: "Write the location here..",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            height: 220.0,
            width: 110.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              onPressed: getCurrentLocation,
              icon: Icon(Icons.location_on),
              label: Text("Get my current location"),
              color: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35.0),
              ),
            ),
          )
        ],
      ),
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return _image == null ? displayUploadScreen() : displayUploadFormScreen();
  }
}
