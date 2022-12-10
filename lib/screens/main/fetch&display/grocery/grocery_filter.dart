import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby/models/grocery.dart';
import 'package:nearby/models/user.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/services/grocery_service.dart';
import 'package:nearby/utils/flush_bars.dart';
import 'package:nearby/utils/pallete.dart';

import 'filtered_groc.dart';
import 'grocery_items_filter.dart';

class GroceryFilter extends StatefulWidget {
  GroceryFilter({Key key}) : super(key: key);

  @override
  _GroceryFilterState createState() => _GroceryFilterState();
}

class _GroceryFilterState extends State<GroceryFilter> {
  AuthServcies _auth = AuthServcies();
  GroceryService _grocService = GroceryService();
  TextEditingController _firstRange = TextEditingController();
  TextEditingController _secondRange = TextEditingController();
  String current = "Groceries";
  List<String> _districtsList = [
    "Ampara",
    "Anuradhapura",
    "Badulla",
    "Batticaloa",
    "Colombo",
    "Galle",
    "Gampaha",
    "Hambantota",
    "Jaffna",
    "Kalutara",
    "Kandy",
    "Kegalle",
    "Kilinochchi",
    "Kurunegala",
    "Mannar",
    "Matale",
    "Matara",
    "Moneragala",
    "Mullaitivu",
    "Nuwara Eliya",
    "Polonnaruwa",
    "Puttalam",
    "Ratnapura",
    "Trincomalee",
    "Vavuniya"
  ];

  List<String> itemTypes = [
    "Beverages",
    "Bread/Bakery",
    "Canned/Jarred Goods",
    "Dairy",
    "Dry/Baking Goods",
    "Frozen Foods",
    "Meat",
    "Produce",
    "Cleaners",
    "Paper Goods",
    "Personal Care",
    "Healthcare",
    "Other"
  ];

