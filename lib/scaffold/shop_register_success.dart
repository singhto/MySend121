import 'package:flutter/material.dart';
import 'package:foodlion/scaffold/home.dart';
import 'package:foodlion/utility/my_style.dart';

class ShopRegisterSuccess extends StatefulWidget {
  @override
  _ShopRegisterSuccessState createState() => _ShopRegisterSuccessState();
}

class _ShopRegisterSuccessState extends State<ShopRegisterSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                MaterialPageRoute route = MaterialPageRoute(
                  builder: (value) => Home(),
                );
                Navigator.of(context)
                    .pushAndRemoveUntil(route, (value) => false);
              })
        ],
        title: Center(
          child: Text(
            'SEND',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //SizedBox(height: 40.0,),
            MyStyle().showLogoThankYou(),
            SizedBox(height: 20.0,),
            Text(
              'ขอบคุณที่สมัครเป็นร้านค้ากับ SEND',
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 24.0),
            ),
            Text('เราจะติดต่อกลับเพื่อยืนยันตัวตน',style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18.0),),
            Text('ภายใน 24 ชั่วโมง',style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18.0),),
          ],
        ),
      ),
    );
  }
}
