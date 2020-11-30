
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeechat_app/ListItem/Coffee.dart';
import 'package:coffeechat_app/ListItem/CoffeeAccess.dart';
import 'package:coffeechat_app/ListItem/CoffeeComments.dart';
import 'package:coffeechat_app/ListItem/CoffeeJoin.dart';
import 'package:coffeechat_app/UI/HomeUIComponent/theme_top_scroll.dart';
import 'package:coffeechat_app/UI/SharedUIComponent/EmptyCoffeeShopsUI.dart';
import 'package:coffeechat_app/Utils/colors.dart';
import 'package:coffeechat_app/Utils/general.dart';
import 'package:coffeechat_app/Utils/storage.dart';
import 'package:coffeechat_app/values/colors.dart';
import 'package:firebase_database/firebase_database.dart' as db;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:link_text/link_text.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:share_it/share_it.dart';

class CoffeeShop extends StatefulWidget {

  final Coffee coffee;
  CoffeeShop(this.coffee);

  @override
  State<StatefulWidget> createState() => _CoffeeShop();
}

class _CoffeeShop extends State<CoffeeShop> {

  StorageSystem ss = new StorageSystem();

  List<CoffeeJoin> coffeeJoins = new List();
  List<CoffeeAccess> coffeeAccess = new List();
  List<CoffeeComment> coffeeComments = new List();

  bool _inAsyncCall = false;
  var selected_menu = 'Coffee Shop';

