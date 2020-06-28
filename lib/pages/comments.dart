import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutteryomeyahackathon/pages/home.dart';
import 'package:flutteryomeyahackathon/widgets/header.dart';
import 'package:flutteryomeyahackathon/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {


  final String postId;
  final String postownerId;
  final String postmediaUrl;

  Comments({this.postId, this.postownerId, this.postmediaUrl}) ;

  @override
  CommentsState createState() => CommentsState(

      postId : this.postId,
      postownerId : this.postownerId,
      postmediaUrl : this.postmediaUrl,

  );

}

class CommentsState extends State<Comments> {

  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postownerId;
  final String postmediaUrl;

  CommentsState({this.postId, this.postownerId, this.postmediaUrl}) ;




  buildComments(){

  return StreamBuilder(
    stream: commentsRef.document(postId)
        .collection("comments")
        .orderBy("timestamp",descending: false).snapshots(),

      builder: (context, snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }

        List<Comment> comments =[];
        snapshot.data.documents.forEach((doc){

          comments.add(Comment.fromDocument(doc));

        });

        return ListView(children: comments,);

      }

  );



  }


  addComment(){

    commentsRef
       .document(postId)
        .collection("comments")
        .add({
        "username": currentUser.username,
        "comment": commentController.text,
         "timestamp": timestamp,
          "avatarUrl":currentUser.photoUrl,
          "userId": currentUser.id,
    });

    addCommentToActivityFeed();

    commentController.clear();

  }


  addCommentToActivityFeed(){

    bool isNotPostOwner = currentUser.id != postownerId;

    if(isNotPostOwner) {
      activityFeedRef.document(postownerId)
          .collection("feedItems").document(postId)
          .setData({

        "type": "comment",
        "commentData":commentController.text,
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": postId,
        "mediaUrl": postmediaUrl,
        "timestamp": timestamp,

      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titletext: "Comments"),
      body: Column(

        children: <Widget>[

          Expanded(child: buildComments(),),
          Divider(),
          ListTile(

            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(labelText: "Write a comment ..."),
            ),

            trailing: OutlineButton(

              onPressed: addComment,
              borderSide: BorderSide.none,
              child: Text("Post"),

            ),
          )

        ],

      ),
    );
  }
}

class Comment extends StatelessWidget {

  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comment({ this.username, this.userId, this.avatarUrl, this.comment, this.timestamp});

  // ignore: missing_return
  factory Comment.fromDocument(DocumentSnapshot doc){

    return Comment(

      username: doc['username'],
      userId: doc['userId'],
      avatarUrl: doc['avatarUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],

    );

  }

  @override
  Widget build(BuildContext context) {
    return Column(

      children: <Widget>[


        ListTile(

          title: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right:3.0),
                child: Text(username,style: TextStyle(fontSize: 12.0,fontWeight: FontWeight.bold),),
              ),
              Text(comment),
            ],
          ),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        Divider(),

      ],

    );
  }
}
