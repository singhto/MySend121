import 'package:flutter/material.dart';
import 'package:foodlion/models/order_model.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:foodlion/scaffold/show_cart.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/sqlite_helper.dart';
import 'package:foodlion/widget/about_shop.dart';
import 'package:foodlion/widget/show_menu.dart';

class ShowShop extends StatefulWidget {
  final UserShopModel userShopModel;
  ShowShop({Key key, this.userShopModel}) : super(key: key);
  @override
  _ShowShopState createState() => _ShowShopState();
}

class _ShowShopState extends State<ShowShop> {
  UserShopModel userShopModel;
  List<Widget> listWidgets = List();
  int indexPage = 0;
  int amount = 0;
  
  @override
  void initState() {
    super.initState();
    userShopModel = widget.userShopModel;
    listWidgets.add(AboutShop(userShopModel: userShopModel,));
    listWidgets.add(ShowMenu(userShopModel: userShopModel,));
    checkAmount();
    showCart();
  }

    Future<void> checkAmount() async {
    print('checkAmount Work');
    try {
      List<OrderModel> list = await SQLiteHelper().readDatabase();
      setState(() {
        amount = list.length;
      });
    } catch (e) {}
  }

  BottomNavigationBarItem aboutShowNav() {
    return BottomNavigationBarItem(
        icon: Icon(Icons.restaurant), title: Text('ข้อมูลร้าน'));
  }

  BottomNavigationBarItem showMenuNav() {
    return BottomNavigationBarItem(
        icon: Icon(Icons.restaurant_menu), title: Text('Menu'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userShopModel.name),
        actions: <Widget>[
          showCart()],
        // actions: <Widget>[
        //   IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {}),
          
        // ],
      ),
      body: listWidgets.length == 0
          ? MyStyle().showProgress()
          : listWidgets[indexPage],
      bottomNavigationBar: showBottonNav(),
    );
  }

    Widget showCart() => GestureDetector(
        onTap: () {
          MaterialPageRoute route =
              MaterialPageRoute(builder: (value) => ShowCart());
          Navigator.of(context).push(route).then(
                (value) => checkAmount(),
              );
        },
        child: MyStyle().showMyCart(amount),
      );

  BottomNavigationBar showBottonNav() => BottomNavigationBar(
    //backgroundColor: MyStyle().primaryColor,
    currentIndex: indexPage,
        onTap: (value) {
          setState(() {
            indexPage = value;
          });
        },
        items: <BottomNavigationBarItem>[
          aboutShowNav(),
          showMenuNav(),
        ],
      );
}
