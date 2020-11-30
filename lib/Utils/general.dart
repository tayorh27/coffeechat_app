import 'dart:async';
import 'dart:convert';

import 'package:coffeechat_app/Utils/colors.dart';
import 'package:coffeechat_app/Utils/storage.dart';
import 'package:coffeechat_app/values/values.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

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

  final String serverToken = 'AAAA0pPB70Y:APA91bFfVENthJfYjW3hBfBcU2yxmDOBG2L-qHzQQfoa80tGwC-ckKzx3r6xy51DhHg-zlAAZVk9-L7LjuvDuoY_SZqJxJAJSkUTfYMzRUWwg0PX6TxXIBVkRyq6lQjtI_YaD8U3dgyT';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  Future<void> sendAndRetrieveMessage(String _body, String _title, List<dynamic> _ids) async {

    _ids.forEach((id) async {
      http.Response r = await http.post(
        'https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': _body,
              'title': _title
            },
            'priority': 'high',
            // 'data': <String, dynamic>{
            //   'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            //   'id': '1',
            //   'status': 'done'
            // },
            'to': id,
          },
        ),
      );
      print(r.body);
    });

    // final Completer<Map<String, dynamic>> completer =
    // Completer<Map<String, dynamic>>();
    //
    // firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print(message);
    //     completer.complete(message);
    //   },
    // );
    //
    // return completer.future;
  }

  Future<void> sendNotificationToTopic(String _body, String _title, String topic) async {
    http.Response r = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': _body,
            'title': _title
          },
          'priority': 'high',
          // 'data': <String, dynamic>{
          //   'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          //   'id': '1',
          //   'status': 'done'
          // },
          'topic': topic,
        },
      ),
    );
    print(r.body);
  }

  String returnFormattedDate(String createdDate) {
    var secs = DateTime.now().difference(DateTime.parse(createdDate)).inSeconds;
    if(secs > 60){
      var mins = DateTime.now().difference(DateTime.parse(createdDate)).inMinutes;
      if(mins > 60){
        var hrs = DateTime.now().difference(DateTime.parse(createdDate)).inHours;
        if(hrs > 24) {
          var days = DateTime.now().difference(DateTime.parse(createdDate)).inDays;
          return (days > 1) ? '$days days ago' : '$days day ago';
        }else {
          return (hrs > 1) ? '$hrs hrs ago' : '$hrs hr ago';
        }
      }else {
        return '$mins mins ago';
      }
    }else {
      return '$secs secs ago';
    }
  }
}
