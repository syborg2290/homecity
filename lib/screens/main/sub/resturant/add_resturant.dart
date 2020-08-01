import 'dart:convert';
import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/screens/main/sub/resturant/add_menu.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/services/resturant_service.dart';
import 'package:nearby/services/services_service.dart';
import 'package:nearby/utils/compress_media.dart';
import 'package:nearby/utils/flush_bars.dart';
import 'package:nearby/utils/maps/locationMap.dart';
import 'package:nearby/utils/media_picker/gallery_pick.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:nearby/utils/image_cropper.dart';
import 'package:intl/intl.dart' as dd;
import 'package:progress_dialog/progress_dialog.dart';

class AddResturant extends StatefulWidget {
  final String type;
  AddResturant({this.type, Key key}) : super(key: key);

  @override
  _AddResturantState createState() => _AddResturantState();
}

class _AddResturantState extends State<AddResturant> {
  File intialImage;
  TextEditingController _restName = TextEditingController();
  TextEditingController _aboutTheRest = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _location = TextEditingController();
  TextEditingController _telephone1 = TextEditingController();
  TextEditingController _telephone2 = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _website = TextEditingController();
  TextEditingController _rangeOfDelivery = TextEditingController();
  TextEditingController openController = TextEditingController();
  TextEditingController closeController = TextEditingController();
  TextEditingController _specialHolidaysAndHoursController =
      TextEditingController();
  double latitude;
  double longitude;
  List foodTakeTypes = ["Any"];
  List<int> closingDays = [];
  List<String> selectedClosingDays = [];
  List<String> daysOfAWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  final format = dd.DateFormat("HH:mm");
  DateTime open;
  DateTime close;
  List menu = [];
  Services _services = Services();
  AuthServcies _authServcies = AuthServcies();
  ResturantService _resturantService = ResturantService();
  ProgressDialog pr;
  String currentUserId;

  @override
  void initState() {
    super.initState();
    _authServcies.getCurrentUser().then((fUser) {
      setState(() {
        currentUserId = fUser.uid;
      });
    });
    pr = ProgressDialog(
      context,
      type: ProgressDialogType.Download,
      textDirection: TextDirection.ltr,
      isDismissible: false,
      customBody: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
        ),
        width: 100,
        height: 100,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 10,
            ),
            child: Column(
              children: <Widget>[
                SpinKitPouringHourglass(color: Pallete.mainAppColor),
                Text("Creating resturant...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromRGBO(129, 165, 168, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        ),
      ),
      showLogs: false,
    );
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

  Widget openAndClose(double width, double height, bool isOpen,
      TextEditingController _controller) {
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
              child: DateTimeField(
                format: format,
                controller: _controller,
                onChanged: (value) {
                  if (isOpen) {
                    setState(() {
                      open = value;
                    });
                  } else {
                    setState(() {
                      close = value;
                    });
                  }
                },
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: isOpen ? 'Open At' : 'Close At',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 18,
                  ),
                ),
                onShowPicker: (context, currentValue) async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime:
                        TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                  );

