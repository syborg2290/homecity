import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby/models/resturant.dart';
import 'package:nearby/models/user.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/services/resturant_service.dart';
import 'package:nearby/utils/pallete.dart';

import 'display_filltered_rest.dart';
import 'display_filtered_items.dart';

class RestFilter extends StatefulWidget {
  RestFilter({Key key}) : super(key: key);

  @override
  _RestFilterState createState() => _RestFilterState();
}

class _RestFilterState extends State<RestFilter> {
  AuthServcies _auth = AuthServcies();
  ResturantService _resturantService = ResturantService();
  TextEditingController _firstRange = TextEditingController();
  TextEditingController _secondRange = TextEditingController();
  String current = "Resturants";
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
    "Hot dishes",
    "Fast foods",
    "Meats",
    "Seafoods",
    "Vegetarian",
    "Drinks",
    "Desserts",
    "Other",
  ];

  List selectedDistrict = [];
  List selectedItemsTypes = [];
  List selectedServices = [];
  List<Resturant> allRest = [];
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
    getAllResturants();
  }

  getAllResturants() async {
    QuerySnapshot qSnap = await _resturantService.getAllResturant();
    qSnap.documents.forEach((docRest) {
      Resturant rest = Resturant.fromDocument(docRest);

      List menuItemsList = rest.menu;

      menuItemsList.forEach((element) {
        var objRated = json.decode(element);
        var itemObj = {
          "id": objRated["id"],
          "restId": rest.id,
          "district": rest.district,
          "restOwnerId": rest.ownerId,
          "docId": docRest.documentID,
          "index": menuItemsList.indexWhere(
              (element) => json.decode(element)["id"] == objRated["id"]),
          "initialImage": objRated["initialImage"],
          "item_type": objRated["item_type"],
          "item_name": objRated["item_name"],
          "price": objRated["price"],
          "portion_count": objRated["portion_count"],
          "about": objRated["about"],
          "foodTake": objRated["foodTake"],
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
        allRest.add(rest);
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
                      if (current == "Resturants") {
                        List<Resturant> filteredRest = [];
                        selectedDistrict.forEach((dis) {
                          allRest
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

                        selectedServices.forEach((ser) {
                          allRest
                              .where((fetchRest) =>
                                  fetchRest.serviceType.contains(ser) ||
                                  fetchRest.serviceType.contains("Any"))
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
                                  builder: (context) => FilteredRest(
                                        currentUserId: currentUserId,
                                        list: filteredRest,
                                      )));
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
                      current = "Resturants";
                    });
                  },
                  child: Chip(
                      backgroundColor:
                          current == "Resturants" ? Pallete.mainAppColor : null,
                      label: Text(
                        "Resturants",
                        style: TextStyle(
                          fontSize: 23,
                          color: current == "Resturants" ? Colors.white : null,
                        ),
                      )),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      current = "Food items";
                    });
                  },
                  child: Chip(
                      backgroundColor:
                          current == "Food items" ? Pallete.mainAppColor : null,
                      label: Text(
                        "Food items",
                        style: TextStyle(
                          fontSize: 23,
                          color: current == "Food items" ? Colors.white : null,
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
            Align(
              alignment: Alignment.center,
              child: Text(
                current == "Resturants" ? "Services" : "Food item types",
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
            current == "Food items"
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
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (selectedServices.contains("Dine-in")) {
                              setState(() {
                                selectedServices.remove("Dine-in");
                              });
                            } else {
                              setState(() {
                                selectedServices.add("Dine-in");
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: selectedServices.contains("Dine-in")
                                    ? Pallete.mainAppColor
                                    : null,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                border: Border.all(
                                  color: selectedServices.contains("Dine-in")
                                      ? Colors.white
                                      : Colors.black,
                                )),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset(
                                'assets/icons/dining.png',
                                width: 30,
                                height: 30,
                                color: selectedServices.contains("Dine-in")
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (selectedServices.contains("Take-away")) {
                              setState(() {
                                selectedServices.remove("Take-away");
                              });
                            } else {
                              setState(() {
                                selectedServices.add("Take-away");
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: selectedServices.contains("Take-away")
                                    ? Pallete.mainAppColor
                                    : null,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                border: Border.all(
                                  color: selectedServices.contains("Take-away")
                                      ? Colors.white
                                      : Colors.black,
                                )),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset(
                                'assets/icons/takeaway.png',
                                width: 30,
                                height: 30,
                                color: selectedServices.contains("Take-away")
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (selectedServices.contains("delivery")) {
                              setState(() {
                                selectedServices.remove("delivery");
                              });
                            } else {
                              setState(() {
                                selectedServices.add("delivery");
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: selectedServices.contains("delivery")
                                    ? Pallete.mainAppColor
                                    : null,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                border: Border.all(
                                  color: selectedServices.contains("delivery")
                                      ? Colors.white
                                      : Colors.black,
                                )),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset(
                                'assets/icons/delivery.png',
                                width: 30,
                                height: 30,
                                color: selectedServices.contains("delivery")
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (selectedServices.contains("Wifi")) {
                              setState(() {
                                selectedServices.remove("Wifi");
                              });
                            } else {
                              setState(() {
                                selectedServices.add("Wifi");
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: selectedServices.contains("Wifi")
                                    ? Pallete.mainAppColor
                                    : null,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                border: Border.all(
                                  color: selectedServices.contains("Wifi")
                                      ? Colors.white
                                      : Colors.black,
                                )),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset(
                                'assets/icons/wifi.png',
                                width: 30,
                                height: 30,
                                color: selectedServices.contains("Wifi")
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (selectedServices.contains("Parking")) {
                              setState(() {
                                selectedServices.remove("Parking");
                              });
                            } else {
                              setState(() {
                                selectedServices.add("Parking");
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: selectedServices.contains("Parking")
                                    ? Pallete.mainAppColor
                                    : null,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                border: Border.all(
                                  color: selectedServices.contains("Parking")
                                      ? Colors.white
                                      : Colors.black,
                                )),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset(
                                'assets/icons/car_park.png',
                                width: 30,
                                height: 30,
                                color: selectedServices.contains("Parking")
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (selectedServices.contains("Drinks")) {
                              setState(() {
                                selectedServices.remove("Drinks");
                              });
                            } else {
                              setState(() {
                                selectedServices.add("Drinks");
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: selectedServices.contains("Drinks")
                                    ? Pallete.mainAppColor
                                    : null,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                border: Border.all(
                                  color: selectedServices.contains("Drinks")
                                      ? Colors.white
                                      : Colors.black,
                                )),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset(
                                'assets/icons/wine.png',
                                width: 30,
                                height: 30,
                                color: selectedServices.contains("Drinks")
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (selectedServices.contains("Celebrations")) {
                              setState(() {
                                selectedServices.remove("Celebrations");
                              });
                            } else {
                              setState(() {
                                selectedServices.add("Celebrations");
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: selectedServices.contains("Celebrations")
                                    ? Pallete.mainAppColor
                                    : null,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                border: Border.all(
                                  color:
                                      selectedServices.contains("Celebrations")
                                          ? Colors.white
                                          : Colors.black,
                                )),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset(
                                'assets/icons/birthday.png',
                                width: 30,
                                height: 30,
                                color: selectedServices.contains("Celebrations")
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
            current == "Food items"
                ? SizedBox(
                    height: 20,
                  )
                : SizedBox.shrink(),
            current == "Food items"
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
            current == "Food items"
                ? SizedBox(
                    height: 10,
                  )
                : SizedBox.shrink(),
            current == "Food items"
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
