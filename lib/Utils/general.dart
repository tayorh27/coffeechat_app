import 'dart:convert';

import 'package:coffeechat_app/Utils/colors.dart';
import 'package:coffeechat_app/Utils/storage.dart';
import 'package:coffeechat_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GeneralUtils {
  StorageSystem ss;

  List<dynamic> cartItems = new List();

  GeneralUtils() {
    ss = new StorageSystem();
    String cart = ss.getItem('cartItems');
    if (cart.isNotEmpty) {
      cartItems = jsonDecode(cart);
    }
  }

  // String formattedMoney(double price, String currency) {
  //   MoneyFormatterOutput mfo = FlutterMoneyFormatter(
  //           amount: price,
  //           settings: MoneyFormatterSettings(
  //               symbol: currency,
  //               thousandSeparator: ',',
  //               decimalSeparator: '.',
  //               symbolAndNumberSeparator: '',
  //               fractionDigits: 2,
  //               compactFormatType: CompactFormatType.short))
  //       .output;
  //   return mfo.symbolOnLeft;
  // }

  Future<Null> neverSatisfied(BuildContext context, String _title, String _body) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(_title),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(_body),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
        msg: "$msg",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 5,
        backgroundColor: Color(MyColors.primary_color),
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}
