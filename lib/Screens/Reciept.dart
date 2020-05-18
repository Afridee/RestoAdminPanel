import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:intl/intl.dart';

class recieptPage extends StatefulWidget {

  final String OrderStatus;
  final List list;
  final int totalCost;
  final String Note;

  const recieptPage({Key key, this.OrderStatus, this.list, this.totalCost, this.Note}) : super(key: key);


  @override
  _recieptPageState createState() => _recieptPageState();
}

class _recieptPageState extends State<recieptPage> {
  @override
  Widget build(BuildContext context) {

    //this little code down here turns off auto rotation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xffeb6383), Color(0xffeb6383)])),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Color(0xffeb6383),
        child: ListView(
          children: <Widget>[
            Container(
              child: Image.asset(
                'assets/images/reciept.png',
                height: 200,
                width: 200,
              ),
            ),
            SizedBox(height: 20),
            Center(
                child: Text(
                  'Total: ৳'+widget.totalCost.toString(),
                  style: TextStyle(
                      fontSize: 25,
                      color: Color(0xffffffff),
                      fontWeight: FontWeight.bold),
                )),
            SizedBox(height: 20),
            Center(
                child: Text(
                  'Order Status : '+widget.OrderStatus,
                  style: TextStyle(
                      fontSize: 20,
                      color: Color(0xffffffff),
                      fontWeight: FontWeight.bold),
                )),
            SizedBox(height: 20),
            Center(
                child: Text(
                  'Note: '+widget.Note,
                  style: TextStyle(
                      fontSize: 15,
                      color: Color(0xffffffff),
                     ),
                textAlign: TextAlign.center,)),
            SizedBox(height: 20),
            Container(
              height: MediaQuery.of(context).size.height-430,
              decoration: BoxDecoration(
                color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    topLeft: Radius.circular(30.0),
                  )
              ),
              child: ListView.builder(
                itemCount: widget.list.length,
                itemBuilder: (context, index){
                  return recieptItem(name: widget.list[index]['name'],qty: widget.list[index]['qty'], price:  widget.list[index]['price']);
                }
              ),
            )
          ],
        ),
      ),
    );
  }
}

class recieptItem extends StatelessWidget {

  final String name;
  final int qty;
  final int price;

  const recieptItem({
    Key key, this.name, this.qty, this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Container(
                        width: 125.00,
                        child: AutoSizeText(
                            name,
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Montserrat',
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis
                        ),
                      ),
                      SizedBox(width: 30,),
                      Text(
                          '৳'+price.toString(),
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 17.0,
                              color: Colors.grey
                          )
                      ),
                      Text(
                          'x'+qty.toString()+' = ',
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 17.0,
                              color: Colors.grey
                          )
                      ),
                      Text(
                          '৳'+(price*qty).toString(),
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 17.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                          )
                      )
                    ]
                )
            ),
          ],
        )
    );
  }
}
