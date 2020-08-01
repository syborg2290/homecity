import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/screens/main/sub/resturant/menu_items_form.dart';

import 'display_menu_item_in_make.dart';

class AddMenu extends StatefulWidget {
  final List menu;
  AddMenu({this.menu, Key key}) : super(key: key);

  @override
  _AddMenuState createState() => _AddMenuState();
}

class _AddMenuState extends State<AddMenu> {
  List menu = [];
  List hotdishes = [];
  List fastfood = [];
  List meat = [];
  List vegetarian = [];
  List drinks = [];
  List desserts = [];

  @override
  void initState() {
    super.initState();
    if (widget.menu != null) {
      setState(() {
        menu = widget.menu;
      });

      widget.menu.forEach((element) {
        if (element["item_type"] == "Hot dishes") {
          setState(() {
            hotdishes.add(element);
          });
        }
        if (element["item_type"] == "Fast food") {
          setState(() {
            fastfood.add(element);
          });
        }

        if (element["item_type"] == "Meat") {
          setState(() {
            meat.add(element);
          });
        }
        if (element["item_type"] == "Vegetarian") {
          setState(() {
            vegetarian.add(element);
          });
        }

        if (element["item_type"] == "Drinks") {
          setState(() {
            drinks.add(element);
          });
        }

        if (element["item_type"] == "Desserts") {
          setState(() {
            desserts.add(element);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
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
              Navigator.pop(context);
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
              onPressed: () {
                Navigator.pop(context, menu);
              },
              child: Center(
                  child: Text("Done",
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () async {
                          if (hotdishes.isNotEmpty) {
                            List re = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DisplayMenuItemInMake(
                                          items: hotdishes,
                                          type: "Hot dishes",
                                        )));
                            if (re != null) {
                              setState(() {
                                hotdishes = re;
                              });
                            }
                          }
                        },
                        child: Chip(
                            backgroundColor: Colors.red,
                            label: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    "Hot dishes  - ",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  hotdishes.length.toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () async {
                          if (fastfood.isNotEmpty) {
                            List re = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DisplayMenuItemInMake(
                                          items: fastfood,
                                          type: "Fast food",
                                        )));
                            if (re != null) {
                              setState(() {
                                fastfood = re;
                              });
                            }
                          }
                        },
                        child: Chip(
                            backgroundColor: Colors.red,
                            label: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    "Fast food  - ",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  fastfood.length.toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () async {
                          if (meat.isNotEmpty) {
                            List re = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DisplayMenuItemInMake(
                                          items: meat,
                                          type: "Meat",
                                        )));
                            if (re != null) {
                              setState(() {
                                meat = re;
                              });
                            }
                          }
                        },
                        child: Chip(
                            backgroundColor: Colors.red,
                            label: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    "Meat  - ",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  meat.length.toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () async {
                          if (vegetarian.isNotEmpty) {
                            List re = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DisplayMenuItemInMake(
                                          items: vegetarian,
                                          type: "Vegetarian",
                                        )));
                            if (re != null) {
                              setState(() {
                                vegetarian = re;
                              });
                            }
                          }
                        },
                        child: Chip(
                            backgroundColor: Colors.red,
                            label: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    "Vegetarian  - ",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  vegetarian.length.toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () async {
                          if (drinks.isNotEmpty) {
                            List re = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DisplayMenuItemInMake(
                                          items: drinks,
                                          type: "Drinks",
                                        )));
                            if (re != null) {
                              setState(() {
                                drinks = re;
                              });
                            }
                          }
                        },
                        child: Chip(
                            backgroundColor: Colors.red,
                            label: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    "Drinks  - ",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  drinks.length.toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () async {
                          if (desserts.isNotEmpty) {
                            List re = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DisplayMenuItemInMake(
                                          items: desserts,
                                          type: "Desserts",
                                        )));
                            if (re != null) {
                              setState(() {
                                desserts = re;
                              });
                            }
                          }
                        },
                        child: Chip(
                            backgroundColor: Colors.red,
                            label: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    "Desserts  - ",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  desserts.length.toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            )),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
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
                              hotdishes.add(obj);
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
                                          color: Colors.black,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Hot dishes",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
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
                              fastfood.add(obj);
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
                                          color: Colors.black,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Fast food",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
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
                              meat.add(meat);
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
                                          color: Colors.black,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Meat",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
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
                              vegetarian.add(vegetarian);
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
                                          color: Colors.black,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Vegetarian",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
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
                              drinks.add(drinks);
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
                                          color: Colors.black,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Drinks",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
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
                              desserts.add(desserts);
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
                                          color: Colors.black,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Desserts",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
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
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
