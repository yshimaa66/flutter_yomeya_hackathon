import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutteryomeyahackathon/models/user.dart';
import 'package:flutteryomeyahackathon/pages/home.dart';
import 'package:flutteryomeyahackathon/pages/users_to_follow.dart';
import 'package:flutteryomeyahackathon/widgets/dailyworker.dart';
import 'package:flutteryomeyahackathon/widgets/header.dart';
import 'package:flutteryomeyahackathon/widgets/post.dart';
import 'package:flutteryomeyahackathon/widgets/post_tile.dart';
import 'package:flutteryomeyahackathon/widgets/progress.dart';
import 'package:slimy_card/slimy_card.dart';
import 'package:timeago/timeago.dart' as timeago;

final usersRef = Firestore.instance.collection("users");


class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {

  // List<dynamic> users = [];

  List<Post> usersPosts = [];
  List<User> users = [];
  List<dynamic> usersId = [];
  List<DailyWorker> dailyworkers = [];
  bool isFollowing = false;
  bool isLoading = false;
  List <DailyWorker> _searchResultdailyworkers = [];
  List <Post> _searchResultposts = [];

  bool repeatdailyworkersearch = true;

  TextEditingController searchcontrollerdailyworkers = new TextEditingController();
  TextEditingController searchcontrollerposts = new TextEditingController();

  @override
  void initState() {
    //getUsers();
    //getUserByID();
    //createUser();
    //updateUser();
    //deleteUser();

    getUsersPosts();

    getdailyworkers();

    super.initState();
  }


  getUsersPosts() async {

    usersPosts.clear();
    users.clear();

    setState(() {
      isLoading = true;
    });


    QuerySnapshot snapshotusersId = await usersRef.getDocuments();

    //var usersId = snapshotusersId.documents;

    users.addAll(snapshotusersId.documents.map((doc) => User.fromDocument(doc))
        .toList());

    //print(usersId.elementAt(0));

    for (var user in users) {
      QuerySnapshot snapshotPosts = await postsRef.document(user.id)
          .collection("userPosts")
          .orderBy("timestamp", descending: true)
          .getDocuments();

      usersPosts.addAll(
          snapshotPosts.documents.map((doc) => Post.fromDocument(doc))
              .toList());

      print(usersPosts);
    }

    usersPosts.sort((a, b) {
      Timestamp as = a.timestamp;
      Timestamp bs = b.timestamp;
      var adate = timeago.format(as.toDate());
      var bdate = timeago.format(bs.toDate());
      return bdate.compareTo(adate);
    });

    setState(() {
      isLoading = false;
    });


    /*if(doc.exists) {

    }*/

  }


  getdailyworkers() async {
    dailyworkers.clear();
    users.clear();

    setState(() {
      isLoading = true;
    });


    QuerySnapshot snapshotDailyWorkers = await dailyworkersRef.orderBy(
        "timestamp", descending: true).getDocuments();

    dailyworkers.addAll(snapshotDailyWorkers.documents.map((doc) =>
        DailyWorker.fromDocument(doc)).toList());

    print(dailyworkers);


    setState(() {
      isLoading = false;
    });
  }



