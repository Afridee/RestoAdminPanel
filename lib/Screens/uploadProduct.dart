import 'dart:io';
import 'package:flutter/services.dart';
import 'package:restoadminpanel/Animation/FadeAnimation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:search_widget/search_widget.dart';

class uploadProduct_page extends StatefulWidget {
  @override
  _uploadProduct_pageState createState() => _uploadProduct_pageState();
}

class _uploadProduct_pageState extends State<uploadProduct_page> {
  //variables:
  String name;
  int qty;
  int price;
  String desc;
  String password;
  String userID;
  bool showSpinner = false;
  File _image;
  String imgURL;
  var itemList = new List();

  //Functions:

  //function 1
  Future getImage() async{
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
    print(basename(_image.path));
  }
  //function 2
  Future uploadProduct(BuildContext context) async{
    String fileName = basename(_image.path);
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child('images/'+fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    final StreamSubscription<StorageTaskEvent> streamSubscription = uploadTask.events.listen((event) {
      print('EVENT ${event.type}');
    });
    String URL = await (await uploadTask.onComplete).ref.getDownloadURL();

    streamSubscription.cancel();
    setState((){
      imgURL = URL;
      print(imgURL);
    });

    final CollectionReference supplies = Firestore.instance.collection('supplies');

    await supplies.document(name).setData({
      'name' : name,
      'desc' : desc,
      'img' : imgURL,
      'price' : price,
      'qty' : qty,
    }, merge: true);
  }
  //function 3
  Future<void> getUserID() async {
    final auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();
    setState(() {
      userID = user.uid;
    });
  }
  //function 4
  Future<void> getCurrentSupplies() async{
    final CollectionReference supplies = Firestore.instance.collection('supplies');

    await for(var snapshot in supplies.snapshots()){
      for(var item in snapshot.documents){
        itemList.add(item.data);
      }
      break;
    }
  }

  @override
  void initState() {
    getUserID();
    getCurrentSupplies();
    super.initState();
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
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: EdgeInsets.only(left: 30,right: 30),
              child: Column(
                children: <Widget>[
                  InkWell(
                    onTap: getImage,
                    child: _image==null? Image(image: AssetImage(
                        'assets/images/addImage.png'),
                      height: 70,
                      width: 70,) : Image(image: FileImage(
                        _image),
                      height: 70,
                      width: 70,),
                  ),
                  SizedBox(height: 10,),
                  Text('picture should have 1:1 ratio and suggested background color is white.', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center,),
                  SizedBox(height: 10,),
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
                              onChanged: (value) {
                                setState(() {
                                  name = value;
                                });
                              },
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "name",
                                  hintStyle:
                                  TextStyle(color: Colors.grey[400])),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.grey[100]))),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  qty = int.parse(value);
                                });
                              },
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "qty",
                                  hintStyle:
                                  TextStyle(color: Colors.grey[400])),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.grey[100]))),
                            child: TextField(
                                keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  price = int.parse(value);
                                });
                              },
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "price",
                                  hintStyle:
                                  TextStyle(color: Colors.grey[400])),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: TextField(
                             keyboardType: TextInputType.multiline,
                              maxLines: 11,
                              onChanged: (value) {
                                setState(() {
                                  desc = value;
                                });
                              },
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "description",
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
                         //uploadProduct(context);
                        print(itemList);
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(colors: [
                              Color(0xffdd3572),
                              Color(0xfff9b294),
                            ]),
                            boxShadow: [
                              BoxShadow(
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  color: Color(0xffdd3572).withOpacity(0.1),
                                  offset: Offset(0, 10))
                            ]),
                        child: Center(
                          child: Text(
                            "Upload",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
