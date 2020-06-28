import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dropdown.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutteryomeyahackathon/models/user.dart';
import 'package:flutteryomeyahackathon/pages/home.dart';
import 'package:flutteryomeyahackathon/pages/timeline.dart';
import 'package:flutteryomeyahackathon/widgets/progress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;

import 'package:uuid/uuid.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



List <File> postFiles = [];
List<Show_Image> show_Image =[];

class Upload extends StatefulWidget {

  User currentUser;




  bool goToCreatePost = false;
  bool goToAddDailyWorker = false;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {

  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController wageforhourController = TextEditingController();
  TextEditingController wagefordayController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController anotherphoneController= TextEditingController();
  TextEditingController experienceController = TextEditingController();


  String countryCode,anothercountryCode;

  LocationResult _pickedLocation;

  File file;

  int i =0;

  bool isUploading = false;
  String postid = Uuid().v4();

  String dailyworkerid = Uuid().v4();





  handleTakePhoto() async{

    Navigator.pop(context);
    // ignore: deprecated_member_use
    File file = await ImagePicker.pickImage(source: ImageSource.camera
    ,maxHeight: 675
    ,maxWidth: 960);

    if(file !=null) {


      setState(() {

        this.file = file;
        Show_Image show_image = Show_Image(file);
        show_Image.add(show_image);
        postFiles.add(file);

      });


    }


  }

  handleChooseFromGallery() async{

    Navigator.pop(context);

    // ignore: deprecated_member_use
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(file !=null) {
      setState(() {
        this.file = file;
        Show_Image show_image = Show_Image(file);
        show_Image.add(show_image);
        postFiles.add(file);


      });
    }

  }

  SelectImage(parentContext){

    return showDialog(context: parentContext ,

    builder: (parentContext){

      return SimpleDialog(

        title: Text("Create Post"),
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

  Container buildSplashScreen() {

    return Container(
      color: Colors.white,

      child: Column(
      mainAxisAlignment: MainAxisAlignment.center ,
        children: <Widget>[

          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  Text("Choose what do you want to create ", style: TextStyle(fontWeight: FontWeight.bold, color:Theme.of(context).primaryColor ),),
                  Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.person),
                                color: Theme.of(context).primaryColor,
                                iconSize: 40.0,
                                onPressed: () {
                                  setState(() {
                                    if(file != null && postFiles.length>0){
                                      widget.goToAddDailyWorker = true;}
                                    else{

                                      Scaffold.of(context).showSnackBar(new SnackBar(
                                          content: new Text('You need to upload a photo')));

                                    }
                                  });
                                },
                              ),
                              SizedBox(width:20.0),
                              IconButton(
                                icon: Icon(Icons.work),
                                color: Theme.of(context).primaryColor,
                                iconSize: 40.0,
                                onPressed: () {
                                  setState(() {
                                    if(file != null && postFiles.length>0){
                                      widget.goToCreatePost = true;}
                                    else{

                                      Scaffold.of(context).showSnackBar(new SnackBar(
                                          content: new Text('You need to upload a photo')));

                                    }
                                  });
                                },
                              ),


                            ],

                        ),
                ],
              ),
            ),

            ),

          SvgPicture.asset("assets/images/upload.svg", height: 260.0,),
          Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: RaisedButton(
              color: Theme.of(context).primaryColor,
              onPressed: () => SelectImage(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),

              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Upload Image"
                  ,style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0
                    ),
                  ),
                ],
              ),

            ),
          ),


          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: show_Image,
              )
          )

        ],
      ),

    );

  }


  clearImage(){

    setState(() {
      file = null;
      postFiles.clear();
      show_Image.clear();
    });

  }


  compressImage() async{

    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    int i=0;
    for(var file in postFiles) {
      Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());

      final compressedImageFile = File('$path/img_$postid'+'_'+'$i.jpg')
        ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));

      setState(() {
        file = compressedImageFile;
        postFiles.removeAt(i);
        postFiles.insert(i, file);
      });

      i++;
    }
  }

  Future<String> uploadImage(imageFile,i) async{


    StorageUploadTask uploadTask = storageRef.child('post_$postid'+'_'+'$i.jpg').putFile(imageFile);

    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;

    String downloadUrl = await storageSnap.ref.getDownloadURL();

    return downloadUrl;


  }

  createPostInFirebase({List <String> mediaUrl, String location, String description}){


    postsRef.document(widget.currentUser.id)
        .collection("userPosts")
        .document(postid)
        .setData({

         "postId": postid,
          "ownerId":widget.currentUser.id,
      "username":widget.currentUser.username,
      "mediaUrl":mediaUrl,
      "description":description,
      "location":location,
      "timestamp":timestamp,
      "likes":{},

    });

    clearImage();

    Navigator.push(context,MaterialPageRoute(
        builder: (context) => Home()
    ));


  }


  createDailyWorkerInFirebase({List <String> mediaUrl, String name, String experience, String phone,
    String anotherphone, String wageforhour, String wageforday, String location}){


    dailyworkersRef
        .document(dailyworkerid)
        .setData({

      'dailyworker_id':dailyworkerid,
      'supervisor_id':widget.currentUser.id,
      'name':name,
      'phone_number':phone,
      'anotherphone_number':anotherphone,
      'wageforhour':wageforhour,
      'wageforday':wageforday,
      "mediaUrl":mediaUrl,
      "experience":experience,
      "location":location,
      "timestamp":timestamp,
      "experience":experience,


    });

    clearImage();

    Navigator.push(context,MaterialPageRoute(
        builder: (context) => Home()
    ));


  }



  handleSubmit() async {

    setState(() {
      isUploading = true;
    });

    await compressImage();
    List <String> imageUrl = [];
    int i=0;
    for(var file in postFiles) {
      imageUrl.add(await uploadImage(file,i));
      i++;
      }


      createPostInFirebase(mediaUrl: imageUrl,
          location: locationController.text,
          description: captionController.text);
      locationController.clear();
      captionController.clear();

    setState(() {
      //file = null;
      isUploading = false;
      postid = Uuid().v4();
    });

  }






  handleDailyWorkerSubmit() async {

    setState(() {
      isUploading = true;
    });

    await compressImage();
    List <String> imageUrl = [];
    int i=0;
    for(var file in postFiles) {
      imageUrl.add(await uploadImage(file,i));
      i++;
    }


    if(countryCode==null){
      countryCode="+20";

    }
    if(anothercountryCode==null){
      anothercountryCode="+20";
    }

    if(locationController.text.isNotEmpty &&
    phoneController.text.isNotEmpty &&
    wageforhourController.text.isNotEmpty &&
    wagefordayController.text.isNotEmpty &&
    experienceController.text.isNotEmpty&&
        locationController.text.isNotEmpty){

    createDailyWorkerInFirebase(mediaUrl: imageUrl,
        name: nameController.text,
        phone: countryCode+phoneController.text,
        anotherphone: anotherphoneController.text.isNotEmpty?anothercountryCode+anotherphoneController.text:"",
        wageforday: wagefordayController.text,
        wageforhour: wageforhourController.text,
        experience: experienceController.text,
        location: locationController.text);
    locationController.clear();
    captionController.clear();
    nameController.clear();
    phoneController.clear();
    anotherphoneController.clear();
    wageforhourController.clear();
    wagefordayController.clear();
    experienceController.clear();

    setState(() {
      //file = null;
      isUploading = false;
      dailyworkerid = Uuid().v4();
    });

    }

    else{

      Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text('You need to fill out all fields')));

    }






  }




  builderPostImage(int index){

    return GestureDetector(
      child:Container(
      decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: FileImage(postFiles[index]),
          )
      ),

    ),);


  }

  Scaffold buildPostForm(){

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
          color: Colors.black),
          onPressed: (){setState(() {

           widget.goToCreatePost=false;

           });
          }),
        title: Text("Create a Job Post"
        ,style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: Text("Post"
            ,style: TextStyle(
                  color: Colors.blueAccent
              ,fontWeight: FontWeight.bold
              ,fontSize: 20.0),),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Padding(
                  padding: EdgeInsets.only(top : 10.0),
                  child: GestureDetector(
                    child: Stack( children:<Widget>[

                      builderPostImage(i),

                      IconButton(
                        icon: Icon(Icons.swap_horizontal_circle,color: Colors.white ,size: 40.0,),
                        onPressed: (){
                          if(i==postFiles.length-1){
                            setState(() {
                              i=0;
                            });
                          }else{
                            setState(() {
                              i++;
                            });

                          }

                        },
                      ),

                    ]
                    ),
                  ),

                ),

              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(

            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.currentUser.photoUrl),
            ),

            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Write what you need to be done ...",
                  border: InputBorder.none
                ),
              ),
            ),

          ),
          Divider(),

          ListTile(

            leading: Icon(Icons.pin_drop, color: Colors.green, size: 35.0,),

            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                    hintText: "Where do you need this job ?",
                    border: InputBorder.none
                ),
              ),
            ),

          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
                onPressed: getUserLocation,
                icon: Icon(Icons.my_location, color: Colors.white),
                color: Colors.blue,
                label: Text("Use Current Location"
                ,style: TextStyle(color: Colors.white),),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)
                ),

            ),
          )
        ],
      ) ,
    );

  }

  getUserLocation() async{
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks= await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String name = placemark.name;
    String subLocality = placemark.subLocality;
    String locality = placemark.locality;
    String administrativeArea = placemark.administrativeArea;
    String postalCode = placemark.postalCode;
    String country = placemark.country;
    String address = "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";
    String formattedaddress = "${locality}, ${country}";
    print(address);
    locationController.text=formattedaddress;

  }


  getCoworkingSpaceLocation() async{
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks= await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String name = placemark.name;
    String subLocality = placemark.subLocality;
    String locality = placemark.locality;
    String administrativeArea = placemark.administrativeArea;
    String postalCode = placemark.postalCode;
    String country = placemark.country;
    String address = "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";
    locationController.text=address;
  }


  Widget _buildDropdownItem(Country country) => Container(
    child: Container(
      width: 50.0,
      child: Row(
        children: <Widget>[
          Container(width: 30.0,
              child: CountryPickerUtils.getDefaultFlagImage(country)),
          SizedBox(
            width: 3.0,
          ),
        ],
      ),
    ),
  );




  Scaffold buildCoworkingSpaceForm(){


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.black),
          onPressed: (){

            setState(() {

              widget.goToAddDailyWorker=false;

            });

          }),
        title: Text("Add Daily Worker"
          ,style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: isUploading ? null : () => handleDailyWorkerSubmit(),
            child: Text("Add"
              ,style: TextStyle(
                  color: Colors.blueAccent
                  ,fontWeight: FontWeight.bold
                  ,fontSize: 20.0),),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          postFiles.isNotEmpty?Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Padding(
                  padding: EdgeInsets.only(top : 10.0),
                  child: GestureDetector(
                    child: Stack( children:<Widget>[

                      builderPostImage(i),

                      IconButton(
                        icon: Icon(Icons.swap_horizontal_circle,color: Colors.white ,size: 40.0,),
                        onPressed: (){
                          if(i==postFiles.length-1){
                            setState(() {
                              i=0;
                            });
                          }else{
                            setState(() {
                              i++;
                            });

                          }

                        },
                      ),

                    ]
                    ),
                  ),

                ),

              ),
            ),
          ):Text(""),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(

            leading: Icon(Icons.contacts, color: Colors.green, size: 35.0,),

            title: Container(
              width: 250.0,
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                    hintText: "Daily Worker name ...",
                    border: InputBorder.none
                ),
              ),
            ),

          ),
          Divider(),

          ListTile(

            leading: Icon(Icons.pin_drop, color: Colors.green, size: 35.0,),

            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                    hintText: "Where does Daily Worker live ?",
                    border: InputBorder.none
                ),
              ),
            ),

          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              onPressed: getCoworkingSpaceLocation,
              icon: Icon(Icons.my_location, color: Colors.white),
              color: Colors.blue,
              label: Text("Use Current Location"
                ,style: TextStyle(color: Colors.white),),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)
              ),

            ),
          ),

          /*Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              onPressed: ()  {
                setState(() {

                  Navigator.pushNamed(context, Map());

                });
              },
              icon: Icon(Icons.map, color: Colors.white),
              color: Colors.blue,
              label: Text("Use Current Location"
                ,style: TextStyle(color: Colors.white),),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)
              ),

            ),
          ),

          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: buildMap(context,_pickedLocation),

          ),*/

          Divider(),

          ListTile(

            leading: Icon(Icons.phone, color: Colors.green, size: 35.0,),

            title: Container(

              child: Row(

                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,

                children: <Widget>[

                  Container(
                    width: 80.0,
                    child: CountryPickerDropdown(
                      initialValue: 'eg',
                      itemBuilder: _buildDropdownItem,
                      onValuePicked: (Country country) {
                        print("${country.name}");

                        countryCode = "+"+country.phoneCode;

                      },
                    ),
                  ),

                  Container(
                    width: 100.0,
                        child: TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                            hintText: "Phone number",
                            hintStyle: TextStyle(fontSize: 15.0),
                            border: InputBorder.none
                        ),
                          keyboardType: TextInputType.number,),


                  ),
                ],
              ),


            )

          ),
          Divider(),

          ListTile(

            leading: Icon(Icons.phone, color: Colors.black26, size: 35.0,),

              title: Container(

                child: Row(

                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,

                  children: <Widget>[

                    Container(
                      width: 80.0,
                      child: CountryPickerDropdown(
                        initialValue: 'eg',
                        itemBuilder: _buildDropdownItem,
                        onValuePicked: (Country country) {
                          print("${country.name}");

                          anothercountryCode = "+"+country.phoneCode;

                        },
                      ),
                    ),

                    Container(
                      width: 100.0,
                      child: TextField(
                        controller: anotherphoneController,
                        decoration: InputDecoration(
                            hintText: "Another phone number (optional)",
                            hintStyle: TextStyle(fontSize: 15.0),
                            border: InputBorder.none
                        ),
                        keyboardType: TextInputType.number,
                      ),


                    ),
                  ],
                ),


              )),

          Divider(),

          ListTile(

            leading: Icon(Icons.monetization_on, color: Colors.green, size: 35.0,),

            title: Container(
              width: 250.0,
              child: Row(
                children: <Widget>[

                  Container(
                    width: 100,
                    child: TextField(
                      controller: wageforhourController,
                      decoration: InputDecoration(
                          hintText: "Wage for hour",
                          border: InputBorder.none
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 10.0,),
                  Divider(),
                  Container(
                    width: 100,
                    child: TextField(
                      controller: wagefordayController,
                      decoration: InputDecoration(
                          hintText: "Wage for day",
                          border: InputBorder.none
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),

          ),

          Divider(),

          ListTile(

            leading: Icon(Icons.description, color: Colors.green, size: 35.0,),
            title: Container(
              width: 250.0,
              child: TextField(
                maxLength: 10000,
                controller: experienceController,
                decoration: InputDecoration(
                    hintText: "His previous work/ What he's good at ...",
                    border: InputBorder.none
                ),
              ),
            ),

          ),

        ],
      ) ,
    );

  }










  @override
  Widget build(BuildContext context) {
    //return buildSplashScreen();
    if(widget.goToCreatePost){
      return  buildPostForm();
    }
    if(widget.goToAddDailyWorker){
      return  buildCoworkingSpaceForm();
    }
    else{
      return buildSplashScreen();
    }

  }
}



class Show_Image extends StatefulWidget {

  File file;
  bool deletedfile = false;

  Show_Image(this.file);

  @override
  _Show_ImageState createState() => _Show_ImageState();

}

builderupdateImage(File file){

  if(file != null) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: FileImage(file),
            )
        ),

      ),
    );
  }else{

    return Text("");


  }

}





