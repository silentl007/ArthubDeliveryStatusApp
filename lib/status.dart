import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Status extends StatefulWidget {
  final String clearAgentID;
  final String orderID;
  Status({this.clearAgentID, this.orderID});
  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<Status> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var getorderdetails;
  var userID = '';
  var username = '';
  var jsonData;
  String accountType = '';
  String clearAgentID = 'Test Agent ID';
  static const purple = Color.fromRGBO(69, 56, 133, 1);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getorderdetails = getOrderDetails();
  }

  getOrderDetails() async {
    String link =
        'https://arthubserver.herokuapp.com/apiR/orderdetails/${widget.orderID}';
    try {
      var data = await http.get(link);
      jsonData = jsonDecode(data.body);
      userID = jsonData['userID'];
      accountType = jsonData['accountType'];
      return data.statusCode;
    } catch (e) {
      print('here at catch - $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: FutureBuilder(
          future: getorderdetails,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(purple),
                      strokeWidth: 9.0,
                    ),
                  ],
                ),
              );
            } else if (snapshot.data == 200) {
              return Container(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    child: ListTile(
                      title: jsonData['status'] == 'Pending'
                          ? text(Colors.red, 'Pending')
                          : text(Colors.green, 'Delivered'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${jsonData['username']}'),
                          Text('Date Ordered: ${jsonData['dateOrdered']}'),
                          Text('No. of items: ${jsonData['itemnumber']}'),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: RaisedButton(
                      onPressed: () {
                        if (snapshot.data['status'] == 'Delivered') {
                          snackbar('Already delivered');
                        } else {
                          diag();
                        }
                      },
                      child: Text(
                        'Confirm Delivery',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      color: purple,
                    ),
                  )
                ],
              ));
            } else if (snapshot.data == 404) {
              return Center(
                  child: Text(
                'No record found for the order ID',
              ));
            } else {
              return Center(
                child: RaisedButton(
                  child: Text('Retry'),
                  onPressed: () {
                    setState(() {
                      getorderdetails = getOrderDetails();
                    });
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }

  text(Color color, String text) {
    return Text(text, style: TextStyle(color: color));
  }

  diag() {
    return showDialog(
        context: context,
        child: FutureBuilder(
            future: deliver(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Container(
                  color: Colors.transparent,
                  child: AlertDialog(
                    content: LinearProgressIndicator(
                      backgroundColor: Colors.white,
                      valueColor: new AlwaysStoppedAnimation<Color>(purple),
                    ),
                  ),
                );
              } else if (snapshot.hasData) {
                return Container(
                    child: snapshot.data == 200
                        ? AlertDialog(
                            content: Text('Status Changed'),
                          )
                        : AlertDialog(
                            content: Text('Status unchanged! Try again!'),
                          ));
              } else {
                return AlertDialog(
                  content: Text('Network error! Try again!'),
                );
              }
            }));
  }

  deliver() async {
    Map body = {
      'userID': jsonData['userID'],
      'orderID': widget.orderID,
      'useremail': jsonData['useremail'],
      'username': jsonData['username'],
      'accountType': jsonData['accountType'],
      'clearAgentID': clearAgentID
    };
    var encodedData = jsonEncode(body);
    try {
      String link = 'https://arthubserver.herokuapp.com/apiS/updatedelivery';
      var update = await http.post(link,
          body: encodedData,
          headers: {'Content-Type': 'application/json; charset=UTF-8'});
      print('status code - ${update.statusCode}');
      return update.statusCode;
    } catch (error) {
      print('error at deliver() - $error');
    }
  }

  snackbar(String text) {
    return _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(text),
      duration: Duration(seconds: 1),
      backgroundColor: Colors.red,
    ));
  }
}
