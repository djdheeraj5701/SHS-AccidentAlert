import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfo extends StatefulWidget {
  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  final textEditingController={
    'Name':TextEditingController(),
    'Address':TextEditingController(),
    'Emergency Contact':TextEditingController()
  };

  getDefaultPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String name = prefs.getString('Name')!;
    final String address = prefs.getString('Address')!;
    final String emergencyContact = prefs.getString('Emergency Contact')!;

    textEditingController['Name']?.text=name;
    textEditingController['Address']?.text=address;
    textEditingController['Emergency Contact']?.text=emergencyContact;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDefaultPrefs();
  }
  @override
  Widget build(BuildContext context) {
    final infoList=<Widget>[];
    textEditingController.forEach((key, value) {
      infoList.add(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: value,
            decoration: InputDecoration(
              hintText: key
            ),
          ),
        )
      );
    });
    infoList.add(
      Text('*Note: Information only used for alerting rescue team')
    );
    infoList.add(
      // ignore: deprecated_member_use
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: MediaQuery.of(context).size.width*0.7,
          height: 70,
          color: Colors.green,
          child: FlatButton(
              onPressed: () async {
                final name=textEditingController['Name']?.text;
                final address=textEditingController['Address']?.text;
                final emergencyContact=textEditingController['Emergency Contact']?.text;
                print('Info saved: $name, $address, $emergencyContact');

                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('Name', name!);
                await prefs.setString('Address', address!);
                await prefs.setString('Emergency Contact', emergencyContact!);

                Navigator.of(context).pop();

              },
              child: const Text(
                  'Save Info',
                style: TextStyle(
                  fontSize: 21,
                  color: Colors.white
                ),
              )
          ),
        ),
      )
    );
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 90,
        backgroundColor: Colors.blue,
        elevation: 10,
        shadowColor: Colors.blueAccent,
        title: const Text("User Info"),
        leading: Tooltip(
            message: "Back to Home",
            child: Padding(
              padding: const EdgeInsets.only(right:20.0),
              child: Center(
                child: SizedBox(
                  height: 50,width: 50,
                  // ignore: deprecated_member_use
                  child: FlatButton(
                    onPressed: (){
                      print("Back");
                      Navigator.of(context).pop();
                    },
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.back,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: infoList
        ),
      ),
    );
  }
}
