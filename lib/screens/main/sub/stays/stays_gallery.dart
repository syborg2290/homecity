import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby/utils/full_screen_media_file.dart';
import 'package:nearby/utils/image_cropper.dart';
import 'package:nearby/utils/media_picker/gallery_pick.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/utils/video_trimmer.dart';
import 'package:nearby/utils/videoplayers/fileVideoPlayer.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';

class StaysGallery extends StatefulWidget {
  final List gallery;
  StaysGallery({this.gallery, Key key}) : super(key: key);

  @override
  _StaysGalleryState createState() => _StaysGalleryState();
}

class _StaysGalleryState extends State<StaysGallery> {
  List gallery = [];
  VideoPlayerController _videocontroller;

  @override
  void initState() {
    super.initState();
    setState(() {
      gallery = widget.gallery;
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
                        gallery.add(mediaObj);
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, gallery);
        return false;
      },
      child: Scaffold(
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
                  Navigator.pop(context, gallery);
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
              'Gallery',
              style: TextStyle(
                  color: Colors.grey[700],
                  fontFamily: "Roboto",
                  fontSize: 20,
                  fontWeight: FontWeight.w400),
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                    icon: Image.asset(
                      'assets/icons/add.png',
                      width: 40,
                      height: 40,
                    ),
                    onPressed: () async {
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
                              if (element.type.toString() ==
                                  "AssetType.image") {
                                var mediaObj = {
                                  "type": "image",
                                  "media": value,
                                };
                                setState(() {
                                  gallery.add(mediaObj);
                                });
                              } else {
                                checkVideoDurations(value, gallery.length);
                                var mediaObj = {
                                  "type": "video",
                                  "media": value,
                                };
                                setState(() {
                                  gallery.add(mediaObj);
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
                            gallery.add(mediaObj);
                          });
                        }

                        if (obj["type"] == "camVideo") {
                          var mediaObj = {
                            "type": "video",
                            "media": File(obj["mediaFile"].path),
                          };
                          setState(() {
                            gallery.add(mediaObj);
                          });
                        }
                      }
                    }),
              )
            ],
          ),
          body: gallery.isEmpty
              ? Center(
                  child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset(
                    'assets/icons/album.png',
                    color: Colors.black.withOpacity(0.2),
                  ),
                ))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      children: List.generate(gallery.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FullScreenMediaFile(
                                        file: gallery[index]["media"],
                                        type: gallery[index]["type"],
                                      )),
                            );
                          },
                          child: Stack(
                            children: <Widget>[
                              Container(
                                width: width * 0.4,
                                height: height * 0.25,
                                child: gallery[index]["type"] == "image"
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          gallery[index]["media"],
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: FileVideoplayer(
                                          aspectRatio: 1 / 2,
                                          video: gallery[index]["media"],
                                        ),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  child: FloatingActionButton(
                                    onPressed: () async {
                                      if (gallery[index]["type"] == "image") {
                                        File croppedImage =
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ImageCropper(
                                                          image: gallery[index]
                                                              ["media"],
                                                        )));
                                        if (croppedImage != null) {
                                          var mediaObj = {
                                            "type": "image",
                                            "media": croppedImage,
                                          };
                                          setState(() {
                                            gallery[index] = mediaObj;
                                          });
                                        }
                                      } else {
                                        final Trimmer _trimmer = Trimmer();
                                        await _trimmer.loadVideo(
                                            videoFile: gallery[index]["media"]);

                                        File trimmedVideo =
                                            await Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                          return VideoTrimmer(
                                            trimmer: _trimmer,
                                            media: gallery[index]["media"],
                                          );
                                        }));
                                        if (trimmedVideo != null) {
                                          var mediaObj = {
                                            "type": "video",
                                            "media": trimmedVideo,
                                          };
                                          setState(() {
                                            gallery[index] = mediaObj;
                                          });
                                        }
                                      }
                                    },
                                    heroTag: index,
                                    backgroundColor: Pallete.mainAppColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                        gallery[index]["type"] == "image"
                                            ? 'assets/icons/crop.png'
                                            : 'assets/icons/cut.png',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    child: FloatingActionButton(
                                      onPressed: () {
                                        setState(() {
                                          gallery.removeAt(index);
                                        });
                                      },
                                      heroTag: (index + 1).toString() + "media",
                                      backgroundColor: Colors.red,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset(
                                          'assets/icons/close.png',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      })),
                )),
    );
  }
}
