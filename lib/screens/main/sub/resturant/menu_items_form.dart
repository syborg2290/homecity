import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby/utils/flush_bars.dart';
import 'package:nearby/utils/image_cropper.dart';
import 'package:nearby/utils/media_picker/gallery_pick.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:photo_manager/photo_manager.dart';

class MenuItemForm extends StatefulWidget {
  final String itemType;
  final obj;

  MenuItemForm({this.obj, this.itemType, Key key}) : super(key: key);

  @override
  _MenuItemFormState createState() => _MenuItemFormState();
}

class _MenuItemFormState extends State<MenuItemForm> {
  File intialImage;
  TextEditingController _itemName = TextEditingController();
  TextEditingController _aboutTheItem = TextEditingController();
  TextEditingController _price = TextEditingController();
  TextEditingController _personCount = TextEditingController();
  List foodTakeTypes = ["Any"];
  List foodTakeTimes = ["Any Time"];
  bool isForEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.obj != null) {
      setState(() {
        isForEdit = true;
        intialImage = widget.obj["initialImage"];
        _itemName.text = widget.obj["item_name"];
        _aboutTheItem.text = widget.obj["about"];
        _price.text = widget.obj["price"];
        _personCount.text = widget.obj["portion_count"];
        foodTakeTypes = widget.obj["foodTake"];
        foodTakeTimes = widget.obj["foodTimes"];
      });
    }
  }

  Widget foodTake(String type, String imagePath, bool isContain) {
    return Container(
      width: 120,
      height: 110,
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
          color: isContain ? Pallete.mainAppColor : Colors.white,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      imagePath,
                      width: 40,
                      height: 40,
                      color: foodTakeTypes.contains(type)
                          ? Colors.white
                          : Colors.black,
                    ),
                    Text(
                      type,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: foodTakeTypes.contains(type)
                            ? Colors.white
                            : Colors.black,
                        fontSize: 13,
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
    );
  }

  Widget foodTime(String type, bool isContain) {
    return Container(
      width: 140,
      height: 70,
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
          color: isContain ? Pallete.mainAppColor : Colors.white,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Center(
              child: Text(
                type,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: foodTakeTimes.contains(type)
                      ? Colors.white
                      : Colors.black,
                  fontSize: 19,
                ),
              ),
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 5,
        margin: EdgeInsets.all(10),
      ),
    );
  }

  done() {
    if (intialImage != null) {
      if (_itemName.text.trim() != "") {
        if (_price.text.trim() != "") {
          if (_personCount.text.trim() != "") {
            if (foodTakeTypes.isNotEmpty) {
              if (foodTakeTimes.isNotEmpty) {
                var obj = {
                  "initialImage": intialImage,
                  "item_type": widget.itemType,
                  "item_name": _itemName.text.trim(),
                  "price": _price.text.trim(),
                  "portion_count": _personCount.text.trim(),
                  "about": _aboutTheItem.text.trim(),
                  "foodTake": foodTakeTypes,
                  "foodTimes": foodTakeTimes,
                };
                Navigator.pop(context, obj);
              } else {
                GradientSnackBar.showMessage(
                    context, "Time that able to get food item is required");
              }
            } else {
              GradientSnackBar.showMessage(context, "Serve types is required");
            }
          } else {
            GradientSnackBar.showMessage(context, "Person count is required");
          }
        } else {
          GradientSnackBar.showMessage(context, "price is required");
        }
      } else {
        GradientSnackBar.showMessage(context, "Initial name is required");
      }
    } else {
      GradientSnackBar.showMessage(context, "Initial image is required");
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
          widget.itemType,
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
                done();
              },
              child: Center(
                  child: Text(isForEdit ? "Edit" : "Add",
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
            intialImage == null
                ? Stack(
                    children: <Widget>[
                      Image.asset(
                        'assets/resturant_back.png',
                        height: height * 0.3,
                        width: width,
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        width: width,
                        height: height * 0.3,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: height * 0.06),
                        child: Column(
                          children: <Widget>[
                            Center(
                                child: Text(
                              "* Add initial image for food item",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () async {
                                var obj = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GalleryPick(
                                              isOnlyImage: true,
                                              isSingle: true,
                                            )));
                                if (obj != null) {
                                  if (obj["type"] == "gallery") {
                                    AssetEntity assetentity =
                                        obj["mediaList"][0];

                                    assetentity.file.then((value) {
                                      setState(() {
                                        intialImage = value;
                                      });
                                    });
                                  } else {
                                    setState(() {
                                      intialImage = File(obj["mediaFile"].path);
                                    });
                                  }
                                }
                              },
                              child: Image.asset(
                                'assets/icons/plus.png',
                                width: width * 0.2,
                                height: height * 0.1,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  )
                : Stack(
                    children: <Widget>[
                      Image.file(
                        intialImage,
                        height: height * 0.3,
                        width: width,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        width: width,
                        height: height * 0.3,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: height * 0.08),
                        child: Center(
                          child: GestureDetector(
                            onTap: () async {
                              var obj = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GalleryPick(
                                            isOnlyImage: true,
                                            isSingle: true,
                                          )));
                              if (obj != null) {
                                if (obj["type"] == "gallery") {
                                  AssetEntity assetentity = obj["mediaList"][0];

                                  assetentity.file.then((value) {
                                    setState(() {
                                      intialImage = value;
                                    });
                                  });
                                } else {
                                  setState(() {
                                    intialImage = obj["mediaFile"];
                                  });
                                }
                              }
                            },
                            child: Image.asset(
                              'assets/icons/plus.png',
                              width: width * 0.2,
                              height: height * 0.1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () async {
                            File croopedImage = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ImageCropper(
                                          image: intialImage,
                                        )));
                            if (croopedImage != null) {
                              setState(() {
                                intialImage = croopedImage;
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(
                                  width * 0.03,
                                )),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                'assets/icons/crop.png',
                                width: width * 0.05,
                                height: height * 0.05,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: width * 0.89,
              child: TextField(
                controller: _itemName,
                decoration: InputDecoration(
                  labelText: "* Name of the food item",
                  labelStyle:
                      TextStyle(fontSize: 18, color: Colors.grey.shade500),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Pallete.mainAppColor,
                      )),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: width * 0.89,
              child: TextField(
                controller: _price,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "* Price per portion(LKR)",
                  labelStyle:
                      TextStyle(fontSize: 18, color: Colors.grey.shade500),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  suffix: Text(
                    "LKR",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Pallete.mainAppColor,
                      )),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: width * 0.89,
              child: TextField(
                controller: _personCount,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "* Portion enough(Person count)",
                  labelStyle:
                      TextStyle(fontSize: 18, color: Colors.grey.shade500),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  suffix: Text(
                    "Person",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Pallete.mainAppColor,
                      )),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: width * 0.89,
              child: TextField(
                controller: _aboutTheItem,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "About the food item",
                  labelStyle:
                      TextStyle(fontSize: 18, color: Colors.grey.shade500),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Pallete.mainAppColor,
                      )),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "* How to serve this food item",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.5),
                  fontSize: 19,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        foodTakeTypes.clear();
                        foodTakeTypes.add("Any");
                      });
                    },
                    child: foodTake("Any", 'assets/icons/anyFoodType.png',
                        foodTakeTypes.contains("Any")),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (foodTakeTypes.contains("Any")) {
                        setState(() {
                          foodTakeTypes.clear();
                          foodTakeTypes.add("Dine-in");
                        });
                      } else {
                        if (foodTakeTypes.contains("Dine-in")) {
                          setState(() {
                            foodTakeTypes.remove("Dine-in");
                          });
                        } else {
                          setState(() {
                            foodTakeTypes.add("Dine-in");
                          });
                        }
                      }
                    },
                    child: foodTake("Dine-in", 'assets/icons/dining.png',
                        foodTakeTypes.contains("Dine-in")),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (foodTakeTypes.contains("Any")) {
                        setState(() {
                          foodTakeTypes.clear();
                          foodTakeTypes.add("Take-away");
                        });
                      } else {
                        if (foodTakeTypes.contains("Take-away")) {
                          setState(() {
                            foodTakeTypes.remove("Take-away");
                          });
                        } else {
                          setState(() {
                            foodTakeTypes.add("Take-away");
                          });
                        }
                      }
                    },
                    child: foodTake("Take-away", 'assets/icons/takeaway.png',
                        foodTakeTypes.contains("Take-away")),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (foodTakeTypes.contains("Any")) {
                        setState(() {
                          foodTakeTypes.clear();
                          foodTakeTypes.add("Delivery");
                        });
                      } else {
                        if (foodTakeTypes.contains("Delivery")) {
                          setState(() {
                            foodTakeTypes.remove("Delivery");
                          });
                        } else {
                          setState(() {
                            foodTakeTypes.add("Delivery");
                          });
                        }
                      }
                    },
                    child: foodTake("Delivery", 'assets/icons/delivery.png',
                        foodTakeTypes.contains("Delivery")),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "* What times able to get this item",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.5),
                  fontSize: 19,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        foodTakeTimes.clear();
                        foodTakeTimes.add("Any Time");
                      });
                    },
                    child: foodTime(
                        "Any Time", foodTakeTimes.contains("Any Time")),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (foodTakeTimes.contains("Any Time")) {
                        setState(() {
                          foodTakeTimes.clear();
                          foodTakeTimes.add("Breakfast");
                        });
                      } else {
                        if (foodTakeTimes.contains("Breakfast")) {
                          setState(() {
                            foodTakeTimes.remove("Breakfast");
                          });
                        } else {
                          setState(() {
                            foodTakeTimes.add("Breakfast");
                          });
                        }
                      }
                    },
                    child: foodTime(
                        "Breakfast", foodTakeTimes.contains("Breakfast")),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (foodTakeTimes.contains("Any Time")) {
                        setState(() {
                          foodTakeTimes.clear();
                          foodTakeTimes.add("Lunch");
                        });
                      } else {
                        if (foodTakeTimes.contains("Lunch")) {
                          setState(() {
                            foodTakeTimes.remove("Lunch");
                          });
                        } else {
                          setState(() {
                            foodTakeTimes.add("Lunch");
                          });
                        }
                      }
                    },
                    child: foodTime("Lunch", foodTakeTimes.contains("Lunch")),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (foodTakeTimes.contains("Any Time")) {
                        setState(() {
                          foodTakeTimes.clear();
                          foodTakeTimes.add("Dinner");
                        });
                      } else {
                        if (foodTakeTimes.contains("Dinner")) {
                          setState(() {
                            foodTakeTimes.remove("Dinner");
                          });
                        } else {
                          setState(() {
                            foodTakeTimes.add("Dinner");
                          });
                        }
                      }
                    },
                    child: foodTime("Dinner", foodTakeTimes.contains("Dinner")),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
