import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:coffeechat_app/UI/BottomNavigationBar.dart';
import 'package:coffeechat_app/UI/LoginOrSignup/Login.dart';
import 'package:coffeechat_app/UI/LoginOrSignup/LoginAnimation.dart';
import 'package:coffeechat_app/UI/LoginOrSignup/Signup.dart';
import 'package:coffeechat_app/Utils/email_service.dart';
import 'package:coffeechat_app/Utils/general.dart';
import 'package:coffeechat_app/Utils/progress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coffeechat_app/Utils/storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class Signup extends StatefulWidget {

  // final Uri link;
  // Signup(this.link);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> with TickerProviderStateMixin {
  //Animation Declaration
  AnimationController sanimationController;
  AnimationController animationControllerScreen;
  Animation animationScreen;
  var tap = 0;

  final formKey = new GlobalKey<FormState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  ProgressDisplay pd;
  StorageSystem ss = new StorageSystem();

  String msgId = '';

  String mEmail = '', mPassword = '', fullname = '';

  String errorMessage;

  var _selectedAvatar = "avatar";

  var avatars = ["avatar","avatar-2","avatar-6","avatar-7","avatar-8","avatar-9","avatar-10","babysitter","-1-2","-1-3","-1-5","-1-6","-1-7","-1-8","-86","-86-2","-86-3","-86-4","-86-5","-86-6","-98"];

  /// Set AnimationController to initState
  @override
  void initState() {
    sanimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800))
          ..addStatusListener((statuss) {
            if (statuss == AnimationStatus.dismissed) {
              setState(() {
                tap = 0;
              });
            }
          });
    // TODO: implement initState
    super.initState();
    pd = new ProgressDisplay(context);
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    getTokenAndDeviceInfo();
  }

  getTokenAndDeviceInfo() async {
    _firebaseMessaging.getToken().then((token) {
      msgId = token;
    });
  }

  /// Dispose animationController
  @override
  void dispose() {
    super.dispose();
    sanimationController.dispose();
  }

  /// Playanimation set forward reverse
  Future<Null> _PlayAnimation() async {
    try {
      await sanimationController.forward();
      await sanimationController.reverse();
    } on TickerCanceled {}
  }

  List<Widget> listAvatars() {
    List<Widget> avatarsWidget = new List();
    var index = 0;
    avatars.forEach((avatar) {
      avatarsWidget.add(
        InkWell(
          child: Stack(
            children: [
              Container(
                width: 64.0,
                height: 64.0,
                margin: EdgeInsets.only(right: 20.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    image: DecorationImage(
                        image: AssetImage("assets/images/$avatar.png"), fit: BoxFit.fitWidth
                    )
                ),
              ),
              (_selectedAvatar == avatar) ? Icon(Icons.check_circle, color: Colors.deepPurpleAccent,) : Text(''),
            ],
          ),
          onTap: (){
            setState(() {
              _selectedAvatar = avatar;
            });
          },
        ),
      );
      index++;
    });
    return avatarsWidget;
  }

  /// Component Widget layout UI
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    mediaQueryData.devicePixelRatio;
    mediaQueryData.size.height;
    mediaQueryData.size.width;

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
                                    // Image(
                                    //   image: AssetImage("assets/img/Logo.png"),
                                    //   height: 70.0,
                                    // ),
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
                                        "Coffee Chat App",
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
                                        icon: Icons.person,
                                        password: false,
                                        isFullname: true,
                                        placeholder: "Full name",
                                        inputType: TextInputType.text,
                                      ),

                                      /// TextFromField Email
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5.0)),
                                      textFromField(
                                        icon: Icons.email,
                                        password: false,
                                        isFullname: false,
                                        placeholder: "Email",
                                        inputType: TextInputType.emailAddress,
                                      ),

                                      /// TextFromField Password
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5.0)),
                                      textFromField(
                                        icon: Icons.vpn_key,
                                        password: true,
                                        isFullname: false,
                                        placeholder: "Password",
                                        inputType: TextInputType.text,
                                      )
                                    ],
                                  ),
                                ),

                                Container(
                                  margin: EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    "Select your avatar",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Roboto"),
                                  ),
                                ),

                                Container(
                                  height: 90.0,
                                  margin: EdgeInsets.only(left: 30.0, top: 20.0),
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: listAvatars()
                                  ),
                                ),

                                /// Button Login
                                FlatButton(
                                    padding: EdgeInsets.only(top: 10.0),
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  new loginScreen()));
                                    },
                                    child: Text(
                                      " Have Account? Sign In",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Roboto"),
                                    )),
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
                      tap == 0
                          ? InkWell(
                              splashColor: Colors.yellow,
                              onTap: () {
                                signupWithEmailAndPassword();
                              },
                              child: buttonBlackBottom(),
                            )
                          : new LoginAnimation(
                              animationController: sanimationController.view,
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

  signupWithEmailAndPassword() {
    try {
      if (!validateAndSave()) {
        return;
      }
      if (!fullname.contains(' ')) {
        pd.displayMessage(context, 'Error', 'Enter full name');
        return;
      }
      pd.displayDialog("Please wait...");
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: mEmail, password: mPassword)
          .then((result) {
        result.user.sendEmailVerification();
        checkFirestoreAndRedirect(mEmail, result.user);
      }).catchError((err) {
        FirebaseAuth.instance.signOut();
        pd.dismissDialog();
        pd.displayMessage(context, 'Error', '${err.toString()}');
      });
    }catch(e) {
      pd.dismissDialog();
      pd.displayMessage(context, 'Error', '${e.toString()}');
    }
  }

  checkFirestoreAndRedirect(String email, User firebaseUser) async {
      Map<String, dynamic> newUserData = new Map();
      // String id = FirebaseDatabase.instance.reference().push().key;
      newUserData['id'] = firebaseUser.uid;
      newUserData['blocked'] = false;
      newUserData['created_date'] = new DateTime.now().toString();
      newUserData['email'] = email;
      newUserData['firstname'] = fullname.split(' ')[0];
      newUserData['lastname'] = fullname.split(' ')[1];
      newUserData['picture'] = "$_selectedAvatar.png";
      newUserData['msgId'] = [msgId];
      newUserData['timestamp'] = FieldValue.serverTimestamp();
      FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .set(newUserData)
          .then((v) {
        Map<String, dynamic> userData = new Map();
        userData['uid'] = firebaseUser.uid;
        userData['email'] = email;
        userData['fn'] = fullname.split(' ')[0];
        userData['ln'] = fullname.split(' ')[1];
        userData['pic'] = "$_selectedAvatar.png";
        ss.setPrefItem('loggedin', 'true');
        ss.setPrefItem('user', jsonEncode(userData));
        pd.dismissDialog();
        setState(() {
          tap = 1;
        });
        new LoginAnimation(
          animationController: sanimationController.view,
        );
        _PlayAnimation();
        return tap;
      });
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
      bool password,
      bool isFullname}) {
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
            obscureText: password,
            validator: (value) => value.isEmpty ? 'Please enter value' : null,
            onSaved: (value) => (password)
                ? mPassword = value
                : isFullname ? fullname = value : mEmail = value,
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

/// textfromfield custom class
//class textFromField extends StatelessWidget {
//  bool password;
//  String placeholder;
//  IconData icon;
//  TextInputType inputType;
//
//  textFromField({this.placeholder, this.icon, this.inputType, this.password});
//
//  @override
//  Widget build(BuildContext context) {
//    return Padding(
//      padding: EdgeInsets.symmetric(horizontal: 30.0),
//      child: Container(
//        height: 60.0,
//        alignment: AlignmentDirectional.center,
//        decoration: BoxDecoration(
//            borderRadius: BorderRadius.circular(14.0),
//            color: Colors.white,
//            boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)]),
//        padding:
//            EdgeInsets.only(left: 20.0, right: 30.0, top: 0.0, bottom: 0.0),
//        child: Theme(
//          data: ThemeData(
//            hintColor: Colors.transparent,
//          ),
//          child: TextFormField(
//            obscureText: password,
//            decoration: InputDecoration(
//                border: InputBorder.none,
//                labelText: placeholder,
//                icon: Icon(
//                  icon,
//                  color: Colors.black38,
//                ),
//                labelStyle: TextStyle(
//                    fontSize: 15.0,
//                    fontFamily: 'Roboto',
//                    letterSpacing: 0.3,
//                    color: Colors.black38,
//                    fontWeight: FontWeight.w600)),
//            keyboardType: inputType,
//          ),
//        ),
//      ),
//    );
//  }
//}

///buttonCustomApple class
class buttonCustomApple extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        alignment: FractionalOffset.center,
        height: 44.0,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(40.0),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15.0)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/img/icon_apple.png",
              height: 25.0,
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 7.0)),
            Text(
              "Sign up with Apple",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 19.0,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Roboto'),
            ),
          ],
        ),
      ),
    );
  }
}

///buttonCustomFacebook class
class buttonCustomFacebook extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        alignment: FractionalOffset.center,
        height: 44.0,
        width: 500.0,
        decoration: BoxDecoration(
          color: Color.fromRGBO(107, 112, 248, 1.0),
          borderRadius: BorderRadius.circular(40.0),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15.0)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/img/icon_facebook.png",
              height: 25.0,
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 7.0)),
            Text(
              "Sign up with Facebook",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 19.0,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Roboto'),
            ),
          ],
        ),
      ),
    );
  }
}

///buttonCustomGoogle class
class buttonCustomGoogle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        alignment: FractionalOffset.center,
        height: 44.0,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10.0)],
          borderRadius: BorderRadius.circular(40.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/img/google.png",
              height: 25.0,
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 7.0)),
            Text(
              "Sign up with Google",
              style: TextStyle(
                  color: Colors.black26,
                  fontSize: 19.0,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Roboto'),
            )
          ],
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
          "Sign Up",
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
