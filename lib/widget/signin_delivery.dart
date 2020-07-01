import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/delivery_model.dart';
import 'package:foodlion/scaffold/home.dart';
import 'package:foodlion/utility/my_constant.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignDelivery extends StatefulWidget {
  @override
  _SignDeliveryState createState() => _SignDeliveryState();
}

class _SignDeliveryState extends State<SignDelivery> {

  // Field
  String user, password;

  // Method

  Widget showContent() {
    return Container(
      alignment: Alignment(0, -0.8),
      child: Container(
        width: 250.0,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 80.0,),
              MyStyle().showIconDrive(),
              MyStyle().mySizeBox(),
              TextField(
                style: MyStyle().h2NormalStyle,
                onChanged: (value) => user = value.trim(),
                decoration: InputDecoration(
                  labelText: 'User :',
                  labelStyle: MyStyle().h3StylePrimary,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyStyle().dartColor)),
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              TextField(
                style: MyStyle().h2NormalStyle,
                onChanged: (valur) => password = valur.trim(),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password :',
                  labelStyle: MyStyle().h3StylePrimary,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyStyle().dartColor)),
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              Container(
                width: 250.0,
                child: RaisedButton.icon(
                  color: MyStyle().primaryColor,
                  onPressed: () {
                    if (user == null ||
                        user.isEmpty ||
                        password == null ||
                        password.isEmpty) {
                      normalDialog(
                          context, 'Have Space', 'Please Fill Ever Blank');
                    } else {
                      checkAuthen();
                    }
                  },
                  icon: Icon(
                    Icons.fingerprint,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Sign In',
                    style: MyStyle().h2StyleWhite,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkAuthen() async {
    String url = '${MyConstant().urlGetDeliveryWhereUser}?isAdd=true&User=$user';

    try {
      Response response = await Dio().get(url);

      if (response.toString() == 'null') {
        normalDialog(context, 'User False', 'No $user in my Database');
      } else {
        var result = json.decode(response.data);
        for (var map in result) {
          DelivaryModel model = DelivaryModel.fromJson(map);
          
          if (password == model.password) {
            successLogin(model);
          } else {
            normalDialog(
                context, 'Password False', 'Please Try Agains Password False');
          }
        }
      }
    } catch (e) {}
  }

  Future<void> successLogin(DelivaryModel model) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('id', model.id);
      preferences.setString('Name', model.name);
      preferences.setString('Lat', model.lat);
      preferences.setString('Lng', model.lng);
      preferences.setString('Login', 'Dev');
      

      MaterialPageRoute route = MaterialPageRoute(builder: (value) => Home());
      Navigator.of(context).pushAndRemoveUntil(route, (value) => false);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        MyStyle().showTitle('เข้าสู่ระบบ SEND Drive'),
        showContent(),
      ],
    );
  }
}