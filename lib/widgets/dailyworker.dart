import 'dart:async';
import 'dart:math';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutteryomeyahackathon/models/user.dart';
import 'package:flutteryomeyahackathon/pages/activity_feed.dart';
import 'package:flutteryomeyahackathon/pages/comments.dart';
import 'package:flutteryomeyahackathon/pages/home.dart';
import 'package:flutteryomeyahackathon/widgets/custom_image.dart';
import 'package:flutteryomeyahackathon/widgets/progress.dart';
import 'package:sk_onboarding_screen/sk_onboarding_model.dart';
import 'package:sk_onboarding_screen/sk_onboarding_screen.dart';
import 'package:slimy_card/slimy_card.dart';
import 'package:timeago/timeago.dart' as timeago;

class DailyWorker extends StatefulWidget {



  final String dailyworker_id;
  final String supervisor_id;
  final String name;
  final String phone_number;
  final String anotherphone_number;
  final dynamic mediaUrl;
  final String location;
  final String experience;
  final String wageforhour;
  final String wageforday;
  final Timestamp timestamp;


  DailyWorker({this.dailyworker_id, this.supervisor_id, this.name, this.phone_number,
    this.location, this.anotherphone_number,
    this.mediaUrl, this.wageforhour, this.wageforday, this.experience, this.timestamp});


  /*var colorlist = [Colors.deepPurple.withOpacity(.5),Colors.deepOrange.withOpacity(.5)
    ,Colors.blue.withOpacity(.5),Colors.green.withOpacity(.5),Colors.yellow.withOpacity(.5)];*/

  var colorlist = [Colors.deepOrange.withOpacity(.5)];

  final _random = new Random();


  factory DailyWorker.fromDocument(DocumentSnapshot doc)
  {
    return DailyWorker(



      dailyworker_id: doc['dailyworker_id'],
      supervisor_id: doc['supervisor_id'],
      name: doc['name'],
      phone_number: doc['phone_number'],
      anotherphone_number: doc['anotherphone_number'],
      mediaUrl: doc['mediaUrl'],
      wageforhour: doc['wageforhour'],
      wageforday: doc['wageforday'],
      location: doc['location'],
      experience: doc['experience'],
      timestamp: doc['timestamp'],

    );


  }



  @override
  _DailyWorkerState createState() => _DailyWorkerState(

    dailyworker_id: this.dailyworker_id,
    supervisor_id: this.supervisor_id,
    name:this.name,
    phone_number:this.phone_number,
    anotherphone_number:this.anotherphone_number,
    mediaUrl:this.mediaUrl,
    location:this.location,
    experience:this.experience,
    wageforhour:this.wageforhour,
    wageforday:this.wageforday,
    timestamp:this.timestamp,


  );


}


class _DailyWorkerState extends State<DailyWorker> {

  

  final String dailyworker_id;
  final String supervisor_id;
  final String name;
  final String phone_number;
  final String anotherphone_number;
  final dynamic mediaUrl;
  final String location;
  final String experience;
  final String wageforhour;
  final String wageforday;
  Timestamp timestamp;
  int i =0;



  _DailyWorkerState({this.dailyworker_id, this.supervisor_id,
      this.name, this.phone_number, this.anotherphone_number, this.mediaUrl, this.location,
      this.experience, this.wageforhour, this.wageforday,this.timestamp});





  builderCoworkingSpaceImage(int i){





    return Center(

        child: Container(
          height: 200.0,
          child: GestureDetector(

              child: Stack(

                alignment: Alignment.center,
                children: <Widget>[

                  circularProgress(),
                  Image.network(mediaUrl[i]),
                ],

              )

          ),
        ),

    );

  }


  List<String> imagesfiles =[];


  Widget buildImagesIcons(int i){

    IconButton(
      icon: Icon(Icons.crop_square,color: Colors.white ,size: 40.0,),
      onPressed: ()=>  builderCoworkingSpaceImage(i));

  }


