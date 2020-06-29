import 'dart:async';
import 'dart:math';

import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dropdown.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms/sms.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../widgets/header.dart';


class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}




class _CreateAccountState extends State<CreateAccount> {

  final _scaffoldkey = GlobalKey<ScaffoldState>();
  final _formkeyusername = GlobalKey<FormState>();
  final _formkeyphonenumber = GlobalKey<FormState>();
  String username, phoneNumber;



  String countryCode;

  String smsOTP;
  String verificationId;
  String errorMessage = '';
  FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController smsOTPController = TextEditingController();

  int _otp, _minOtpValue, _maxOtpValue;




  void generateOtp([int min = 1000, int max = 9999]) {
    //Generates four digit OTP by default
    _minOtpValue = min;
    _maxOtpValue = max;
    _otp = _minOtpValue + Random().nextInt(_maxOtpValue - _minOtpValue);
  }

  static const platform = const MethodChannel('sendSms');

  Future<Null> sendSms(String phoneNumber,String countryCode)async {
    print("SendSMS");
    generateOtp(1000, 9999);
    try {
      final String result = await platform.invokeMethod('send',<String,dynamic>{"phone":countryCode+phoneNumber
        ,"msg":_otp}); //Replace a 'X' with 10 digit phone number
      print(result);
    } on PlatformException catch (e) {
      print(e.toString());
    }

    smsOTPDialog(context);

  }

  void sendOtp(String phoneNumber,String countryCode,
      [String messageText,
        int min = 1000,
        int max = 9999,
        ]) {
    //function parameter 'message' is optional.
    generateOtp(min, max);
    SmsSender sender = new SmsSender();
    String address = countryCode+phoneNumber;
    SmsMessage message = new SmsMessage(address, _otp.toString());
    message.onStateChanged.listen((state) {
    if (state == SmsMessageState.Sent) {
    print("SMS is sent!");

    } else if (state == SmsMessageState.Delivered) {
    print("SMS is delivered!");
    }
    });
    sender.sendSms(message);

    smsOTPDialog(context);

  }


  bool resultChecker(int enteredOtp) {
    //To validate OTP
    return enteredOtp == _otp;
  }




