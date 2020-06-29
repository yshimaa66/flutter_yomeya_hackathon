import 'package:flutter/material.dart';
import 'package:flutteryomeyahackathon/pages/timeline.dart';

import 'pages/home.dart';


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

      home: Timeline(),
    );
  }
}

