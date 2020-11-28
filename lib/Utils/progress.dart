import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ProgressDisplay {
  BuildContext context;
  ProgressDialog pr;

  ProgressDisplay(BuildContext context) {
    this.context = context;
    pr = new ProgressDialog(context);
  }

  void displayDialog(String text) {
    pr.style(message: text);// .setMessage(text);
    pr.show();
  }

  void dismissDialog() {
    if (pr != null) {
      pr.hide();
    }
  }

  Future<Null> displayMessage(
      BuildContext context, String _title, String _body) async {
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
}
