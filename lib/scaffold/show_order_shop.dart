import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/food_model.dart';
import 'package:foodlion/models/order_user_model.dart';
import 'package:foodlion/models/user_model.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowOrderShop extends StatefulWidget {
  @override
  _ShowOrderShopState createState() => _ShowOrderShopState();
}

class _ShowOrderShopState extends State<ShowOrderShop> {
  List<OrderUserModel> orderUserModels = List();
  List<UserModel> userModels = List();
  List<List<FoodModel>> listFoodModels = List();
  List<List<String>> listAmounts = List();
  List<List<String>> listSums = List();
  List<List<String>> listStatuss = List();

  @override
  void initState() {
    super.initState();
    readOrder();
  }

  Future<Null> readOrder() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idShop = preferences.getString('id');

    String url =
        'http://movehubs.com/app/getOrderWhereIdShop.php?isAdd=true&idShop=$idShop';
    await Dio().get(url).then((value) async {
      var result = json.decode(value.data);
      for (var map in result) {
        // print('map ==>> ${map.toString()}');
        OrderUserModel orderUserModel = OrderUserModel.fromJson(map);

        String amount = orderUserModel.amountFoods;
        amount = amount.substring(1, amount.length - 1);
        List<String> amounts = amount.split(',');
        listAmounts.add(amounts);

        String foodId = orderUserModel.idFoods;
        foodId = foodId.substring(1, foodId.length - 1);
        List<String> foods = foodId.split(',');
        List<FoodModel> foodModels = List();
        for (var id in foods) {
          FoodModel foodModel = await MyAPI().findDetailFoodWhereId(id);
          foodModels.add(foodModel);
        }

        UserModel userModel =
            await MyAPI().findDetailUserWhereId(orderUserModel.idUser);
        if (orderUserModel.success != '0') {
          setState(() {
            orderUserModels.add(orderUserModel);
            userModels.add(userModel);
            listFoodModels.add(foodModels);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการรับออเดอร์'),
      ),
      body: orderUserModels.length == 0
          ? Center(
              child: MyStyle().showProgress()
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                itemCount: orderUserModels.length,
                itemBuilder: (context, index) => Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'ลูกค้า : ${userModels[index].name}',
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        Text(
                          '${orderUserModels[index].success}',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: orderUserModels[index].success == 'ShopOrder' ||
                                  orderUserModels[index].success == 'Success'
                                ? Colors.green
                                : Colors.grey.shade500 
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text('วันที่ : ${orderUserModels[index].dateTime}'),
                        SizedBox(
                          width: 20.0,
                        ),
                        Text('เลขที่ : ${orderUserModels[index].id}'),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Center(child: Text('รายการอาหาร')),
                          flex: 5,
                        ),
                        Expanded(
                          child: Text('ราคา'),
                          flex: 1,
                        ),
                        Expanded(
                          child: Text('จำนวน'),
                          flex: 1,
                        ),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemCount: listFoodModels[index].length,
                      itemBuilder: (context, index2) => Row(
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: Text(
                                '${listFoodModels[index][index2].nameFood}'),
                          ),
                          Expanded(
                            flex: 1,
                            child:
                                Text(listFoodModels[index][index2].priceFood),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(listAmounts[index][index2].trim()),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            'ราคารวม ${orderUserModels[index].totalPrice} บาท',
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor),
                          )
                        ],
                      ),
                    ),
                    Divider(
                      height: 5,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
