
import 'package:coffeechat_app/ListItem/Coffee.dart';
import 'package:coffeechat_app/Utils/storage.dart';
import 'package:flutter/material.dart';

class SharedCoffeeUI extends StatefulWidget {

  SharedCoffeeUI();

  @override
  State<StatefulWidget> createState() => _SharedCoffeeUI();
}

class _SharedCoffeeUI extends State<SharedCoffeeUI> {

  StorageSystem ss = new StorageSystem();

  List<Coffee> myCoffee = new List();

  bool _inAsyncCall = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}