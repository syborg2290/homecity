import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/screens/main/sub/education/education_gallery.dart';
import 'package:nearby/screens/main/sub/education/tution/tution_schedule.dart';
import 'package:nearby/screens/main/sub/education/view_Experiences.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/services/education_service.dart';
import 'package:nearby/services/services_service.dart';
import 'package:nearby/utils/compress_media.dart';
import 'package:nearby/utils/flush_bars.dart';
import 'package:nearby/utils/image_cropper.dart';
import 'package:nearby/utils/media_picker/gallery_pick.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:progress_dialog/progress_dialog.dart';

class AddTution extends StatefulWidget {
  final String type;
  final String subject;
  AddTution({this.type, this.subject, Key key}) : super(key: key);

  @override
  _AddTutionState createState() => _AddTutionState();
}

class _AddTutionState extends State<AddTution> {
  File intialImage;
  TextEditingController _name = TextEditingController();
  TextEditingController _aboutThe = TextEditingController();
  TextEditingController _aboutTheInstructor = TextEditingController();
  TextEditingController _telephone1 = TextEditingController();
  TextEditingController _telephone2 = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _subject = TextEditingController();
  String tutionType = "All";

  Services _services = Services();
  AuthServcies _authServcies = AuthServcies();
  EducationService _educationService = EducationService();
  ProgressDialog pr;
  String currentUserId;
  List gallery = [];
  List shedule = [];
  List experiences = [];

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
                Text("Creating " + widget.type.toLowerCase() + "...",
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
        if (_subject.text.trim() != "") {
          if (_telephone1.text != "") {
            pr.show();
            List uploadGallery = [];
            if (gallery.isNotEmpty) {
              for (var ele in gallery) {
                if (ele["type"] == "image") {
                  String downUrl = await _educationService.uploadImagEducation(
                      await compressImageFile(ele["media"], 80));
                  String thumbUrl =
                      await _educationService.uploadImageEducationThumbnail(
                          await compressImageFile(ele["media"], 40));
                  var obj = {
                    "url": downUrl,
                    "thumb": thumbUrl,
                    "type": "image",
                  };
                  uploadGallery.add(json.encode(obj));
                } else {
                  String downUrl =
                      await _educationService.uploadVideoToEducation(
                          await compressVideoFile(ele["media"]));
                  String thumbUrl =
                      await _educationService.uploadVideoToEducationThumb(
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

            List uploadExperience = [];

            if (experiences.isNotEmpty) {
              for (var item in experiences) {
                String downUrl = await _educationService.uploadImagEducation(
                    await compressImageFile(item["initialImage"], 80));
                var obj = {
                  "initialImage": downUrl,
                  "about": item["about"],
                };
                uploadExperience.add(json.encode(obj));
              }
            }

            List scheduleUpload = [];
            for (var sh in shedule) {
              scheduleUpload.add(json.encode(sh));
            }

            String initialImageUpload = await _educationService
                .uploadImagEducation(await compressImageFile(intialImage, 80));

            String restId = await _educationService.addEducation(
              currentUserId,
              _name.text.trim(),
              _aboutThe.text.trim(),
              initialImageUpload,
              null,
              null,
              null,
              _email.text.trim(),
              null,
              _telephone1.text.trim(),
              _telephone2.text.trim(),
              null,
              uploadGallery,
              uploadExperience,
              widget.type,
              _aboutTheInstructor.text.trim(),
              scheduleUpload,
              _subject.text.trim(),
              tutionType,
              widget.subject,
              null,
            );
            await _services.addService(_name.text.trim(), restId, null, null,
                widget.type, "Education");

            pr.hide().whenComplete(() {
              Navigator.pop(context);
            });
          } else {
            GradientSnackBar.showMessage(
                context, widget.type + " telephone number is required");
          }
        } else {
          GradientSnackBar.showMessage(
              context, widget.type + " subject name is required");
        }
      } else {
        GradientSnackBar.showMessage(
            context, widget.type + " instructor name is required");
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
          'Add new ' + widget.type.toLowerCase(),
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
                        'assets/education_back.jpg',
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
            textBoxContainer(_name, "* Name of the instructor", 1, width, false,
                TextInputType.text),
            SizedBox(
              height: 20,
            ),
            textBoxContainer(_subject, "* Common name of the subject", 1, width,
                false, TextInputType.text),
            SizedBox(
              height: 20,
            ),
            textBoxContainer(_aboutTheInstructor, "About the instructor", 3,
                width, false, TextInputType.text),
            SizedBox(
              height: 20,
            ),
            textBoxContainer(
                _aboutThe,
                "About the " + widget.type.toLowerCase(),
                5,
                width,
                false,
                TextInputType.text),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Tution Type",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            SizedBox(
              height: 10,
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
                            tutionType = "All";
                          });
                        },
                        child: Chip(
                            backgroundColor: tutionType == "All"
                                ? Pallete.mainAppColor
                                : null,
                            label: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                "All",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: tutionType == "All"
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
                            tutionType = "Group";
                          });
                        },
                        child: Chip(
                            backgroundColor: tutionType == "Group"
                                ? Pallete.mainAppColor
                                : null,
                            label: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                "Group",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: tutionType == "Group"
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
                            tutionType = "Individual";
                          });
                        },
                        child: Chip(
                            backgroundColor: tutionType == "Individual"
                                ? Pallete.mainAppColor
                                : null,
                            label: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                "Individual",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: tutionType == "Individual"
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
              height: 30,
            ),
            GestureDetector(
              onTap: () async {
                List reSchdule = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TutionSchedule(
                              schedule: shedule,
                            )));
                if (reSchdule != null) {
                  setState(() {
                    shedule = reSchdule;
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
                          'assets/icons/schedule.png',
                          width: 30,
                          height: 30,
                          color: Colors.grey.shade800,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Make the schedule",
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
                List reExperience = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewExperiences(
                              experiences: experiences,
                            )));
                if (reExperience != null) {
                  setState(() {
                    experiences = reExperience;
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
                          'assets/icons/experience.png',
                          width: 30,
                          height: 30,
                          color: Colors.grey.shade800,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Experiences in here",
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
                        builder: (context) => EducationGallery(
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
