import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeechat_app/ListItem/Coffee.dart';
import 'package:coffeechat_app/Utils/colors.dart';
import 'package:coffeechat_app/Utils/general.dart';
import 'package:coffeechat_app/Utils/storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:coffeechat_app/Library/date_picker/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class CreateCoffee extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CreateCoffee();
}

class _CreateCoffee extends State<CreateCoffee> {
  StorageSystem ss = new StorageSystem();

  final dateFormat = DateFormat("yyyy-MM-dd");
  List<File> _fileImage = List();

  List<String> coffee_access = ['public', 'private'];
  String selected_access = 'public';

  bool _inAsyncCall = false;
  final formKey = new GlobalKey<FormState>();

  TextEditingController t1 = new TextEditingController(text: '');
  TextEditingController t2 = new TextEditingController(text: '');
  TextEditingController t3 = new TextEditingController(text: '');
  // TextEditingController t4 = new TextEditingController(text: '');
  // TextEditingController t5 = new TextEditingController(text: '');
  // TextEditingController t6 = new TextEditingController(text: '');
  // TextEditingController t7 = new TextEditingController(text: '');

  TextEditingController e1 = new TextEditingController(text: '');
  String _event_start_date = '', _event_end_date = '';
  TextEditingController e2 = new TextEditingController(text: '');

  List<String> _images = new List();

  /// Custom text header for bottomSheet
  final _fontCostumSheetBotomHeader = TextStyle(
      fontFamily: "Roboto",
      color: Colors.black54,
      fontWeight: FontWeight.w600,
      fontSize: 16.0);

  /// Custom text for bottomSheet
  final _fontCostumSheetBotom = TextStyle(
      fontFamily: "Roboto",
      color: Colors.black45,
      fontWeight: FontWeight.w400,
      fontSize: 16.0);

  @override
  Widget build(BuildContext context) {
    var _appbar = AppBar(
      backgroundColor: Color(0xFFFFFFFF),
      elevation: 0.0,
      iconTheme: IconThemeData(color: Color(MyColors.primary_color)),
      title: Padding(
        padding: const EdgeInsets.only(left: 0.0),
        child: Text(
          "Create A Coffee",
        ),
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop(false);
        },
        icon: Icon(Icons.arrow_back),
      ),
    );

