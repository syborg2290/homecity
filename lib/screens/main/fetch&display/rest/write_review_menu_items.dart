import 'dart:io';

import 'package:animator/animator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearby/utils/full_screen_media_file.dart';
import 'package:nearby/utils/media_picker/gallery_pick.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/utils/video_trimmer.dart';
import 'package:nearby/utils/videoplayers/fileVideoPlayer.dart';
import 'package:panorama/panorama.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';

class WriteMenuItemReview extends StatefulWidget {
  final double rate;
  final String currentUserId;
  final String restId;
  WriteMenuItemReview({this.rate, this.currentUserId, this.restId, Key key})
      : super(key: key);

  @override
  _WriteMenuItemReviewState createState() => _WriteMenuItemReviewState();
}

class _WriteMenuItemReviewState extends State<WriteMenuItemReview> {
  TextEditingController _review = TextEditingController();
  VideoPlayerController _videocontroller;
  List media = [];

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
          labelStyle: TextStyle(fontSize: 20, color: Colors.grey.shade500),
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

  checkVideoDurations(File video, int index) async {
    _videocontroller = VideoPlayerController.file(video)
      ..initialize().then((_) {
        if (_videocontroller.value.duration.inSeconds > 300) {
          videoTrimDialog(_videocontroller.value.duration.inMinutes.toString(),
              video, index);
          return;
        }
      });
  }

