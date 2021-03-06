import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/food_model.dart';
import 'package:foodlion/models/order_model.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:foodlion/utility/sqlite_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowFood extends StatefulWidget {
  final FoodModel foodModel;
  ShowFood({Key key, this.foodModel});
  @override
  _ShowFoodState createState() => _ShowFoodState();
}

class _ShowFoodState extends State<ShowFood> {
  // Field
  FoodModel foodModel;
  int amountFood = 1;
  String idShop, idUser, idFood, nameshop, nameFood, urlFood, priceFood;
  bool statusShop = false;
  String nameCurrentShop;

  // Method
  @override
  void initState() {
    super.initState();
    foodModel = widget.foodModel;
    setupVariable();
  }

  Future<void> setupVariable() async {
    idShop = foodModel.idShop;
    idFood = foodModel.id;
    nameshop = await MyAPI().findNameShopWhere(idShop);
    nameFood = foodModel.nameFood;
    urlFood = foodModel.urlFood;
    priceFood = foodModel.priceFood;

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      idUser = preferences.getString('Login');

      List<OrderModel> orderModels = await SQLiteHelper().readDatabase();
      if (orderModels.length != 0) {
        for (var model in orderModels) {
          nameCurrentShop = model.nameShop;
          if (idShop != model.idShop) {
            statusShop = true;
          }
        }
      }
    } catch (e) {}
  }

  Widget showPrice() {
    return Column(
      children: <Widget>[
        Text(
          'ราคา :  ${foodModel.priceFood} บาท',
          style: MyStyle().h1PrimaryStyle,
        ),
      ],
    );
  }

  Text showDetail() {
    return Text(
      foodModel.detailFood,
      style: MyStyle().h2StylePrimary,
    );
  }

  Text showName() {
    return Text(
      foodModel.nameFood,
      style: MyStyle().h1Style,
    );
  }

  Widget showImage() => Stack(
        children: <Widget>[
          Hero(
            tag: widget.foodModel.urlFood,
            child: CachedNetworkImage(
              imageUrl: foodModel.urlFood,
              height: 260.0,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  color: Colors.white,
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
      );

  Widget chooseAmount() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          IconButton(
              icon: Icon(
                Icons.add_circle,
                size: 36.0,
                color: Colors.green,
              ),
              onPressed: () {
                setState(() {
                  amountFood++;
                });
              }),
          MyStyle().mySizeBox(),
          Text(
            '$amountFood',
            style: MyStyle().h1PrimaryStyle,
          ),
          MyStyle().mySizeBox(),
          IconButton(
              icon: Icon(
                Icons.remove_circle,
                size: 36.0,
                color: Colors.red,
              ),
              onPressed: () {
                if (amountFood != 0) {
                  setState(() {
                    amountFood--;
                  });
                }
              }),
        ],
      ),
    );
  }



  Widget showButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            chooseAmount(),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              showImage(),
            ],
          ),
          SizedBox(height: 20.0,),
          showName(),
          SizedBox(height: 20.0,),
          showDetail(),
          showPrice(),
          SizedBox(height: 30.0,),
          showButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (statusShop) {
              normalDialog(context, 'ไม่สามารถเลือกได้ คะ ?',
                  'โปรดเลือกอาหาร จาก ร้าน $nameCurrentShop คะ ถ้าต้องการเลือก รายการอาหารนี่ ให้ Confirm Order ก่อนคะ');
            } else if (amountFood == 0) {
              normalDialog(context, 'ยังไม่มี รายการอาหาร',
                  'กรุณาเพิ่มจำนวน รายการอาหาร');
            } else if (idUser == null) {
              normalDialog(
                  context, 'ยังไม่ได้ Login', 'กรุณา Login ก่อน Order คะ');
            } else {
              //print('idFood=$idFood, idShop=$idShop,nameShop=$nameshop, nameFood=$nameFood, urlFood=$urlFood, priceFood=$priceFood, amountFood=$amountFood');
              
              OrderModel model = OrderModel(
                idFood: idFood,
                idShop: idShop,
                nameShop: nameshop,
                nameFood: nameFood,
                urlFood: urlFood,
                priceFood: priceFood,
                amountFood: amountFood.toString(),
              );
              SQLiteHelper().insertDatabase(model);
              Navigator.of(context).pop();
              
            }
        },
        label: Text('เพิ่มอาหารไปยังตะกร้า'),
        icon: Icon(Icons.shopping_cart),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
