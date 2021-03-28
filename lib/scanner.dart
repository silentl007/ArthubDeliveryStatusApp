import 'package:ArthubDelivery/status.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan_fix/barcode_scan.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  static const purple = Color.fromRGBO(69, 56, 133, 1);
  final orderIDcontroller = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double padding40 = size.height * 0.05;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          padding: EdgeInsets.only(left: padding40, right: padding40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: orderIDcontroller,
                cursorColor: purple,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: purple)),
                  labelText: 'Order ID',
                  helperText: 'Please insert order ID',
                  icon: Icon(Icons.confirmation_num, color: purple),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.qr_code, color: purple,),
                    onPressed: () async {
                      String code = await BarcodeScanner.scan();
                      setState(() {
                        orderIDcontroller.text = code;
                      });
                    },
                  ),
                ),
              ),
              RaisedButton(
                onPressed: () {
                  if (orderIDcontroller.text.isEmpty) {
                    snackbar('The field is empty');
                  } else if (orderIDcontroller.text.length != 36) {
                    snackbar('Incorrect order ID');
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Status(
                                  orderID: orderIDcontroller.text,
                                )));
                  }
                },
                child: Text(
                  'Proceed',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                color: purple,
              )
            ],
          ),
        ),
      ),
    );
  }

  snackbar(String text) {
    return _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(text),
      duration: Duration(seconds: 1),
      backgroundColor: Colors.red,
    ));
  }
}