  Future<void> verifyPhone(String countryCode, String phoneNumber) async {
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsOTPDialog(context).then((value) {
        print('sign in');
      });
    };
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: countryCode+phoneNumber, // PHONE NUMBER TO SEND OTP
          codeAutoRetrievalTimeout: (String verId) {
            //Starts the phone number verification process for the given phone number.
            //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
            this.verificationId = verId;
          },
          codeSent:
          smsOTPSent, // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
          timeout: const Duration(seconds: 20),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print(phoneAuthCredential);
          },
          verificationFailed: (AuthException exceptio) {
            print('${exceptio.message}');
          });
    } catch (e) {
      handleError(e);
      //print("Error signing in: $e");
    }
  }

  Future<bool> smsOTPDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter SMS Code'),
            content: Container(
              height: 85,
              child: Column(children: [
                PinInputTextField(
                  inputFormatter: [LengthLimitingTextInputFormatter(6)],
                  pinLength: 6,
                  decoration: BoxLooseDecoration(
                    strokeColor: Colors.black12,
                    radius: Radius.circular(15),
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      fontFamily: 'Montserrat',
                      fontStyle: FontStyle.normal,
                    ),
                    enteredColor: Theme.of(context).primaryColor,
                    solidColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    gapSpaces: [7,7,7,7,7],
                  ),
                  controller: smsOTPController,
                  textInputAction: TextInputAction.go,
                  keyboardType: TextInputType.phone,

                ),
                (errorMessage != ''
                    ? Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                )
                    : Container())
              ]),

            ),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black12),),
                onPressed: (){
                  Navigator.pop(context);

                  //print(_otp);

                },
              ),
              FlatButton(
                child: Text('Done',style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),),
                onPressed: (){


                     _auth.currentUser().then((user) {
                       if (user != null) {
                         Navigator.of(context).pop();
                         SnackBar snackBar = SnackBar(content: Text(
                             "This phone number is already in use"));
                         _scaffoldkey.currentState.showSnackBar(snackBar);
                       } else {
                         Navigator.pop(context);
                         createUserAccount();
                       }
                     });


                },
              )
            ],
          );
        });
  }




  createUserAccount() {


    final formusername = _formkeyusername.currentState;
    final formphonenumber = _formkeyphonenumber.currentState;


    setState(() {

      if(formusername.validate() && formphonenumber.validate()) {

        formusername.save();
        formphonenumber.save();

        SnackBar snackBar = SnackBar(content: Text("Welcome $username"));
        _scaffoldkey.currentState.showSnackBar(snackBar);

        Timer(Duration(seconds:2), (){

          var userData = {'username' : username, 'phone_number':"$countryCode$phoneNumber"};

          Navigator.pop(context, userData);


        });


      }

      });




        }





  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        Navigator.of(context).pop();
        smsOTPDialog(context).then((value) {
          print('sign in');
        });
        break;
      default:
        setState(() {
          errorMessage = error.message;
        });

        break;
    }
  }




  submit(){


    final formphonenumber = _formkeyphonenumber.currentState;

    formphonenumber.save();

    final formusername = _formkeyusername.currentState;

    formusername.save();

    if(countryCode == null){

      countryCode="+20";

    }

    print("$countryCode$phoneNumber");


    if(username.trim().length<3){

      SnackBar snackBar = SnackBar(content: Text(
          "Username is too short"));
      _scaffoldkey.currentState.showSnackBar(snackBar);


    }
    else if(phoneNumber.trim().length<10){

      SnackBar snackBar = SnackBar(content: Text(
          "Invalid Phone number"));
      _scaffoldkey.currentState.showSnackBar(snackBar);


    }
    else {


      verifyPhone(countryCode, phoneNumber);
      //sendOtp(phone_number, countryCode);
      //sendSms(phone_number, countryCode);

      //_sendSMS(countryCode, phone_number);

    }

  }

  Widget _buildDropdownItem(Country country) => Container(
    child: Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
        SizedBox(
          width: 8.0,
        ),
        Text("+${country.phoneCode}(${country.isoCode})"),
      ],
    ),
  );


  @override
  Widget build(BuildContext parentContext) {

    return Scaffold(

      key: _scaffoldkey,

      appBar: header(context, titletext: "Set up your profile",removeBackButton: true),
      body: ListView(

        children: <Widget>[

          Container(

            child: Column(children: <Widget>[

              Padding(
                padding:EdgeInsets.only(top: 25.0) ,

                child: Center(

                  child: Text("Create an account", style: TextStyle(fontSize: 25.0),),


                ),



              ),

              Padding(
              padding:EdgeInsets.all(16.0) ,

              child: Container(

                child: Form(

                  key: _formkeyusername,
                  autovalidate: true,
                  child: TextFormField(
                    validator: (val){

                      if(val.trim().length < 3 || val.isEmpty){

                        return "Username too short";

                      }
                      else{
                        return null;
                      }

                    },
                    onSaved: (val)=> username=val,
                    decoration: InputDecoration(border: OutlineInputBorder()
                        , labelText: "Username"
                        , labelStyle: TextStyle(fontSize: 15.0)
                        , hintText: "Must be at least 3 characters"),
                  ),

                ),


                )),

              Padding(
                  padding:EdgeInsets.all(16.0) ,

                  child: Container(

                    child: Row(

                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,

                      children: <Widget>[

                          Expanded(
                            child: CountryPickerDropdown(
                              initialValue: 'eg',
                              itemBuilder: _buildDropdownItem,
                              onValuePicked: (Country country) {
                                print("${country.name}");

                                countryCode = "+"+country.phoneCode;

                              },
                            ),
                          ),

                        Expanded(
                        child: Form(

                          key: _formkeyphonenumber,
                          autovalidate: true,

                          child: TextFormField(
                            validator: (val){

                              if(val.trim().length < 10 || val.isEmpty){

                                return "Invalid phone number";

                              }
                              else{
                                return null;
                              }

                            },
                            onSaved: (val)=> phoneNumber=val,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(border: OutlineInputBorder()
                                , labelText: "Phone Number"
                                , labelStyle: TextStyle(fontSize: 15.0)

                            ),
                          ),

                        )
                        ),
                      ],
                    ),


                  )),


              GestureDetector(

                onTap: submit,

                child: Container(

                  width: 350 ,
                  height: 50.0,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                   ),
                  child: Center(
                      child: Text("Submit",
                        style: TextStyle(color: Colors.white, fontSize: 15.0,fontWeight: FontWeight.bold),
                      )
                  ),

                ),

              )

            ],),

          ),

        ],


      ),

    );

  }
}

