import 'package:flutter/material.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfoShop extends StatefulWidget {
  @override
  _InfoShopState createState() => _InfoShopState();
}

class _InfoShopState extends State<InfoShop> {
  UserShopModel userShopModel;

  @override
  void initState() {
    super.initState();
    findShop();
  }

  Future<Null> findShop() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idShop = preferences.getString('id');
    print('idShop = $idShop');

    try {
      var object = await MyAPI().findDetailShopWhereId(idShop);
      setState(() {
        userShopModel = object;
      });
    } catch (e) {}
  }

  Marker yourLocation() {
    return Marker(
        markerId: MarkerId('myLoaction'),
        position: LatLng(
          double.parse(userShopModel.lat),
          double.parse(userShopModel.lng),
        ),
        infoWindow: InfoWindow(title: userShopModel.name));
  }

  Set<Marker> myMarker() {
    return <Marker>[yourLocation()].toSet();
  }

  Container showMap() {
    LatLng latLng = LatLng(
        double.parse(userShopModel.lat), double.parse(userShopModel.lng));
    CameraPosition position = CameraPosition(target: latLng, zoom: 16);
    return Container(
      width: 500.0,
      height: 100.0,
      child: GoogleMap(
        initialCameraPosition: position,
        onMapCreated: (controller) {},
        markers: myMarker(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: MyStyle().showTitleAppBar(userShopModel.name),
      //   titleSpacing: 0.2,
      // ),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      color: Theme.of(context).primaryColor,
                      iconSize: 30.0,
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: Icon(Icons.favorite),
                      color: Theme.of(context).primaryColor,
                      iconSize: 30.0,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                showMap(),
                SizedBox(
                  height: 6.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${userShopModel.name}',
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'ระยะทาง ... km',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(height: 6.0),
                Text(
                  '83/1 หมู่ 5 ต.หนองไขว่',
                  style: TextStyle(fontSize: 18.0),
                ),
                Divider(
                  height: 5.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    
                    FlatButton(
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      onPressed: () {},
                      child: Text(
                        'เมนูอาหาร',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    FlatButton(
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      onPressed: () {},
                      child: Text(
                        'รีวิว',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
