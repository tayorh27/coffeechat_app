import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeechat_app/ListItem/Coffee.dart';
import 'package:coffeechat_app/ListItem/CoffeeAccess.dart';
import 'package:coffeechat_app/ListItem/CoffeeJoin.dart';
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
                  colors: (coffee.access_type == 'public') ? <Color>[Color(0xFF121940), Color(0xFF6E48AA)] : <Color>[Colors.red, Colors.redAccent])),
        ),
      ),
      onTap: () async {
        setState(() {
          _inAsyncCall = true;
        });

        String id = FirebaseDatabase.instance.reference().push().key;
        String user = ss.getItem('user');
        Map<String, dynamic> json = jsonDecode(user);

        QuerySnapshot query = await FirebaseFirestore.instance.collection('coffee-joins').where('coffee_id',isEqualTo: coffee.id).where('user_id', isEqualTo: json['uid']).get();
        if(query.size > 0){
          setState(() {
            _inAsyncCall = false;
          });
          new GeneralUtils().neverSatisfied(
              context, 'Notice', 'You have joined already.');
          return;
        }

        DocumentSnapshot _userQuery = await FirebaseFirestore.instance.collection('users').doc(json['uid']).get();
        dynamic userQ = _userQuery.data();

        if(coffee.access_type == 'public') {
          CoffeeJoin cj = CoffeeJoin(id, coffee.id, json['uid'], '${json['fn']} ${json['ln']}', json['email'], json['pic'], userQ['msgId'], FieldValue.serverTimestamp());

          FirebaseFirestore.instance.collection('coffee-joins').doc(id).set(cj.toJSON()).then((value) async {
            await FirebaseFirestore.instance.collection('coffee').doc(coffee.id).update({'total_users': FieldValue.increment(1)});
            await FirebaseMessaging().subscribeToTopic(coffee.id);
            setState(() {
              _inAsyncCall = false;
            });
            new GeneralUtils().showToast('You have been accepted to this shop.');
          });
        }else {

          QuerySnapshot query = await FirebaseFirestore.instance.collection('coffee-requests').where('coffee_id',isEqualTo: coffee.id).where('user_id', isEqualTo: json['uid']).get();
          if(query.size > 0){
            setState(() {
              _inAsyncCall = false;
            });
            new GeneralUtils().neverSatisfied(
                context, 'Notice', 'You have sent a request already.');
            return;
          }

          CoffeeAccess ca = CoffeeAccess(id, coffee.id, json['uid'], '${json['fn']} ${json['ln']}', json['email'], json['pic'], userQ['msgId'], FieldValue.serverTimestamp());

          FirebaseFirestore.instance.collection('coffee-requests').doc(id).set(ca.toJSON()).then((value) async {
            // FirebaseMessaging().//send notification to coffee creator using cloud functions doc.write
            await new GeneralUtils().sendAndRetrieveMessage('${json['fn']} is requesting access to: ${coffee.title}', 'CoffeeChat - Request Access', userQ['msgId']);
            setState(() {
              _inAsyncCall = false;
            });
            new GeneralUtils().showToast('Request to access this shop has been sent.');
          });
        }
      },
    );
  }

  List<Coffee> myCoffee = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _inAsyncCall = true;
    });
    FirebaseFirestore.instance
        .collection('coffee').orderBy('timestamp', descending: true)
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
    return Scaffold(
        appBar: AppBar(
          title: Text('Coffee Shops'),
          actions: [
            FlatButton.icon(
                onPressed: () {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (_, __, ___) => new CreateCoffee()));
                },
                icon: Icon(Icons.add),
                label: Text('CREATE'))
          ],
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
                    ...coffeeBuilder(),
                  ],
                ))));
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
            image: DecorationImage(
                image: NetworkImage(img),
                fit: BoxFit.cover)),
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
              subtitle: Text(new GeneralUtils().returnFormattedDate(coffee.created_date),
                  style: TextStyle(
                    color: Colors.black38,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    letterSpacing: -0.384,
                  )),
              trailing: buttonWidget(coffee),
            ),
            (imgs.length > 0) ? Container(
              height: 15.0,
            ) : Text(''),
            (imgs.length > 0) ? Container(
              height: 105.0,
              margin: EdgeInsets.only(left: 20.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: coffeeImagesBuilder(coffee.images)
              ),
            ) : Text(''),
            (imgs.length > 0) ? Container(
              height: 15.0,
            ) : Text(''),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                  coffee.title,
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
                                QuerySnapshot query = await FirebaseFirestore.instance.collection('coffee-joins').where('coffee_id',isEqualTo: coffee.id).where('user_id', isEqualTo: json['uid']).get();
                                if(query.size == 0){

                                  if(coffee.access_type == 'public'){
                                    joinCoffeeShop(coffee, false);
                                    return;
                                  }

                                  setState(() {
                                    _inAsyncCall = false;
                                  });
                                  new GeneralUtils().neverSatisfied(
                                      context, 'Notice', "You haven't joined. Please click the ${(coffee.access_type == 'public') ? 'join' : 'request'} button to access this shop.");
                                  return;
                                }
                                setState(() {
                                  _inAsyncCall = false;
                                });
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                        pageBuilder: (_, __, ___) => new CoffeeShop(coffee)));
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

    DocumentSnapshot _userQuery = await FirebaseFirestore.instance.collection('users').doc(json['uid']).get();
    dynamic userQ = _userQuery.data();

    CoffeeJoin cj = CoffeeJoin(id, coffee.id, json['uid'], json['fn'], json['email'], json['pic'], userQ['msgId'], FieldValue.serverTimestamp());

    FirebaseFirestore.instance.collection('coffee-joins').doc(id).set(cj.toJSON()).then((value) async {
      await FirebaseFirestore.instance.collection('coffee').doc(coffee.id).update({'total_users': FieldValue.increment(1)});
      await FirebaseMessaging().subscribeToTopic(coffee.id);
      setState(() {
        _inAsyncCall = false;
      });
      if(displayDialog) {
        new GeneralUtils().showToast('You have been accepted to this shop.');
        return;
      }
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (_, __, ___) => new CoffeeShop(coffee)));
    });
  }
}
