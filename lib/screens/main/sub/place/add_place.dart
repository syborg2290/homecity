import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/services/place_service.dart';
import 'package:nearby/services/services_service.dart';
import 'package:nearby/utils/compress_media.dart';
import 'package:nearby/utils/flush_bars.dart';
import 'package:nearby/utils/image_cropper.dart';
import 'package:nearby/utils/maps/locationMap.dart';
import 'package:nearby/utils/media_picker/gallery_pick.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:progress_dialog/progress_dialog.dart';

class AddPlace extends StatefulWidget {
  final String type;
  AddPlace({this.type, Key key}) : super(key: key);

  @override
  _AddPlaceState createState() => _AddPlaceState();
}

class _AddPlaceState extends State<AddPlace> {
  File intialImage;
  TextEditingController _placeName = TextEditingController();
  TextEditingController _aboutThePlace = TextEditingController();
  TextEditingController _location = TextEditingController();
  TextEditingController _fee = TextEditingController();
  double latitude;
  double longitude;
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
  TextEditingController _specialHolidaysAndHoursController =
      TextEditingController();
  Services _services = Services();
  AuthServcies _authServcies = AuthServcies();
  PlaceService _placeService = PlaceService();
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
                Text("Creating place...",
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

  done() async {
    if (intialImage != null) {
      if (_placeName.text.trim() != "") {
        if (_aboutThePlace.text.trim() != null) {
          if (latitude != null) {
            pr.show();

            String initialImageUpload = await _placeService
                .uploadImagePlace(await compressImageFile(intialImage, 80));

            String placeId = await _placeService.addPlace(
              currentUserId,
              _placeName.text.trim(),
              initialImageUpload,
              _aboutThePlace.text.trim(),
              latitude,
              longitude,
              _fee.text.trim(),
              closingDays,
              _specialHolidaysAndHoursController.text.trim(),
            );
            await _services.addService(
                _placeName.text.trim(), placeId, widget.type, "Places");
            pr.hide().whenComplete(() {
              Navigator.pop(context);
            });
          } else {
            GradientSnackBar.showMessage(context, "Please pin the location");
          }
        } else {
          GradientSnackBar.showMessage(
              context, "Give a small description about the place");
        }
      } else {
        GradientSnackBar.showMessage(context, "Place name is required");
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
          widget.type,
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
                        'assets/place_background.png',
                        height: height * 0.3,
                        width: width,
                        fit: BoxFit.cover,
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
                              "* Add initial image for the place",
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
                controller: _placeName,
                decoration: InputDecoration(
                  labelText: "* Name of the place",
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
                controller: _aboutThePlace,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: "About the place",
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
            SizedBox(
              height: 20,
            ),
            Container(
              width: width * 0.89,
              child: TextField(
                controller: _fee,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Any Entrance fee per person",
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
            SizedBox(
              height: 20,
            ),
            Text(
              "Mention days of unavailable to visit",
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
              height: 10,
            ),
            Text(
              "Mention Special holidays and hours of unavailable to visit",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withOpacity(0.5),
                fontSize: 19,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: width * 0.89,
              child: TextField(
                controller: _specialHolidaysAndHoursController,
                maxLines: 3,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Special holidays and hours",
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
          ],
        ),
      ),
    );
  }
}
