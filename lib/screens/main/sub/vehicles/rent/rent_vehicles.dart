import 'dart:convert';
import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/screens/main/sub/vehicles/rent/renting_types.dart';
import 'package:nearby/screens/main/sub/vehicles/vehi_gallery.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/services/services_service.dart';
import 'package:nearby/services/vehi_service.dart';
import 'package:nearby/utils/compress_media.dart';
import 'package:nearby/utils/flush_bars.dart';
import 'package:nearby/utils/image_cropper.dart';
import 'package:nearby/utils/maps/locationMap.dart';
import 'package:nearby/utils/media_picker/gallery_pick.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:intl/intl.dart' as dd;

class RentVehicles extends StatefulWidget {
  final String type;
  RentVehicles({this.type, Key key}) : super(key: key);

  @override
  _RentVehiclesState createState() => _RentVehiclesState();
}

class _RentVehiclesState extends State<RentVehicles> {
  File intialImage;
  TextEditingController _serviceName = TextEditingController();
  TextEditingController _details = TextEditingController();
  TextEditingController _location = TextEditingController();
  TextEditingController _banner = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _website = TextEditingController();
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
  VehiService _vehiService = VehiService();
  AuthServcies _authServcies = AuthServcies();
  ProgressDialog pr;
  String currentUserId;
  String selectedDistrict = "Colombo";
  var _districtsList = [
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
  List gallery = [];
  final format = dd.DateFormat("HH:mm");
  DateTime open;
  DateTime close;
  TextEditingController _telephone1 = TextEditingController();
  TextEditingController _telephone2 = TextEditingController();
  TextEditingController openController = TextEditingController();
  TextEditingController closeController = TextEditingController();
  List rentVehicles = [];

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
                Text("Creating rent vehicles...",
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
      if (_serviceName.text.trim() != "") {
        if (_banner.text.trim() != "") {
          if (selectedDistrict != null) {
            if (_address.text.trim() != "") {
              if (latitude != null) {
                if (_telephone1.text != "") {
                  if (openController.text != "" && closeController.text != "") {
                    pr.show();

                    List vehiclesForRent = [];

                    if (rentVehicles.isNotEmpty) {
                      for (var item in rentVehicles) {
                        String downUrl = await _vehiService.uploadImageVehiSe(
                            await compressImageFile(item["initialImage"], 80));

                        List uploadGalleryRent = [];
                        if (item["gallery"].isNotEmpty) {
                          for (var ele in item["gallery"]) {
                            if (ele["type"] == "image") {
                              String downUrl = await _vehiService
                                  .uploadImageVehiSe(await compressImageFile(
                                      ele["media"], 80));
                              String thumbUrl =
                                  await _vehiService.uploadImageVehiSeThumbnail(
                                      await compressImageFile(
                                          ele["media"], 40));
                              var obj = {
                                "url": downUrl,
                                "thumb": thumbUrl,
                                "type": "image",
                              };
                              uploadGalleryRent.add(json.encode(obj));
                            } else {
                              String downUrl =
                                  await _vehiService.uploadVideoToVehiSe(
                                      await compressVideoFile(ele["media"]));
                              String thumbUrl =
                                  await _vehiService.uploadVideoToVehiSeThumb(
                                      await getThumbnailForVideo(ele["media"]));
                              var obj = {
                                "url": downUrl,
                                "thumb": thumbUrl,
                                "type": "video",
                              };
                              uploadGalleryRent.add(json.encode(obj));
                            }
                          }
                        }

                        var obj = {
                          "initialImage": downUrl,
                          "item_type": item["item_type"],
                          "vehi_name": item["vehi_name"],
                          "price": item["price"],
                          "details": item["details"],
                          "brand": item["brand"],
                          "model": item["model"],
                          "gallery": uploadGalleryRent,
                        };
                        vehiclesForRent.add(json.encode(obj));
                      }
                    }

                    List uploadGallery = [];
                    if (gallery.isNotEmpty) {
                      for (var ele in gallery) {
                        if (ele["type"] == "image") {
                          String downUrl = await _vehiService.uploadImageVehiSe(
                              await compressImageFile(ele["media"], 80));
                          String thumbUrl =
                              await _vehiService.uploadImageVehiSeThumbnail(
                                  await compressImageFile(ele["media"], 40));
                          var obj = {
                            "url": downUrl,
                            "thumb": thumbUrl,
                            "type": "image",
                          };
                          uploadGallery.add(json.encode(obj));
                        } else {
                          String downUrl =
                              await _vehiService.uploadVideoToVehiSe(
                                  await compressVideoFile(ele["media"]));
                          String thumbUrl =
                              await _vehiService.uploadVideoToVehiSeThumb(
                                  await getThumbnailForVideo(ele["media"]));
                          var obj = {
                            "url": downUrl,
                            "thumb": thumbUrl,
                            "type": "video",
                          };
                          uploadGallery.add(json.encode(obj));
                        }
                      }
                    }

                    String initialImageUpload =
                        await _vehiService.uploadImageVehiSe(
                            await compressImageFile(intialImage, 80));

                    String vehiSeId = await _vehiService.addVehiSe(
                      currentUserId,
                      _serviceName.text.trim(),
                      _details.text.trim(),
                      initialImageUpload,
                      _address.text.trim(),
                      latitude,
                      longitude,
                      _email.text.trim(),
                      selectedDistrict,
                      _website.text.trim(),
                      closingDays,
                      close,
                      open,
                      _telephone1.text.trim(),
                      _telephone2.text.trim(),
                      _specialHolidaysAndHoursController.text.trim(),
                      vehiclesForRent,
                      uploadGallery,
                      null,
                      widget.type,
                      null,
                      null,
                      null,
                      null,
                      null,
                      null,
                      null,
                      null,
                      null,
                    );
                    await _services.addService(_serviceName.text.trim(),
                        vehiSeId, widget.type, "Vehicle services");
                    await _vehiService.addMainBanner(
                      _serviceName.text.trim(),
                      initialImageUpload,
                      vehiSeId,
                      _banner.text.trim(),
                      _address.text.trim(),
                      null,
                      widget.type,
                      null,
                    );
                    pr.hide().whenComplete(() {
                      Navigator.pop(context);
                    });
                  } else {
                    GradientSnackBar.showMessage(
                        context, "Open and close time is required");
                  }
                } else {
                  GradientSnackBar.showMessage(
                      context, "Repair center telephone number is required");
                }
              } else {
                GradientSnackBar.showMessage(
                    context, "Please pin the location");
              }
            } else {
              GradientSnackBar.showMessage(
                  context, "Repair center address is required");
            }
          } else {
            GradientSnackBar.showMessage(context, "Please select a district");
          }
        } else {
          GradientSnackBar.showMessage(context, "Banner title is required");
        }
      } else {
        GradientSnackBar.showMessage(context, "Repair center name is required");
      }
    } else {
      GradientSnackBar.showMessage(context, "Initial image is required");
    }
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

  Widget textBoxContainer(TextEditingController _contro, String hint, int lines,
      double width, bool autoFocus, TextInputType typeText) {
    return Container(
      width: width * 0.89,
      child: TextField(
        controller: _contro,
        maxLines: lines,
        autofocus: autoFocus,
        keyboardType: typeText,
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: TextStyle(fontSize: 18, color: Colors.grey.shade500),
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
    );
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
                        'assets/vehi_back.png',
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
                              "* Add initial image for the vehicles renting center",
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
            textBoxContainer(_serviceName, "* Name of the renting center", 1,
                width, false, TextInputType.text),
            SizedBox(
              height: 20,
            ),
            textBoxContainer(_banner, "* Provide a title for the banner", 1,
                width, false, TextInputType.text),
            SizedBox(
              height: 20,
            ),
            textBoxContainer(
                _details, "Details", 8, width, false, TextInputType.text),
            SizedBox(
              height: 20,
            ),
            textBoxContainer(
                _address, "* Address", 1, width, false, TextInputType.text),
            SizedBox(
              height: 20,
            ),
            Container(
              width: width * 0.89,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: "District",
                      hintText: 'District',
                      labelStyle:
                          TextStyle(fontSize: 18, color: Colors.grey.shade500),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                        borderSide: BorderSide(
                          color: Colors.grey.shade500,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                          borderSide: BorderSide(
                            color: Pallete.mainAppColor,
                          )),
                    ),
                    isEmpty: selectedDistrict == '',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedDistrict,
                        isDense: true,
                        onChanged: (String newValue) {
                          setState(() {
                            selectedDistrict = newValue;
                            state.didChange(newValue);
                          });
                        },
                        items: _districtsList.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
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
            textBoxContainer(_telephone1, "* Telephone 1", 1, width, false,
                TextInputType.phone),
            SizedBox(
              height: 20,
            ),
            textBoxContainer(_telephone2, "Telephone 2", 1, width, false,
                TextInputType.phone),
            SizedBox(
              height: 20,
            ),
            textBoxContainer(
                _email, "Email address", 1, width, false, TextInputType.text),
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
            SizedBox(
              height: 20,
            ),
            Text(
              "Mention days of closing",
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
              "* Open and close time of your shop",
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
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Mention Special holidays and hours of closing",
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
            textBoxContainer(
                _specialHolidaysAndHoursController,
                "Special holidays and hours",
                3,
                width,
                false,
                TextInputType.text),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async {
                List reVehicle = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RentTypes(
                              vehicles: rentVehicles,
                            )));
                if (reVehicle != null) {
                  setState(() {
                    rentVehicles = reVehicle;
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
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/icons/rent_car.png',
                          width: 30,
                          height: 30,
                          color: Colors.grey.shade800,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Add renting vehicles",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey.shade800)),
                        ),
                      ],
                    ),
                  ))),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async {
                List reGallery = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VehiGallery(
                              gallery: gallery,
                            )));
                if (reGallery != null) {
                  setState(() {
                    gallery = reGallery;
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
                      left: width * 0.3,
                    ),
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          'assets/icons/album.png',
                          width: 30,
                          height: 30,
                          color: Colors.grey.shade800,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Gallery",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey.shade800)),
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
