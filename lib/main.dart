import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeechat_app/UI/HomeUIComponent/DynamicLinkPage.dart';
import 'package:coffeechat_app/values/values.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'UI/BottomNavigationBar.dart';
import 'UI/LoginOrSignup/ChoseLoginOrSignup.dart';
import 'UI/LoginOrSignup/Login.dart';
import 'Utils/colors.dart';
import 'Utils/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    /// To set orientation always portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    ///Set color status bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent, //or set color with: Color(0xFF0000FF)
    ));
    FirebaseAnalytics analytics = FirebaseAnalytics();
    return MaterialApp(
      title: 'Coffee Chat App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        primaryColorLight: Colors.white,
        primaryColorBrightness: Brightness.light,
        primaryColor: Colors.white,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      routes: <String, WidgetBuilder>{
        "login": (BuildContext context) => new loginScreen(),
        "choose": (BuildContext context) => new ChoseLogin()
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

/// Component UI
class _SplashScreenState extends State<SplashScreen> {

  StorageSystem ss = new StorageSystem();

  @override
  /// Setting duration in splash screen
  startTime() async {
    return new Timer(Duration(milliseconds: 4500), NavigatorPage);
  }
  /// To navigate layout change
  Future NavigatorPage() async {
    //ss.clearPref();
    String logged = ss.getItem('loggedin');
    //print('logged ========$logged');
    if(logged.isEmpty){
      Navigator.of(context).pushReplacementNamed("choose");
    }else {
      if(logged == 'signInAnonymously'){
//        FirebaseAuth.instance.signOut().then((v){
//
//        });
        ss.clearPref();
        Navigator.of(context).pushReplacementNamed("login");
        return;
      }else{
        if(logged == 'true'){
          Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                  new bottomNavigationBar()));
        }else {
          FirebaseAuth.instance.signOut().then((v){
            ss.clearPref();
            Navigator.of(context).pushReplacementNamed("login");
          });
        }
      }
    }
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          final Uri deepLink = dynamicLink?.link;

          if (deepLink != null) {
            Navigator.push(
                context,
                PageRouteBuilder(
                    pageBuilder: (_, __, ___) => new DynamicLinkPage(deepLink)));
          }
        },
        onError: (OnLinkErrorException e) async {
          print('onLinkError');
          print(e.message);
        }
    );

    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (_, __, ___) => new DynamicLinkPage(deepLink)));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    String user = ss.getItem('user');
    if(user.isEmpty) {
      ss.clearPref();
      ss.disposePref();
    }else {
      Map<String, dynamic> json = jsonDecode(user);
      FirebaseFirestore.instance.collection("users").doc("${json["uid"]}").update(
          {"status":"offline"});
    }
    super.dispose();
  }
  /// Declare startTime to InitState
  @override
  void initState() {
    super.initState();
    this.initDynamicLinks();
    startTime();
  }

  /// Code Create UI Splash Screen
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        /// Set Background image in splash screen layout (Click to open code)
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/bg3.jpg'), fit: BoxFit.cover)),
        child: Container(
          /// Set gradient black in image splash screen (Click to open code)
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.3),
                    Color.fromRGBO(0, 0, 0, 0.4)
                  ],
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter)),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 30.0),
                    ),
                    /// Text header "Welcome To" (Click to open code)
                    Text(
                      "Welcome to",//Welcome to
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w200,
                        fontFamily: "Roboto",
                        fontSize: 19.0,
                      ),
                    ),
                    /// Animation text Treva Shop to choose Login with Hero Animation (Click to open code)
                    Hero(
                      tag: "Cca",
                      child: Text(
                        "COFFEE CHAT APP",//TAC - Online \nGift Shop
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w900,
                          fontSize: 35.0,
                          letterSpacing: 0.4,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

