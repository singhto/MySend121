import 'package:flutter/material.dart';
import 'package:foodlion/utility/my_style.dart';

class DashboardDelivery extends StatefulWidget {
  @override
  _DashboardDeliveryState createState() => _DashboardDeliveryState();
}

class _DashboardDeliveryState extends State<DashboardDelivery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //SizedBox(height: 40.0,),
            Text(
              'คุณมี ... คะแนน',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2),
            ),
            SizedBox(
              height: 20.0,
            ),
            MyStyle().showLogoThankYou(),
            SizedBox(
              height: 20.0,
            ),

            Text(
              'กรุณาเติมคูปองให้เพียงพอ',
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 18.0),
            ),
            Text(
              'เพื่อไม่ให้พลาด Order จากลูกค้าของคุณ',
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 18.0),
            ),
            SizedBox(
              height: 15.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(child: Text('เติมปอง'), onPressed: () {}),
                RaisedButton(child: Text('ประวัติเติมปอง'), onPressed: () {}),
              ],
            )
          ],
        ),
      ),
    );
  }
}
