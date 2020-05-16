import 'package:flutter/services.dart';
import 'package:restoadminpanel/Animation/FadeAnimation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:restoadminpanel/Screens/uploadProduct.dart';
import 'package:provider/provider.dart';

class login_page extends StatefulWidget {
  @override
  _login_pageState createState() => _login_pageState();
}

class _login_pageState extends State<login_page> {
  //variables:
  String email;
  String password;
  String userID;
  bool loogedIn = false;
  bool showSpinner = false;
  String loginError = '';

  //functions:

  //function 1
  Future<void> login() async {
    try {
      setState(
        () {
          showSpinner = true;
        },
      );
      final auth = FirebaseAuth.instance;
      final user = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (user != null) {
        setState(
          () {
            loogedIn = true;
          },
        );
        final FirebaseUser user = await auth.currentUser();
        userID = user.uid;
        var route = new MaterialPageRoute(
          builder: (BuildContext context) => new uploadProduct_page(),
        );
        Navigator.of(context).push(route);
        setState(
          () {
            showSpinner = false;
          },
        );
      }
    } catch (e) {
      print(e.message);
      setState(
        () {
          showSpinner = false;
          loginError = e.message;
        },
      );
    }
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
                  height: 400,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        right: MediaQuery.of(context).size.width / 2 - 130,
                        top: 90,
                        width: 200,
                        height: 200,
                        child: FadeAnimation(
                            1.5,
                            Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/Resto_logo.png'))),
                            )),
                      ),
                      Positioned(
                        top: 270,
                        right: MediaQuery.of(context).size.width / 2 - 70,
                        child: FadeAnimation(
                          1.6,
                          Container(
                            margin: EdgeInsets.only(top: 30),
                            child: Center(
                              child: Text(
                                "Resto",
                                style: TextStyle(
                                    color: Color(0xffdd3572),
                                    fontSize: 60,
                                    fontFamily: 'Lucy the Cat'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 350,
                        right: MediaQuery.of(context).size.width / 2 - 65,
                        child: FadeAnimation(
                          1.6,
                          Container(
                            margin: EdgeInsets.only(top: 30),
                            child: Center(
                              child: Text(
                                "Admin Panel",
                                style: TextStyle(
                                    color: Color(0xffdd3572),
                                    fontSize: 20,
                                  fontFamily: 'Varela',
                                  fontWeight: FontWeight.bold
                                   ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
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
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (value) {
                                    setState(() {
                                      email = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Email",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                child: TextField(
                                  obscureText: true,
                                  onChanged: (value) {
                                    setState(() {
                                      password = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Password",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
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
                          onTap: () {
                            login();
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
                                "Login",
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
                      Text(loginError,
                          style: TextStyle(
                              color: Color(0xffdd3572), fontSize: 10.0)),
                      SizedBox(
                        height: 20,
                      ),
                      FadeAnimation(
                        1.5,
                        InkWell(
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(color: Color(0xffdd3572)),
                          ),
                          onTap: () {},
                        ),
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
