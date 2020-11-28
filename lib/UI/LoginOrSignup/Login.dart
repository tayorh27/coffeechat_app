import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:coffeechat_app/UI/BottomNavigationBar.dart';
import 'package:coffeechat_app/UI/LoginOrSignup/LoginAnimation.dart';
import 'package:coffeechat_app/UI/LoginOrSignup/Signup.dart';
import 'package:coffeechat_app/Utils/general.dart';
import 'package:coffeechat_app/Utils/progress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coffeechat_app/Utils/storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class loginScreen extends StatefulWidget {
  @override
  _loginScreenState createState() => _loginScreenState();
}

/// Component Widget this layout UI
class _loginScreenState extends State<loginScreen>
    with TickerProviderStateMixin {
  //Animation Declaration
  AnimationController sanimationController;

  final formKey = new GlobalKey<FormState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  ProgressDisplay pd;
  StorageSystem ss = new StorageSystem();

  var tap = 0;
  String msgId = '';

  String mEmail = '', mPassword = '';

  String errorMessage;

  @override

  /// set state animation controller
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

//    try {
//      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//      if(Platform.isAndroid) {
//        if (deviceInfo.androidInfo != null) {
//          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//          device_info = androidInfo.androidId;
//          print('devAnd = $device_info');
//        }
//      }else if(Platform.isIOS) {
//        if (deviceInfo.iosInfo != null) {
//          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//          device_info = iosInfo.identifierForVendor;
//          print('deviOS = $device_info');
//        }
//      }
//    }catch(e){
//      print(e.toString());
//    }
  }

  /// Dispose animation controller
  @override
  void dispose() {
    //ss.disposePref();
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

  /// Component Widget layout UI
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    mediaQueryData.devicePixelRatio;
    mediaQueryData.size.width;
    mediaQueryData.size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        /// Set Background image in layout (Click to open code)
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("assets/images/bg4.jpg"),
          fit: BoxFit.cover,
        )),
        child: Container(
          /// Set gradient color in image (Click to open code)
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(0, 0, 0, 0.0),
                Color.fromRGBO(0, 0, 0, 0.3)
              ],
              begin: FractionalOffset.topCenter,
              end: FractionalOffset.bottomCenter,
            ),
          ),

          /// Set component layout
          child: ListView(
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
                                    top: mediaQueryData.padding.top + 10.0)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                // Image(
                                //   image: AssetImage("assets/img/Logo.png"),
                                //   height: 70.0,
                                // ),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.0)),
                                Container(
                                  height: 200.0,
                                ),
                                /// Animation text treva shop accept from signup layout (Click to open code)
                                Hero(
                                  tag: "Tac",
                                  child: Text(
                                    "Coffee Chat App",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.6,
                                        color: Colors.deepPurpleAccent,
                                        fontFamily: "Roboto",
                                        fontSize: 20.0),
                                  ),
                                ),
                              ],
                            ),


                            Form(
                              key: formKey,
                              child: Column(
                                children: <Widget>[
                                  /// TextFromField Email
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.0)),
                                  textFromField(
                                    icon: Icons.email,
                                    password: false,
                                    placeholder: "Email",
                                    inputType: TextInputType.emailAddress,
                                  ),

                                  /// TextFromField Password
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5.0)),
                                  textFromField(
                                    icon: Icons.vpn_key,
                                    password: true,
                                    placeholder: "Password",
                                    inputType: TextInputType.text,
                                  )
                                ],
                              ),
                            ),

                            /// Button Forgot Password
                            FlatButton(
                                padding: EdgeInsets.only(top: 0.0),
                                onPressed: () {
                                  _handleForgotPassword();
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Roboto"),
                                )),

                            /// Button Signup
                            FlatButton(
                                padding: EdgeInsets.only(top: 20.0),
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              new Signup()));
                                },
                                child: Text(
                                  "Don't Have Account? Sign Up",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Roboto"),
                                )),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: mediaQueryData.padding.top + 100.0,
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
                            signinWithEmailAndPassword();
                          },
                          child: buttonBlackBottom(),
                        )
                      : new LoginAnimation(
                          animationController: sanimationController.view,
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleForgotPassword() {
    try {
      if (mEmail.isEmpty) {
        pd.displayMessage(
            context, 'Notice', 'Please enter your email address.');
        return;
      }
      pd.displayDialog("please wait...");
      FirebaseAuth.instance.sendPasswordResetEmail(email: mEmail).then((v) {
        pd.dismissDialog();
        pd.displayMessage(
            context, 'Info',
            'Please check your mail for further instructions.');
      }).catchError((err) {
        pd.dismissDialog();
        pd.displayMessage(context, 'Error', '${err.toString()}');
      });
    }catch(e) {
      pd.dismissDialog();
      pd.displayMessage(context, 'Error', '${e.toString()}');
    }
  }


  signinWithEmailAndPassword() {
    try {
      if (!validateAndSave()) {
        return;
      }
      pd.displayDialog("Please wait...");
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: mEmail, password: mPassword)
          .then((user) {
        checkFirestoreAndRedirect(mEmail, user.user.uid);
      }).catchError((err) {
        pd.dismissDialog();
        pd.displayMessage(context, 'Error', '${err.toString()}');
      });
    }catch(e) {
      pd.dismissDialog();
      pd.displayMessage(context, 'Error', '${e.toString()}');
    }
  }

  checkFirestoreAndRedirect(String email, String uid) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((result) {
      //check if user exists in database
      if (!result.exists) {
        FirebaseAuth.instance.signOut();
        pd.dismissDialog();
        pd.displayMessage(
            context, 'Error', 'User does not exist. Please create an account.');
        return;
      }
      //check if user has been blocked
      Map<String, dynamic> user = result.data();
      bool blocked = user['blocked'];
//      print('blocked = $blocked');
      if (blocked) {
        FirebaseAuth.instance.signOut();
        pd.dismissDialog();
        pd.displayMessage(context, 'Error',
            'Sorry, user has been blocked. Please contact support.');
      }
      Map<String, dynamic> updateUserData = new Map();
      if (msgId.isNotEmpty) {
        updateUserData['msgId'] = FieldValue.arrayRemove([msgId]);
      }
      FirebaseFirestore.instance
          .collection('users')
          .doc(email.toLowerCase())
          .update(updateUserData)
          .then((v) {
        pd.dismissDialog();
        Map<String, dynamic> userData = new Map();
        userData['email'] = email;
        userData['fn'] = user['firstname'];
        userData['ln'] = user['lastname'];
        userData['pic'] = user['picture'];
        ss.setPrefItem('loggedin', 'true');
        ss.setPrefItem('user', jsonEncode(userData));
        setState(() {
          tap = 1;
        });
        new LoginAnimation(
          animationController: sanimationController.view,
        );
        _PlayAnimation();
        return tap;
      });
    }).catchError((err) {
//      print('after sign: $err');
      FirebaseAuth.instance.signOut();
      pd.dismissDialog();
      pd.displayMessage(
          context, 'Error', 'An error occurred. Please try again.');
      return;
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
      bool password}) {
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
            onSaved: (value) =>
                (!password) ? mEmail = value : mPassword = value,
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
//  String mEmail, mPassword;
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
//            validator: (value) => value.isEmpty ? 'Please enter value' : null,
//            onSaved: (value) =>
//                (!password) ? mEmail = value : mPassword = value,
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
              "Sign in with Apple",
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
              "Sign in with Facebook",
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
              "Sign in with Google",
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
          "Login",
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
