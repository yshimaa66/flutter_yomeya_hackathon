import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";

import '../models/user.dart';
import '../widgets/header.dart';
import '../widgets/progress.dart';
import 'activity_feed.dart';
import 'home.dart';

class UsersToFollow extends StatefulWidget {
  @override
  _UsersToFollowState createState() => _UsersToFollowState();

  // eh elfr2 ?? kda static m4 hy3mel define lel variables kol mara grby run

}

class _UsersToFollowState extends State<UsersToFollow> {
  List<dynamic> users = [];
  List<UsersToFollowResult> usersToFollowList = [];
  bool isLoading = false;

  @override
  void initState() {
    //getUsers();
    //getUserByID();
    //createUser();
    //updateUser();
    //deleteUser();

    handleuserstofollow();

    super.initState();
  }

  handleuserstofollow() async {
    users.clear();
    usersToFollowList.clear();

    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshotusers = await usersRef
        .orderBy("timestamp", descending: true)
        .limit(50)
        .getDocuments();

    users.addAll(
        snapshotusers.documents.map((doc) => User.fromDocument(doc)).toList());

    print(users.length);

    for (var user in users) {
      if (user.id != currentUser.id) {
        UsersToFollowResult usersToFollowResult = UsersToFollowResult(user);
        //searchResults.add(Text(user.username));
        usersToFollowList.add(usersToFollowResult);
      }
    }

    print(usersToFollowList.length);

    //return users_to_follow_result;

    setState(() {
      isLoading = false;
    });
  }

/*
for(User user in users){

      Users_to_follow_Result users_to_follow_result = Users_to_follow_Result();
      //searchResults.add(Text(user.username));
      users_to_follow_result.add(user);

    }
 */

  buildUsersToFollowResults(context) {
    if (isLoading) {
      return circularProgress();
    } else if (usersToFollowList.isEmpty) {
      return Text("");
    } else {
      print(usersToFollowList.length);
      return ListView(
        children: usersToFollowList,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titletext: "User to follow"),
      body: buildUsersToFollowResults(context),
    );
  }
}

class UsersToFollowResult extends StatelessWidget {
  final User user;

  UsersToFollowResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.username,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(user.email, style: TextStyle(color: Colors.white)),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          )
        ],
      ),
    );
  }
}
