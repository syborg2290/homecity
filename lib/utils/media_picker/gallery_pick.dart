import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearby/utils/media_picker/mainPicker.dart';
import 'package:permission_handler/permission_handler.dart';

class GalleryPick extends StatefulWidget {
  final bool isOnlyImage;
  final bool isSingle;
  final bool isPano;
  GalleryPick({this.isOnlyImage, this.isPano, this.isSingle, Key key})
      : super(key: key);

  @override
  _GalleryPickState createState() => _GalleryPickState();
}

class _GalleryPickState extends State<GalleryPick> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var orientation = MediaQuery.of(context).orientation;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        title: Text("Device gallery",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            )),
        elevation: 0.0,
        leading: IconButton(
            icon: Image.asset(
              'assets/icons/left-arrow.png',
              width: width * 0.07,
              height: height * 0.07,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: <Widget>[
          widget.isPano
              ? SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(
                    right: 10,
                  ),
                  child: IconButton(
                      icon: Image.asset(
                        'assets/icons/camera.png',
                        width: width * 0.08,
                        height: height * 0.08,
                      ),
                      onPressed: () async {
                        var status = await Permission.camera.status;
                        if (status.isUndetermined) {
                          var statusRe = await Permission.camera.request();

                          if (statusRe.isGranted) {
                            final pickedFile = await ImagePicker().getImage(
                              source: ImageSource.camera,
                            );
                            if (pickedFile != null) {
                              var obj = {
                                "mediaFile": pickedFile,
                                "type": "camPhoto",
                              };

                              Navigator.pop(context, obj);
                            }
                          }
                        }

                        if (status.isGranted) {
                          final pickedFile = await ImagePicker().getImage(
                            source: ImageSource.camera,
                          );
                          if (pickedFile != null) {
                            var obj = {
                              "mediaFile": pickedFile,
                              "type": "camPhoto",
                            };

                            Navigator.pop(context, obj);
                          }
                        } else {
                          var statusRe2 = await Permission.camera.request();
                          if (statusRe2.isGranted) {
                            final pickedFile = await ImagePicker().getImage(
                              source: ImageSource.camera,
                            );
                            if (pickedFile != null) {
                              var obj = {
                                "mediaFile": pickedFile,
                                "type": "camPhoto",
                              };

                              Navigator.pop(context, obj);
                            }
                          }
                        }
                      }),
                ),
          widget.isOnlyImage
              ? SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(
                    right: 10,
                  ),
                  child: IconButton(
                      icon: Image.asset(
                        'assets/icons/video-camera.png',
                        width: width * 0.08,
                        height: height * 0.08,
                      ),
                      onPressed: () async {
                        var statuscam = await Permission.camera.status;
                        var statusmi = await Permission.microphone.status;

                        if (statuscam.isUndetermined &&
                            statusmi.isUndetermined) {
                          var statusReCam = await Permission.camera.request();
                          var statusReMi =
                              await Permission.microphone.request();
                          if (statusReMi.isGranted && statusReCam.isGranted) {
                            final pickedFile = await ImagePicker().getVideo(
                                source: ImageSource.camera,
                                maxDuration: Duration(
                                  minutes: 5,
                                ));
                            if (pickedFile != null) {
                              var obj = {
                                "mediaFile": pickedFile,
                                "type": "camVideo",
                              };

                              Navigator.pop(context, obj);
                            }
                          }
                        }

                        if (statusmi.isGranted && statuscam.isGranted) {
                          final pickedFile = await ImagePicker().getVideo(
                            source: ImageSource.camera,
                          );
                          if (pickedFile != null) {
                            var obj = {
                              "mediaFile": pickedFile,
                              "type": "camVideo",
                            };

                            Navigator.pop(context, obj);
                          }
                        } else {
                          var statusRe2Cam = await Permission.camera.request();
                          var statusRe2Mi =
                              await Permission.microphone.request();
                          if (statusRe2Mi.isGranted && statusRe2Cam.isGranted) {
                            final pickedFile = await ImagePicker().getVideo(
                              source: ImageSource.camera,
                            );
                            if (pickedFile != null) {
                              var obj = {
                                "mediaFile": pickedFile,
                                "type": "camVideo",
                              };

                              Navigator.pop(context, obj);
                            }
                          }
                        }
                      }),
                )
        ],
      ),
      body: MainPicker(
        isOnlyImage: widget.isOnlyImage,
        isSingle: widget.isSingle,
      ),
    );
  }
}
