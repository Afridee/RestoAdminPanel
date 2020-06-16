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
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:restoadminpanel/Screens/register_user.dart';
import 'package:restoadminpanel/Screens/Records.dart';
import 'package:restoadminpanel/Screens/login_screen.dart';
import 'package:connectivity/connectivity.dart';


class uploadProduct_page extends StatefulWidget {
  @override
  _uploadProduct_pageState createState() => _uploadProduct_pageState();
}

class _uploadProduct_pageState extends State<uploadProduct_page> {
  //variables:
  int qty;
  int price;
  String password;
  String userID;
  bool showSpinner = false;
  File _image;
  String imgURL;
  var itemList = new List();
  Icon custom_Icon = Icon(Icons.search);
  Widget search_text = Text('');
  TextEditingController name_controller;
  TextEditingController desc_controller;
  TextEditingController qty_controller;
  TextEditingController price_controller;
  PageController pageController;
  int pageIndex = 1;
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;
  bool connectedToInternet = true;


  //Functions:

  //function 1
  Future getImage() async{
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      imgURL = null;
    });
    print(basename(_image.path));
  }
  //function 2
  Future uploadProduct(BuildContext context) async{
    //sets the image url for manually selected image
    if(imgURL==null && _image!=null){
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
    }
    //supplies collection reference
    final CollectionReference supplies = Firestore.instance.collection('supplies');
    //updating produt
    if(name_controller.text.length>0 && qty_controller.text.length>0 && price_controller.text.length>0 && desc_controller.text.length>0 && connectedToInternet && (_image!=null || imgURL!=null)){
      await supplies.document(name_controller.text).setData({
        'name' : name_controller.text,
        'desc' : desc_controller.text,
        'img' : imgURL,
        'price' : price,
        'qty' : qty,
      }, merge: true);
      setState(() {
        showSpinner = false;
      });
      //shows succeess dialogue
      _showDialog('Success!', 'Product uploaded successfully');
      //resets to empty
      name_controller.text = '';
      qty_controller.text = '';
      price_controller.text = '';
      desc_controller.text = '';
      _image = null;
      imgURL = null;
      //updates Search Datalist
      getCurrentSupplies();
    }else if(connectedToInternet){
      _showDialog('Empty fields!', 'Please fill up all the fields or upload an image if you have not');
      setState(() {
        showSpinner = false;
      });
    }
    //Internet Connection notice
    if(!connectedToInternet){
      _showDialog('No Internet!', 'Please check your internet connection');
      setState(() {
        showSpinner = false;
      });
    }
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
  //function 5
  void seacrchIconState(){
    setState(() {
      if (this.custom_Icon.icon == Icons.search) {
        this.custom_Icon = Icon(Icons.cancel);
        this.search_text = SearchWidget<dynamic>(
          dataList: itemList,
          queryBuilder: (String query, List<dynamic> list) {
            return list.where((dynamic item) => item['name'].toLowerCase().contains(query.toLowerCase())).toList();
          },
          popupListItemBuilder: (dynamic item) {
            return InkWell(onTap: (){
              resetTexts(item['name'], item['desc'], item['img']);
            },child : PopupListItemWidget(item));
          },
          selectedItemBuilder: (dynamic selectedItem, VoidCallback deleteSelectedItem) {
            return Container();
          },
          textFieldBuilder: (TextEditingController controller, FocusNode focusNode) {
            return TextField(
              controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: "Search Here...",
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white, fontSize: 20));;
          },
        );
      } else {
        this.custom_Icon = Icon(Icons.search);
        this.search_text = Text('');
      }
    });
  }
  //function 6
  void resetTexts(String name, String description, String imgURL){
     setState(() {
       name_controller.text = name;
       desc_controller.text = description;
       this.imgURL = imgURL;
       _image = null;
     });
  }
  //function 7
  navBarOnTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }
  //function 8
  onPageChanged(int pageIndex) {
    if (!mounted) return;
    setState(() {
      this.pageIndex = pageIndex;
    });
  }
  //function 9
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
    pageController = PageController(initialPage: 1);
    name_controller = new TextEditingController();
    desc_controller = new TextEditingController();
    price_controller = new TextEditingController();
    qty_controller = new TextEditingController();
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

    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Color(0xffdd3572),
                          Color(0xffdd3572),
                        ]
                    )
                )
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            title: search_text,
            actions: <Widget>[
              IconButton(
                icon: custom_Icon,
                onPressed: () {
                  seacrchIconState();
                },
              )
            ],
            leading: IconButton(
              icon : Icon(Icons.power_settings_new),
              onPressed: () async{
                final auth = FirebaseAuth.instance;
                await auth.signOut();
                var route = new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new login_page(),
                );
                Navigator.of(context).push(route);
              },
            ),
          ),
        backgroundColor: Colors.white,
        body: PageView(
          children: <Widget>[
            registration_page(),
            SingleChildScrollView(
              child: Container(
                child: Padding(
                  padding: EdgeInsets.only(left: 30,right: 30),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 10),
                      InkWell(
                        onTap: getImage,
                        child: _image==null? Image(image: imgURL==null? AssetImage(
                            'assets/images/addImage.png') : NetworkImage(imgURL),
                          height: 100,
                          width: 100,) : Image(image: FileImage(
                            _image),
                          height: 100,
                          width: 100,),
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
                                  controller: name_controller,
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
                                  controller: qty_controller,
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
                                  controller: price_controller,
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
                                  controller: desc_controller,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 4,
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
                            setState(() {
                              showSpinner = true;
                            });
                            uploadProduct(context);
                            print(name_controller.text);
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
                      SizedBox(height: 30)
                    ],
                  ),
                ),
              ),
            ),
            RecordDataTable()
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: 1,
          color: Color(0xffdd3572),
          backgroundColor: Colors.white,
          buttonBackgroundColor: Color(0xfff9b294),
          height: 50,
          items: <Widget>[
            Icon(Icons.person_add, size: 30, color: Colors.white),
            Icon(Icons.library_add, size: 30, color: Colors.white),
            Icon(Icons.receipt, size: 30, color: Colors.white)
          ],
          animationDuration: Duration(
              milliseconds: 200
          ),
          animationCurve: Curves.bounceInOut,
          onTap: (index){
            navBarOnTap(index);
          },
        ),
      ),
    );
  }
}

class PopupListItemWidget extends StatelessWidget {
  const PopupListItemWidget(this.item);

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        item['name'],
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}