  builddailyworkers(BuildContext context,
      List<DailyWorker> dailyworkerstobuild) {

    if (isLoading) {
      return circularProgress();
    }

    else if (dailyworkerstobuild.isEmpty) {
      return Container(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SvgPicture.asset(
                "assets/images/no_content.svg", height: 260.0,),
            ),


          ],
        ),

      );
    }

    else {
      return Column(

        children: dailyworkerstobuild,

      );
    }
  }


  onSearchTextChangedDailyWorker(String text) {


    _searchResultdailyworkers.clear();


    if (text.isEmpty) {
      setState(() {});
      return;
    }


      for (var dailyworker in dailyworkers) {
        if (dailyworker.location.toLowerCase().contains(text.toLowerCase()) ||
            dailyworker.experience.toLowerCase().contains(text.toLowerCase())) {
          print(dailyworker.dailyworker_id.toLowerCase() + "---->" +
              text.toLowerCase());

          setState(() {

            _searchResultdailyworkers.add(dailyworker);


          });

          print(_searchResultdailyworkers[0].dailyworker_id);


        }
      }




    setState(() {



    });


    }





    buildposts(BuildContext context, List<Post> poststobuild) {
      if (isLoading) {
        return circularProgress();
      }

      /*return Column(

      children:posts,

    );*/

      else if (poststobuild.isEmpty) {
        return Container(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SvgPicture.asset(
                  "assets/images/no_content.svg", height: 260.0,),
              ),


            ],
          ),

        );
      }

      else {
        return Column(

          children: poststobuild,

        );
      }
    }


    onSearchTextChangedPost(String text) async {
      _searchResultposts.clear();
      if (text.isEmpty) {
        setState(() {});
        return;
      }

      for (int i = 0; i < usersPosts.length; i++) {
        if (usersPosts[i].location.toLowerCase().contains(text.toLowerCase()) ||
            usersPosts[i].description.toLowerCase().contains(
                text.toLowerCase())) {
          _searchResultposts.add(usersPosts[i]);
        }
      }

      setState(() {});
    }





    Widget builddailyworkerswidget(){

      return Scaffold(
        body: RefreshIndicator(
          onRefresh: () =>
              getdailyworkers(),

          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: new Card(
                  child: new ListTile(
                    leading: new Icon(Icons.search),
                    title: new TextField(
                      controller: searchcontrollerdailyworkers,
                      decoration: new InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none),
                          onChanged: onSearchTextChangedDailyWorker,
                    ),
                    trailing: new IconButton(
                      icon: new Icon(Icons.cancel), onPressed: () {
                      searchcontrollerdailyworkers.clear();
                      onSearchTextChangedDailyWorker('');
                    },),
                  ),
                ),),

              new Expanded(
                child: _searchResultdailyworkers.length != 0 ||
                    searchcontrollerdailyworkers.text.isNotEmpty
                    ? new ListView(

                  children: <Widget>[

                    builddailyworkers(
                        context, _searchResultdailyworkers),

                  ],
                )


                    :
                new ListView(
                  children: <Widget>[
                    builddailyworkers(context, dailyworkers),
                  ],
                ),)
            ],

          ),
        ),
      );


    }




    Widget buildpostswidget(){

    return Scaffold(

      body: RefreshIndicator(
        onRefresh: () =>
            getUsersPosts(),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: new Card(
                child: new ListTile(
                  leading: new Icon(Icons.search),
                  title: new TextField(
                    controller: searchcontrollerposts,
                    decoration: new InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none),
                    onChanged: onSearchTextChangedPost,
                  ),
                  trailing: new IconButton(
                    icon: new Icon(Icons.cancel), onPressed: () {
                    searchcontrollerposts.clear();
                    onSearchTextChangedPost('');
                  },),
                ),
              ),),

            new Expanded(
              child: _searchResultposts.length != 0 ||
                  searchcontrollerposts.text.isNotEmpty
                  ? new ListView(

                children: <Widget>[
                  buildposts(context, _searchResultposts),

                ],
              )


                  :
              new ListView(
                children: <Widget>[
                  buildposts(context, usersPosts),
                ],
              ),)
          ],

        ),
      ),
    );








    }






    @override
    Widget build(BuildContext context) {
      return Scaffold(
        //appBar: header(context, isApptitle: true),
        body: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: TabBar(
                    unselectedLabelColor: Theme
                        .of(context)
                        .primaryColor,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Theme
                                .of(context)
                                .primaryColor, Theme
                                .of(context)
                                .accentColor
                            ]),
                        borderRadius: BorderRadius.circular(50),
                        color: Theme
                            .of(context)
                            .primaryColor),
                    tabs: [
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Icon(Icons.person),
                        ),
                      ),

                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Icon(Icons.work),
                        ),
                      ),
                    ]),
                body: TabBarView(children: [

                  builddailyworkerswidget(),
                  buildpostswidget(),

                ]),
              ),
            )
        ),

        /*child: ListView(
          children: <Widget>[
            buildProfilePosts(context),
          ],
        ),*/


      );
    }
  }



