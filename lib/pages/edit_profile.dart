import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user.dart';
import '../widgets/progress.dart';
import 'home.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffolfkey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  User user;

  bool _displayNameValid = true;
  bool _bioValid = true;

  File file;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });

    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();

    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;

    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Display Name",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayNameValid ? null : "DisplayName too short",
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Update Bio",
            errorText: _bioValid ? null : "Bio too long",
          ),
        )
      ],
    );
  }

  handlesubmitfile() async {
    String photoUrl;

    if (file == null) {
      photoUrl = user.photoUrl;
    } else {
      await compressImage();
      photoUrl = await uploadImage(file);

      //return photoUrl;

    }

    updateProfileData(photoUrl);
  }

  updateProfileData(String photoUrl) {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.trim().isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;

      bioController.text.trim().length > 200
          ? _bioValid = false
          : _bioValid = true;

      if (file != null) {
        usersRef.document(widget.currentUserId).updateData({
          "photoUrl": photoUrl,
        });

        SnackBar snackBar = SnackBar(
          content: Text("Profile updated!"),
        );
        _scaffolfkey.currentState.showSnackBar(snackBar);
      }

      if (_displayNameValid && _bioValid) {
        usersRef.document(widget.currentUserId).updateData({
          //"photoUrl": handlesubmitfile(),
          "displayName": displayNameController.text,
          "bio": bioController.text,
        });

        SnackBar snackBar = SnackBar(
          content: Text("Profile updated!"),
        );
        _scaffolfkey.currentState.showSnackBar(snackBar);
      }
    });
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  handleTakePhoto() async {
    final imagePicker = ImagePicker();

    Navigator.pop(context);
    final pickedFile = await imagePicker.getImage(
        source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
    final file = File(pickedFile.path);

    if (file != null) {
      setState(() {
        this.file = file;
      });
    }
  }

  handleChooseFromGallery() async {
    final imagePicker = ImagePicker();
    Navigator.pop(context);

    final pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    final file = File(pickedFile.path);

    if (file != null) {
      setState(() {
        this.file = file;
      });
    }
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());

    String currentUserId = currentUser.id;
    final compressedImageFile = File('$path/img_$currentUserId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));

    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    String currentUserId = currentUser.id;
    StorageUploadTask uploadTask =
        storageRef.child('profile_$currentUserId.jpg').putFile(imageFile);

    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;

    String downloadUrl = await storageSnap.ref.getDownloadURL();

    return downloadUrl;
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (parentContext) {
          return SimpleDialog(
            title: Text("Change your profile photo"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffolfkey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.done, size: 30.0, color: Colors.green),
          )
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: Stack(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 40.0,
                              backgroundImage: file == null
                                  ? NetworkImage(user.photoUrl)
                                  : FileImage(file),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(45.0),
                              child: IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  size: 30.0,
                                  color: Colors.grey[400],
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectImage(context);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            buildDisplayNameField(),
                            buildBioField(),
                          ],
                        ),
                      ),
                      RaisedButton(
                        onPressed: handlesubmitfile,
                        child: Text(
                          "Update Profile",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: FlatButton.icon(
                          onPressed: logout,
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                          label: Text(
                            "Log out",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