                  return DateTimeField.convert(time);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  done() async {
    if (intialImage != null) {
      if (_restName.text.trim() != "") {
        if (_address.text.trim() != "") {
          if (latitude != null) {
            if (_telephone1.text != "") {
              if (foodTakeTypes.isNotEmpty) {
                if (openController.text != "" && closeController.text != "") {
                  pr.show();
                  List menuUpload = [];
                  if (menu.isNotEmpty) {
                    for (var item in menu) {
                      String downUrl = await _resturantService.uploadImageRest(
                          await compressImageFile(item["initialImage"], 80));
                      var obj = {
                        "initialImage": downUrl,
                        "item_type": item["item_type"],
                        "item_name": item["item_name"],
                        "price": item["price"],
                        "portion_count": item["portion_count"],
                        "about": item["about"],
                        "foodTake": item["foodTake"],
                        "foodTimes": item["foodTimes"],
                      };
                      menuUpload.add(json.encode(obj));
                    }
                  }

                  String initialImageUpload =
                      await _resturantService.uploadImageRest(
                          await compressImageFile(intialImage, 80));

                  String restId = await _resturantService.addResturant(
                    currentUserId,
                    _restName.text.trim(),
                    _aboutTheRest.text.trim(),
                    initialImageUpload,
                    _address.text.trim(),
                    latitude,
                    longitude,
                    _email.text.trim(),
                    _website.text.trim(),
                    closingDays,
                    close,
                    open,
                    _telephone1.text.trim(),
                    _telephone2.text.trim(),
                    foodTakeTypes,
                    _specialHolidaysAndHoursController.text.trim(),
                    menuUpload,
                  );
                  await _services.addService(
                      _restName.text.trim(), restId, widget.type, widget.type);
                  pr.hide().whenComplete(() {
                    Navigator.pop(context);
                  });
                } else {
                  GradientSnackBar.showMessage(
                      context, "Open and close time is required");
                }
              } else {
                GradientSnackBar.showMessage(
                    context, "Resturant type of service is required");
              }
            } else {
              GradientSnackBar.showMessage(
                  context, "Resturant telephone number is required");
            }
          } else {
            GradientSnackBar.showMessage(context, "Please pin the location");
          }
        } else {
          GradientSnackBar.showMessage(
              context, "Resturant address is required");
        }
      } else {
        GradientSnackBar.showMessage(context, "Resturant name is required");
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
          'Add new resturant',
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
                await done();
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
                              "* Add initial image for your resturant",
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
                controller: _restName,
                decoration: InputDecoration(
                  labelText: "* Name of the resturant",
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
                controller: _aboutTheRest,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "About the resturant",
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
            Divider(),
            SizedBox(
              height: 20,
            ),
            Container(
              width: width * 0.89,
              child: TextField(
                controller: _address,
                decoration: InputDecoration(
                  labelText: "* Address of the resturant",
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
                readOnly: true,
                onTap: () async {
                  List<double> locationCo = [];
                  locationCo.add(latitude);
                  locationCo.add(longitude);
                  List<double> locationCoord = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LocationMap(
                                isFromFeed: false,
                                locationCoord:
                                    latitude == null ? null : locationCo,
                              )));
                  if (locationCoord != null) {
                    setState(() {
                      latitude = locationCoord[0];
                      longitude = locationCoord[1];
                      _location.text = "Location pinned";
                    });
                  }
                },
                controller: _location,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "* location",
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
            Divider(),
            SizedBox(
              height: 20,
            ),
            Container(
              width: width * 0.89,
              child: TextField(
                controller: _telephone1,
                autofocus: false,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "* Telephone 1",
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
                autofocus: false,
                controller: _telephone2,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Telephone 2",
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
                controller: _email,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Email address",
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
                controller: _website,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefix: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(
                      "www.",
                      style:
                          TextStyle(fontSize: 18, color: Colors.grey.shade500),
                    ),
                  ),
                  labelText: "Website",
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
            Divider(),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "* Type of services your resturant able to provide",
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
            foodTakeTypes.contains("Delivery")
                ? Container(
                    width: width * 0.8,
                    child: TextField(
                      autofocus: false,
                      controller: _rangeOfDelivery,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Range of delivery(KM)",
                        suffix: Text(
                          "KM",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        labelStyle: TextStyle(
                            fontSize: 18, color: Colors.grey.shade500),
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
                  )
                : SizedBox.shrink(),
            SizedBox(
              height: 20,
            ),
            Divider(),
            Text(
              "* Mention days of closing your resturant",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withOpacity(0.5),
                fontSize: 19,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
                height: height * 0.1,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: daysOfAWeek.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            if (daysOfAWeek[index] == "Monday") {
                              if (selectedClosingDays.contains("Monday")) {
                                setState(() {
                                  closingDays.remove(1);
                                  selectedClosingDays.remove("Monday");
                                });
                              } else {
                                setState(() {
                                  closingDays.add(1);
                                  selectedClosingDays.add("Monday");
                                });
                              }
                            }
                            if (daysOfAWeek[index] == "Tuesday") {
                              if (selectedClosingDays.contains("Tuesday")) {
                                setState(() {
                                  closingDays.remove(2);
                                  selectedClosingDays.remove("Tuesday");
                                });
                              } else {
                                setState(() {
                                  closingDays.add(2);
                                  selectedClosingDays.add("Tuesday");
                                });
                              }
                            }
                            if (daysOfAWeek[index] == "Wednesday") {
                              if (selectedClosingDays.contains("Wednesday")) {
                                setState(() {
                                  closingDays.remove(3);
                                  selectedClosingDays.remove("Wednesday");
                                });
                              } else {
                                setState(() {
                                  closingDays.add(3);
                                  selectedClosingDays.add("Wednesday");
                                });
                              }
                            }
                            if (daysOfAWeek[index] == "Thursday") {
                              if (selectedClosingDays.contains("Thursday")) {
                                setState(() {
                                  closingDays.remove(4);
                                  selectedClosingDays.remove("Thursday");
                                });
                              } else {
                                setState(() {
                                  closingDays.add(4);
                                  selectedClosingDays.add("Thursday");
                                });
                              }
                            }
                            if (daysOfAWeek[index] == "Friday") {
                              if (selectedClosingDays.contains("Friday")) {
                                setState(() {
                                  closingDays.remove(5);
                                  selectedClosingDays.remove("Friday");
                                });
                              } else {
                                setState(() {
                                  closingDays.add(5);
                                  selectedClosingDays.add("Friday");
                                });
                              }
                            }
                            if (daysOfAWeek[index] == "Saturday") {
                              if (selectedClosingDays.contains("Saturday")) {
                                setState(() {
                                  closingDays.remove(6);
                                  selectedClosingDays.remove("Saturday");
                                });
                              } else {
                                setState(() {
                                  closingDays.add(6);
                                  selectedClosingDays.add("Saturday");
                                });
                              }
                            }
                            if (daysOfAWeek[index] == "Sunday") {
                              if (selectedClosingDays.contains("Sunday")) {
                                setState(() {
                                  closingDays.remove(7);
                                  selectedClosingDays.remove("Sunday");
                                });
                              } else {
                                setState(() {
                                  closingDays.add(7);
                                  selectedClosingDays.add("Sunday");
                                });
                              }
                            }
                          },
                          child: Container(
                            width: width * 0.3,
                            height: height * 0.1,
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              color: selectedClosingDays
                                      .contains(daysOfAWeek[index])
                                  ? Colors.red
                                  : Colors.white,
                              child: Center(
                                child: Text(daysOfAWeek[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: selectedClosingDays
                                              .contains(daysOfAWeek[index])
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 17,
                                    )),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 5,
                              margin: EdgeInsets.all(10),
                            ),
                          ),
                        );
                      }),
                )),
            SizedBox(
              height: 20,
            ),
            Text(
              "* Open and close time of the resturant",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withOpacity(0.5),
                fontSize: 19,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                openAndClose(width, height, true, openController),
                openAndClose(width, height, false, closeController),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: width * 0.89,
              child: TextField(
                controller: _specialHolidaysAndHoursController,
                maxLines: 3,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Special holidays and hours of closing",
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
            Divider(),
            GestureDetector(
              onTap: () async {
                List menuCard = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddMenu(
                              menu: menu,
                            )));
                if (menuCard != null) {
                  setState(() {
                    menu = menuCard;
                  });
                }
              },
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey.shade500,
                      )),
                  width: width * 0.89,
                  height: height * 0.09,
                  child: Center(
                      child: Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.2,
                    ),
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          'assets/icons/foodmenu.png',
                          width: 30,
                          height: 30,
                          color: Colors.grey.shade800,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Add menu card",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey.shade500)),
                        ),
                      ],
                    ),
                  ))),
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
