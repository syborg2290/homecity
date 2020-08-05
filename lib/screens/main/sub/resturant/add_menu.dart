import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () async {
                            var obj = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MenuItemForm(
                                          itemType: 'Hot dishes',
                                        )));
                            if (obj != null) {
                              setState(() {
                                menu.add(obj);
                              });
                            }
                          },
                          child: Container(
                            width: 190,
                            height: 190,
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: <Widget>[
                                          Image.asset(
                                            'assets/icons/hotdishes.png',
                                            width: 100,
                                            height: 100,
                                            color: Pallete.mainAppColor,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Hot dishes",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Pallete.mainAppColor,
                                                fontSize: 19,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 5,
                              margin: EdgeInsets.all(10),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            var obj = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MenuItemForm(
                                          itemType: 'Fast food',
                                        )));
                            if (obj != null) {
                              setState(() {
                                menu.add(obj);
                              });
                            }
                          },
                          child: Container(
                            width: 190,
                            height: 190,
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: <Widget>[
                                          Image.asset(
                                            'assets/icons/fast-food.png',
                                            width: 100,
                                            height: 100,
                                            color: Pallete.mainAppColor,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Fast food",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Pallete.mainAppColor,
                                                fontSize: 19,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 5,
                              margin: EdgeInsets.all(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () async {
                            var obj = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MenuItemForm(
                                          itemType: 'Meat',
                                        )));
                            if (obj != null) {
                              setState(() {
                                menu.add(obj);
                              });
                            }
                          },
                          child: Container(
                            width: 190,
                            height: 190,
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: <Widget>[
                                          Image.asset(
                                            'assets/icons/meat.png',
                                            width: 100,
                                            height: 100,
                                            color: Pallete.mainAppColor,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Meat",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Pallete.mainAppColor,
                                                fontSize: 19,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 5,
                              margin: EdgeInsets.all(10),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            var obj = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MenuItemForm(
                                          itemType: 'Vegetarian',
                                        )));
                            if (obj != null) {
                              setState(() {
                                menu.add(obj);
                              });
                            }
                          },
                          child: Container(
                            width: 190,
                            height: 190,
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: <Widget>[
                                          Image.asset(
                                            'assets/icons/vegetarian.png',
                                            width: 100,
                                            height: 100,
                                            color: Pallete.mainAppColor,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Vegetarian",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Pallete.mainAppColor,
                                                fontSize: 19,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 5,
                              margin: EdgeInsets.all(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () async {
                            var obj = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MenuItemForm(
                                          itemType: 'Drinks',
                                        )));
                            if (obj != null) {
                              setState(() {
                                menu.add(obj);
                              });
                            }
                          },
                          child: Container(
                            width: 190,
                            height: 190,
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: <Widget>[
                                          Image.asset(
                                            'assets/icons/drink.png',
                                            width: 100,
                                            height: 100,
                                            color: Pallete.mainAppColor,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Drinks",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Pallete.mainAppColor,
                                                fontSize: 19,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 5,
                              margin: EdgeInsets.all(10),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            var obj = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MenuItemForm(
                                          itemType: 'Desserts',
                                        )));
                            if (obj != null) {
                              setState(() {
                                menu.add(obj);
                              });
                            }
                          },
                          child: Container(
                            width: 190,
                            height: 190,
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: <Widget>[
                                          Image.asset(
                                            'assets/icons/desserts.png',
                                            width: 100,
                                            height: 100,
                                            color: Pallete.mainAppColor,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Desserts",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Pallete.mainAppColor,
                                                fontSize: 19,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 5,
                              margin: EdgeInsets.all(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () async {
                            var obj = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MenuItemForm(
                                          itemType: 'Seafoods',
                                        )));
                            if (obj != null) {
                              setState(() {
                                menu.add(obj);
                              });
                            }
                          },
                          child: Container(
                            width: 190,
                            height: 190,
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: <Widget>[
                                          Image.asset(
                                            'assets/icons/seafood.png',
                                            width: 100,
                                            height: 100,
                                            color: Pallete.mainAppColor,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Seafoods",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Pallete.mainAppColor,
                                                fontSize: 19,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 5,
                              margin: EdgeInsets.all(10),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            var obj = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MenuItemForm(
                                          itemType: 'Other',
                                        )));
                            if (obj != null) {
                              setState(() {
                                menu.add(obj);
                              });
                            }
                          },
                          child: Container(
                            width: 190,
                            height: 190,
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: <Widget>[
                                          Image.asset(
                                            'assets/icons/other.png',
                                            width: 100,
                                            height: 100,
                                            color: Pallete.mainAppColor,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Other",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Pallete.mainAppColor,
                                                fontSize: 19,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 5,
                              margin: EdgeInsets.all(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
