import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/screens/main/sub/vehicles/vehi_gallery.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/services/services_service.dart';
import 'package:nearby/services/vehi_service.dart';
import 'package:nearby/utils/compress_media.dart';
import 'package:nearby/utils/flush_bars.dart';
import 'package:nearby/utils/image_cropper.dart';
import 'package:nearby/utils/media_picker/gallery_pick.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:progress_dialog/progress_dialog.dart';

class HireVehicle extends StatefulWidget {
  final String type;
  HireVehicle({this.type, Key key}) : super(key: key);

  @override
  _HireVehicleState createState() => _HireVehicleState();
}

class _HireVehicleState extends State<HireVehicle> {
  File intialImage;
  TextEditingController _name = TextEditingController();
  TextEditingController _details = TextEditingController();
  TextEditingController _banner = TextEditingController();
  TextEditingController _address = TextEditingController();
  List<String> daysOfAWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  Services _services = Services();
  AuthServcies _authServcies = AuthServcies();
  VehiService _vehiService = VehiService();
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
  TextEditingController _telephone1 = TextEditingController();
  TextEditingController _telephone2 = TextEditingController();
  TextEditingController _email = TextEditingController();

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
                Text("Creating hire vehicle...",
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
      if (_name.text.trim() != "") {
        if (_banner.text.trim() != "") {
          if (selectedDistrict != null) {
            if (_address.text.trim() != "") {
              if (_telephone1.text != "") {
                pr.show();

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
                      String downUrl = await _vehiService.uploadVideoToVehiSe(
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
                  _name.text.trim(),
                  _details.text.trim(),
                  initialImageUpload,
                  null,
                  null,
                  null,
                  _email.text.trim(),
                  selectedDistrict,
                  null,
                  null,
                  null,
                  null,
                  _telephone1.text.trim(),
                  _telephone1.text.trim(),
                  null,
                  null,
                  uploadGallery,
                  null,
                  widget.type,
                  _address.text.trim(),
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,
                  "available"
                );
                await _services.addService(_name.text.trim(), vehiSeId,
                    widget.type, "Vehicle services");
                await _vehiService.addMainBanner(
                  _name.text.trim(),
                  initialImageUpload,
                  vehiSeId,
                  _banner.text.trim(),
                  null,
                  _address.text.trim(),
                  widget.type,
                  null,
                );
                pr.hide().whenComplete(() {
                  Navigator.pop(context);
                });
              } else {
                GradientSnackBar.showMessage(
                    context, "Service telephone number is required");
              }
            } else {
              GradientSnackBar.showMessage(
                  context, "Service home city is required");
            }
          } else {
            GradientSnackBar.showMessage(context, "Please select a district");
          }
        } else {
          GradientSnackBar.showMessage(context, "Banner title is required");
        }
      } else {
        GradientSnackBar.showMessage(context, "Service name is required");
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
          "Hire vehicle",
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
                              "* Add initial image for the service",
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
            textBoxContainer(_name, "* Name of the service", 1, width, false,
                TextInputType.text),
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
            textBoxContainer(
                _address, "* Home city", 1, width, false, TextInputType.text),
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
                _email, "Email", 1, width, false, TextInputType.text),
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
