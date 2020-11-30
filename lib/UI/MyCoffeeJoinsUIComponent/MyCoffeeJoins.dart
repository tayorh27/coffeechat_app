
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeechat_app/ListItem/Coffee.dart';
import 'package:coffeechat_app/ListItem/CoffeeJoin.dart';
import 'package:coffeechat_app/UI/HomeUIComponent/CoffeeShop.dart';
import 'package:coffeechat_app/UI/SharedUIComponent/EmptyCoffeeShopsUI.dart';
import 'package:coffeechat_app/Utils/colors.dart';
import 'package:coffeechat_app/Utils/general.dart';
import 'package:coffeechat_app/Utils/storage.dart';
import 'package:coffeechat_app/values/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:share_it/share_it.dart';

class MyCoffeeJoins extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyCoffeeJoins();
}

class _MyCoffeeJoins extends State<MyCoffeeJoins> {

  StorageSystem ss = new StorageSystem();

  List<Coffee> myCoffee = new List();
  List<String> myCoffeeJoinIDs = new List();

  bool _inAsyncCall = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _inAsyncCall = true;
    });
    String user = ss.getItem('user');
    Map<String, dynamic> json = jsonDecode(user);
    FirebaseFirestore.instance
        .collection('coffee-joins').where('user_id', isEqualTo: json['uid']).orderBy('timestamp', descending: true)
        .snapshots()
        .listen((event) {
      myCoffee.clear();
      event.docs.forEach((element) async {
        CoffeeJoin cj = CoffeeJoin.fromSnapshot(element.data());
        await getCoffeeByID(cj.coffee_id, cj.id);
      });
      setState(() {
        _inAsyncCall = false;
      });
    });
  }

  getCoffeeByID(String coffeeID, String cjID) async {
    DocumentSnapshot query = await FirebaseFirestore.instance.collection('coffee').doc(coffeeID).get();
    if(query.exists) {
      setState(() {
        myCoffee.add(Coffee.fromSnapshot(query.data()));
        myCoffeeJoinIDs.add(cjID);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Accessed Coffee Shops'),
          actions: [
          ],
        ),
        backgroundColor: Colors.white,
        body: ModalProgressHUD(
            opacity: 0.3,
            inAsyncCall: _inAsyncCall,
            progressIndicator: CircularProgressIndicator(),
            color: Color(MyColors.button_text_color),
            child: (myCoffee.isNotEmpty) ? Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: myCoffee.length,
                    itemBuilder: (context, position) {
                      return Slidable(actionPane: new SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        secondaryActions: <Widget>[
                          new IconSlideAction(
                            key: Key(myCoffee[position].id.toString()),
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () async {
                              await FirebaseFirestore.instance.collection('coffee-joins').doc(myCoffeeJoinIDs[position]).delete();
                              // setState(() {
                              //   myCoffee.removeAt(position);
                              // });

                              ///
                              /// SnackBar show if cart delete
                              ///
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text("Coffee Deleted"),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.redAccent,
                              ));
                            },
                          ),
                        ],
                        child: buildCoffeeShops(myCoffee[position]),
                      );
                    }
                  // children: [
                  //   Container(
                  //     height: 20.0,
                  //   ),
                  //   ...coffeeBuilder(),
                  // ],
                )) : EmptyCoffeeShop("No Accessed Coffee Shops created yet!")));
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

}