  List selectedDistrict = [];
  List selectedItemsTypes = [];
  List selectedServices = [];
  List<Grocery> allGroc = [];
  List allMenuItems = [];
  String currentUserId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _auth.getCurrentUser().then((fUser) {
      setState(() {
        currentUserId = fUser.uid;
      });
      _auth.getUserObj(fUser.uid).then((value) {
        User user = User.fromDocument(value);

        setState(() {
          selectedDistrict.add(user.district);
        });
      });
    });
    getAllGroc();
  }

  getAllGroc() async {
    QuerySnapshot qSnap = await _grocService.getAllGrocery();
    qSnap.documents.forEach((docRest) {
      Grocery groc = Grocery.fromDocument(docRest);

      List menuItemsList = groc.items;

      menuItemsList.forEach((element) {
        var objRated = json.decode(element);

        var itemObj = {
          "id": objRated["id"],
          "grocId": groc.id,
          "district": groc.district,
          "grocOwnerId": groc.ownerId,
          "docId": docRest.documentID,
          "index": menuItemsList.indexWhere(
              (element) => json.decode(element)["id"] == objRated["id"]),
          "initialImage": objRated["initialImage"],
          "item_type": objRated["item_type"],
          "item_name": objRated["item_name"],
          "status": objRated["status"],
          "price": objRated["price"],
          "about": objRated["about"],
          "brand": objRated["brand"],
          "gallery": objRated["gallery"],
          "total_ratings": objRated["total_ratings"],
          "ratings": objRated["ratings"],
          "review": objRated["review"],
        };
        setState(() {
          allMenuItems.add(itemObj);
        });
      });
      setState(() {
        allGroc.add(groc);
        isLoading = false;
      });
    });
  }

  Widget priceRange(
      double width, double height, TextEditingController _controller) {
    return Padding(
      padding: EdgeInsets.only(
        top: height * 0.01,
      ),
      child: Center(
        child: Container(
          width: width * 0.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey.shade500,
              width: 1,
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: height * 0.01,
              bottom: height * 0.01,
              // right: width * 0.4,
            ),
            child: Center(
              child: TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Price(LKR)',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          "Filters",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 20,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(
            12,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset(
              'assets/icons/close.png',
              width: 30,
              height: 30,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (current == "Groceries") {
                        List<Grocery> filteredRest = [];
                        selectedDistrict.forEach((dis) {
                          allGroc
                              .where((fetchRest) => fetchRest.district == dis)
                              .toList()
                              .forEach((fRERest) {
                            if (filteredRest.firstWhere(
                                    (testRest) => testRest.id == fRERest.id,
                                    orElse: () => null) ==
                                null) {
                              filteredRest.add(fRERest);
                            }
                          });
                        });

                        if (filteredRest.isNotEmpty) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FilteredGroc(
                                        currentUserId: currentUserId,
                                        list: filteredRest,
                                      )));
                        } else {
                          GradientSnackBar.showMessage(context,
                              "Not available any results on this filter");
                        }
                      } else {
                        List filteredItems = [];
                        selectedDistrict.forEach((dis) {
                          allMenuItems
                              .where(
                                  (fetchItem) => fetchItem["district"] == dis)
                              .toList()
                              .forEach((fRERest) {
                            if (filteredItems.firstWhere(
                                    (testRest) =>
                                        testRest["id"] == fRERest["id"],
                                    orElse: () => null) ==
                                null) {
                              filteredItems.add(fRERest);
                            }
                          });
                        });

                        selectedItemsTypes.forEach((dis) {
                          allMenuItems
                              .where(
                                  (fetchItem) => fetchItem["item_type"] == dis)
                              .toList()
                              .forEach((fRERest) {
                            if (filteredItems.firstWhere(
                                    (testRest) =>
                                        testRest["id"] == fRERest["id"],
                                    orElse: () => null) ==
                                null) {
                              filteredItems.add(fRERest);
                            }
                          });
                        });
                        allMenuItems
                            .where((fetchItem) =>
                                int.parse(fetchItem["price"]) >=
                                    int.parse(_firstRange.text.trim() == ""
                                        ? 0.toString()
                                        : _firstRange.text.trim()) &&
                                int.parse(fetchItem["price"]) <=
                                    int.parse(_secondRange.text.trim() == ""
                                        ? 0.toString()
                                        : _secondRange.text.trim()))
                            .toList()
                            .forEach((fRERest) {
                          if (filteredItems.firstWhere(
                                  (testRest) => testRest["id"] == fRERest["id"],
                                  orElse: () => null) ==
                              null) {
                            filteredItems.add(fRERest);
                          }
                        });
                        if (filteredItems.isNotEmpty) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FilteredItems(
                                        currentUserId: currentUserId,
                                        list: filteredItems,
                                      )));
                        } else {
                          GradientSnackBar.showMessage(context,
                              "Not available any results on this filter");
                        }
                      }
                    },
              child: Center(
                  child: Text("Apply filter",
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
          children: [
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Main filter",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey[900],
                    fontFamily: "Roboto",
                    fontSize: 25,
                    fontWeight: FontWeight.w800),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      current = "Groceries";
                    });
                  },
                  child: Chip(
                      backgroundColor:
                          current == "Groceries" ? Pallete.mainAppColor : null,
                      label: Text(
                        "Groceries",
                        style: TextStyle(
                          fontSize: 23,
                          color: current == "Groceries" ? Colors.white : null,
                        ),
                      )),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      current = "Items";
                    });
                  },
                  child: Chip(
                      backgroundColor:
                          current == "Items" ? Pallete.mainAppColor : null,
                      label: Text(
                        "Items",
                        style: TextStyle(
                          fontSize: 23,
                          color: current == "Items" ? Colors.white : null,
                        ),
                      )),
                )
              ],
            ),
            SizedBox(
              height: 25,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Select districts",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey[900],
                    fontFamily: "Roboto",
                    fontSize: 25,
                    fontWeight: FontWeight.w800),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: _districtsList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 16 / 5,
                ),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                      onTap: () {
                        if (selectedDistrict.contains(_districtsList[index])) {
                          setState(() {
                            selectedDistrict.remove(_districtsList[index]);
                          });
                        } else {
                          setState(() {
                            selectedDistrict.add(_districtsList[index]);
                          });
                        }
                      },
                      child: Chip(
                          backgroundColor:
                              selectedDistrict.contains(_districtsList[index])
                                  ? Pallete.mainAppColor
                                  : null,
                          label: Text(
                            _districtsList[index],
                            style: TextStyle(
                              color: selectedDistrict
                                      .contains(_districtsList[index])
                                  ? Colors.white
                                  : null,
                            ),
                          )));
                }),
            SizedBox(
              height: 20,
            ),
            current == "Items"
                ? Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Item types",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey[900],
                          fontFamily: "Roboto",
                          fontSize: 25,
                          fontWeight: FontWeight.w800),
                    ),
                  )
                : SizedBox.shrink(),
            SizedBox(
              height: 10,
            ),
            current == "Items"
                ? GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: itemTypes.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      childAspectRatio: 16 / 5,
                    ),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                          onTap: () {
                            if (selectedItemsTypes.contains(itemTypes[index])) {
                              setState(() {
                                selectedItemsTypes.remove(itemTypes[index]);
                              });
                            } else {
                              setState(() {
                                selectedItemsTypes.add(itemTypes[index]);
                              });
                            }
                          },
                          child: Chip(
                              backgroundColor:
                                  selectedItemsTypes.contains(itemTypes[index])
                                      ? Pallete.mainAppColor
                                      : null,
                              label: Text(
                                itemTypes[index],
                                style: TextStyle(
                                  color: selectedItemsTypes
                                          .contains(itemTypes[index])
                                      ? Colors.white
                                      : null,
                                ),
                              )));
                    })
                : SizedBox.shrink(),
            current == "Items"
                ? SizedBox(
                    height: 20,
                  )
                : SizedBox.shrink(),
            current == "Items"
                ? Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Price range(LKR)",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey[900],
                          fontFamily: "Roboto",
                          fontSize: 25,
                          fontWeight: FontWeight.w800),
                    ),
                  )
                : SizedBox.shrink(),
            current == "Items"
                ? SizedBox(
                    height: 10,
                  )
                : SizedBox.shrink(),
            current == "Items"
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      priceRange(width, height, _firstRange),
                      priceRange(width, height, _secondRange),
                    ],
                  )
                : SizedBox.shrink(),
            SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}