    return Scaffold(
      appBar: _appbar,
      body: ModalProgressHUD(
          opacity: 0.3,
          inAsyncCall: _inAsyncCall,
          progressIndicator: CircularProgressIndicator(),
          color: Color(MyColors.button_text_color),
          child: manualView()),
    );
  }

  List<Widget> buildSelectedImages() {
    List<Widget> imageContainers = new List();

    var index = 0;
    _fileImage.forEach((element) {
      imageContainers.add(
        Container(
          width: 70.0,
          height: 70.0,
          margin: EdgeInsets.only(right: 20.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              image: DecorationImage(
                  image: FileImage(element), fit: BoxFit.cover)),
          child: Align(
            alignment: Alignment.center,
            child: IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    _fileImage.removeAt(index - 1);
                  });
                }),
          ),
        ),
      );
      index++;
    });

    return imageContainers;
  }

  Widget manualView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: SingleChildScrollView(
        /// Create List Menu
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      margin:
                          EdgeInsets.only(top: 20.0, left: 30.0, right: 20.0),
                      height: 70.0,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 70.0,
                            margin: EdgeInsets.only(left: 80.0),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: buildSelectedImages(),
                            ),
                          ),
                          InkWell(
                            child: Container(
                              height: 64.0,
                              width: 64.0,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black38, blurRadius: 15.0)
                                  ],
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          'https://tacadmin.firebaseapp.com/assets/img/default-avatar.png'))),
                              child: Icon(
                                Icons.add,
                                size: 24.0,
                              ),
                            ),
                            onTap: getImage,
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                    textFromField(t1,
                        icon: Icons.title,
                        password: false,
                        placeholder: "Title*",
                        inputType: TextInputType.text,
                        min: 1,
                        max: 1),
                    Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                    textFromField(t2,
                        icon: Icons.edit,
                        password: false,
                        placeholder: "Description",
                        inputType: TextInputType.multiline,
                        min: 3,
                        max: 10),
                    Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                    textFromField(t3,
                        icon: Icons.link,
                        password: false,
                        placeholder: "Zoom Invitation*",
                        inputType: TextInputType.multiline,
                        min: 3,
                        max: 10),
                    // Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                    // textFromField(
                    //   t4,
                    //   icon: Icons.email,
                    //   password: false,
                    //   placeholder: "Email Address (optional)",
                    //   inputType: TextInputType.emailAddress,
                    // ),
                    //gender
                    Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                    dropDownField(),
                    // Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                    // textFromField(
                    //   t5,
                    //   icon: Icons.supervised_user_circle,
                    //   password: false,
                    //   placeholder: "Relationship*",
                    //   inputType: TextInputType.text,
                    // ),
                    // Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                    // textFromField(
                    //   t6,
                    //   icon: Icons.work,
                    //   password: false,
                    //   placeholder: "Occupation (optional)",
                    //   inputType: TextInputType.text,
                    // ),
                    // Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                    // textFromField(
                    //   t7,
                    //   icon: Icons.home,
                    //   password: false,
                    //   placeholder: "Address (optional)",
                    //   inputType: TextInputType.text,
                    // ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(left: 30.0, right: 0.0),
                              child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 2.5,
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
                                      child: new DateTimeField(
                                        format: dateFormat,
                                        onChanged: (date) {
                                          _event_start_date = date.toString();
                                        },
                                        controller: e1,
                                        decoration: new InputDecoration(
                                            labelText: 'Start Date*',
                                            alignLabelWithHint: true,
                                            hasFloatingPlaceholder: true,
                                            border: InputBorder.none,
                                            labelStyle: TextStyle(
                                                fontSize: 13.0,
                                                fontFamily: 'Roboto',
                                                letterSpacing: 0.3,
                                                color: Colors.black38,
                                                fontWeight: FontWeight.w600)),
                                        onShowPicker: (context, currentValue) {
                                          return showDatePicker(
                                              context: context,
                                              firstDate: DateTime(1900),
                                              initialDate: currentValue ??
                                                  DateTime.now(),
                                              lastDate: DateTime(2500));
                                        },
                                      )))),
                          Padding(
                              padding: EdgeInsets.only(left: 10.0, right: 0.0),
                              child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 2.4,
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
                                      child: new DateTimeField(
                                        format: dateFormat,
                                        onChanged: (date) {
                                          _event_end_date = date.toString();
                                        },
                                        controller: e2,
                                        decoration: new InputDecoration(
                                            labelText: 'End Date*',
                                            alignLabelWithHint: true,
                                            hasFloatingPlaceholder: true,
                                            border: InputBorder.none,
                                            labelStyle: TextStyle(
                                                fontSize: 13.0,
                                                fontFamily: 'Roboto',
                                                letterSpacing: 0.3,
                                                color: Colors.black38,
                                                fontWeight: FontWeight.w600)),
                                        onShowPicker: (context, currentValue) {
                                          return showDatePicker(
                                              context: context,
                                              firstDate: DateTime(1900),
                                              initialDate: currentValue ??
                                                  DateTime.now(),
                                              lastDate: DateTime(2500));
                                        },
                                      )))),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),

                    InkWell(
                      onTap: saveManualInputData,
                      child: Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Container(
                          height: 55.0,
                          child: Text(
                            "Create Coffee",
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
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  uploadImageToStorage(File _fileImage) async {
    String key = FirebaseDatabase.instance.reference().push().key;
    final Reference ref =
        FirebaseStorage.instance.ref().child('coffee-images').child('$key.jpg');
    final UploadTask uploadTask = ref.putFile(_fileImage);
    uploadTask.whenComplete(() async {
      TaskSnapshot storageTaskSnapshot = uploadTask.snapshot;
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      _images.add(downloadUrl);
    });
  }

  createDynamicLink(String id, String title, String desc) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://coffeechat.page.link',
      link: Uri.parse('https://coffeechatapp.com?id=$id'),
      androidParameters: AndroidParameters(
        packageName: 'com.cc.coffeechat_app',
        minimumVersion: 1,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.cc.coffeechat_app',
        minimumVersion: '1.0.0',
        appStoreId: '123456789',
      ),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: 'share-coffee-link',
        medium: 'social',
        source: 'app',
      ),
      // itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
      //   providerToken: '123456',
      //   campaignToken: 'example-promo',
      // ),
      socialMetaTagParameters:  SocialMetaTagParameters(
        title: title,
        description: desc,
      ),
    );

    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri shortUrl = shortDynamicLink.shortUrl;
    return shortUrl.toString();
  }

  saveManualInputData() async {
    try {
      if (t1.text.isEmpty ||
          t3.text.isEmpty ||
          e1.text.isEmpty ||
          e2.text.isEmpty) {
        new GeneralUtils().neverSatisfied(
            context, 'Error', 'Please fill all fields marked with *');
        return;
      }
      setState(() {
        _inAsyncCall = true;
      });

      if (_fileImage.isNotEmpty) {
        _fileImage.forEach((element) async {
          await uploadImageToStorage(element);
          // _images.add(url);
        });
      }

      String id = FirebaseDatabase.instance.reference().push().key;

      dynamic shareLink = await createDynamicLink(id, t1.text, t2.text);

      String user = ss.getItem('user');
      Map<String, dynamic> json = jsonDecode(user);

      DocumentSnapshot _userQuery = await FirebaseFirestore.instance.collection('users').doc(json['uid']).get();
      dynamic userQ = _userQuery.data();
      Coffee _coffee = new Coffee(
          id,
          json['uid'],
          json['fn'],
          json['pic'],
          t1.text,
          t2.text,
          t3.text,
          selected_access,
          _event_start_date,
          _event_end_date,
          userQ['msgId'],
          _images,
          new DateTime.now().toString(),
          FieldValue.serverTimestamp(),0,0,shareLink
      );

      // print(_coffee.toJSON());

      FirebaseFirestore.instance
          .collection('coffee')
          .doc(id)
          .set(_coffee.toJSON())
          .then((d) {
        setState(() {
          t1.clear();
          t2.clear();
          t3.clear();
          // t4.clear();
          // t5.clear();
          // t6.clear();
          // t7.clear();
          e1.clear();
          e2.clear();
          _inAsyncCall = false;
        });
        new GeneralUtils().showToast('Coffee successfully created.');
        Navigator.of(context).pop(false);
      }).catchError((err) {
        print(err);
        setState(() {
          _inAsyncCall = false;
        });
        new GeneralUtils().neverSatisfied(
            context, 'Error', 'An error occurred, please try again.');
      });
    } catch (e) {
      print(e);
      setState(() {
        _inAsyncCall = false;
      });
      new GeneralUtils().neverSatisfied(
          context, 'Error', 'An error occurred, please try again.');
    }
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    form.save();
    return form.validate();
  } //not used

  //dropdown custom class
  Widget dropDownField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        height: 60.0,
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)]),
        padding:
            EdgeInsets.only(left: 20.0, right: 30.0, top: 0.0, bottom: 0.0),
        child: Theme(
            data: ThemeData(
              hintColor: Colors.transparent,
            ),
            child: DropdownButton(
              items: coffee_access.map((m) {
                return DropdownMenuItem<String>(
                  value: m,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.verified_user,
                        color: Colors.black38,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 15.0),
                        child: Text(
                          m,
                          textAlign: TextAlign.left,
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String item) {
                setState(() {
                  selected_access = item;
                });
              },
              value: selected_access,
              hint: Text(
                'public',
                textAlign: TextAlign.right,
              ),
              underline: Divider(
                height: 0.0,
                color: Colors.white,
              ),
              isExpanded: true, //icon: Icon(Icons.verified_user),
              style: TextStyle(
                  fontSize: 15.0,
                  fontFamily: 'Roboto',
                  letterSpacing: 0.3,
                  color: Colors.black38,
                  fontWeight: FontWeight.w600),
            )),
      ),
    );
  }

  /// textfromfield custom class
  Widget textFromField(TextEditingController _controller,
      {String placeholder,
      IconData icon,
      TextInputType inputType,
      int min,
      int max,
      bool password}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        // height: 60.0,
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)]),
        padding:
            EdgeInsets.only(left: 20.0, right: 30.0, top: 0.0, bottom: 0.0),
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
                icon: Icon(
                  icon,
                  color: Colors.black38,
                ),
                fillColor: Color(MyColors.primary_color),
                focusColor: Color(MyColors.primary_color),
                labelStyle: TextStyle(
                    fontSize: 15.0,
                    fontFamily: 'Roboto',
                    letterSpacing: 0.3,
                    color: Colors.black38,
                    fontWeight: FontWeight.w600)),
            keyboardType: inputType,
          ),
        ),
      ),
    );
  }

  /// textfromfield custom class
  Widget textFromFieldEvents(TextEditingController _controller,
      {String placeholder,
      IconData icon,
      TextInputType inputType,
      bool password}) {
    return Padding(
      padding: EdgeInsets.only(left: 30.0, right: 0.0),
      child: Container(
        width: MediaQuery.of(context).size.width / 3.2,
        height: 60.0,
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)]),
        padding: EdgeInsets.only(left: 10.0, right: 0.0, top: 0.0, bottom: 0.0),
        child: Theme(
          data: ThemeData(
            hintColor: Colors.transparent,
          ),
          child: TextFormField(
            obscureText: password,
            controller: _controller,
            decoration: InputDecoration(
                border: InputBorder.none,
                labelText: placeholder,
                labelStyle: TextStyle(
                    fontSize: 13.0,
                    fontFamily: 'Roboto',
                    letterSpacing: 0.3,
                    color: Colors.black38,
                    fontWeight: FontWeight.w600)),
            keyboardType: inputType,
          ),
        ),
      ),
    );
  }

  Future<void> getImage() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Source'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text('Select image source'),
                Container(
                  height: 10.0,
                ),
                ListTile(
                  title: Text('Camera'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    var image = await ImagePicker()
                        .getImage(source: ImageSource.camera, imageQuality: 60);
                    setState(() {
                      _fileImage.add(File(image.path));
                    });
                  },
                ),
                Divider(
                  height: 1.0,
                  color: Colors.black,
                ),
                ListTile(
                  title: Text('Gallery'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    var image = await ImagePicker().getImage(
                        source: ImageSource.gallery, imageQuality: 60);
                    setState(() {
                      _fileImage.add(File(image.path));
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('CANCEL'),
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
