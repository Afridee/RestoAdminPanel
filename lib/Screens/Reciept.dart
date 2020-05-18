import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:intl/intl.dart';

class recieptPage extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  final DocumentReference order;

  const recieptPage({Key key, this.userInfo, this.order}) : super(key: key);

  @override
  _recieptPageState createState() => _recieptPageState();
}

class _recieptPageState extends State<recieptPage> {
  //variables:
  String note = 'None';
  String status = 'Processing';
  var stat_arr = '''
[
    [
        "Processing",
        "Rejected",
        "Delivered"
    ]
]
    ''';


  //functions:
  //function 1:
  showPickerArray(BuildContext context) {
    new Picker(
        adapter: PickerDataAdapter<String>(pickerdata: new JsonDecoder().convert(stat_arr), isArray: true),
        hideHeader: true,
        title: new Text("Status:"),
        onConfirm: (Picker picker, List value) {
          setState(() {
            status = picker.getSelectedValues().toString().replaceAll('[', '').replaceAll(']', '');
          });
        }
    ).showDialog(context);
  }
  //function 2:
  updateStatusAndNote(){
    widget.order.setData({
      'Notes': note,
      'status'  : status
    }, merge: true);
  }

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
                child: StreamBuilder(
                    stream: widget.order.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          'Total: ৳' + snapshot.data['totalCost'].toString(),
                          style: TextStyle(
                              fontSize: 25,
                              color: Color(0xffffffff),
                              fontWeight: FontWeight.bold),
                        );
                      }
                      return Container(
                        width: 0,
                        height: 0,
                      );
                    })),
            SizedBox(height: 20),
            Center(
                child: StreamBuilder(
                    stream: widget.order.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return InkWell(
                          onTap: (){
                            showPickerArray(context);
                          },
                          child: Text(
                            'Order Status : ' + snapshot.data['status'],
                            style: TextStyle(
                                fontSize: 20,
                                color: Color(0xffffffff),
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      }
                      return Container(
                        height: 0,
                        width: 0,
                      );
                    })),
            SizedBox(height: 20),
            Center(
                child: StreamBuilder(
                    stream: widget.order.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          'Note: ' + snapshot.data['Notes'],
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xffffffff),
                          ),
                          textAlign: TextAlign.center,
                        );
                      }
                      return Container(height: 0, width: 0);
                    })),
            SizedBox(height: 20),
            Container(
              height: MediaQuery.of(context).size.height - 430,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    topLeft: Radius.circular(30.0),
                  )),
              child: StreamBuilder(
                  stream: widget.order.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ListView.builder(
                          itemCount: snapshot.data['items'].length,
                          itemBuilder: (context, index) {
                            return recieptItem(
                              name: snapshot.data['items'][index]['name'],
                              qty: snapshot.data['items'][index]['qty'],
                              price: snapshot.data['items'][index]['price'],
                              order: widget.order,
                            );
                          },
                        ),
                      );
                    }
                    return Container(height: 0, width: 0);
                  }),
            ),
            Container(color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Text('Note:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                )),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[100],
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  onChanged: (value) {
                    setState(() {
                      note = value;
                    });
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Note...",
                      hintStyle: TextStyle(color: Colors.grey[400])),
                ),
              ),
            ),
            Container(
              height: 100,
              color: Colors.white,
              child: Center(
                  child:InkWell(
                    onTap: (){
                     updateStatusAndNote();
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width - 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: Color(0xffdd3572)
                        ),
                        child: Center(
                            child: Text('Done',
                              style: TextStyle(
                                  fontFamily: 'Varela',
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                              ),
                            )
                        )
                    ),
                  ) ,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class recieptItem extends StatefulWidget {
  final String name;
  final int qty;
  final int price;
  final DocumentReference order;

  const recieptItem({
    Key key,
    this.name,
    this.qty,
    this.price,
    this.order,
  }) : super(key: key);

  @override
  _recieptItemState createState() => _recieptItemState();
}

class _recieptItemState extends State<recieptItem> {
  //functions:

  //function 1:
  Future manageQty(String operation, String selectedName) async {
    //to hold the current list
    var itemList = new List();

    //to hold the selected Item
    Map<String, dynamic> selectedItem;

    //to hold the updated selected Item
    Map<String, dynamic> UpdatedSelectedItem;

    //selectecItemIndex:
    int selectecItemIndex = 0;

    //when adding:
    if (operation == 'add') {
      //to initialize itemlist from cloud
      await for (var item in widget.order.snapshots()) {
        itemList = item.data['items'];
        break;
      }
      //to initialize selectedItem from cloud
      for (int i = 0; i < itemList.length; i++) {
        if (itemList[i]['name'] == selectedName) {
          selectedItem = itemList[i];
          selectecItemIndex = i;
        }
      }

      //initializing updated selectec item
      UpdatedSelectedItem = selectedItem;
      UpdatedSelectedItem.update('qty', (value) => selectedItem['qty'] + 1);

      //putting the new value on the list
      itemList.removeAt(selectecItemIndex);
      itemList.add(UpdatedSelectedItem);

      //updating total cost
      int totalCost = 0;
      for (int i = 0; i < itemList.length; i++) {
        totalCost = totalCost + itemList[i]['qty'] * itemList[i]['price'];
      }

      //and finally setting the data
      await widget.order
          .setData({'items': itemList, 'totalCost': totalCost}, merge: true);
    }

    //while deducting:
    if (operation == 'deduct') {
      //to initialize itemlist from cloud
      await for (var item in widget.order.snapshots()) {
        itemList = item.data['items'];
        break;
      }
      //to initialize selectedItem from cloud
      for (int i = 0; i < itemList.length; i++) {
        if (itemList[i]['name'] == selectedName) {
          selectedItem = itemList[i];
          selectecItemIndex = i;
        }
      }

      //initializing updated selectec item
      UpdatedSelectedItem = selectedItem;
      if (selectedItem['qty'] >= 1) {
        UpdatedSelectedItem.update('qty', (value) => selectedItem['qty'] - 1);
      }

      //putting the new value on the list
      itemList.removeAt(selectecItemIndex);
      itemList.add(UpdatedSelectedItem);

      //updating total cost
      int totalCost = 0;
      for (int i = 0; i < itemList.length; i++) {
        totalCost = totalCost + itemList[i]['qty'] * itemList[i]['price'];
      }

      //and finally setting the data
      await widget.order
          .setData({'items': itemList, 'totalCost': totalCost}, merge: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
                child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 125.00,
                  child: AutoSizeText(widget.name,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
                Text('৳' + widget.price.toString(),
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15.0,
                        color: Colors.grey)),
                Text('x ${widget.qty}',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red))
              ])
            ])),
            Row(
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.add),
                    color: Colors.black,
                    onPressed: () {
                      manageQty('add', widget.name);
                    }),
                IconButton(
                    icon: Icon(Icons.remove),
                    color: Colors.black,
                    onPressed: () {
                      manageQty('deduct', widget.name);
                    })
              ],
            )
          ],
        ));
  }
}