Widget buildMap(context, LocationResult _pickedLocation){
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          onPressed: () async {
            LocationResult result = await showLocationPicker(
              context,
              "AIzaSyDumsO7VM6GuoUYePPnLPEcR7kdp6Cw0yY",
              initialCenter: LatLng(31.1975844, 29.9598339),
//                      automaticallyAnimateToCurrentLocation: true,
//                      mapStylePath: 'assets/mapStyle.json',
              myLocationButtonEnabled: true,
              layersButtonEnabled: true,
//                      resultCardAlignment: Alignment.bottomCenter,
            );
            print("result = $result");

            _pickedLocation = result;
          },
          child: Text('Pick location'),
        ),
        Text(_pickedLocation.toString()),
      ],
    ),
  );

}



class _Show_ImageState extends State<Show_Image> {


  @override
  Widget build(BuildContext context) {

    File updatedfile = widget.file;


    return GestureDetector(
      child:  !widget.deletedfile ? Container(
          height: 150.0,
          width: MediaQuery.of(context).size.width * 0.5,
      child: Center(
      child: AspectRatio(
      aspectRatio: 16/9,
      child: Padding(
      padding: EdgeInsets.only(top : 10.0),
        child: GestureDetector(

          child: Stack(children: <Widget>[

            !widget.deletedfile ?builderupdateImage(widget.file):Text(""),

            !widget.deletedfile ? IconButton(
              icon: Icon(Icons.delete,color: Colors.white ,size: 30.0,),
              onPressed: (){

                    setState(() {

                      widget.deletedfile = true;
                      postFiles.remove(widget.file);
                      show_Image.remove(widget.file);
                      widget.file = null;



                    });
            },

            ):Text(""),
          ],
      ),
        ),
      ),
      ),
      )
      ):Text(""),
    );
  }
}


