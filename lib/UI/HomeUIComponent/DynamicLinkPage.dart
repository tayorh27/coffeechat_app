
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeechat_app/ListItem/Coffee.dart';
import 'package:coffeechat_app/ListItem/CoffeeJoin.dart';
import 'package:coffeechat_app/UI/SharedUIComponent/EmptyCoffeeShopsUI.dart';
import 'package:coffeechat_app/Utils/colors.dart';
import 'package:coffeechat_app/Utils/general.dart';
import 'package:coffeechat_app/Utils/storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'CoffeeShop.dart';

class DynamicLinkPage extends StatefulWidget {

  final Uri link;
  DynamicLinkPage(this.link);

  @override
  State<StatefulWidget> createState() => _DynamicLinkPage();
}

class _DynamicLinkPage extends State<DynamicLinkPage> {

  StorageSystem ss = new StorageSystem();
  bool _inAsyncCall = false;
  String msgId = '';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token) {
      msgId = token;
    });
    setState(() {
      _inAsyncCall = true;
    });
    FirebaseAuth.instance.signInAnonymously().then((value) {
      joinCoffeeShop();
    }).catchError((err) {
      print(err);
      setState(() {
        _inAsyncCall = false;
      });
      new GeneralUtils().neverSatisfied(
          context, 'Error', 'An error occurred, please try again.');
    });
  }

  joinCoffeeShop() async {

    String coffee_id = widget.link.query.substring(4);
    print(widget.link);
    print(widget.link.query);
    print(coffee_id);

    String id = FirebaseDatabase.instance.reference().push().key;

    CoffeeJoin cj = CoffeeJoin(id, coffee_id, id, 'Guest', '$id@coffee.chat', 'avatar.png', [msgId], FieldValue.serverTimestamp());

    FirebaseFirestore.instance.collection('coffee-joins').doc(id).set(cj.toJSON()).then((value) async {
      await FirebaseFirestore.instance.collection('coffee').doc(coffee_id).update({'total_users': FieldValue.increment(1)});
      await FirebaseMessaging().subscribeToTopic(coffee_id);

      DocumentSnapshot _coffeeQuery = await FirebaseFirestore.instance.collection('coffee').doc(coffee_id).get();
      Coffee coffee = Coffee.fromSnapshot(_coffeeQuery.data());
      
      setState(() {
        _inAsyncCall = false;
      });
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (_, __, ___) => new CoffeeShop(coffee)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Joining'),
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
            child: EmptyCoffeeShop('Granting you access...')));
  }
}