import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class AboutShop extends StatefulWidget {
  final UserShopModel userShopModel;
  AboutShop({Key key, this.userShopModel}) : super(key: key);
  @override
  _AboutShopState createState() => _AboutShopState();
}

class _AboutShopState extends State<AboutShop> {
  UserShopModel userShopModel;
  double lat1, lng1, lat2, lng2, distance;
  String distanceString;
  int transport;
  Location location = Location();

  @override
  void initState() {
    super.initState();
    findLat1Lng1();
    userShopModel = widget.userShopModel;
  }

  Future<Null> findLat1Lng1() async {
    LocationData locationData = await findLocationData();
    setState(() {
      lat1 = locationData.latitude;
      lng1 = locationData.longitude;
      lat2 = double.parse(userShopModel.lat);
      lng2 = double.parse(userShopModel.lng);
      //print('lat1 $lat1, $lng1, $lat2, $lng2');
      distance = calculateDistance(lat1, lng1, lat2, lng2);
      var myFormat = NumberFormat('##0.0#', 'en_US');
      distanceString = myFormat.format(distance);
      transport = calculateTransport(distance);

      //print('distance = $distance');
      //print('transport = $transport');
    });
  }

  int calculateTransport(double distance) {
    int transport = 0;
    if (distance <= 1) {
      transport = 0;
      return transport;
    } else {
      transport = 19 + ((distance - 1) * 4).round();
      return transport;
    }
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    double distance = 0;

    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
    distance = 12742 * asin(sqrt(a));

    return distance;
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return await location.getLocation();
    } catch (e) {
      return null;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Image.network(
                userShopModel.urlShop,
                height: 220.0,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 6.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${userShopModel.name}',
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor),
                    ),
                    Text(
                      distance == null ? '...' : '$distanceString กิโลเมตร',
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.star,
                            size: 18.0, color: Theme.of(context).primaryColor),
                        Icon(Icons.star,
                            size: 18.0, color: Theme.of(context).primaryColor),
                        Icon(Icons.star,
                            size: 18.0, color: Theme.of(context).primaryColor),
                        Icon(Icons.star,
                            size: 18.0, color: Theme.of(context).primaryColor),
                        Icon(Icons.star,
                            size: 18.0, color: Theme.of(context).primaryColor),
                      ],
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: <Widget>[
                    //     Text(
                    //       distance == null ? '...' : 'ค่าส่ง $transport บาท',
                    //       style: TextStyle(
                    //           fontSize: 18.0,
                    //           color: Theme.of(context).primaryColor),
                    //     )
                    //   ],
                    // )
                  ],
                ),
                SizedBox(height: 8.0),
                Text(
                  'ที่ตั้งร้านค้า :  ${userShopModel.lat} ${userShopModel.lng}',
                  style: TextStyle(
                      fontSize: 18.0, color: Theme.of(context).primaryColor),
                ),
                Text(
                  'เจ้าของร้าน : ${userShopModel.name}',
                  style: TextStyle(
                      fontSize: 18.0, color: Theme.of(context).primaryColor),
                ),
                Divider(
                  height: 5.0,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