  TextEditingController t1 = new TextEditingController(text: '');
  ScrollController sc = new ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _inAsyncCall = true;
    });
    String user = ss.getItem('user');
    Map<String, dynamic> json = jsonDecode(user);

    getUsersInCoffeeShop();
    if(json['uid'] == widget.coffee.user_id && widget.coffee.access_type == 'private') {
      getUserRequestsInCoffeeShop();
    }
    getUserCommentsInCoffeeShop();
  }

  void getUsersInCoffeeShop() {
    FirebaseFirestore.instance
        .collection('coffee-joins').where('coffee_id', isEqualTo: widget.coffee.id).orderBy('timestamp', descending: true)
        .snapshots()
        .listen((event) {
      coffeeJoins.clear();
      event.docs.forEach((element) {
        setState(() {
          coffeeJoins.add(CoffeeJoin.fromSnapshot(element.data()));
        });
      });
    });
  }

  void getUserRequestsInCoffeeShop() {
    FirebaseFirestore.instance
        .collection('coffee-requests').where('coffee_id', isEqualTo: widget.coffee.id).orderBy('timestamp', descending: true)
        .snapshots()
        .listen((event) {
      coffeeAccess.clear();
      event.docs.forEach((element) {
        setState(() {
          coffeeAccess.add(CoffeeAccess.fromSnapshot(element.data()));
        });
      });
    });
  }

  void getUserCommentsInCoffeeShop() {
    Query reference = FirebaseFirestore.instance
        .collection('coffee-comments').where('coffee_id', isEqualTo: widget.coffee.id).orderBy('timestamp', descending: false);
    reference.snapshots().listen((event) {
      coffeeComments.clear();
      event.docs.forEach((element) {
        setState(() {
          coffeeComments.add(CoffeeComment.fromSnapshot(element.data()));
        });
      });
      setState(() {
        _inAsyncCall = false;
        sc.animateTo(
          sc.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.coffee.title}'),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        backgroundColor: Colors.white,
        body: ModalProgressHUD(
            opacity: 0.3,
            inAsyncCall: _inAsyncCall,
            progressIndicator: CircularProgressIndicator(),
            color: Color(MyColors.button_text_color),
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    Container(
                      height: 20.0,
                    ),
                    _topScroll(context),
                    ...buildSelectedMenuLayout(),
                  ],
                ))));
  }

  Widget _topScroll(BuildContext context) {
    String user = ss.getItem('user');
    Map<String, dynamic> json = jsonDecode(user);
    return Container(
      height: 55,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          topScrollElement(context, "Coffee Shop", selected: selected_menu == "Coffee Shop",
              onTap: () {
                changeMenu('Coffee Shop', context);
              }),
          topScrollElement(context, "Users",
              selected: selected_menu == "Users", onTap: () {
                changeMenu('Users', context);
              }),
          (json['uid'] == widget.coffee.user_id && widget.coffee.access_type == 'private') ? topScrollElement(context, "Request Access",
              selected: selected_menu == "Request Access", onTap: () {
                changeMenu('Request Access', context);
              }) : Text(''),
          topScrollElement(context, "Chats",
              selected: selected_menu == "Chats", onTap: () {
                changeMenu('Chats', context);
              }),
        ],
      ),
    );
  }

  void changeMenu(String menu, BuildContext context) {
    if (!mounted) return;
    setState(() {
      selected_menu = menu;
      _topScroll(context);
      buildSelectedMenuLayout();
    });
  }

  List<Widget> buildSelectedMenuLayout() {
    List<dynamic> options = [
      {
      'id':'Coffee Shop',
        'errorText': '',
        'widget': buildCoffeeShopLayout()
      },
      {
        'id':'Users',
        'errorText': 'No user has joined this shop.',
        'widget': buildUsersLayout()
      },
      {
        'id':'Request Access',
        'errorText': 'No user has requested for an access.',
        'widget': buildRequestAccessLayout()
      },
      {
        'id':'Chats',
        'errorText': 'No chat available yet.',
        'widget': buildChatsLayout()
      }
    ];
    dynamic _findOption = options.firstWhere((element) => element['id'] == selected_menu);
    return (_findOption['widget'].length > 0) ? _findOption['widget'] : [EmptyCoffeeShop(_findOption['errorText'])];
  }

  List<Widget> buildCoffeeShopLayout() {
    List<dynamic> imgs = widget.coffee.images;
    return [
     Container(
      margin: EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Image.asset(
              "assets/images/${widget.coffee.avatar}",
              fit: BoxFit.none,
            ),
            title: Text(widget.coffee.name,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.384,
                )),
            subtitle: Text(new GeneralUtils().returnFormattedDate(widget.coffee.created_date),
                style: TextStyle(
                  color: Colors.black38,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  letterSpacing: -0.384,
                )),
            // trailing: buttonWidget(coffee),
          ),
          (imgs.length > 0) ? Container(
            height: 15.0,
          ) : Text(''),
          (imgs.length > 0) ? Container(
            height: 105.0,
            margin: EdgeInsets.only(left: 20.0),
            child: ListView(
                scrollDirection: Axis.horizontal,
                children: coffeeImagesBuilder(widget.coffee.images)
            ),
          ) : Text(''),
          (imgs.length > 0) ? Container(
            height: 15.0,
          ) : Text(''),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
                widget.coffee.title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Roboto",
                  fontSize: 15,
                  letterSpacing: -0.384,
                )),
          ),
          Container(
            height: 15.0,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
                widget.coffee.description,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Roboto",
                  fontSize: 15,
                  letterSpacing: -0.384,
                )),
          ),
          Container(
            height: 15.0,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: LinkText(
              text: widget.coffee.zoom_invite,
              textAlign: TextAlign.start,
              textStyle: TextStyle(
                    color: Colors.black,
                fontWeight: FontWeight.w700,
                    fontFamily: "Roboto",
                    fontSize: 15,
                    letterSpacing: -0.384,
                  ),
              linkStyle: TextStyle(
                color: Colors.blue,
                fontFamily: "Roboto",
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: -0.384,
              ),
            )
            // Text(
            //     widget.coffee.description,
            //     textAlign: TextAlign.start,
            //     style: TextStyle(
            //       color: Colors.black,
            //       fontFamily: "Roboto",
            //       fontSize: 15,
            //       letterSpacing: -0.384,
            //     )),
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
                        "${widget.coffee.total_users}",
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
                                  url: widget.coffee.link,
                                  androidSheetTitle: 'CoffeeChat App'
                              );
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
                        "${widget.coffee.total_comments}",
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
              ],
            ),
          ),
        ],
      ),
    )
    ];
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
            image: DecorationImage(
                image: NetworkImage(img),
                fit: BoxFit.cover)),
      ));
    });
    return imgBuilder;
  }

  List<Widget> buildUsersLayout() {
    List<Widget> usersBuilder = new List();
    coffeeJoins.forEach((user) {
      usersBuilder.add(
        Padding(padding: EdgeInsets.all(20.0), child: Container(
          child: Column(
            children: [
              ListTile(
                leading: Image.asset(
                  "assets/images/${user.picture}",
                  fit: BoxFit.none,
                ),
                title: Text(user.name,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: -0.384,
                    )),
                // subtitle: Text('${DateTime.now().difference(DateTime.parse(coffee.created_date)).inMinutes} mins ago',
                //     style: TextStyle(
                //       color: Colors.black38,
                //       fontFamily: "Roboto",
                //       fontWeight: FontWeight.w500,
                //       fontSize: 13,
                //       letterSpacing: -0.384,
                //     )),
                // trailing: buttonWidget(coffee),
              ),
              Divider(thickness: 1.0, color: Colors.grey,)
            ],
          ),
        ),)
      );
    });
    return usersBuilder;
  }

  List<Widget> buildRequestAccessLayout() {
    List<Widget> accessBuilder = new List();
    coffeeAccess.forEach((user) {
      accessBuilder.add(
          Padding(padding: EdgeInsets.all(20.0), child: Container(
            child: Column(
              children: [
                ListTile(
                  leading: Image.asset(
                    "assets/images/${user.picture}",
                    fit: BoxFit.none,
                  ),
                  title: Text(user.name,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.384,
                      )),
                  // subtitle: Text('${DateTime.now().difference(DateTime.parse(coffee.created_date)).inMinutes} mins ago',
                  //     style: TextStyle(
                  //       color: Colors.black38,
                  //       fontFamily: "Roboto",
                  //       fontWeight: FontWeight.w500,
                  //       fontSize: 13,
                  //       letterSpacing: -0.384,
                  //     )),
                  trailing: buttonWidget(user),
                ),
                Divider(thickness: 1.0, color: Colors.grey,)
              ],
            ),
          ),)
      );
    });
    return accessBuilder;
  }

  List<Widget> buildChatsLayout() {
    return [
      Container(
        height: MediaQuery.of(context).size.height - 175.0,
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 250.0,
              child: ListView(
                  scrollDirection: Axis.vertical,
                  controller: sc,
                  children: displayChats()
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: chatTextField(),
            )
          ],
        )
      )
    ];
  }

  Widget chatTextField() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(bottom: 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 10.0, right: 0.0),
              child: Container(
                  width:
                  MediaQuery.of(context).size.width - 110.0,
                  height: 60.0,
                  alignment: AlignmentDirectional.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 10.0,
                            color: Colors.black12)
                      ]),
                  padding: EdgeInsets.only(
                      left: 0.0,
                      right: 0.0,
                      top: 0.0,
                      bottom: 0.0),
                  child: Theme(
                      data: ThemeData(
                        hintColor: Colors.transparent,
                      ),
                      child: textFromField(t1,
                          password: false,
                          placeholder: "Type a message",
                          inputType: TextInputType.multiline,
                          min: 3,
                          max: 10),))),
          Padding(
              padding: EdgeInsets.only(left: 10.0, right: 0.0),
              child: Container(
                  width: 60.0,
                  height: 60.0,
                  alignment: AlignmentDirectional.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 10.0,
                            color: Colors.black12)
                      ]),
                  padding: EdgeInsets.only(
                      left: 10.0,
                      right: 0.0,
                      top: 0.0,
                      bottom: 0.0),
                  child: Theme(
                      data: ThemeData(
                        hintColor: Colors.transparent,
                      ),
                      child: IconButton(icon: Icon(Icons.send), onPressed: (){
                        sendMessage();
                      })))),
        ],
      ),
    );
  }

  List<Widget> displayChats() {
    String user = ss.getItem('user');
    Map<String, dynamic> json = jsonDecode(user);

    List<Widget> chatsBuilder = new List();
    coffeeComments.forEach((comment) {
      chatsBuilder.add(
          Padding(padding: EdgeInsets.only(top: 0), child: Container(
            child: Column(
              children: [
                (comment.user_id != json['uid']) ? ListTile(
                  leading: Image.asset(
                    "assets/images/${comment.picture}",
                    fit: BoxFit.none,
                  ),
                  title: Text(comment.name,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.384,
                      )),
                  subtitle: Text(comment.message,
                      style: TextStyle(
                        color: Colors.black38,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        letterSpacing: -0.384,
                      )),
                  trailing: Text(new GeneralUtils().returnFormattedDate(comment.created_date),
                      style: TextStyle(
                        color: Colors.black38,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        letterSpacing: -0.384,
                      )),
                ) : Directionality(
                  textDirection: TextDirection.rtl,
                    child: ListTile(
                  leading: Image.asset(
                    "assets/images/${comment.picture}",
                    fit: BoxFit.none,
                  ),
                  title: Text(comment.name,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.384,
                      )),
                  subtitle: Directionality(
                    textDirection: TextDirection.ltr,
                    child:Text(comment.message,textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.black38,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        letterSpacing: -0.384,
                      ))),
                  trailing: Directionality(
                    textDirection: TextDirection.ltr,
                    child:Text(new GeneralUtils().returnFormattedDate(comment.created_date),
                      style: TextStyle(
                        color: Colors.black38,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        letterSpacing: -0.384,
                      ))),
                ))
              ],
            ),
          ),)
      );
    });
    return chatsBuilder;
  }

  void sendMessage() async {
    if(t1.text.isEmpty) {
      return;
    }
    setState(() {
      _inAsyncCall = true;
    });
    String id = db.FirebaseDatabase.instance.reference().push().key;
    String user = ss.getItem('user');
    Map<String, dynamic> json = jsonDecode(user);

    DocumentSnapshot _userQuery = await FirebaseFirestore.instance.collection('users').doc(json['uid']).get();
    dynamic userQ = _userQuery.data();

    CoffeeComment cc = CoffeeComment(id, widget.coffee.id, json['uid'], '${json['fn']} ${json['ln']}', json['email'], json['pic'], t1.text, new DateTime.now().toString(), userQ['msgId'], FieldValue.serverTimestamp());
    FirebaseFirestore.instance.collection('coffee-comments').doc(id).set(cc.toJSON()).then((value) async {
      await FirebaseFirestore.instance.collection('coffee').doc(widget.coffee.id).update({'total_users': FieldValue.increment(1)});
      await new GeneralUtils().sendNotificationToTopic(t1.text, 'CoffeeChat - New Message', widget.coffee.id);
      setState(() {
        t1.clear();
        // coffeeComments.add(cc);
        _inAsyncCall = false;
        sc.animateTo(
          sc.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      });

    }).catchError((err) {
      print(err);
      setState(() {
        _inAsyncCall = false;
      });
      new GeneralUtils().neverSatisfied(
          context, 'Error', 'An error occurred, please try again.');
    });
  }

  buttonWidget(CoffeeAccess coffeeUser) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(0.0),
        child: Container(
          width: 100.0,
          height: 30.0,
          child: Text(
            "Accept",
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
                  colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])),
        ),
      ),
      onTap: () async {
        setState(() {
          _inAsyncCall = true;
        });

        String id = db.FirebaseDatabase.instance.reference().push().key;

        FirebaseFirestore.instance.collection('coffee-joins').doc(id).set(coffeeUser.toJSON()).then((value) async {
          await FirebaseFirestore.instance.collection('coffee').doc(widget.coffee.id).update({'total_users': FieldValue.increment(1)});
          await FirebaseFirestore.instance.collection('coffee-requests').doc(coffeeUser.id).delete();
          await FirebaseMessaging().subscribeToTopic(widget.coffee.id);
          //send notification to user
          await new GeneralUtils().sendAndRetrieveMessage('You have been granted access to: ${widget.coffee.title}', 'CoffeeChat - Access Granted', coffeeUser.msgId);
          setState(() {
            coffeeAccess.remove(coffeeUser);
            _inAsyncCall = false;
          });
          new GeneralUtils().showToast('You have accepted ${coffeeUser.name} to this shop.');
        });

      },
    );
  }

  /// textfromfield custom class
  Widget textFromField(TextEditingController _controller,
      {String placeholder,
        TextInputType inputType,
        int min,
        int max,
        bool password}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        // height: 60.0,
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)]),
        padding:
        EdgeInsets.only(left: 10.0, right: 30.0, top: 0.0, bottom: 0.0),
        child: Theme(
          data: ThemeData(
            hintColor: Colors.transparent,
          ),
          child: TextFormField(
            obscureText: password,
            minLines: min,
            maxLines: max,
            controller: _controller,
            decoration: InputDecoration(
                border: InputBorder.none,
                labelText: placeholder,
                fillColor: Color(MyColors.primary_color),
                focusColor: Color(MyColors.primary_color),
                labelStyle: TextStyle(
                    fontSize: 15.0,
                    fontFamily: 'Roboto',
                    letterSpacing: 0.3,
                    color: Colors.black38,
                    fontWeight: FontWeight.w700)),
            keyboardType: inputType,
          ),
        ),
      ),
    );
  }
}