import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeechat_app/Utils/colors.dart';
import 'package:coffeechat_app/Utils/general.dart';
import 'package:coffeechat_app/Utils/progress.dart';
import 'package:coffeechat_app/Utils/storage.dart';
import 'package:flutter/material.dart';

import '../BottomNavigationBar.dart';

class NetworkPreferences extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NetworkPreferences();
}

class _NetworkPreferences extends State<NetworkPreferences> {
  List<String> _prefs = [];

  List<String> _selectedPrefs = [];

  ProgressDisplay pd;
  StorageSystem ss = new StorageSystem();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pd = new ProgressDisplay(context);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Select Network Preferences"),
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0.0,
        iconTheme: IconThemeData(color: Color(MyColors.primary_color)),
        actions: [
          FlatButton(
              onPressed: () {
                savePrefs();
              },
              child: Text("DONE"))
        ],
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_prefs[index],style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                fontFamily: "Roboto",
                color: Colors.grey,
                fontSize: 18.0),
            ),
            leading: isExist(_prefs[index]) ? Icon(Icons.check_box) : Icon(Icons.check_box_outline_blank),
            onTap: () {
              if(!isExist(_prefs[index])) {
                setState(() {
                  _selectedPrefs.add(_prefs[index]);
                });
              }
            },
          );
        },
        itemCount: _prefs.length,
        scrollDirection: Axis.vertical,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      ),
    );
  }

  bool isExist(String item) {
    return _selectedPrefs.contains(item);//.contains ((element) => element == item);
  }

  savePrefs() async {
    if(_selectedPrefs.isEmpty){
      new GeneralUtils().neverSatisfied(
          context, 'Error', 'Select at least one network preference.');
      return;
    }

    pd.displayDialog("Please wait...");

    String user = ss.getItem('user');
    Map<String, dynamic> json = jsonDecode(user);

    await FirebaseFirestore.instance.collection("users").doc("${json["uid"]}").update({"prefs":_selectedPrefs});

    Map<String, dynamic> userData = new Map();
    userData['prefs'] = _selectedPrefs;
    ss.setPrefItem('networkPrefs', jsonEncode(userData));

    pd.dismissDialog();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) =>
        new bottomNavigationBar()));
  }
}
