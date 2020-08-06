import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/screens/main/sub/resturant/display_menu_item_in_make.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/screens/main/sub/resturant/menu_items_form.dart';

class AddMenu extends StatefulWidget {
  final List menu;
  AddMenu({this.menu, Key key}) : super(key: key);

  @override
  _AddMenuState createState() => _AddMenuState();
}

class _AddMenuState extends State<AddMenu> {
  List menu = [];

  @override
  void initState() {
    super.initState();
    if (widget.menu != null) {
      setState(() {
        menu = widget.menu;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, menu);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: Padding(
            padding: const EdgeInsets.all(
              12,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context, menu);
              },
              child: Image.asset(
                'assets/icons/left-arrow.png',
                width: 30,
                height: 30,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
          centerTitle: false,
          title: Text(
            'Food menu',
            style: TextStyle(
                color: Colors.grey[700],
                fontFamily: "Roboto",
                fontSize: 20,
                fontWeight: FontWeight.w400),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                onPressed: () async {
                  if (menu.isNotEmpty) {
                    List reItems = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DisplayMenuItemInMake(
                                  items: menu,
                                )));
                    if (reItems != null) {
                      setState(() {
                        menu = reItems;
                      });
                    }
                  }
                },
                child: Center(
                    child: Text("New items - " + menu.length.toString(),
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
                        ))),
                color: Pallete.mainAppColor,
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0),
                    side: BorderSide(
                      color: Pallete.mainAppColor,
                    )),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              FutureBuilder(
                  future: DefaultAssetBundle.of(context)
                      .loadString("assets/json/food_menu.json"),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                          child: SpinKitCircle(color: Pallete.mainAppColor));
                    }
                    List myData = json.decode(snapshot.data);

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.count(
                          physics: ScrollPhysics(),
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          children: List.generate(myData.length, (index) {
                            return GestureDetector(
                              onTap: () async {
                                var obj = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MenuItemForm(
                                              itemType: myData[index]
                                                  ['category_name'],
                                            )));
                                if (obj != null) {
                                  setState(() {
                                    menu.add(obj);
                                  });
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 5,
                                  right: 5,
                                ),
                                child: Container(
                                  width: width * 0.25,
                                  height: height * 0.1,
                                  child: Card(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: Container(
                                      width: width * 0.25,
                                      height: height * 0.1,
                                      child: Column(
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  myData[index]
                                                      ['category_name'],
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Pallete.mainAppColor,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Image.asset(
                                                  myData[index]['image_path'],
                                                  width: 80,
                                                  height: 80,
                                                  color: Pallete.mainAppColor,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    elevation: 5,
                                    margin: EdgeInsets.all(5),
                                  ),
                                ),
                              ),
                            );
                          })),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
