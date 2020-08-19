import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby/screens/main/sub/vehicles/rent/renting_gallery.dart';
import 'package:nearby/utils/flush_bars.dart';
import 'package:nearby/utils/image_cropper.dart';
import 'package:nearby/utils/media_picker/gallery_pick.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:photo_manager/photo_manager.dart';

class RentVehiForm extends StatefulWidget {
  final String type;
  final obj;
  RentVehiForm({this.type, this.obj, Key key}) : super(key: key);

  @override
  _RentVehiFormState createState() => _RentVehiFormState();
}

class _RentVehiFormState extends State<RentVehiForm> {
  File intialImage;
  TextEditingController _vehiName = TextEditingController();
  TextEditingController _brandName = TextEditingController();
  TextEditingController _model = TextEditingController();
  TextEditingController _aboutTheVehicle = TextEditingController();
  TextEditingController _pricePerKm = TextEditingController();
  bool isForEdit = false;
  String fuel = "Petrol";
  String transmission = "Automatic";
  TextEditingController _enginecapacity = TextEditingController();
  List gallery = [];

  @override
  void initState() {
    super.initState();
    if (widget.obj != null) {
      setState(() {
        isForEdit = true;
        intialImage = widget.obj["initialImage"];
        _vehiName.text = widget.obj["vehi_name"];
        _aboutTheVehicle.text = widget.obj["details"];
        _pricePerKm.text = widget.obj["price"];
        _brandName.text = widget.obj["brand"];
        _model.text = widget.obj["model"];
        _enginecapacity.text = widget.obj["engine_capacity"];
        transmission = widget.obj["transmission"];
        fuel = widget.obj["fuel"];
        gallery = widget.obj["gallery"];
      });
    }
  }

  done() {
    if (intialImage != null) {
      if (_vehiName.text.trim() != "") {
        if (_pricePerKm.text.trim() != "") {
          var obj = {
            "initialImage": intialImage,
            "item_type": widget.type,
            "vehi_name": _vehiName.text.trim(),
            "price": _pricePerKm.text.trim(),
            "details": _aboutTheVehicle.text.trim(),
            "brand": _brandName.text.trim(),
            "model": _model.text.trim(),
            "engine_capacity": _enginecapacity.text.trim(),
            "fuel": fuel,
            "transmission": transmission,
            "gallery": gallery,
          };
          Navigator.pop(context, obj);
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
              fontSize: 18,
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
                              "* Add initial image for the vehicle",
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
                                              isPano: false,
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
                                            isPano: false,
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
            textBoxContainer(
                _vehiName, "* Vehicle", 1, width, false, TextInputType.text),
            SizedBox(
              height: 20,
            ),
            Container(
              width: width * 0.89,
              child: TextField(
                controller: _pricePerKm,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "* Price per KM (LKR)",
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
            textBoxContainer(
                _brandName, "Brand", 1, width, false, TextInputType.text),
            SizedBox(
              height: 20,
            ),
            textBoxContainer(
                _model, "Model", 1, width, false, TextInputType.text),
            SizedBox(
              height: 20,
            ),
            Container(
              width: width * 0.89,
              child: TextField(
                controller: _enginecapacity,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Engine capacity",
                  labelStyle:
                      TextStyle(fontSize: 18, color: Colors.grey.shade500),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  suffix: Text(
                    "cc",
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Transmission of the vehicle",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            transmission = "Automatic";
                          });
                        },
                        child: Chip(
                            backgroundColor: transmission == "Automatic"
                                ? Pallete.mainAppColor
                                : null,
                            label: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                "Automatic",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: transmission == "Automatic"
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ))),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            transmission = "Manual";
                          });
                        },
                        child: Chip(
                            backgroundColor: transmission == "Manual"
                                ? Pallete.mainAppColor
                                : null,
                            label: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                "Manual",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: transmission == "Manual"
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ))),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            transmission = "Tiptronic";
                          });
                        },
                        child: Chip(
                            backgroundColor: transmission == "Tiptronic"
                                ? Pallete.mainAppColor
                                : null,
                            label: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                "Tiptronic",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: transmission == "Tiptronic"
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ))),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Fuel type of the vehicle",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            fuel = "Petrol";
                          });
                        },
                        child: Chip(
                            backgroundColor:
                                fuel == "Petrol" ? Pallete.mainAppColor : null,
                            label: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                "Petrol",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: fuel == "Petrol"
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ))),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            fuel = "Diesel";
                          });
                        },
                        child: Chip(
                            backgroundColor:
                                fuel == "Diesel" ? Pallete.mainAppColor : null,
                            label: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                "Diesel",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: fuel == "Diesel"
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ))),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            fuel = "Electric";
                          });
                        },
                        child: Chip(
                            backgroundColor: fuel == "Electric"
                                ? Pallete.mainAppColor
                                : null,
                            label: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                "Electric",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: fuel == "Electric"
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ))),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            fuel = "Hybrid";
                          });
                        },
                        child: Chip(
                            backgroundColor:
                                fuel == "Hybrid" ? Pallete.mainAppColor : null,
                            label: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                "Hybrid",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: fuel == "Hybrid"
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ))),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            fuel = "Plug-in hybrid";
                          });
                        },
                        child: Chip(
                            backgroundColor: fuel == "Plug-in hybrid"
                                ? Pallete.mainAppColor
                                : null,
                            label: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                "Plug-in hybrid",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: fuel == "Plug-in hybrid"
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ))),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            textBoxContainer(_aboutTheVehicle, "Details", 3, width, false,
                TextInputType.text),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async {
                List reGallery = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RentGallery(
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