  Widget buildCardTop(BuildContext context) {

      return Stack(
        children: <Widget>[
          builderCoworkingSpaceImage(i),

          Padding(
            padding: const EdgeInsets.only(top: 220),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, position) {
                      return IconButton(
                          icon: Icon(Icons.crop_square,color: Colors.white ,size: 20.0,),
                          onPressed: (){

                            print(position);
                            setState(() {
                            i=position;
                            });

                          }

                      );
                    },
                    itemCount: mediaUrl.length,
                  ),
                ),
              ],
            ),
          ),

        ],
      );







  }



  @override
  Widget build(BuildContext context) {

    var element = widget.colorlist[widget._random.nextInt(widget.colorlist.length)];


    print(dailyworker_id);



    return Container(

      color: Theme.of(context).primaryColor.withOpacity(0.2),
      child: Column(
        children: <Widget>[
          GestureDetector(

            onTap: () => print(dailyworker_id),

            child:
            StreamBuilder(
              initialData: false,
              stream: slimyCard.stream, //Stream of SlimyCard
              builder: ((BuildContext context, AsyncSnapshot snapshot) {
                return Stack(
                  children: <Widget>[
                    SlimyCard(
                      color: element,
                      width: 500,
                      topCardHeight: 400,
                      bottomCardHeight: 200,
                      borderRadius: 15,
                      topCardWidget: Container(
                        height:350,
                        child: Column(
                            children: <Widget>[
                          Text(name,style: TextStyle(fontSize: 50,color: Colors.black26,fontWeight: FontWeight.bold,fontFamily: "Signatra" ),),
                          Container(
                              height:250,

                              child: Stack(
                                  children: <Widget>[

                                    imageProgress(),

                                  Swiper(
                                itemBuilder: (BuildContext context, int index) {
                                  return new Image.network(
                                    mediaUrl[index],
                                    fit: BoxFit.fill,
                                  );
                                },
                                autoplay: true,
                                itemCount: mediaUrl.length,
                                scrollDirection: Axis.vertical,
                                pagination: new SwiperPagination(alignment: Alignment.centerRight),
                                control: new SwiperControl(),
                              )

                              ]),
                          )


                            ]),
                      ),
                      bottomCardWidget: Column(children: <Widget>[

                        Row(
                          children: <Widget>[
                            Icon(Icons.phone, color: Colors.white, size: 15.0,),
                            SizedBox(width:5),
                            Column(
                              children: <Widget>[
                                Text(phone_number,style:TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold)),
                                anotherphone_number!=""?
                                Text(anotherphone_number,
                                    style:TextStyle(fontSize: 15,color: Colors.white,
                                        fontWeight: FontWeight.bold)):Text(""),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Icon(Icons.attach_money, color: Colors.white, size: 15.0,),
                            SizedBox(width:5),
                            Text("Wage per hour : "+wageforhour+" EGP",style:TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Icon(Icons.monetization_on, color: Colors.white, size: 15.0,),
                            SizedBox(width:5),
                            Text("Wage per day : "+wageforday+" EGP",style:TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Icon(Icons.location_on, color: Colors.white, size: 15.0,),
                            SizedBox(width:5),
                            Text(location,style:TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Icon(Icons.description, color: Colors.white, size: 15.0,),
                            SizedBox(width:5),
                            Text(experience,style:TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold)),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Row(
                              mainAxisSize:MainAxisSize.min,
                              children: <Widget>[

                                RaisedButton(
                                  color: Colors.black26,
                                  onPressed: () => print(""),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),

                                  ),
                                  child:
                                      Icon(Icons.phone
                                        ,color: Colors.green,
                                      ),


                                ),


                                SizedBox(width: 5.0,),

                                RaisedButton(
                                  color: Colors.black26,
                                  onPressed: () => print(""),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),

                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text("Contact Supervisor"
                                        ,style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.0
                                        ),
                                      ),
                                    ],
                                  ),

                                ),
                              ],
                            ),
                          ),
                        ),

                      ],
                      ),
                      slimeEnabled: true,
                    ),
                  ],
                );
              }),
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
