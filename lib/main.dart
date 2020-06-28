import 'package:flutter/material.dart';
import 'package:flutteryomeyahackathon/pages/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() {

  //firestore.instance.settings(timestampsInSnapshotsEnabled:true).then((value) => null);

  runApp(MyApp());
}



class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterShare',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(

        primarySwatch: Colors.green,//primryColor
        accentColor: Colors.teal,

      ),

      home: Home(),
    );
  }
}

