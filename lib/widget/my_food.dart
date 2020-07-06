import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/food_model.dart';
import 'package:foodlion/models/order_model.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:foodlion/scaffold/show_cart.dart';
import 'package:foodlion/scaffold/show_food.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/sqlite_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyFood extends StatefulWidget {
  final String idShop;
  
  MyFood({Key key, this.idShop}) : super(key: key);
  @override
  _MyFoodState createState() => _MyFoodState();
}

class _MyFoodState extends State<MyFood> {
  // Field
  bool statusData = true;
  List<FoodModel> foodModels = List();
  String myIdShop;
  int amount = 0;
List<UserShopModel> userShopModels = List();


  // Method
  @override
  void initState() {
    super.initState();
    myIdShop = widget.idShop;
    readAllFood();
    checkAmount();
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

  Future<String> getIdShop() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idShop = preferences.getString('id');

    return idShop;
  }

  Future<void> readAllFood() async {
    String idShop = await getIdShop();
    if (myIdShop != null) {
      idShop = myIdShop;
    }
    // print('idShop ===> $idShop');
    String url =
        'http://movehubs.com/app/getFoodWhereIdShop.php?isAdd=true&idShop=$idShop';

    Response response = await Dio().get(url);
    // print('response ===>> $response');

    
    if (response.toString() != 'null') {
      var result = json.decode(response.data);
      // print('result ===>>> $result');

      for (var map in result) {
        FoodModel model = FoodModel.fromJson(map);
        setState(() {
          foodModels.add(model);
          statusData = false;
        });
      }
    }
  }

  Widget showNoData() {
    return Center(
      child: Text(
        'ไม่มีรายการอาหาร กรุณาเพิ่ม',
        style: TextStyle(fontSize: 24.0),
      ),
    );
  }

  Widget showListFood() {
    return ListView.builder(
      itemCount: foodModels.length,
      itemBuilder: (value, index) => showContent(index),
    );
  }

  Widget showContent(int index) => GestureDetector(
        onTap: () {
          print('You Click idFood');
          MaterialPageRoute route = MaterialPageRoute(
              builder: (value) => ShowFood(
                    foodModel: foodModels[index],
                  ));
          Navigator.of(context).push(route).then(
                (value) => checkAmount(),
              );
        },
        child: Row(
          children: <Widget>[
            showImageFood(index),
            showText(index),
          ],
        ),
      );

  Widget showText(int index) => Container(
        padding: EdgeInsets.all(10.0),
        width: MediaQuery.of(context).size.width * 0.5,
        // height: MediaQuery.of(context).size.width * 0.4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            showNameFood(index),
            showDetailFood(index),
            showPrice(index),
          ],
        ),
      );

  Widget showPrice(int index) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            'ราคา : ${foodModels[index].priceFood} บาท',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      );

  Widget showDetailFood(int index) {
    String string = foodModels[index].detailFood;
    if (string.length > 50) {
      string = string.substring(0, 49);
      string = '$string ...';
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.5 - 20,
          child: Text(
            string,
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget showNameFood(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.5 - 30,
          child: Text(
            foodModels[index].nameFood,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget showImageFood(int index) {
    return Container(
      padding: EdgeInsets.all(20.0),
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.width * 0.5,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            image: DecorationImage(
              image: NetworkImage(foodModels[index].urlFood),
              fit: BoxFit.cover,
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการอาหาร'),
        actions: <Widget>[showCart()],
      ),
      body: statusData ? showNoData() : showListFood(),
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
}