  videoTrimDialog(String duration, File video, int index) {
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.INFO,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Center(
              child: Text(
                "Keep video duration between 1 to 5 minitues long",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 300,
              height: 250,
              child: FileVideoplayer(
                video: video,
                aspectRatio: 1.2 / 1,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 20,
                left: 20,
              ),
              child: Container(
                height: 50,
                width: double.infinity,
                child: FlatButton(
                  onPressed: () async {
                    final Trimmer _trimmer = Trimmer();
                    await _trimmer.loadVideo(videoFile: video);

                    File trimmedVideo = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return VideoTrimmer(
                        trimmer: _trimmer,
                      );
                    }));

                    if (trimmedVideo != null) {
                      Navigator.of(context, rootNavigator: true).pop();
                      var mediaObj = {
                        "type": "video",
                        "media": trimmedVideo,
                      };
                      setState(() {
                        media.add(mediaObj);
                      });
                    }
                  },
                  padding: EdgeInsets.all(0),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Pallete.mainAppColor,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      constraints: BoxConstraints(
                          maxWidth: double.infinity, minHeight: 50),
                      child: Text(
                        "Trim video",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )..show();
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
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
              icon: Image.asset(
                'assets/icons/left-arrow.png',
                width: width * 0.07,
                height: height * 0.07,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        centerTitle: true,
        title: Text(
          "Review",
          style: TextStyle(
              color: Colors.grey[700],
              fontFamily: "Roboto",
              fontSize: 25,
              fontWeight: FontWeight.w400),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              onPressed: () {
                // done();
              },
              child: Center(
                  child: Text("post",
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: height * 0.2,
            ),
            RatingBar(
              initialRating: widget.rate,
              minRating: 0,
              itemSize: 50,
              unratedColor: Colors.grey[300],
              direction: Axis.horizontal,
              allowHalfRating: true,
              glow: true,
              tapOnlyMode: true,
              glowColor: Colors.white,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                MaterialIcons.star,
                color: Pallete.mainAppColor,
              ),
              onRatingUpdate: (rating) {},
            ),
            SizedBox(
              height: 20,
            ),
            textBoxContainer(
                _review,
                media.isNotEmpty ? "* Review caption" : "* Write your review",
                media.isNotEmpty ? 1 : 8,
                width,
                false,
                TextInputType.text),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    var status = await Permission.camera.status;
                    if (status.isUndetermined) {
                      var statusRe = await Permission.camera.request();

                      if (statusRe.isGranted) {
                        final pickedFile = await ImagePicker().getImage(
                          source: ImageSource.camera,
                        );
                        if (pickedFile != null) {
                          var mediaObj = {
                            "type": "image",
                            "media": File(pickedFile.path),
                          };
                          setState(() {
                            media.add(mediaObj);
                          });
                        }
                      }
                    }

                    if (status.isGranted) {
                      final pickedFile = await ImagePicker().getImage(
                        source: ImageSource.camera,
                      );
                      if (pickedFile != null) {
                        var mediaObj = {
                          "type": "image",
                          "media": File(pickedFile.path),
                        };
                        setState(() {
                          media.add(mediaObj);
                        });
                      }
                    } else {
                      var statusRe2 = await Permission.camera.request();
                      if (statusRe2.isGranted) {
                        final pickedFile = await ImagePicker().getImage(
                          source: ImageSource.camera,
                        );
                        if (pickedFile != null) {
                          var mediaObj = {
                            "type": "image",
                            "media": File(pickedFile.path),
                          };
                          setState(() {
                            media.add(mediaObj);
                          });
                        }
                      }
                    }
                  },
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            color: Pallete.mainAppColor,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            border: Border.all(color: Colors.white)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/icons/camera.png',
                            width: 40,
                            height: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("Camera")
                    ],
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    var status = await Permission.camera.status;
                    if (status.isUndetermined) {
                      var statusRe = await Permission.camera.request();

                      if (statusRe.isGranted) {
                        final pickedFile = await ImagePicker().getVideo(
                          source: ImageSource.camera,
                        );
                        if (pickedFile != null) {
                          var mediaObj = {
                            "type": "video",
                            "media": File(pickedFile.path),
                          };
                          checkVideoDurations(
                              File(pickedFile.path), media.length);
                          setState(() {
                            media.add(mediaObj);
                          });
                        }
                      }
                    }

                    if (status.isGranted) {
                      final pickedFile = await ImagePicker().getVideo(
                        source: ImageSource.camera,
                      );
                      if (pickedFile != null) {
                        var mediaObj = {
                          "type": "video",
                          "media": File(pickedFile.path),
                        };
                        checkVideoDurations(
                            File(pickedFile.path), media.length);
                        setState(() {
                          media.add(mediaObj);
                        });
                      }
                    } else {
                      var statusRe2 = await Permission.camera.request();
                      if (statusRe2.isGranted) {
                        final pickedFile = await ImagePicker().getVideo(
                          source: ImageSource.camera,
                        );
                        if (pickedFile != null) {
                          var mediaObj = {
                            "type": "video",
                            "media": File(pickedFile.path),
                          };
                          checkVideoDurations(
                              File(pickedFile.path), media.length);
                          setState(() {
                            media.add(mediaObj);
                          });
                        }
                      }
                    }
                  },
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            color: Pallete.mainAppColor,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            border: Border.all(color: Colors.white)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/icons/video-camera.png',
                            width: 40,
                            height: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("Video camera")
                    ],
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    var obj = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GalleryPick(
                                  isOnlyImage: false,
                                  isSingle: false,
                                  isPano: false,
                                )));
                    if (obj != null) {
                      if (obj["type"] == "gallery") {
                        List<AssetEntity> assetentity = obj["mediaList"];

                        assetentity.forEach((element) {
                          element.file.then((value) {
                            if (element.type.toString() == "AssetType.image") {
                              var mediaObj = {
                                "type": "image",
                                "media": value,
                              };
                              setState(() {
                                media.add(mediaObj);
                              });
                            } else {
                              checkVideoDurations(value, media.length);
                              var mediaObj = {
                                "type": "video",
                                "media": value,
                              };
                              setState(() {
                                media.add(mediaObj);
                              });
                            }
                          });
                        });
                      }
                      if (obj["type"] == "camPhoto") {
                        var mediaObj = {
                          "type": "image",
                          "media": File(obj["mediaFile"].path),
                        };
                        setState(() {
                          media.add(mediaObj);
                        });
                      }

                      if (obj["type"] == "camVideo") {
                        var mediaObj = {
                          "type": "video",
                          "media": File(obj["mediaFile"].path),
                        };
                        setState(() {
                          media.add(mediaObj);
                        });
                      }
                    }
                  },
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            color: Pallete.mainAppColor,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            border: Border.all(color: Colors.white)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/icons/album.png',
                            width: 40,
                            height: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("Gallery")
                    ],
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    var obj = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GalleryPick(
                                  isOnlyImage: true,
                                  isSingle: true,
                                  isPano: true,
                                )));
                    if (obj != null) {
                      if (obj["type"] == "gallery") {
                        AssetEntity assetentity = obj["mediaList"][0];

                        assetentity.file.then((value) {
                          var mediaObj = {
                            "type": "pano",
                            "media": value,
                          };
                          setState(() {
                            media.add(mediaObj);
                          });
                        });
                      } else {
                        var mediaObj = {
                          "type": "pano",
                          "media": File(obj["mediaFile"].path),
                        };
                        setState(() {
                          media.add(mediaObj);
                        });
                      }
                    }
                  },
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            color: Pallete.mainAppColor,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            border: Border.all(color: Colors.white)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/icons/pana.png',
                            width: 40,
                            height: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("Panaroma image")
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: height * 0.20,
              child: ListView.builder(
                  itemCount: media.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: width * 0.35,
                        height: height * 0.20,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10)),
                        child: media[index]["type"] == "image"
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FullScreenMediaFile(
                                                file: media[index]["media"],
                                                type: "image",
                                              )));
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    media[index]["media"],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : media[index]["type"] == "video"
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: FileVideoplayer(
                                      aspectRatio: 1 / 2,
                                      video: media[index]["media"],
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  FullScreenMediaFile(
                                                    file: media[index]["media"],
                                                    type: "pano",
                                                  )));
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Stack(
                                        children: <Widget>[
                                          Image.file(
                                            media[index]["media"],
                                            fit: BoxFit.contain,
                                          ),
                                          Container(
                                            width: width * 0.3,
                                            height: height * 0.20,
                                            color:
                                                Colors.black.withOpacity(0.2),
                                          ),
                                          Animator(
                                            duration:
                                                Duration(milliseconds: 2000),
                                            tween: Tween(begin: 1.2, end: 1.3),
                                            curve: Curves.bounceIn,
                                            cycles: 0,
                                            builder: (anim) => Center(
                                              child: Transform.scale(
                                                scale: anim.value,
                                                child: Image.asset(
                                                  'assets/icons/arrows.png',
                                                  width: 50,
                                                  height: 50,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
