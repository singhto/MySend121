import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/order_user_model.dart';
import 'package:foodlion/scaffold/dashboard_delivery.dart';
import 'package:foodlion/scaffold/rider_success.dart';
import 'package:foodlion/scaffold/show_cart.dart';
import 'package:foodlion/scaffold/show_order_shop.dart';
import 'package:foodlion/widget/add_my_food.dart';
import 'package:foodlion/widget/guest.dart';
import 'package:foodlion/widget/info_shop.dart';
import 'package:foodlion/widget/main_home.dart';
import 'package:foodlion/widget/my_delivery.dart';
import 'package:foodlion/widget/my_food_shop.dart';
import 'package:foodlion/widget/order_shop.dart';
import 'package:foodlion/widget/register_delivery.dart';
import 'package:foodlion/widget/register_shop.dart';
import 'package:foodlion/widget/register_user.dart';
import 'package:foodlion/widget/show_order_user.dart';
import 'package:foodlion/widget/signin_delivery.dart';
import 'package:foodlion/widget/signin_shop.dart';
import 'package:foodlion/widget/signin_user.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utility/my_style.dart';

class Home extends StatefulWidget {
  final Widget currentWidget;
  final int indexLogin;
  final OrderUserModel orderUserModel;
  final String nameShop;
  final int distance;
  final int transport;
  Home(
      {Key key,
      this.currentWidget,
      this.indexLogin,
      this.orderUserModel,
      this.nameShop,
      this.distance,
      this.transport})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Field
  Widget cuttentWidget = MyStyle().showProgress();
  String nameLogin, avatar, modeLogin, loginType, token, nameShop, id;
  bool statusLogin = false; //false => no login
  int amount = 0, distance, transport;
  OrderUserModel orderUserModel;
  double lat, lng;

  // Method
  @override
  void initState() {
    super.initState();

    orderUserModel = widget.orderUserModel;
    nameShop = widget.nameShop;
    distance = widget.distance;
    transport = widget.transport;

    findLatLng();
  }

