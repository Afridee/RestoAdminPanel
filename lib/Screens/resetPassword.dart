import 'package:flutter/services.dart';
import 'package:restoadminpanel/Animation/FadeAnimation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class resetPasswordPage extends StatefulWidget {
  final String title;
  final String img;

  const resetPasswordPage({Key key,@required this.title,@required this.img}) : super(key: key);

  @override
  _resetPasswordPageState createState() => _resetPasswordPageState();
}

class _resetPasswordPageState extends State<resetPasswordPage> {

  //variables:
  String email;
  String ErrorMessage='';


  //functions:

  //function 1:
  Future<void> resetPassword(String email) async {
    try {
      final auth = FirebaseAuth.instance;
      await auth.sendPasswordResetEmail(email: email);
      resetMailSentAlert();
    }catch(e){
      //print(e);
      setState(() {
          ErrorMessage = e.message.toString();
      });
      //print('the email you entered does not exist or may be removed');
    }
  }
  //function 2:
  void resetMailSentAlert() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Check your mail", style: TextStyle(fontSize: 30, color: Colors.white, fontFamily: 'Varela'),),
          content: new Text("We've sent an email to this email adress.", style: TextStyle(fontSize: 15, color: Colors.white, fontFamily: 'Varela'),),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close", style: TextStyle(fontSize: 17, color: Colors.white, fontFamily: 'Varela', fontWeight: FontWeight.bold), ),
              onPressed: () {
                var route = new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new login_page(),
                );
                Navigator.of(context).push(route);
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

  @override
  Widget build(BuildContext context) {

    //this little code down here turns off auto rotation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffffffff),
          elevation: 0.0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xffdd3572)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 350,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        right: MediaQuery. of(context). size. width/2-200,
                        top: 30,
                        width: 400,
                        height: 300,
                        child: FadeAnimation(1.5, Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(widget.img)
                              )
                          ),
                        )),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0, left: 30, right: 30),
                  child: Column(
                    children: <Widget>[
                      FadeAnimation(1.8, Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromRGBO(143, 148, 251, .2),
                                  blurRadius: 20.0,
                                  offset: Offset(0, 10)
                              )
                            ]
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(widget.title, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xffdd3572)),textAlign: TextAlign.center,),
                            Text('Enter the email address associated with your account.', style: TextStyle(fontSize: 15,  color: Colors.grey),textAlign: TextAlign.center,),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey[100]))
                              ),
                              child: TextField(
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value){
                                  setState(() {
                                    email = value;
                                  });
                                },
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Email",
                                    hintStyle: TextStyle(color: Colors.grey[400])
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      SizedBox(height: 30,),
                      FadeAnimation(2, InkWell(
                        onTap: (){
                          resetPassword(email);
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                  colors: [
                                    Color(0xffdd3572),
                                    Color(0xfff9b294),
                                  ]
                              )
                          ),
                          child: Center(
                            child: Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),),
                          ),
                        ),
                      )),
                      SizedBox(height: 20,),
                      FadeAnimation(1.5, Text(ErrorMessage, style: TextStyle(color: Color(0xffdd3572)),)),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}