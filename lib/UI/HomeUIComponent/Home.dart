import 'package:coffeechat_app/values/colors.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _MyHome();
}

class _MyHome extends State<Home> {

  buttonWidget() {
    return Padding(
      padding: EdgeInsets.all(0.0),
      child: Container(
        width: 100.0,
        height: 30.0,
        child: Text(
          "Join",
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
    );
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Coffee Shops'),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: (){})
        ],
      ),
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Container(height: 20.0,),
            buildCoffeeShops(),
            buildCoffeeShops(),
            buildCoffeeShops(),
            buildCoffeeShops(),
            buildCoffeeShops(),
            buildCoffeeShops(),
            buildCoffeeShops(),
            buildCoffeeShops(),
            buildCoffeeShops(),
            buildCoffeeShops(),
            buildCoffeeShops(),
            buildCoffeeShops(),
            buildCoffeeShops(),
            buildCoffeeShops(),
            buildCoffeeShops(),
            buildCoffeeShops(),
            buildCoffeeShops(),
            buildCoffeeShops(),
          ],
        )
      )
    );
  }

  Widget buildCoffeeShops() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      child: Card(
        shadowColor: Colors.black,
        color: Colors.white,
        elevation: 2.5,
        child: Column(
          children: [
            ListTile(
              leading: Image.asset(
                "assets/images/ellipse-86-3.png",
                fit: BoxFit.none,
              ),
              title: Text('Samatha', style: TextStyle(
                color: Colors.black,
                fontFamily: "Roboto",
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: -0.384,
              )),
              subtitle: Text('20 mins ago', style: TextStyle(
                color: Colors.black38,
                fontFamily: "Roboto",
                fontWeight: FontWeight.w500,
                fontSize: 13,
                letterSpacing: -0.384,
              )),
              trailing: buttonWidget(),
            ),
            Container(height: 15.0,),
            Container(
              height: 105.0,
              margin: EdgeInsets.only(left: 20.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    width: 105.0,
                    height: 105.0,
                    margin: EdgeInsets.only(right: 20.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        image: DecorationImage(
                            image: AssetImage("assets/images/rectangle-7.png"), fit: BoxFit.fitWidth
                        )
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 15.0,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text("Today’s shooting went well, thank you everyone. Today’s shooting went well, thank you everyone. Today’s shooting went well, thank you everyone. Today’s shooting went well, thank you everyone", style: TextStyle(
                color: Colors.black,
                fontFamily: "Roboto",
                fontSize: 15,
                letterSpacing: -0.384,
              )),
            ),
            Container(height: 15.0,),
            Container(
              height: 20,
              margin: EdgeInsets.only(right: 1, left: 20.0, bottom: 20.0),
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
                          "12",
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
                              onPressed: (){},
                            )
                        ),
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
                          "375",
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
      ),
    );
  }
}