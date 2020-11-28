import 'dart:async';
import 'package:flutter/material.dart';
import 'package:coffeechat_app/UI/BottomNavigationBar.dart';
import 'package:coffeechat_app/UI/HomeUIComponent/Home.dart';
import 'package:coffeechat_app/UI/LoginOrSignup/Login.dart';
import 'package:coffeechat_app/UI/LoginOrSignup/Signup.dart';
import 'package:coffeechat_app/Utils/progress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coffeechat_app/Utils/storage.dart';


class ChoseLogin extends StatefulWidget {
  @override
  _ChoseLoginState createState() => _ChoseLoginState();
}

/// Component Widget this layout UI
class _ChoseLoginState extends State<ChoseLogin> with TickerProviderStateMixin {
  /// Declare Animation
  AnimationController animationController;
  var tapLogin = 0;
  var tapSignup = 0;

  //progress init
  ProgressDisplay pd;
  StorageSystem ss = new StorageSystem();

  @override
  /// Declare animation in initState
  void initState() {
    // TODO: implement initState
    /// Animation proses duration
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300))
          ..addStatusListener((statuss) {
            if (statuss == AnimationStatus.dismissed) {
              setState(() {
                tapLogin = 0;
                tapSignup = 0;
              });
            }
          });
    super.initState();
  }

  /// To dispose animation controller
  @override
  void dispose() {
    //ss.disposePref();
    super.dispose();
    animationController.dispose();
    // TODO: implement dispose
  }

  /// Playanimation set forward reverse
  Future<Null> _Playanimation() async {
    try {
      await animationController.forward();
      await animationController.reverse();
    } on TickerCanceled {}
  }

  /// Component Widget layout UI
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    mediaQuery.devicePixelRatio;
    mediaQuery.size.height;
    mediaQuery.size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
         Container(
          /// Set Background image in layout (Click to open code)
          decoration: BoxDecoration(
             image: DecorationImage(
                 image: AssetImage('assets/images/bg1.jpg'), fit: BoxFit.cover)
    ),
          child: Container(
            /// Set gradient color in image (Click to open code)
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                  Color.fromRGBO(0, 0, 0, 0.3),
                  Color.fromRGBO(0, 0, 0, 0.4)
                ],
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter)),

            /// Set component layout
            child: ListView(
              padding: EdgeInsets.all(0.0),
              children: <Widget>[
                Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: <Widget>[
                    Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: <Widget>[
                        Container(
                          alignment: AlignmentDirectional.center,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                    top: mediaQuery.padding.top + 50.0),
                              ),
                              Center(
                                /// Animation text treva shop accept from splashscreen layout (Click to open code)
                                child: Hero(
                                  tag: "Tac",
                                  child: Text(
                                    "Coffee Chat App",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w900,
                                      fontSize: 32.0,
                                      letterSpacing: 0.4,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              /// Padding Text "Get best product in treva shop" (Click to open code)
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 160.0,
                                      right: 160.0,
                                      top: mediaQuery.padding.top + 190.0,
                                      bottom: 10.0),
                                  child: Container(
                                    color: Colors.white,
                                    height: 0.5,
                                  )),

                              /// to set Text "get best product...." (Click to open code)
                              Text(
                                "Offer coffee to one another",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: "Roboto",
                                    letterSpacing: 1.3),
                              ),
                              Padding(padding: EdgeInsets.only(top: 250.0)),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            /// To create animation if user tap == animation play (Click to open code)
                            tapLogin == 0
                                ? Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      splashColor: Colors.white,
                                      onTap: () {
                                        setState(() {
                                          tapLogin = 1;
                                        });
                                        _Playanimation();
                                        return tapLogin;
                                      },
                                      child: ButtonCustom(txt: "Signup"),
                                    ),
                                  )
                                : AnimationSplashSignup(
                                    animationController: animationController.view,
                                  ),
                            Padding(padding: EdgeInsets.only(top: 25.0)),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  /// To set white line (Click to open code)
                                  Container(
                                    color: Colors.white,
                                    height: 0.2,
                                    width: 80.0,
                                  ),


                                  /// To set white line (Click to open code)
                                  Container(
                                    color: Colors.white,
                                    height: 0.2,
                                    width: 80.0,
                                  )
                                ],
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 80.0)),
                          ],
                        ),

                        /// To create animation if user tap == animation play (Click to open code)
                        tapSignup == 0
                            ? Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors.white,
                                  onTap: () {
                                    setState(() {
                                      tapSignup = 1;
                                    });
                                    _Playanimation();
                                    return tapSignup;
                                  },
                                  child: ButtonCustom(txt: "Login"),
                                ),
                              )
                            : AnimationSplashLogin(
                                animationController: animationController.view,
                              ),
                      ],
                    ),
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

  void skipPressed() {
    pd = new ProgressDisplay(context);
    pd.displayDialog("Please wait...");
    FirebaseAuth.instance.signInAnonymously().then((user){
      pd.dismissDialog();
      ss.setPrefItem('loggedin', 'signInAnonymously');
      Navigator.of(context).pushReplacement(
          PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
              new bottomNavigationBar()));
    }).catchError((err){
      pd.dismissDialog();
      pd.displayMessage(context, 'Error', '${err.toString()}');
    });
  }
}

