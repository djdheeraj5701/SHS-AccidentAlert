import 'dart:math';

import 'package:accident_detection/user/userInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'dart:async';
import 'dart:convert';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';

class AccelerometerClass extends StatefulWidget {
  @override
  _AccelerometerClassState createState() => _AccelerometerClassState();
}

class _AccelerometerClassState extends State<AccelerometerClass> {
  bool isSharing=false;
  bool SMSsent=false;

  List<double>? _accelerometerValues=[0,0,0];
  List<double>? _maxUAV=[0,0,0,0];
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  // Future<void> initiateMessage(BuildContext context, String message, String recipient) async {
  //   final String _result =
  //   await sendSMS(message: message, recipients: <String>[recipient])
  //       .catchError((dynamic onError) {
  //     print(onError);
  //   });
  //   print(_result);
  // }

  sendRescueSMS(sostext) async {
    print(sostext);

    final prefs = await SharedPreferences.getInstance();
    final String name = prefs.getString('Name')!;
    final String address = prefs.getString('Address')!;
    final String emergencyContact = prefs.getString('Emergency Contact')!;

    final Telephony telephony = Telephony.instance;
    await telephony.requestPhoneAndSmsPermissions;

    Location location = new Location();
    await location.requestPermission();

    final userloc=await location.getLocation();

    final lati=userloc.latitude;
    final longi=userloc.longitude;

    print("$sostext by $name living in $address\n"+
        "SOS location: \nhttps://www.google.com/maps/place/$lati,$longi");

    telephony.sendSms(
        to: emergencyContact,
        message: "$sostext by $name living in $address\n"+
            "SOS location: \nhttps://www.google.com/maps/place/$lati,$longi"
    );
    // initiateMessage(context,
    //     "$sostext by $name living in $address\n"+
    //     "SOS location: \nhttps://www.google.com/maps/place/$lati,$longi"
    //     , emergencyContact);
    _maxUAV=[0,0,0,0];
  }

  @override
  Widget build(BuildContext context) {
    // final userAccelerometer = _userAccelerometerValues
    //     ?.map((double v) => v.toStringAsFixed(2))
    //     .toList();
    final maxUAV = _maxUAV
        ?.map((double v) => v.toStringAsFixed(2))
        .toList();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 90,
        backgroundColor: Colors.blue,
        elevation: 10,
        shadowColor: Colors.blueAccent,
        title: const Text("Accident Detection"),
        actions: [
          Tooltip(
            message: "User Info",
            child: Padding(
              padding: const EdgeInsets.only(right:20.0),
              child: Center(
                child: SizedBox(
                  height: 50,width: 50,
                  // ignore: deprecated_member_use
                  child: FlatButton(
                    onPressed: (){
                      print("User info");
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => UserInfo()),
                      );
                    },
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.person_crop_circle,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          GestureDetector(
            onTap: () async {
              sendRescueSMS("SOS");
              await alertPop();
              setState(() {
                SMSsent=true;
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width/2.5,
              height: MediaQuery.of(context).size.width/2.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width/3),
                border: Border.all(width: 5,color: Colors.red),
              ),
              child: const Center(
                child: Text(
                  "SOS",
                  style: TextStyle(
                    fontSize: 40,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              print("Enable Safety");
              setState(() {
                isSharing=!isSharing;
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width/1.5,
              height: 100,
              decoration: BoxDecoration(
                color: isSharing?Colors.green:Colors.red
              ),
              child: Center(
                child: Text(
                  (isSharing?"Disable":"Enable")+" Safety",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white
                  ),
                ),
              ),
            ),
          ),
          SMSsent?GestureDetector(
            onTap: (){
              print("Cancel SOS");
              setState(() {
                sendRescueSMS("False Alert sent");
                SMSsent=false;
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width/1.5,
              height: 100,
              decoration: BoxDecoration(
                  color: Colors.black
              ),
              child: const Center(
                child: Text(
                  "Cancel SOS",
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.white
                  ),
                ),
              ),
            ),
          ):SizedBox(),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('maxUAV: $maxUAV'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
      accelerometerEvents.listen(
            (AccelerometerEvent event) {
          setState(() {
            _maxUAV=<double>[max(event.x, _maxUAV![0]),max(event.y, _maxUAV![1]),max(event.z, _maxUAV![1])];
            _accelerometerValues = <double>[event.x, event.y, event.z];
            _maxUAV?.add(
              sqrt(
                    pow(event.x, 2)+
                    pow(event.y, 2)+
                    pow(event.z, 2)
              )
            );
          });
          if(isSharing && _maxUAV![3]>55){
            sendRescueSMS("AccidentAlert!!!");
            alertPop();
            setState(() {
              SMSsent=true;
            });
          }
          Future.delayed(const Duration(milliseconds: 50));
        },
      ),
    );
  }

  Future<void> alertPop() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accident Alert '),
          content: const SingleChildScrollView(
            child: Text('We detected a crash and have sent SMS to concerned people.'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

