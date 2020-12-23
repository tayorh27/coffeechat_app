import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeechat_app/ListItem/ChatUsers.dart';
import 'package:coffeechat_app/ListItem/Coffee.dart';
import 'package:coffeechat_app/ListItem/CoffeeAccess.dart';
import 'package:coffeechat_app/ListItem/CoffeeJoin.dart';
import 'package:coffeechat_app/ListItem/CoffeeUsers.dart';
import 'package:coffeechat_app/ListItem/SavedUsers.dart';
import 'package:coffeechat_app/UI/HomeUIComponent/CoffeeShop.dart';
import 'package:coffeechat_app/UI/HomeUIComponent/CreateCoffee.dart';
import 'package:coffeechat_app/Utils/colors.dart';
import 'package:coffeechat_app/Utils/general.dart';
import 'package:coffeechat_app/Utils/storage.dart';
import 'package:coffeechat_app/values/colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:share_it/share_it.dart';
import 'package:coffeechat_app/Library/date_picker/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyHome();
}

class _MyHome extends State<Home> {
  StorageSystem ss = new StorageSystem();

  buttonWidget(Coffee coffee) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(0.0),
        child: Container(
          width: 100.0,
          height: 30.0,
          child: Text(
            (coffee.access_type == 'public') ? "Join" : "Request",
            style: TextStyle(
                color: Colors.white,
                letterSpacing: 0.2,
                fontFamily: "Roboto",
                fontSize: 16.0,
                fontWeight: FontWeight.w800),
          ),
          alignment: FractionalOffset.center,
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
              borderRadius: BorderRadius.circular(30.0),
              gradient: LinearGradient(
                  colors: (coffee.access_type == 'public')
                      ? <Color>[Color(0xFF121940), Color(0xFF6E48AA)]
                      : <Color>[Colors.red, Colors.redAccent])),
        ),
      ),
      onTap: () async {
        setState(() {
          _inAsyncCall = true;
        });

        String id = FirebaseDatabase.instance.reference().push().key;
        String user = ss.getItem('user');
        Map<String, dynamic> json = jsonDecode(user);

        QuerySnapshot query = await FirebaseFirestore.instance
            .collection('coffee-joins')
            .where('coffee_id', isEqualTo: coffee.id)
            .where('user_id', isEqualTo: json['uid'])
            .get();
        if (query.size > 0) {
          setState(() {
            _inAsyncCall = false;
          });
          new GeneralUtils()
              .neverSatisfied(context, 'Notice', 'You have joined already.');
          return;
        }

        DocumentSnapshot _userQuery = await FirebaseFirestore.instance
            .collection('users')
            .doc(json['uid'])
            .get();
        dynamic userQ = _userQuery.data();

        if (coffee.access_type == 'public') {
          CoffeeJoin cj = CoffeeJoin(
              id,
              coffee.id,
              json['uid'],
              '${json['fn']} ${json['ln']}',
              json['email'],
              json['pic'],
              userQ['msgId'],
              FieldValue.serverTimestamp());

          FirebaseFirestore.instance
              .collection('coffee-joins')
              .doc(id)
              .set(cj.toJSON())
              .then((value) async {
            await FirebaseFirestore.instance
                .collection('coffee')
                .doc(coffee.id)
                .update({'total_users': FieldValue.increment(1)});
            await FirebaseMessaging().subscribeToTopic(coffee.id);
            setState(() {
              _inAsyncCall = false;
            });
            new GeneralUtils()
                .showToast('You have been accepted to this shop.');
          });
        } else {
          QuerySnapshot query = await FirebaseFirestore.instance
              .collection('coffee-requests')
              .where('coffee_id', isEqualTo: coffee.id)
              .where('user_id', isEqualTo: json['uid'])
              .get();
          if (query.size > 0) {
            setState(() {
              _inAsyncCall = false;
            });
            new GeneralUtils().neverSatisfied(
                context, 'Notice', 'You have sent a request already.');
            return;
          }

          CoffeeAccess ca = CoffeeAccess(
              id,
              coffee.id,
              json['uid'],
              '${json['fn']} ${json['ln']}',
              json['email'],
              json['pic'],
              userQ['msgId'],
              FieldValue.serverTimestamp());

          FirebaseFirestore.instance
              .collection('coffee-requests')
              .doc(id)
              .set(ca.toJSON())
              .then((value) async {
            // FirebaseMessaging().//send notification to coffee creator using cloud functions doc.write
            await new GeneralUtils().sendAndRetrieveMessage(
                '${json['fn']} is requesting access to: ${coffee.title}',
                'CoffeeChat - Request Access',
                userQ['msgId']);
            if(!mounted) return;
            setState(() {
              _inAsyncCall = false;
            });
            new GeneralUtils()
                .showToast('Request to access this shop has been sent.');
          });
        }
      },
    );
  }

  buttonWidgetForUsers(CoffeeUsers user) {
    return Padding(
      padding: EdgeInsets.all(0.0),
      child: Container(
        width: 100.0,
        height: 30.0,
        child: Text(
          (user.status == 'online') ? "Online" : "Offline",
          style: TextStyle(
              color: Colors.white,
              letterSpacing: 0.2,
              fontFamily: "Roboto",
              fontSize: 16.0,
              fontWeight: FontWeight.w800),
        ),
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
            borderRadius: BorderRadius.circular(30.0),
            gradient: LinearGradient(
                colors: (user.status == 'online')
                    ? <Color>[Color(0xFF121940), Color(0xFF6E48AA)]
                    : <Color>[Colors.red, Colors.redAccent])),
      ),
    );
  }

  List<Coffee> myCoffee = new List();

  List<CoffeeUsers> cUsers = new List();

  List<String> requestDates = new List();

  bool isNetWorkView = false;

  final _scafoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController bottomSheet;

  TextEditingController e1 = new TextEditingController(text: '');
  final dateFormat = DateFormat("yyyy-MM-dd");
  String meeting_date = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _inAsyncCall = true;
    });

    String user = ss.getItem('user');
    Map<String, dynamic> jsonStat = jsonDecode(user);

    FirebaseFirestore.instance
        .collection("users")
        .doc("${jsonStat["uid"]}")
        .update({"status": "online"});

    //list all users
    FirebaseFirestore.instance
        .collection('users')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((event) {
      cUsers.clear();
      event.docs.forEach((element) {
        setState(() {
          if(element.data()["id"] != jsonStat["uid"]) {
            cUsers.add(CoffeeUsers.fromSnapshot(element.data()));
          }
        });
      });
      setState(() {
        _inAsyncCall = false;
      });
    });

    String userPrefs = ss.getItem('networkPrefs');
    Map<String, dynamic> json = jsonDecode(userPrefs);
    // dynamic list = ["Java","Hello"];
    //json["prefs"]
    FirebaseFirestore.instance
        .collection('coffee')
        .where("interest", arrayContainsAny: json["prefs"])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((event) {
      myCoffee.clear();
      event.docs.forEach((element) {
        setState(() {
          myCoffee.add(Coffee.fromSnapshot(element.data()));
        });
      });
      setState(() {
        _inAsyncCall = false;
      });
    });
  }

  bool _inAsyncCall = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    String user = ss.getItem('user');
    Map<String, dynamic> json = jsonDecode(user);
    String email = json["email"];
    return Scaffold(
        key: _scafoldKey,
        appBar: AppBar(
          title: Text('Coffee Shops'),
          actions: [
            (email.startsWith("pattern"))
                ? FlatButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: (_, __, ___) => new CreateCoffee()));
                    },
                    icon: Icon(Icons.add),
                    label: Text('CREATE'))
                : Text(""),
            FlatButton(
                onPressed: () {
                  setState(() {
                    isNetWorkView = !isNetWorkView;
                  });
                },
                child: (isNetWorkView) ? Text('USERS') : Text('NETWORKS'))
          ],
        ),
        backgroundColor: Colors.white,
        body: ModalProgressHUD(
            opacity: 0.3,
            inAsyncCall: _inAsyncCall,
            progressIndicator: CircularProgressIndicator(),
            color: Color(MyColors.button_text_color),
            child: GestureDetector(child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: (isNetWorkView)
                      ? [
                    Container(
                      height: 20.0,
                    ),
                    ...coffeeBuilder(),
                  ]
                      : [
                    Container(
                      height: 20.0,
                    ),
                    ...coffeeUsersBuilder(),
                  ],
                )), onTap: (){
              if(bottomSheet != null) {
                bottomSheet.close();
              }
            },),
    ));
  }

  List<Widget> coffeeBuilder() {
    List<Widget> builder = new List();

    myCoffee.forEach((coffee) {
      builder.add(buildCoffeeShops(coffee));
    });

    return builder;
  }

  List<Widget> coffeeImagesBuilder(dynamic images) {
    List<Widget> imgBuilder = new List();
    List<dynamic> _images = images;
    _images.forEach((img) {
      imgBuilder.add(Container(
        width: 105.0,
        height: 105.0,
        margin: EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            image:
                DecorationImage(image: NetworkImage(img), fit: BoxFit.cover)),
      ));
    });
    return imgBuilder;
  }

  Widget buildCoffeeShops(Coffee coffee) {
    List<dynamic> imgs = coffee.images;
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      child: Card(
        shadowColor: Colors.black,
        color: Colors.white,
        elevation: 2.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Image.asset(
                "assets/images/${coffee.avatar}",
                fit: BoxFit.none,
              ),
              title: Text(coffee.name,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: -0.384,
                  )),
              subtitle: Text(
                  new GeneralUtils().returnFormattedDate(coffee.created_date),
                  style: TextStyle(
                    color: Colors.black38,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    letterSpacing: -0.384,
                  )),
              trailing: buttonWidget(coffee),
            ),
            (imgs.length > 0)
                ? Container(
                    height: 15.0,
                  )
                : Text(''),
            (imgs.length > 0)
                ? Container(
                    height: 105.0,
                    margin: EdgeInsets.only(left: 20.0),
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: coffeeImagesBuilder(coffee.images)),
                  )
                : Text(''),
            (imgs.length > 0)
                ? Container(
                    height: 15.0,
                  )
                : Text(''),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(coffee.title,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: -0.384,
                  )),
            ),
            Container(
              height: 15.0,
            ),
            Container(
              height: 20,
              margin: EdgeInsets.only(right: 1, left: 15.0, bottom: 20.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 20,
                    margin: EdgeInsets.only(right: 26),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 20,
                            margin: EdgeInsets.only(right: 5),
                            child: Image.asset(
                              "assets/images/icon-6.png",
                              fit: BoxFit.none,
                            ),
                          ),
                        ),
                        Text(
                          "${coffee.total_users}",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.w300,
                            fontSize: 12,
                            letterSpacing: -0.288,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 90,
                    height: 20,
                    margin: EdgeInsets.only(right: 27),
                    child: Row(
                      children: [
                        Container(
                            child: FlatButton(
                          child: Image.asset(
                            "assets/images/share.png",
                            fit: BoxFit.none,
                          ),
                          onPressed: () {
                            ShareIt.link(
                                url: coffee.link,
                                androidSheetTitle: 'CoffeeChat App');
                          },
                        )),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 20,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          child: Image.asset(
                            "assets/images/icon-3.png",
                            fit: BoxFit.none,
                          ),
                        ),
                        Spacer(),
                        Text(
                          "${coffee.total_comments}",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.w300,
                            fontSize: 12,
                            letterSpacing: -0.288,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 90,
                    height: 20,
                    margin: EdgeInsets.only(right: 27),
                    child: Row(
                      children: [
                        Container(
                            child: FlatButton(
                          child: Image.asset(
                            "assets/images/path-1555.png",
                            fit: BoxFit.none,
                          ),
                          onPressed: () async {
                            setState(() {
                              _inAsyncCall = true;
                            });
                            String user = ss.getItem('user');
                            Map<String, dynamic> json = jsonDecode(user);
                            QuerySnapshot query = await FirebaseFirestore
                                .instance
                                .collection('coffee-joins')
                                .where('coffee_id', isEqualTo: coffee.id)
                                .where('user_id', isEqualTo: json['uid'])
                                .get();
                            if (query.size == 0) {
                              if (coffee.access_type == 'public') {
                                joinCoffeeShop(coffee, false);
                                return;
                              }

                              setState(() {
                                _inAsyncCall = false;
                              });
                              new GeneralUtils().neverSatisfied(
                                  context,
                                  'Notice',
                                  "You haven't joined. Please click the ${(coffee.access_type == 'public') ? 'join' : 'request'} button to access this shop.");
                              return;
                            }
                            setState(() {
                              _inAsyncCall = false;
                            });
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (_, __, ___) =>
                                        new CoffeeShop(coffee)));
                          },
                        )),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  joinCoffeeShop(Coffee coffee, bool displayDialog) async {
    String id = FirebaseDatabase.instance.reference().push().key;
    String user = ss.getItem('user');
    Map<String, dynamic> json = jsonDecode(user);

    DocumentSnapshot _userQuery = await FirebaseFirestore.instance
        .collection('users')
        .doc(json['uid'])
        .get();
    dynamic userQ = _userQuery.data();

    CoffeeJoin cj = CoffeeJoin(
        id,
        coffee.id,
        json['uid'],
        json['fn'],
        json['email'],
        json['pic'],
        userQ['msgId'],
        FieldValue.serverTimestamp());

    FirebaseFirestore.instance
        .collection('coffee-joins')
        .doc(id)
        .set(cj.toJSON())
        .then((value) async {
      await FirebaseFirestore.instance
          .collection('coffee')
          .doc(coffee.id)
          .update({'total_users': FieldValue.increment(1)});
      await FirebaseMessaging().subscribeToTopic(coffee.id);
      setState(() {
        _inAsyncCall = false;
      });
      if (displayDialog) {
        new GeneralUtils().showToast('You have been accepted to this shop.');
        return;
      }
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (_, __, ___) => new CoffeeShop(coffee)));
    });
  }

  //users builder
  List<Widget> coffeeUsersBuilder() {
    List<Widget> builder = new List();

    cUsers.forEach((_user) {
      builder.add(buildCoffeeUsers(_user));
    });

    return builder;
  }

  Widget buildCoffeeUsers(CoffeeUsers user) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      child: Card(
        shadowColor: Colors.black,
        color: Colors.white,
        elevation: 2.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Image.asset(
                "assets/images/${user.picture}",
                fit: BoxFit.none,
              ),
              title: Text("${user.firstname} ${user.lastname}",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: -0.384,
                  )),
              trailing: buttonWidgetForUsers(user),
            ),
            Container(
              height: 15.0,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(user.bio,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: -0.384,
                  )),
            ),
            Container(
              height: 15.0,
            ),
            Container(
              height: 20,
              margin: EdgeInsets.only(right: 1, left: 15.0, bottom: 20.0),
              child: Row(
                children: [
                  Container(
                    width: 240,
                    height: 20,
                    margin: EdgeInsets.only(right: 26),
                    child: Row(
                      children: [
                        FlatButton(
                            onPressed: () {
                              saveUser(user);
                            },
                            child: Text(
                              "Save User",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color(MyColors.primary_color),
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: -0.288,
                              ),
                            )),
                        FlatButton(
                            onPressed: () {
                              showBottomSheet(context, user);
                            },
                            child: Text(
                              "Chat With User",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color(MyColors.primary_color),
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: -0.288,
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  saveUser(CoffeeUsers user) async {
    setState(() {
      _inAsyncCall = true;
    });
    String id = FirebaseDatabase.instance.reference().push().key;
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('saved-users')
        .where("user.id", isEqualTo: user.id)
        .get();
    if (query.size > 0) {
      setState(() {
        _inAsyncCall = false;
      });
      new GeneralUtils().showToast('User already saved.');
      return;
    }
    String _user = ss.getItem('user');
    Map<String, dynamic> json = jsonDecode(_user);

    DocumentSnapshot _userQuery = await FirebaseFirestore.instance.collection('users').doc(json['uid']).get();
    dynamic userQ = _userQuery.data();

    SavedUsers su = SavedUsers(
        id, json["uid"], json["email"], '${json['fn']} ${json['ln']}', userQ["msgId"], new DateTime.now().toString(), FieldValue.serverTimestamp(), user);
    await FirebaseFirestore.instance
        .collection('saved-users')
        .doc(id)
        .set(su.toJSON());
    setState(() {
      _inAsyncCall = false;
    });
    new GeneralUtils().showToast('User saved successfully.');
  }

  showBottomSheet(BuildContext context, CoffeeUsers user) {
    bottomSheet = _scafoldKey.currentState.showBottomSheet((context) {
      return Container(
        height: 400.0,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(0)),
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.grey[300], spreadRadius: 20)
          ],
        ),
        child: ListView(
          // mainAxisSize: MainAxisSize.max,
          // crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.start,
          scrollDirection: Axis.vertical,
          children: [
            Text(
              "Specify at least 3 dates when you would like to have a chat with ${user.firstname}.",
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
        Theme(
                            data: ThemeData(
                              hintColor: Colors.transparent,
                            ),
                            child: new DateTimeField(
                              format: dateFormat,
                              onChanged: (date) {
                                meeting_date = date.toString();
                                displayTimePicker();
                              },
                              controller: e1,
                              decoration: new InputDecoration(
                                  labelText: 'Select Date and Time*',
                                  hintText: "Select Date and Time*",
                                  alignLabelWithHint: true,
                                  hasFloatingPlaceholder: true,
                                  border: InputBorder.none,
                                  labelStyle: TextStyle(
                                      fontSize: 13.0,
                                      fontFamily: 'Roboto',
                                      letterSpacing: 0.3,
                                      color: Colors.black38,
                                      fontWeight: FontWeight.w600)),
                              onShowPicker: (context, currentValue) {
                                return showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1900),
                                    initialDate: currentValue ??
                                        DateTime.now(),
                                    lastDate: DateTime(2500));
                              },
                            )),
            Container(height: 20.0,),
            ...buildDatesView(),
            (requestDates.length > 0) ? InkWell(
              onTap: (){
                bottomSheet.close();
                chatUser(user);
              },
              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: Container(
                  height: 55.0,
                  child: Text(
                    "Send Chat Request",
                    style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 0.2,
                        fontFamily: "Roboto",
                        fontSize: 18.0,
                        fontWeight: FontWeight.w800),
                  ),
                  alignment: FractionalOffset.center,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black38, blurRadius: 15.0)
                      ],
                      borderRadius: BorderRadius.circular(30.0),
                      gradient: LinearGradient(colors: <Color>[
                        Color(0xFF121940),
                        Color(0xFF6E48AA)
                      ])),
                ),
              ),
            ) : Text('')
          ],
        ),
      );
    });
  }

  List<Widget> buildDatesView() {
    List<Widget> builder = new List();

    requestDates.forEach((element) {
      builder.add(
        ListTile(
          leading: Icon(Icons.access_time_outlined),
          title: Text(element),
          trailing: FlatButton.icon(onPressed: (){
            bottomSheet.setState(() {
              requestDates.remove(element);
            });
          }, icon: Icon(Icons.delete), label: Text('')),
        )
      );
    });

    return builder;
  }

  displayTimePicker() {
    showTimePicker(context: context, initialTime: TimeOfDay.now()).then((value) {
      if(requestDates.length == 3) {
        new GeneralUtils().showToast('You can only add 3 dates.');
        return;
      }
      bottomSheet.setState(() {
        requestDates.add("$meeting_date ${value.hour}:${value.minute}");
        meeting_date = "";
        e1.clear();
      });
      Navigator.of(context).pop();
    });
  }

  chatUser(CoffeeUsers user) async {
    setState(() {
      _inAsyncCall = true;
    });
    String id = FirebaseDatabase.instance.reference().push().key;
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('chats-request')
        .where("user.id", isEqualTo: user.id)
        .get();
    if (query.size > 0) {
      setState(() {
        _inAsyncCall = false;
      });
      new GeneralUtils().showToast('Request sent already to user.');
      await new GeneralUtils().sendAndRetrieveMessage(
          '${user.firstname} ${user.lastname} is requesting to chat with you.',
          'CoffeeChat - Chat Request',
          user.msgId);
      return;
    }

    String _user = ss.getItem('user');
    Map<String, dynamic> json = jsonDecode(_user);

    DocumentSnapshot _userQuery = await FirebaseFirestore.instance.collection('users').doc(json['uid']).get();
    dynamic userQ = _userQuery.data();

    ChatUsers cu = ChatUsers(id, json["uid"], json["email"], '${json['fn']} ${json['ln']}', userQ["msgId"], new DateTime.now().toString(),
        FieldValue.serverTimestamp(), requestDates, "", "pending", user, user.id);
    await FirebaseFirestore.instance
        .collection('chats-request')
        .doc(id)
        .set(cu.toJSON());
    setState(() {
      _inAsyncCall = false;
      requestDates.clear();
    });
    new GeneralUtils().showToast('Request sent successfully.');
    await new GeneralUtils().sendAndRetrieveMessage(
        '${user.firstname} ${user.lastname} is requesting to chat with you.',
        'CoffeeChat - Chat Request',
        user.msgId);
  }
}
