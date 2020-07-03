import 'package:flutter/material.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:foodlion/widget/my_food.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MySearch extends StatefulWidget {
  @override
  _MySearchState createState() => _MySearchState();
}

class _MySearchState extends State<MySearch> {
  List<UserShopModel> _list = [];
  List<UserShopModel> _search = [];

  var loading = false;

  Future<Null> fetchData() async {
    setState(() {
      loading = true;
    });
    _list.clear();
    final response = await http.get('http://movehubs.com/app/getAllShop.php');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        for (Map i in data) {
          _list.add(UserShopModel.fromJson(i));
          loading = false;
        }
      });
    }
  }

  TextEditingController controller = new TextEditingController();

  onSearch(String text) async {
    _search.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    _list.forEach((f) {
      if (f.name.contains(text) || f.id.toString().contains(text))
        _search.add(f);
      {}
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10.0),
              color: Theme.of(context).primaryColor,
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.search),
                  title: TextField(
                    controller: controller,
                    onChanged: onSearch,
                    decoration: InputDecoration(
                        hintText: 'ค้นหา', border: InputBorder.none),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      controller.clear();
                      onSearch('');
                    },
                  ),
                ),
              ),
            ),
            loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: _search.length != 0 || controller.text.isNotEmpty
                        ? ListView.builder(
                            itemCount: _search.length,
                            itemBuilder: (context, i) {
                              final b = _search[i];
                              return Container(
                                padding: EdgeInsets.all(10.0),
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(1.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          leading: Icon(Icons.alarm),
                                          title: Text(
                                            b.name,
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          onTap: () {
                                            print('id Shop ==>>${b.id}');

                                            Navigator.of(context).pop();
                                            MaterialPageRoute materialPageRoute = MaterialPageRoute(
                                              builder: (context) => MyFood(),
                                            );
                                            Navigator.push(context, materialPageRoute);
                                          },
                                          subtitle: Text('${b.lat} ${b.lng}'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            itemBuilder: (context, i) {
                              final a = _list[i];
                            },
                            itemCount: _list.length,
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