  Future<Null> findLatLng() async {
    // print('##################findLatLng on Home Work#######################');
    LocationData locationData = await findLocationData();
    setState(() {
      lat = locationData.latitude;
      lng = locationData.longitude;

      checkLogin();
      checkWidget();
    });
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return location.getLocation();
    } catch (e) {
      return null;
    }
  }

  void checkWidget() {
    Widget myWidget = widget.currentWidget;

    if (myWidget != null) {
      print('Widget NotNull');
      setState(() {
        cuttentWidget = myWidget;
      });
    }
  }

  Future<void> checkLogin() async {
    // print('#############CheckLogin On Home Work#############');
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      modeLogin = preferences.getString('Login');
      nameLogin = preferences.getString('Name');
      avatar = preferences.getString('UrlShop');
      loginType = preferences.getString('Login');
      id = preferences.getString('id');

      if (modeLogin == 'Shop') {
        if (!(nameLogin == null || nameLogin.isEmpty)) {
          setState(() {
            statusLogin = true;
            cuttentWidget = OrderShop();
          });
        }
      } else if (modeLogin == 'User') {
        MaterialPageRoute route = MaterialPageRoute(
          builder: (context) => MainHome(),
        );
        Navigator.pushAndRemoveUntil(context, route, (route) => false);
      } else if (modeLogin == 'Dev') {
        String url =
            'http://movehubs.com/app/getOrderWhereIdDevAnSuccess.php?isAdd=true&idDelivery=$id&Success=RiderOrder';
        Response response = await Dio().get(url);
        // print('res Dev ######################===>>>> $response');

        if (response.toString() != 'null') {
          var result = json.decode(response.data);
          for (var map in result) {
            // print('map = $map');

            OrderUserModel orderUserModel = OrderUserModel.fromJson(map);

            MaterialPageRoute route = MaterialPageRoute(
              builder: (context) => RiderSuccess(
                orderUserModel: orderUserModel,
              ),
            );
            Navigator.pushAndRemoveUntil(context, route, (route) => false);
          }
        } else {
          setState(() {
            statusLogin = true;
            cuttentWidget = MyDelivery();
          });
        }
      } else {
        setState(() {
          cuttentWidget = Guest();
        });
      }
    } catch (e) {}
  }

  Widget showDrawer() {
    // print('modeLogin ===>>> $modeLogin');
    Widget myWidget;
    if (modeLogin == 'Shop') {
      myWidget = shopList();
    } else if (modeLogin == 'User') {
      myWidget = userList();
    } else if (modeLogin == 'Dev') {
      myWidget = deliveryList();
    } else {
      myWidget = generalList();
    }
    return Drawer(
      child: myWidget,
      
    );
  }

  ListView generalList() {
    return ListView(
      children: <Widget>[
        showHead(),
        menuSignIn(),
        menuSignInShop(),
        menuSignInDriver(),
        menuSignUp(),
      ],
    );
  }

  ListView userList() {
    return ListView(
      children: <Widget>[
        showHeadUser(),
        //menuHome(),
        menuShowCart(),
        menuUserOrder(),
        menuSignOut(),
      ],
    );
  }

  ListView shopList() {
    return ListView(
      children: <Widget>[
        showHeadShop(),
        menuOrderShop(),
        handleMenu(),
        menuInfoShop(),
        //menuMyFoodShop(),
        menuAddMyFood(),
        menuSignOut(),
      ],
    );
  }

  ListView deliveryList() {
    return ListView(
      children: <Widget>[
        showHeadUser(),
        menuOrderDelivery(),
        menuInfoDelivery(),
        menuHistoryDelivery(),
        menuSignOut(),
      ],
    );
  }

  Widget menuMyFood() {
    return ListTile(
      leading: Icon(
        Icons.restaurant_menu,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'รายการอาหาร',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'เมนูอาหารของฉัน',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          cuttentWidget = MyFoodShop();
        });
      },
    );
  }

  // Widget menuMyFoodShop() {
  //   return ListTile(
  //     leading: Icon(
  //       Icons.restaurant_menu,
  //       size: 36.0,
  //       color: MyStyle().dartColor,
  //     ),
  //     title: Text(
  //       'รายการอาหาร',
  //       style: MyStyle().h2Style,
  //     ),
  //     subtitle: Text(
  //       'เมนูอาหารของร้าน',
  //       style: MyStyle().h3StylePrimary,
  //     ),
  //     onTap: () {
  //       MaterialPageRoute materialPageRoute = MaterialPageRoute(
  //         builder: (context) => MyFoodShop(),
  //       );
  //       Navigator.push(context, materialPageRoute);
  //     },
  //   );
  // }

  Widget menuAddMyFood() {
    return ListTile(
      leading: Icon(
        Icons.playlist_add,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'เพิ่ม รายการ อาหาร',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'เพิ่มข้อมูลรายการอาหารของฉัน',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        routeToAddMyFood();
      },
    );
  }

  Widget menu() {
    return ListTile(
      leading: Icon(
        Icons.android,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'text',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'sub text',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget handleMenu() {
    return ListTile(
      leading: Icon(
        Icons.history,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'ประวัติการรับออเดอร์',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'ข้อมูลออเดอร์ของร้านทั้งหมด',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        routeToShowOrderShop();
      },
    );
  }

  Widget menuOrderDelivery() {
    return ListTile(
      leading: Icon(
        Icons.list,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'รับ Order',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'รอรับ Order',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        setState(() {
          cuttentWidget = MyDelivery();
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget menuInfoDelivery() {
    return ListTile(
      leading: Icon(
        Icons.dashboard,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'เติมปอง',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'เติมปองให้เพียงพอสำหรับรับ Order',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        setState(() {
          cuttentWidget = DashboardDelivery();
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget menuHistoryDelivery() {
    return ListTile(
      leading: Icon(
        Icons.work,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'ผลงานที่ผ่านมา',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'เช็คประวัติและผลงานการทำงาน',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {},
    );
  }

  Widget menuInfoShop() {
    return ListTile(
      leading: Icon(
        Icons.home,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'ข้อมูลร้าน',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'ข้อมูลร้านค้า, เมนูอาหาร',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        routeToInfoShop();
      },
    );
  }

  Widget menuUserOrder() {
    return ListTile(
      leading: Icon(
        Icons.directions_bike,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'สถานะคำสั่งซื้อ',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'ติดตามสถานะคำสั่งซื้อของคุณ',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        setState(() {
          cuttentWidget = ShowOrderUser();
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget menuShowCart() {
    return ListTile(
      leading: Icon(
        Icons.shopping_cart,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'ตะกร้า',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'แสดงรายการสินค้า ที่มีใน ตะกร้า',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        routeToShowCart();
      },
    );
  }

  Widget menuOrderShop() {
    return ListTile(
      leading: Icon(
        Icons.playlist_add_check,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'รายการอาหาร ที่ลูกค้าสั่ง',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'รายการอาหาร ที่ลูกค้าสั่งมา แสดงสถานะ',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          cuttentWidget = OrderShop();
        });
      },
    );
  }

  Widget menuSignOut() {
    return ListTile(
      leading: Icon(
        Icons.exit_to_app,
        color: MyStyle().dartColor,
        size: 36.0,
      ),
      title: Text(
        'ออกจากระบบ',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'กดที่นี่ เพื่อออกจากระบบ',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        // Navigator.of(context).pop();
        signOutProcess();
      },
    );
  }

  Future<void> signOutProcess() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.clear();

      // exit(0);

      MaterialPageRoute route = MaterialPageRoute(builder: (value) => Home());
      Navigator.of(context).pushAndRemoveUntil(route, (value) => false);
    } catch (e) {}
  }

  Future<void> chooseRegister(String title, bool registerBool) async {
    showDialog(
      context: context,
      builder: (value) => AlertDialog(
        title: ListTile(
          leading: Icon(
            Icons.account_circle,
            size: 36,
            color: MyStyle().dartColor,
          ),
          title: Text(
            'เลือกสมัครบริการ',
            style: MyStyle().h1Style,
          ),
        ),
        content: showButtom(registerBool),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: MyStyle().h2Style,
            ),
          ),
        ],
      ),
    );
  }

  Widget menuSignUp() {
    return ListTile(
      leading: Icon(
        Icons.account_circle,
        size: 36,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'สมัครใช้บริการ',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'คลิกเพื่อ สมัครใช้บริการ',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        chooseRegister('Register', true);
      },
    );
  }

  Widget menuSignIn() {
    return ListTile(
      leading: Icon(
        Icons.fastfood,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'สั่งอาหาร',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'เมนูอรอ่ยพร้อมเสิร์ฟ',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          cuttentWidget = SingInUser();
        });
      },
    );
  }

  Widget menuSignInShop() {
    return ListTile(
      leading: Icon(
        Icons.store_mall_directory,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'สำหรับร้านค้า',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'เข้าสู่ระบบเพื่อจัดการร้านค้า',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          cuttentWidget = SignInshop();
        });
      },
    );
  }

  Widget menuSignInDriver() {
    return ListTile(
      leading: Icon(
        Icons.motorcycle,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'สำหรับ Driver',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'เข้าสู่ระบบเพื่อส่งอาหาร',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          cuttentWidget = SignDelivery();
        });
      },
    );
  }

  Widget showButtom(bool registerBool) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 150.0,
          child: Row(
            children: <Widget>[
              FlatButton.icon(
                onPressed: () {
                  if (registerBool) {
                    setState(() {
                      cuttentWidget = RegisterUser();
                    });
                  } else {
                    setState(() {
                      cuttentWidget = SingInUser();
                    });
                  }
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.touch_app,
                  color: MyStyle().primaryColor,
                ),
                label: Text(
                  'เพื่อสั่งอาหาร',
                  style: MyStyle().h2StylePrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 150.0,
          child: Row(
            children: <Widget>[
              FlatButton.icon(
                onPressed: () {
                  if (registerBool) {
                    setState(() {
                      cuttentWidget = RegisterShop();
                    });
                  } else {
                    setState(() {
                      cuttentWidget = SignInshop();
                    });
                  }
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.fastfood,
                  color: MyStyle().primaryColor,
                ),
                label: Text(
                  'เพื่อขายอาหาร',
                  style: MyStyle().h2StylePrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 150.0,
          child: Row(
            children: <Widget>[
              FlatButton.icon(
                onPressed: () {
                  if (registerBool) {
                    setState(() {
                      cuttentWidget = RegisterDelivery();
                    });
                  } else {
                    setState(() {
                      cuttentWidget = SignDelivery();
                    });
                  }
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.directions_bike,
                  color: MyStyle().primaryColor,
                ),
                label: Text(
                  'เพื่อส่งอาหาร',
                  style: MyStyle().h2StylePrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget showHead() {
    // print('nameLogin ==>>> $nameLogin');
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('images/bic2.png'), fit: BoxFit.cover),

      ),
      
      currentAccountPicture: MyStyle().showLogo(),
      accountName: Text(
        'SEND',
        style: MyStyle().h2StyleWhite,
      ),
      accountEmail: Text('เข้าสู่ระบบ'),
    );
  }

  Widget showHeadUser() {
    // print('nameLogin ==>>> $nameLogin');
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('images/bic3.png'), fit: BoxFit.cover),
      ),
      currentAccountPicture: MyStyle().showLogo(),
      accountName: Text(
        nameLogin,
        style: MyStyle().h2StyleWhite,
      ),
      accountEmail: Text('Login'),
    );
  }

  Widget showHeadShop() {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('images/bic4.png'), fit: BoxFit.cover),
      ),
      currentAccountPicture: MyStyle().showLogo(),
      accountName: Text(
        nameLogin,
        style: MyStyle().h2StyleWhite,
      ),
    );
  }

  Widget showAvatar() => CircleAvatar(
        backgroundImage: NetworkImage(avatar),
      );

  Widget showCart() {
    return loginType == 'User'
        ? GestureDetector(
            onTap: () {
              routeToShowCart();
            },
            child: MyStyle().showMyCart(amount),
          )
        : MyStyle().mySizeBox();
  }

  void routeToShowCart() {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (value) => ShowCart());
    Navigator.of(context).push(materialPageRoute).then((value) => checkLogin());
  }

  void routeToInfoShop() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => InfoShop(),
    );
    Navigator.push(context, materialPageRoute);
  }

  void routeToShowOrderShop() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => ShowOrderShop(),
    );
    Navigator.push(context, materialPageRoute);
  }

  void routeToAddMyFood() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => AddMyFood(),
    );
    Navigator.push(context, materialPageRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: showDrawer(),
      appBar: AppBar(
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
      body: cuttentWidget,
    );
  }
}
