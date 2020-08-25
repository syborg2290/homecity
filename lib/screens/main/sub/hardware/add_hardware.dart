import 'dart:convert';
import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/screens/main/sub/gallery.dart';
import 'package:nearby/screens/main/sub/hardware/rent_tools_types.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/services/hardwareNTools_service.dart';
import 'package:nearby/services/services_service.dart';
import 'package:nearby/utils/compress_media.dart';
import 'package:nearby/utils/flush_bars.dart';
import 'package:nearby/utils/image_cropper.dart';
import 'package:nearby/utils/maps/locationMap.dart';
import 'package:nearby/utils/media_picker/gallery_pick.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'main_category.dart';
import 'package:intl/intl.dart' as dd;
import 'package:uuid/uuid.dart';

class AddHardware extends StatefulWidget {
  final String category;
  AddHardware({this.category, Key key}) : super(key: key);

  @override
  _AddHardwareState createState() => _AddHardwareState();
}

class _AddHardwareState extends State<AddHardware> {
  File intialImage;
  TextEditingController _name = TextEditingController();
  TextEditingController _aboutThe = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _location = TextEditingController();
  TextEditingController _telephone1 = TextEditingController();
  TextEditingController _telephone2 = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _website = TextEditingController();
  TextEditingController openController = TextEditingController();
  TextEditingController closeController = TextEditingController();
  TextEditingController _specialHolidaysAndHoursController =
      TextEditingController();

