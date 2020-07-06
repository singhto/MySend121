import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/food_model.dart';
import 'package:foodlion/models/order_model.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:foodlion/scaffold/show_food.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/sqlite_helper.dart';

class ShowMenu extends StatefulWidget {
  final UserShopModel userShopModel;
  ShowMenu({Key key, this.userShopModel}) : super(key: key);
  @override
  _ShowMenuState createState() => _ShowMenuState();
}

class _ShowMenuState extends State<ShowMenu> {
  UserShopModel userShopModel;
  String idShop;
  List<FoodModel> foodModels = List();
  int amount = 0;

  @override
  void initState() {
    super.initState();
    userShopModel = widget.userShopModel;
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

  Future<Null> readAllFood() async {
    idShop = userShopModel.id;
    // print('idShop ===> $idShop');
    String url =
        'http://movehubs.com/app/getFoodWhereIdShop.php?isAdd=true&idShop=$idShop';

    Response response = await Dio().get(url);
    //print('response ===>> $response');

    var result = json.decode(response.data);
    //print('response ===>> $result');

    for (var map in result) {
      FoodModel foodModel = FoodModel.fromJson(map);
      setState(() {
        foodModels.add(foodModel);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return foodModels.length == 0
        ? Center(
            child: Text(
              'ไม่มีรายการอาหาร...',
              style: MyStyle().h1PrimaryStyle,
            ),
          )
        : ListView.builder(
            itemCount: foodModels.length,
            itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    MaterialPageRoute route = MaterialPageRoute(
                        builder: (value) => ShowFood(
                              foodModel: foodModels[index],
                            ));
                    Navigator.of(context).push(route).then(
                          (value) => checkAmount(),
                        );
                  },
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        width: 1.0,
                        color: Colors.grey[200],
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image(
                              height: 150.0,
                              width: 150.0,
                              image: NetworkImage(foodModels[index].urlFood),
                              fit: BoxFit.cover),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        foodModels[index].nameFood,
                                        style: MyStyle().h2Style,
                                        overflow: TextOverflow.clip
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  foodModels[index].detailFood,
                                  style: MyStyle().h2NormalStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      foodModels[index].priceFood,
                                      style: MyStyle().h2Style,
                                    ),
                                    Text(
                                      ' บาท',
                                      style: MyStyle().h2Style,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
  }
}
