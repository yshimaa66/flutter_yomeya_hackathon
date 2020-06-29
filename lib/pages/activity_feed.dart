import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../widgets/header.dart';
import '../widgets/progress.dart';
import 'home.dart';
import 'post_screen.dart';
import 'profile.dart';

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}



class _ActivityFeedState extends State<ActivityFeed> {


  getActivityFeed()async{

    QuerySnapshot snapshot = await activityFeedRef.document(currentUser.id)
        .collection("feedItems").orderBy("timestamp",descending: true).limit(50).getDocuments();


    List<ActivityFeedItem> feedItems = [];
    snapshot.documents.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
      //print("Activity Feed Item: ${doc.data}");
    });
    
    return feedItems;

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.grey,
      appBar: header(context, titletext:"Activity Feed"),
      body: Container(

        child: FutureBuilder(
          future: getActivityFeed(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return circularProgress();
      }
      return ListView(
        children: snapshot.data,
      );
    }),

      ),

    );
  }
}


Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {

  final String username;
  final String userId;
  final String type;
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;

  ActivityFeedItem({this.username, this.userId, this.type, this.mediaUrl,
    this.postId, this.userProfileImg, this.commentData, this.timestamp});

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc){

    return ActivityFeedItem(

      username: doc['username'],
      userId: doc['userId'],
      type: doc['type'],
      mediaUrl: doc['mediaUrl'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'],

    );

  }


  showPost(context){

    Navigator.push(context, MaterialPageRoute(builder: (context) =>
        PostScreen(postId: postId, userId: userId,)));


  }

  configureMediaPreview(context){

    if(type == "like" || type == "comment"){

      mediaPreview = GestureDetector(

        onTap: () => showPost(context),

        child: Container(

          height: 50.0,
          width: 50.0,

          child: AspectRatio(

            aspectRatio: 16/9,

            child: Container(

              decoration: BoxDecoration(

                image: DecorationImage(

                  fit: BoxFit.cover,
                  image: NetworkImage(mediaUrl),

                )

              ),

            ),

          ),


        ),

      );


    }

    else{

      mediaPreview=Text('');

    }


    if(type == "like"){


      activityItemText=" liked your post";

    }

    else if(type == "follow"){


      activityItemText=" is following you";

    }

    else if(type == "comment"){


      activityItemText=" commented on your post '$commentData'";

    }


  }


  @override
  Widget build(BuildContext context) {

    configureMediaPreview(context);

    return Padding(
      padding: const EdgeInsets.only(bottom:2.0),
      child: Container(

        color: Colors.white54,

        child: ListTile(

          title: GestureDetector(

            onTap: () => showProfile(context, profileId: userId),

            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: activityItemText,
                  ),

                ]

              ),

            ),

          ),

         leading: GestureDetector(
           onTap: () => showProfile(context, profileId: userId),
           child: CircleAvatar(
             backgroundImage: NetworkImage(userProfileImg),
           ),
         ),

          subtitle: Text(timeago.format(timestamp.toDate()),overflow: TextOverflow.ellipsis,),

          trailing: mediaPreview,
        ),



      ),
    );
  }
}

showProfile(BuildContext context, {String profileId}){

  Navigator.push(context, MaterialPageRoute(builder: (context) =>
      Profile(profileId:profileId)));

}