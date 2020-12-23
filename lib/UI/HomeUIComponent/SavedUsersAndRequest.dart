import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeechat_app/ListItem/ChatUsers.dart';
import 'package:coffeechat_app/ListItem/CoffeeUsers.dart';
import 'package:coffeechat_app/ListItem/SavedUsers.dart';
import 'package:coffeechat_app/UI/HomeUIComponent/theme_top_scroll.dart';
import 'package:coffeechat_app/UI/SharedUIComponent/EmptyCoffeeShopsUI.dart';
import 'package:coffeechat_app/UI/ZoomUI/StartZoom.dart';
import 'package:coffeechat_app/Utils/colors.dart';
import 'package:coffeechat_app/Utils/general.dart';
import 'package:coffeechat_app/Utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:intl/intl.dart';

class SavedUsersAndRequest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SavedUsersAndRequest();
}

class _SavedUsersAndRequest extends State<SavedUsersAndRequest> {

  StorageSystem ss = new StorageSystem();

  bool _inAsyncCall = false;
  var selected_menu = 'Saved Users';

  List<SavedUsers> savedUsers = new List();

  List<ChatUsers> chatUserRequests = new List();
  List<ChatUsers> chatUsers = new List();

  final _scafoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController bottomSheet;

  String meeting_selected_date = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _inAsyncCall = true;
    });
    getSavedUsers();
    getChatRequest();
    getChats();
  }

  void getSavedUsers() {
    String user = ss.getItem('user');
    Map<String, dynamic> json = jsonDecode(user);
    FirebaseFirestore.instance
        .collection('saved-users').where('uid', isEqualTo: json["uid"]).orderBy('timestamp', descending: true)
        .snapshots()
        .listen((event) {
      if(!mounted) return;
      savedUsers.clear();
      event.docs.forEach((element) {
        setState(() {
          savedUsers.add(SavedUsers.fromSnapshot(element.data()));
        });
      });
    });
  }

  void getChatRequest() {
    String user = ss.getItem('user');
    Map<String, dynamic> json = jsonDecode(user);
    FirebaseFirestore.instance
        .collection('chats-request').where('request_to', isEqualTo: json["uid"]).where("status", isEqualTo: "pending").orderBy('timestamp', descending: true)
        .snapshots()
        .listen((event) {
      if(!mounted) return;
      chatUserRequests.clear();
      event.docs.forEach((element) {
        setState(() {
          chatUserRequests.add(ChatUsers.fromSnapshot(element.data()));
        });
      });
    });
  }

  void getChats() {
    String user = ss.getItem('user');
    Map<String, dynamic> json = jsonDecode(user);
    FirebaseFirestore.instance
        .collection('chats-request').where('uid', isEqualTo: json["uid"]).orderBy('timestamp', descending: true)
        .snapshots()
        .listen((event) {
      if(!mounted) return;
      chatUsers.clear();
      event.docs.forEach((element) {
        setState(() {
          chatUsers.add(ChatUsers.fromSnapshot(element.data()));
        });
      });
      setState(() {
        _inAsyncCall = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scafoldKey,
        appBar: AppBar(
          title: Text('Saved Users And Chat Requests'),
          automaticallyImplyLeading: false,
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
          topScrollElement(context, "Saved Users", selected: selected_menu == "Saved Users",
              onTap: () {
                changeMenu('Saved Users', context);
              }),
          topScrollElement(context, "Chat Requests",
              selected: selected_menu == "Chat Requests", onTap: () {
                changeMenu('Chat Requests', context);
              }),
          topScrollElement(context, "Available Chats",
              selected: selected_menu == "Available Chats", onTap: () {
                changeMenu('Available Chats', context);
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
        'id':'Saved Users',
        'errorText': 'No saved users available yet.',
        'widget': buildSavedUsersLayout()
      },
      {
        'id':'Chat Requests',
        'errorText': 'No chat request available yet.',
        'widget': buildChatRequestsLayout()
      },
      {
        'id':'Available Chats',
        'errorText': 'No chat available yet.',
        'widget': buildChatsAvailable()
      }
    ];
    dynamic _findOption = options.firstWhere((element) => element['id'] == selected_menu);
    return (_findOption['widget'].length > 0) ? _findOption['widget'] : [EmptyCoffeeShop(_findOption['errorText'])];
  }

  List<Widget> buildSavedUsersLayout() {
    List<Widget> usersBuilder = new List();
    savedUsers.forEach((user) {
      usersBuilder.add(
          Padding(padding: EdgeInsets.only(left:0.0, right: 0.0, top: 20.0), child: Container(
            child: Column(
              children: [
                ListTile(
                  leading: Image.asset(
                    "assets/images/${user.user.picture}",
                    fit: BoxFit.none,
                  ),
                  title: Text("${user.user.firstname} ${user.user.lastname}",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.384,
                      )),
                ),
                Divider(thickness: 1.0, color: Colors.grey,)
              ],
            ),
          ),)
      );
    });
    return usersBuilder;
  }

  List<Widget> buildChatRequestsLayout() {
    List<Widget> usersBuilder = new List();
    chatUserRequests.forEach((user) {
      usersBuilder.add(
          Padding(padding: EdgeInsets.only(left:20.0, right: 20.0, top: 20.0), child: Container(
            child: Column(
              children: [
                ListTile(
                  leading: Image.asset(
                    "assets/images/${user.user.picture}",
                    fit: BoxFit.none,
                  ),
                  title: Text("${user.user.firstname} ${user.user.lastname}",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.384,
                      )),
                  subtitle: Text(new GeneralUtils().returnFormattedDate(user.created_date),
                      style: TextStyle(
                        color: Colors.black38,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        letterSpacing: -0.384,
                      )),
                  trailing: Container(
                    width: 100.0,
                    height: 30.0,
                    child: Text("Review",
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
                  onTap: (){
                    showBottomSheet(context, user);
                  },
                ),
                Divider(thickness: 1.0, color: Colors.grey,)
              ],
            ),
          ),)
      );
    });
    return usersBuilder;
  }

  showBottomSheet(BuildContext context, ChatUsers user) {
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
          scrollDirection: Axis.vertical,
          children: [
            Text(
              "${user.name} wants to have a chat with you. You are required to select the date you will be available from the specified dates below.",
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
            Container(height: 20.0,),
            ...buildDatesView(user),
            InkWell(
              onTap: (){
                bottomSheet.close();
                acceptUserRequest(user, true);
              },
              child: Padding(
                padding: EdgeInsets.only(left:20.0, right: 20.0, top: 20.0),
                child: Container(
                  height: 55.0,
                  child: Text(
                    "Accept Request",
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
            ),
            InkWell(
              onTap: (){
                bottomSheet.close();
                acceptUserRequest(user, false);
              },
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Container(
                  height: 55.0,
                  child: Text(
                    "Decline Request",
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
                        Colors.red, Colors.redAccent
                      ])),
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  acceptUserRequest(ChatUsers user, bool accepted) async{
    if(accepted) {
      if (meeting_selected_date.isEmpty) {
        new GeneralUtils()
            .neverSatisfied(context, 'Error', 'Please select a date.');
        return;
      }
    }
    setState(() {
      _inAsyncCall = true;
    });
    await FirebaseFirestore.instance
        .collection('chats-request')
        .doc(user.id)
        .update({"status": (accepted) ? "accepted" : "declined", "selected_date": meeting_selected_date});
    setState(() {
      _inAsyncCall = false;
    });
    if(accepted) {
      new GeneralUtils().showToast('Request accepted successfully.');
    }else {
      new GeneralUtils().showToast('Request declined successfully.');
    }

    String selected_date = "";
    List<String> dates = meeting_selected_date.split(" ");
    List<String> _d = dates[0].split("-");
    List<String> _t = dates[2].split(":");
    DateTime sd = DateTime(int.parse(_d[0]), int.parse(_d[1]), int.parse(_d[2]), int.parse(_t[0]), int.parse(_t[1]));
    selected_date = DateFormat.yMMMMEEEEd().format(sd);
    selected_date += " ${DateFormat.Hm().format(sd)}";

    if(accepted) {
      await new GeneralUtils().sendAndRetrieveMessage(
          '${user.user.firstname} ${user.user.lastname} has accepted to chat with you on $selected_date.',
          'CoffeeChat - Chat Accepted',
          user.msgId);
    }else {
      await new GeneralUtils().sendAndRetrieveMessage(
          '${user.user.firstname} ${user.user.lastname} has declined to chat with you.',
          'CoffeeChat - Chat Declined',
          user.msgId);
    }

  }

  List<Widget> buildDatesView(ChatUsers user) {
    List<Widget> builder = new List();

    user.dates.forEach((element) {
      String selected_date = "";
      List<String> dates = element.split(" ");
      List<String> _d = dates[0].split("-");
      List<String> _t = dates[2].split(":");
      DateTime sd = DateTime(int.parse(_d[0]), int.parse(_d[1]), int.parse(_d[2]), int.parse(_t[0]), int.parse(_t[1]));
      selected_date = DateFormat.yMMMMEEEEd().format(sd);
      selected_date += " ${DateFormat.Hm().format(sd)}";

      builder.add(
          ListTile(
            leading: Icon(Icons.access_time_outlined),
            title: Text(selected_date, style: TextStyle(fontWeight: FontWeight.w500),),
            trailing: FlatButton.icon(onPressed: (){
              bottomSheet.setState(() {
                meeting_selected_date = element;
              });
            }, icon: (meeting_selected_date == element) ? Icon(Icons.check_box) : Icon(Icons.check_box_outline_blank),
                label: Text('')
            ),
          )
      );
    });

    return builder;
  }

  List<Widget> buildChatsAvailable() {
    List<Widget> usersBuilder = new List();
    chatUsers.forEach((user) {

      //2020-12-24 00:00:00.000 18:0
      List<String> dates = user.selected_date.split(" ");
      List<String> _d = dates[0].split("-");
      List<String> _t = dates[2].split(":");
      DateTime sd = DateTime(int.parse(_d[0]), int.parse(_d[1]), int.parse(_d[2]), int.parse(_t[0]), int.parse(_t[1]));

      int dateDiff = sd.difference(DateTime.now()).inSeconds;
      print(dateDiff);

      String selected_date = user.status;
      if(user.selected_date.isNotEmpty && user.status != "declined") {
        selected_date = DateFormat.yMMMMEEEEd().format(sd);
        selected_date += " ${DateFormat.Hm().format(sd)}";

      }
      usersBuilder.add(
          Padding(padding: EdgeInsets.only(left:0.0, right: 0.0, top: 20.0), child: Container(
            child: Column(
              children: [
                ListTile(
                  leading: Image.asset(
                    "assets/images/${user.user.picture}",
                    fit: BoxFit.none,
                  ),
                  title: Text("${user.user.firstname} ${user.user.lastname}",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.384,
                      )),
                  subtitle: Text('Selected Available Date: $selected_date',
                      style: TextStyle(
                        color: Colors.black38,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        letterSpacing: -0.384,
                      )),
                  trailing: (user.status == "accepted") ? (dateDiff > 0) ? buttonWidget(user) : Text("") : Text(""),
                ),
                Divider(thickness: 1.0, color: Colors.grey,)
              ],
            ),
          ),)
      );
    });
    return usersBuilder;
  }

  buttonWidget(ChatUsers user) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(0.0),
        child: Container(
          width: 100.0,
          height: 30.0,
          child: Text(
            "Start Chat",
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
        //change to review page instead
Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => new ZoomMeetingWidget(meetingId: user.user.zoomID,meetingPassword:user.user.zoomPassword, username: user.name)));
      },
    );
  }
}