/// Button Custom widget
class ButtonCustom extends StatelessWidget {
  @override
  String txt;
  GestureTapCallback ontap;

  ButtonCustom({this.txt});

  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.white,
        child: LayoutBuilder(builder: (context, constraint) {
          return Container(
            width: 300.0,
            height: 52.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.transparent,
                border: Border.all(color: Colors.white)),
            child: Center(
                child: Text(
              txt,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 19.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Roboto",
                  letterSpacing: 0.5),
            )),
          );
        }),
      ),
    );
  }
}

/// Set Animation Login if user click button login
class AnimationSplashLogin extends StatefulWidget {
  AnimationSplashLogin({Key key, this.animationController})
      : animation = new Tween(
          end: 900.0,
          begin: 70.0,
        ).animate(CurvedAnimation(
            parent: animationController, curve: Curves.fastOutSlowIn)),
        super(key: key);

  final AnimationController animationController;
  final Animation animation;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Padding(
      padding: EdgeInsets.only(bottom: 60.0),
      child: Container(
        height: animation.value,
        width: animation.value,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: animation.value < 600 ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }

  @override
  _AnimationSplashLoginState createState() => _AnimationSplashLoginState();
}

/// Set Animation Login if user click button login
class _AnimationSplashLoginState extends State<AnimationSplashLogin> {
  @override
  Widget build(BuildContext context) {
    widget.animationController.addListener(() {
      if (widget.animation.isCompleted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => new loginScreen()));
      }
    });
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: widget._buildAnimation,
    );
  }
}

/// Set Animation signup if user click button signup
class AnimationSplashSignup extends StatefulWidget {
  AnimationSplashSignup({Key key, this.animationController})
      : animation = new Tween(
          end: 900.0,
          begin: 70.0,
        ).animate(CurvedAnimation(
            parent: animationController, curve: Curves.fastOutSlowIn)),
        super(key: key);

  final AnimationController animationController;
  final Animation animation;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Padding(
      padding: EdgeInsets.only(bottom: 60.0),
      child: Container(
        height: animation.value,
        width: animation.value,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: animation.value < 600 ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }

  @override
  _AnimationSplashSignupState createState() => _AnimationSplashSignupState();
}

/// Set Animation signup if user click button signup
class _AnimationSplashSignupState extends State<AnimationSplashSignup> {
  @override
  Widget build(BuildContext context) {
    widget.animationController.addListener(() {
      if (widget.animation.isCompleted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => new Signup()));
      }
    });
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: widget._buildAnimation,
    );
  }
}