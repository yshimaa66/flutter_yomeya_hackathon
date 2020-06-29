import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../models/user.dart';
import '../widgets/header.dart';
import '../widgets/post.dart';
import '../widgets/post_tile.dart';
import '../widgets/progress.dart';
import 'edit_profile.dart';
import 'home.dart';

class Profile extends StatefulWidget {

  final String profileId;

  Profile({this.profileId});


  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final String currentUserId = currentUser?.id;

  bool isFollowing = false;

  bool isLoading =false;

  String postOrientation = "grid";

  int postCount=0;
  int followerCount=0;
  int followingCount=0;

  List <Post> posts = [];

  @override
  void initState(){

    super.initState();

    getProfilePosts();

    getFollowers();

    getFollowing();

    checkIfFollowing();

  }


  checkIfFollowing() async {

    DocumentSnapshot doc = await followersRef.document(widget.profileId)
        .collection("userFollowers").document(currentUserId).get();

    setState(() {
      isFollowing = doc.exists;
    });

  }

  getFollowers() async{

    QuerySnapshot snapshot = await followersRef.document(widget.profileId)
        .collection("userFollowers").getDocuments();

    setState(() {
      followerCount=snapshot.documents.length;
    });

  }

  getFollowing()async{
    QuerySnapshot snapshot = await followingRef.document(widget.profileId)
        .collection("userFollowing").getDocuments();

    setState(() {
      followingCount=snapshot.documents.length;
    });
  }

  getProfilePosts() async {


    setState(() {

      isLoading = true;

    });

    QuerySnapshot snapshot =
    await postsRef.document(widget.profileId).collection("userPosts").orderBy("timestamp",descending: true).getDocuments();

    setState(() {

      isLoading = false;
      postCount = snapshot.documents.length;
      posts= snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();

    });

  }




 /* String currentUserId;

   void getUserId() async {
     final FirebaseAuth auth = FirebaseAuth.instance;

     final FirebaseUser user = await auth.currentUser();

    final String uid = user.uid;

    currentUserId = uid;
    // here you write the codes to input the data into firestore
  }*/





  buildCountColumn(String label, int count){

    return Column(

      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(color:Colors.grey,fontSize: 15.0, fontWeight: FontWeight.w400),
          ),
        )

      ],

    );


  }

  Container buildButton({String text, Function function}){

    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 200.0,
          height: 26.0,
          child: Text(
            text,
            style: TextStyle(
                 color: isFollowing ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            border: Border.all(color: isFollowing ? Colors.grey : Colors.blue),
            borderRadius: BorderRadius.circular(5.0),
          ),


        ),

      ),



    );


  }

  editProfile(){

    Navigator.push(context,MaterialPageRoute(
       builder: (context) => EditProfile(currentUserId:currentUserId)
    ));


  }

  buildProfileButton(){

     //return Text("profile button");

    bool isProfileOwner = currentUserId == widget.profileId;
    if(isProfileOwner){

      return buildButton(
        text: "Edit Profile",
        function: editProfile,
      );

    }else if(isFollowing){

      return buildButton(
        text: "Unfollow",
        function: handleUnfollowUser,
      );

    }

    else if(!isFollowing){

      return buildButton(
        text: "Follow",
        function: handleFollowUser,
      );

    }

  }


  handleFollowUser(){


    setState(() {

      isFollowing=true;


    });

    followersRef.document(widget.profileId).collection("userFollowers").document(currentUserId).setData({});

    followingRef.document(currentUserId).collection("userFollowing").document(widget.profileId).setData({});

    activityFeedRef.document(widget.profileId)
        .collection("feedItems").document(currentUserId)
        .setData({

      "type": "follow",
      "username": currentUser.username,
      "ownerId": widget.profileId,
      "userId": currentUser.id,
      "userProfileImg": currentUser.photoUrl,
      "timestamp": timestamp,

    });

  }


  handleUnfollowUser(){

    setState(() {

      isFollowing=false;


    });

    followersRef.document(widget.profileId).collection("userFollowers")
        .document(currentUserId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    followingRef.document(currentUserId).collection("userFollowing")
        .document(widget.profileId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    activityFeedRef.document(widget.profileId)
        .collection("feedItems").document(currentUserId)
        .get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });


  }




  buildProfileHeader(){

    return FutureBuilder(

      future: usersRef.document(widget.profileId).get(),

      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(

          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[

              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(user.photoUrl),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn("posts", postCount),
                            buildCountColumn("followers",followerCount),
                            buildCountColumn("following",followingCount),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[

                            buildProfileButton(),

                          ],

                        )
                      ],
                    ),
                  )
                ],
              ),

              Container(

                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.username
                 ,style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),

                ),

              ),

              Container(

                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  user.displayName
                  ,style: TextStyle(fontWeight: FontWeight.bold),

                ),

              ),

              Container(

                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 2.0),
                child: Text(
                  user.bio
                ),

              )

            ],
          ),
          
        );

      },

    );

  }



  buildProfilePosts(){

    if(isLoading){

      return circularProgress();
    }

    /*return Column(

      children:posts,

    );*/


    else if(posts.isEmpty){


      return Container(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center ,
          children: <Widget>[

            SvgPicture.asset("assets/images/no_content.svg", height: 260.0,),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
                child: Text("No Posts"
                  ,style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                  ),
                ),

              ),
          ],
        ),

      );



    }


    else if(postOrientation == "grid"){

      List<GridTile> grideTiles=[];

      posts.forEach((post) {

        grideTiles.add(GridTile(child: PostTile(post)));

      });

      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: grideTiles,
      );

    }
    else if(postOrientation == "list"){

      return Column(

        children:posts,

      );

    }

    
  }


  setPostOrientation(String postOrientation){

    setState(() {

      this.postOrientation=postOrientation;

    });

  }


  buildTogglePostOrientation(){


    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setPostOrientation("grid"),
            icon:Icon(Icons.grid_on),
            color: postOrientation == "grid" ? Theme.of(context).primaryColor : Colors.grey,

        ),
        IconButton(
          onPressed: () => setPostOrientation("list"),
            icon:Icon(Icons.list),
            color: postOrientation == "list" ? Theme.of(context).primaryColor : Colors.grey,

        ),
      ],
    );


  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titletext: "Profile"),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(),
          buildTogglePostOrientation(),
          Divider(
            height: 0.0,
          ),
          buildProfilePosts(),
        ],
      ),

    );
  }
}
