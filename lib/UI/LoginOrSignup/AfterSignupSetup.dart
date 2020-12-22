import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeechat_app/Utils/progress.dart';
import 'package:coffeechat_app/Utils/storage.dart';
import 'package:flutter/material.dart';

import 'NetworkPreferences.dart';

class AfterSignupSetup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AfterSignupSetup();
}

class _AfterSignupSetup extends State<AfterSignupSetup> {

  final formKey = new GlobalKey<FormState>();

  String bio = "", zoomID = "", zoomPassword = "";

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
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Container(
            /// Set Background image in layout
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg4.jpg"),
                  fit: BoxFit.cover,
                )),
            child: Container(
              /// Set gradient color in image


              /// Set component layout
              child: ListView(
                padding: EdgeInsets.all(0.0),
                children: <Widget>[
                  Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            alignment: AlignmentDirectional.topCenter,
                            child: Column(
                              children: <Widget>[
                                /// padding logo
                                Padding(
                                    padding: EdgeInsets.only(
                                        top:
                                        mediaQueryData.padding.top + 10.0)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0)),
                                    Container(
                                      height: 200.0,
                                    ),
                                    /// Animation text treva shop accept from login layout
                                    Hero(
                                      tag: "Tac",
                                      child: Text(
                                        "Setup Your Profile",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.6,
                                            fontFamily: "Roboto",
                                            color: Colors.deepPurpleAccent,
                                            fontSize: 20.0),
                                      ),
                                    ),
                                  ],
                                ),

                                Form(
                                  key: formKey,
                                  child: Column(
                                    children: <Widget>[
                                      /// TextFromField Name
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.0)),
                                      textFromField(
                                        icon: Icons.info,
                                        isBio: true,
                                        isZoomID: true,
                                        placeholder: "Short bio about you... *",
                                        inputType: TextInputType.multiline,
                                        min: 3,
                                        max: 10
                                      ),

                                      /// TextFromField Email
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5.0)),
                                      textFromField(
                                        icon: Icons.edit,
                                        isBio: false,
                                        isZoomID: true,
                                        placeholder: "Your Zoom ID *",
                                        inputType: TextInputType.text,
                                          min: 1,
                                          max: 1
                                      ),

                                      /// TextFromField Password
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5.0)),
                                      textFromField(
                                        icon: Icons.vpn_key,
                                        isBio: false,
                                        isZoomID: false,
                                        placeholder: "Zoom Password *",
                                        inputType: TextInputType.text,
                                          min: 1,
                                          max: 1
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: mediaQueryData.padding.top + 80.0,
                                      bottom: 0.0),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),

                      /// Set Animaion after user click buttonLogin
                      InkWell(
                        splashColor: Colors.yellow,
                        onTap: () {
                          saveProfileInfo();
                        },
                        child: buttonBlackBottom(),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  saveProfileInfo() async{
    try {
      if (!validateAndSave()) {
        return;
      }
      pd.displayDialog("Please wait...");

      String user = ss.getItem('user');
      Map<String, dynamic> json = jsonDecode(user);

      await FirebaseFirestore.instance.collection("users").doc("${json["uid"]}").update({"bio":bio, "zoom_id":zoomID, "zoom_pwd":zoomPassword});

      Map<String, dynamic> userData = new Map();
      userData['bio'] = bio;
      userData['zoomID'] = zoomID;
      userData['zoomPassword'] = zoomPassword;
      ss.setPrefItem('profile', jsonEncode(userData));

      pd.dismissDialog();

      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => new NetworkPreferences()));

    }catch(e) {
      pd.dismissDialog();
      pd.displayMessage(context, 'Error', '${e.toString()}');
    }
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    form.save();
    return form.validate();
  }

  /// textfromfield custom class
  Widget textFromField(
      {String placeholder,
        IconData icon,
        TextInputType inputType,
        bool isBio,
        bool isZoomID,
      int min, int max}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        height: 60.0,
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)]),
        padding:
        EdgeInsets.only(left: 20.0, right: 30.0, top: 0.0, bottom: 0.0),
        child: Theme(
          data: ThemeData(
            hintColor: Colors.transparent,
          ),
          child: TextFormField(
            minLines: min,
            maxLines: max,
            validator: (value) => value.isEmpty ? 'Please enter value' : null,
            onSaved: (value) => (isBio)
                ? bio = value
                : isZoomID ? zoomID = value : zoomPassword = value,
            decoration: InputDecoration(
                border: InputBorder.none,
                labelText: placeholder,
                icon: Icon(
                  icon,
                  color: Colors.black38,
                ),
                labelStyle: TextStyle(
                    fontSize: 15.0,
                    fontFamily: 'Roboto',
                    letterSpacing: 0.3,
                    color: Colors.black38,
                    fontWeight: FontWeight.w600)),
            keyboardType: inputType,
          ),
        ),
      ),
    );
  }

}

///ButtonBlack class
class buttonBlackBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Container(
        height: 55.0,
        child: Text(
          "Save Profile",
          style: TextStyle(
              color: Colors.white,
              letterSpacing: 0.2,
              fontFamily: "Roboto",
              fontSize: 18.0,
              fontWeight: FontWeight.w800),
        ),
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
            borderRadius: BorderRadius.circular(30.0),
            gradient: LinearGradient(
                colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])),
      ),
    );
  }
}