  final format = dd.DateFormat("HH:mm");
  DateTime open;
  DateTime close;
  double latitude;
  double longitude;
  HardwareNToolsService _hardwareNToolsService = HardwareNToolsService();
  Services _services = Services();
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
  List items = [];
  List rentTools = [];

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
                Text("Creating hardware & tools",
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

  done() async {
    if (intialImage != null) {
      if (_name.text.trim() != "") {
        if (selectedDistrict != null) {
          if (_address.text.trim() != "") {
            if (latitude != null) {
              if (_telephone1.text != "" || _telephone2.text != "") {
                if (openController.text != "" && closeController.text != "") {
                  pr.show();
                  var uuid = Uuid();
                  List uploadGallery = [];
                  if (gallery.isNotEmpty) {
                    for (var ele in gallery) {
                      if (ele["type"] == "image") {
                        String downUrl =
                            await _hardwareNToolsService.uploadImage(
                                await compressImageFile(ele["media"], 80));
                        String thumbUrl =
                            await _hardwareNToolsService.uploadImageThumbnail(
                                await compressImageFile(ele["media"], 40));
                        var obj = {
                          "url": downUrl,
                          "thumb": thumbUrl,
                          "type": "image",
                          "ownerId": currentUserId,
                        };
                        uploadGallery.add(json.encode(obj));
                      } else {
                        String downUrl = await _hardwareNToolsService
                            .uploadVideo(await compressVideoFile(ele["media"]));
                        String thumbUrl =
                            await _hardwareNToolsService.uploadVideoToThumb(
                                await getThumbnailForVideo(ele["media"]));
                        var obj = {
                          "url": downUrl,
                          "thumb": thumbUrl,
                          "type": "video",
                          "ownerId": currentUserId,
                        };
                        uploadGallery.add(json.encode(obj));
                      }
                    }
                  }

                  List itemsUpload = [];
                  List rentUpload = [];

                  for (var sel in items) {
                    String initialImageUploadSel =
                        await _hardwareNToolsService.uploadImage(
                            await compressImageFile(sel["initialImage"], 80));
                    List sellItemsGallery = [];

                    if (sel["gallery"].isNotEmpty) {
                      for (var ele in sel["gallery"]) {
                        if (ele["type"] == "image") {
                          String downUrl =
                              await _hardwareNToolsService.uploadImage(
                                  await compressImageFile(ele["media"], 80));
                          String thumbUrl =
                              await _hardwareNToolsService.uploadImageThumbnail(
                                  await compressImageFile(ele["media"], 40));
                          var obj = {
                            "url": downUrl,
                            "thumb": thumbUrl,
                            "type": "image",
                            "ownerId": currentUserId,
                          };
                          sellItemsGallery.add(json.encode(obj));
                        } else {
                          String downUrl =
                              await _hardwareNToolsService.uploadVideo(
                                  await compressVideoFile(ele["media"]));
                          String thumbUrl =
                              await _hardwareNToolsService.uploadVideoToThumb(
                                  await getThumbnailForVideo(ele["media"]));
                          var obj = {
                            "url": downUrl,
                            "thumb": thumbUrl,
                            "type": "video",
                            "ownerId": currentUserId,
                          };
                          sellItemsGallery.add(json.encode(obj));
                        }
                      }
                    }

                    var obj = {
                      "id":
                          uuid.v1().toString() + new DateTime.now().toString(),
                      "initialImage": initialImageUploadSel,
                      "item_type": sel["item_type"],
                      "item_name": sel["item_name"],
                      "price": sel["price"],
                      "about": sel["about"],
                      "gallery": sellItemsGallery,
                      "total_ratings": 0.0,
                    };

                    itemsUpload.add(json.encode(obj));
                  }

                  for (var rent in rentTools) {
                    String initialImageUploadSel =
                        await _hardwareNToolsService.uploadImage(
                            await compressImageFile(rent["initialImage"], 80));
                    List sellItemsGallery = [];

                    if (rent["gallery"].isNotEmpty) {
                      for (var ele in rent["gallery"]) {
                        if (ele["type"] == "image") {
                          String downUrl =
                              await _hardwareNToolsService.uploadImage(
                                  await compressImageFile(ele["media"], 80));
                          String thumbUrl =
                              await _hardwareNToolsService.uploadImageThumbnail(
                                  await compressImageFile(ele["media"], 40));
                          var obj = {
                            "url": downUrl,
                            "thumb": thumbUrl,
                            "type": "image",
                            "ownerId": currentUserId,
                          };
                          sellItemsGallery.add(json.encode(obj));
                        } else {
                          String downUrl =
                              await _hardwareNToolsService.uploadVideo(
                                  await compressVideoFile(ele["media"]));
                          String thumbUrl =
                              await _hardwareNToolsService.uploadVideoToThumb(
                                  await getThumbnailForVideo(ele["media"]));
                          var obj = {
                            "url": downUrl,
                            "thumb": thumbUrl,
                            "type": "video",
                            "ownerId": currentUserId,
                          };
                          sellItemsGallery.add(json.encode(obj));
                        }
                      }
                    }

                    var obj = {
                      "id":
                          uuid.v1().toString() + new DateTime.now().toString(),
                      "initialImage": initialImageUploadSel,
                      "item_type": rent["item_type"],
                      "item_name": rent["item_name"],
                      "price": rent["price"],
                      "about": rent["about"],
                      "gallery": sellItemsGallery,
                      "total_ratings": 0.0,
                    };

                    rentUpload.add(json.encode(obj));
                  }

                  String initialImageUpload = await _hardwareNToolsService
                      .uploadImage(await compressImageFile(intialImage, 80));

                  String restId =
                      await _hardwareNToolsService.addHardwareNService(
                    currentUserId,
                    _name.text.trim(),
                    _aboutThe.text.trim(),
                    initialImageUpload,
                    _address.text.trim(),
                    latitude,
                    longitude,
                    _email.text.trim(),
                    _website.text.trim(),
                    close,
                    open,
                    _telephone1.text.trim(),
                    _telephone2.text.trim(),
                    _specialHolidaysAndHoursController.text.trim(),
                    selectedDistrict,
                    uploadGallery,
                    items,
                    rentUpload,
                  );
                  await _services.addService(
                      _name.text.trim(),
                      restId,
                      latitude,
                      longitude,
                      "Hardware,tools & materials",
                      "Hardware,tools & materials");

                  pr.hide().whenComplete(() {
                    Navigator.pop(context);
                  });
                } else {
                  GradientSnackBar.showMessage(
                      context, "Open and close time is required");
                }
              } else {
                GradientSnackBar.showMessage(
                    context, "Only one telephone number is required");
              }
            } else {
              GradientSnackBar.showMessage(context, "Please pin the location");
            }
          } else {
            GradientSnackBar.showMessage(context, "Shop address is required");
          }
        } else {
          GradientSnackBar.showMessage(context, "Please select a district");
        }
      } else {
        GradientSnackBar.showMessage(context, "Shop name is required");
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
          'Add new hardware and tools',
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
                        'assets/apparel_back.jpg',
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
                        padding: EdgeInsets.only(top: height * 0.06),
                        child: Column(
                          children: <Widget>[
                            Center(
                                child: Text(
                              "* Add initial image",
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
            textBoxContainer(_name, "* Name of the shop", 1, width, false,
                TextInputType.text),
            SizedBox(
              height: 20,
            ),
            textBoxContainer(_aboutThe, "About the shop", 5, width, false,
                TextInputType.text),
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
            textBoxContainer(_address, "* Address of the shop", 1, width, false,
                TextInputType.text),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "* Open and close time of the shop",
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
            textBoxContainer(
                _specialHolidaysAndHoursController,
                "Special holidays and hours of closing",
                3,
                width,
                false,
                TextInputType.text),
            widget.category == "any" || widget.category == "sell"
                ? SizedBox(
                    height: 20,
                  )
                : SizedBox.shrink(),
            widget.category == "any" || widget.category == "sell"
                ? GestureDetector(
                    onTap: () async {
                      List reSllingItems = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HardwareMainCategory(
                                    items: items,
                                  )));
                      if (reSllingItems != null) {
                        setState(() {
                          items = reSllingItems;
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
                          padding: EdgeInsets.all(
                            0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                'assets/icons/hardware_tools.png',
                                width: 30,
                                height: 30,
                                color: Colors.grey.shade800,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Add items",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade800)),
                              ),
                            ],
                          ),
                        ))),
                  )
                : SizedBox.shrink(),
            widget.category == "any" || widget.category == "rent"
                ? SizedBox(
                    height: 20,
                  )
                : SizedBox.shrink(),
            widget.category == "any" || widget.category == "rent"
                ? GestureDetector(
                    onTap: () async {
                      List reSllingItems = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RentToolsType(
                                    items: rentTools,
                                  )));
                      if (reSllingItems != null) {
                        setState(() {
                          rentTools = reSllingItems;
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
                          padding: EdgeInsets.all(
                            0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                'assets/icons/builder.png',
                                width: 30,
                                height: 30,
                                color: Colors.grey.shade800,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Customize rent tools",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade800)),
                              ),
                            ],
                          ),
                        ))),
                  )
                : SizedBox.shrink(),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async {
                List reGallery = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Gallery(
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
