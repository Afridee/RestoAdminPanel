import 'package:flutter/services.dart';
import 'package:restoadminpanel/Animation/FadeAnimation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restoadminpanel/Screens/uploadProduct.dart';
import 'package:provider/provider.dart';
import 'package:restoadminpanel/Screens/Records.dart';
import 'package:connectivity/connectivity.dart';

class registration_page extends StatefulWidget {
  @override
  _registration_pageState createState() => _registration_pageState();
}

class _registration_pageState extends State<registration_page> {
  //variables:
  String newUserID;
  bool showSpinner = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TextEditingController name_controller;
  TextEditingController email_controller;
  TextEditingController location_controller;
  TextEditingController cell_controller;
  TextEditingController password_controller;
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;
  bool connectedToInternet = true;

  //functions:

  //function 1
  Future<void> signUp(String email, String password) async {
     try{
       final newUser= await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
       setState(() {
         newUserID = newUser.user.uid;
       });
     }catch(e){
       _showDialog('Error!', e.message);
     }
  }
  //function 2
  void _showDialog(String Title, String content) {
    // flutter defined function
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(Title, style: TextStyle(fontSize: 30, color: Colors.white, fontFamily: 'Varela'),),
          content: new Text(content, style: TextStyle(fontSize: 15, color: Colors.white, fontFamily: 'Varela'),),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("OK", style: TextStyle(fontSize: 17, color: Colors.white, fontFamily: 'Varela', fontWeight: FontWeight.bold), ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: Color(0xffdd3572),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
        );
      },
    );
  }
  //function 3
  Future<void> setUserData(String uid) async{
    final DocumentReference newUseDoc = Firestore.instance.document('users/'+uid);

    if(name_controller.text.length>0 &&
        cell_controller.text.length>0 &&
        location_controller.text.length>0 &&
        email_controller.text.length>0 &&
        password_controller.text.length>0 && connectedToInternet){
      await newUseDoc.setData({
        'name': name_controller.text,
        'cell': cell_controller.text,
        'location' : location_controller.text,
        'email' : email_controller.text
      }, merge:true);
      _showDialog('Congrats!', 'successfuly registered user');
      setState(() {
        newUserID = null;
      });
    }else if(connectedToInternet){
      _showDialog('Fillup all the fields!', 'leave no  text field empty...');
    }

    if(!connectedToInternet){
      _showDialog('Network Error!', 'Check your internet connecton');
    }

  }

  @override
  void initState() {
    connectivity = new Connectivity();
    subscription = connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if(result == ConnectivityResult.wifi || result == ConnectivityResult.mobile){
        setState(() {
          connectedToInternet = true;
        });
      }else if(result == ConnectivityResult.none){
        setState(() {
          connectedToInternet = false;
        });
      }
    });
    name_controller = new TextEditingController();
    email_controller = new TextEditingController();
    location_controller = new TextEditingController();
    cell_controller = new TextEditingController();
    password_controller = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //this little code down here turns off auto rotation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
            Container(
            margin: EdgeInsets.only(top: 9),
            child: Center(
              child: Text(
                "Register",
                style: TextStyle(
                    color: Color(0xffdd3572),
                    fontSize: 60,
                    fontFamily: 'Lucy the Cat'),
              ),
            ),
          ),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      FadeAnimation(
                        1.8,
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(143, 148, 251, .2),
                                    blurRadius: 20.0,
                                    offset: Offset(0, 10))
                              ]),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[100]))),
                                child: TextField(
                                  controller: name_controller,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Name",
                                    hintStyle:
                                    TextStyle(color: Colors.grey[400],),),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[100]))),
                                child: TextField(
                                  controller: location_controller,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Adress",
                                    hintStyle:
                                    TextStyle(color: Colors.grey[400],),),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[100]))),
                                child: TextField(
                                  controller: cell_controller,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Cell",
                                    hintStyle:
                                    TextStyle(color: Colors.grey[400],),),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[100]))),
                                child: TextField(
                                  controller: email_controller,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Email",
                                      hintStyle:
                                      TextStyle(color: Colors.grey[400],),),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: password_controller,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Password",
                                      hintStyle:
                                      TextStyle(color: Colors.grey[400],),),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      FadeAnimation(
                        2,
                        InkWell(
                          onTap: () async {
                              await signUp(email_controller.text, password_controller.text);

                              if(newUserID!=null){
                                await setUserData(newUserID);
                              }
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(colors: [
                                  Color(0xffdd3572),
                                  Color(0xfff9b294),
                                ])),
                            child: Center(
                              child: Text(
                                "Register",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
