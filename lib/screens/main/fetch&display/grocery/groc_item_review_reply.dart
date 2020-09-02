import 'dart:convert';
import 'dart:io';

import 'package:animator/animator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearby/models/grocery.dart';
import 'package:nearby/models/user.dart';
import 'package:nearby/services/activity_feed_service.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/services/grocery_service.dart';
import 'package:nearby/utils/compress_media.dart';
import 'package:nearby/utils/custom_tile.dart';
import 'package:nearby/utils/full_screen_network_file.dart';
import 'package:nearby/utils/image_cropper.dart';
import 'package:nearby/utils/media_picker/gallery_pick.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/utils/video_trimmer.dart';
import 'package:nearby/utils/videoplayers/fileVideoPlayer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:readmore/readmore.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class GrocItemReviewReply extends StatefulWidget {
  final String reviewOwner;
  final String reviewOwnerId;
  final int index;
  final int reviewIndex;
  final String docId;
  final String currentUserId;
  final String ownerId;
  final String id;
  GrocItemReviewReply(
      {this.reviewOwner,
      this.reviewOwnerId,
      this.docId,
      this.currentUserId,
      this.ownerId,
      this.index,
      this.reviewIndex,
      this.id,
      Key key})
      : super(key: key);

  @override
  _GrocItemReviewReplyState createState() => _GrocItemReviewReplyState();
}

class _GrocItemReviewReplyState extends State<GrocItemReviewReply> {
  TextEditingController replyController = TextEditingController();
  bool onTapTextfield = false;
  GroceryService _grocService = GroceryService();
  ActivityFeedService _activityFeedService = ActivityFeedService();
  AuthServcies _auth = AuthServcies();
  VideoPlayerController _videocontroller;
  ProgressDialog pr;
  bool isLoading = true;
  List<DocumentSnapshot> all = [];
  int maxLines = 1;
  List allReplays = [];
  String videoStatus = "okay";

  @override
  void initState() {
    super.initState();
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
                Text("Sending reply...",
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
    _grocService
        .getAllGrocItemsReviewReplys(
            widget.index, widget.docId, widget.reviewIndex)
        .then((value) {
      setState(() {
        allReplays = value;
      });
    });
    _auth.getAllUsers().then((allUser) {
      setState(() {
        all = allUser;
        isLoading = false;
      });
    });
  }

  checkVideoDurations(
    File video,
  ) async {
    _videocontroller = VideoPlayerController.file(video)
      ..initialize().then((_) {
        if (_videocontroller.value.duration.inSeconds > 300) {
          setState(() {
            videoStatus = "not_okay";
          });
          videoTrimDialog(
              _videocontroller.value.duration.inMinutes.toString(), video);
        } else {
          setState(() {
            videoStatus = "okay";
          });
        }
      });
  }

  videoTrimDialog(
    String duration,
    File video,
  ) {
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
                        media: video,
                      );
                    }));

                    if (trimmedVideo != null) {
                      Navigator.of(context, rootNavigator: true).pop();
                      pr.show();
                      await uploadMediaReply(trimmedVideo, "video");

                      pr.hide();
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

  uploadMediaReply(File upload, String type) async {
    List uploadMedia = [];
    if (type == "image") {
      String downUrl = await _grocService
          .uploadImageGroc(await compressImageFile(upload, 70));
      String thumbUrl = await _grocService
          .uploadImageGrocThumbnail(await compressImageFile(upload, 40));
      var obj = {
        "url": downUrl,
        "thumb": thumbUrl,
        "type": type,
      };
      uploadMedia.add(json.encode(obj));
    } else if (type == "video") {
      String downUrl =
          await _grocService.uploadVideoToGroc(await compressVideoFile(upload));
      String thumbUrl = await _grocService
          .uploadVideoToGrocThumb(await getThumbnailForVideo(upload));
      var obj = {
        "url": downUrl,
        "thumb": thumbUrl,
        "type": type,
      };
      uploadMedia.add(json.encode(obj));
    } else {
      String downUrl = await _grocService
          .uploadImageGroc(await compressImageFile(upload, 70));
      String thumbUrl = await _grocService
          .uploadImageGrocThumbnail(await compressImageFile(upload, 40));
      var obj = {
        "url": downUrl,
        "thumb": thumbUrl,
        "type": type,
      };
      uploadMedia.add(json.encode(obj));
    }

    await _grocService.addReplyToGroceryItemReview(widget.index, widget.docId,
        uploadMedia, widget.currentUserId, widget.reviewIndex, null);
    if (widget.currentUserId != widget.ownerId) {
      await _activityFeedService.createActivityFeed(
        widget.currentUserId,
        widget.ownerId,
        widget.docId,
        "review_reply",
        widget.index,
        widget.reviewIndex,
        allReplays.length,
      );
    }
  }

  chatMenu(context) {
    showModalBottomSheet(
        context: context,
        elevation: 0,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        builder: (context) {
          return Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  children: <Widget>[
                    FlatButton(
                      child: Icon(
                        Icons.close,
                      ),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Send media",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  children: <Widget>[
                    ModalTile(
                      title: "Camera",
                      subtitle: "Device camera captured",
                      icon: 'assets/icons/camera.png',
                      onTap: () async {
                        var status = await Permission.camera.status;
                        if (status.isUndetermined) {
                          var statusRe = await Permission.camera.request();

                          if (statusRe.isGranted) {
                            final pickedFile = await ImagePicker().getImage(
                              source: ImageSource.camera,
                            );
                            if (pickedFile != null) {
                              File croppedImage = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ImageCropper(
                                            image: File(pickedFile.path),
                                          )));

                              if (croppedImage != null) {
                                pr.show();
                                await uploadMediaReply(croppedImage, "image");

                                pr.hide();
                              } else {
                                pr.show();
                                await uploadMediaReply(
                                    File(pickedFile.path), "image");
                                pr.hide();
                              }
                            }
                          }
                        }

                        if (status.isGranted) {
                          final pickedFile = await ImagePicker().getImage(
                            source: ImageSource.camera,
                          );
                          if (pickedFile != null) {
                            File croppedImage = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ImageCropper(
                                          image: File(pickedFile.path),
                                        )));

                            if (croppedImage != null) {
                              pr.show();
                              await uploadMediaReply(croppedImage, "image");

                              pr.hide();
                            } else {
                              pr.show();
                              await uploadMediaReply(
                                  File(pickedFile.path), "image");

                              pr.hide();
                            }
                          }
                        } else {
                          var statusRe2 = await Permission.camera.request();
                          if (statusRe2.isGranted) {
                            final pickedFile = await ImagePicker().getImage(
                              source: ImageSource.camera,
                            );
                            if (pickedFile != null) {
                              File croppedImage = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ImageCropper(
                                            image: File(pickedFile.path),
                                          )));

                              if (croppedImage != null) {
                                pr.show();
                                await uploadMediaReply(croppedImage, "image");

                                pr.hide();
                              } else {
                                pr.show();
                                await uploadMediaReply(
                                    File(pickedFile.path), "image");

                                pr.hide();
                              }
                            }
                          }
                        }
                      },
                    ),
                    ModalTile(
                      title: "Video camera",
                      subtitle: "Device video-camera recorded",
                      icon: 'assets/icons/video-camera.png',
                      onTap: () async {
                        var status = await Permission.camera.status;
                        if (status.isUndetermined) {
                          var statusRe = await Permission.camera.request();

                          if (statusRe.isGranted) {
                            final pickedFile = await ImagePicker().getVideo(
                              source: ImageSource.camera,
                            );
                            if (pickedFile != null) {
                              await checkVideoDurations(File(pickedFile.path));

                              if (videoStatus == "okay") {
                                final Trimmer _trimmer = Trimmer();
                                await _trimmer.loadVideo(
                                    videoFile: File(pickedFile.path));

                                File trimmedVideo =
                                    await Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                  return VideoTrimmer(
                                    trimmer: _trimmer,
                                    media: File(pickedFile.path),
                                  );
                                }));
                                if (trimmedVideo != null) {
                                  pr.show();
                                  await uploadMediaReply(trimmedVideo, "video");

                                  pr.hide();
                                } else {
                                  pr.show();
                                  await uploadMediaReply(
                                      File(pickedFile.path), "video");

                                  pr.hide();
                                }
                              }
                            }
                          }
                        }

                        if (status.isGranted) {
                          final pickedFile = await ImagePicker().getVideo(
                            source: ImageSource.camera,
                          );
                          if (pickedFile != null) {
                            await checkVideoDurations(File(pickedFile.path));

                            if (videoStatus == "okay") {
                              final Trimmer _trimmer = Trimmer();
                              await _trimmer.loadVideo(
                                  videoFile: File(pickedFile.path));

                              File trimmedVideo = await Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return VideoTrimmer(
                                  trimmer: _trimmer,
                                  media: File(pickedFile.path),
                                );
                              }));
                              if (trimmedVideo != null) {
                                pr.show();
                                await uploadMediaReply(trimmedVideo, "video");
                                pr.hide();
                              } else {
                                pr.show();
                                await uploadMediaReply(
                                    File(pickedFile.path), "video");
                                pr.hide();
                              }
                            }
                          }
                        } else {
                          var statusRe2 = await Permission.camera.request();
                          if (statusRe2.isGranted) {
                            final pickedFile = await ImagePicker().getVideo(
                              source: ImageSource.camera,
                            );
                            if (pickedFile != null) {
                              await checkVideoDurations(File(pickedFile.path));

                              if (videoStatus == "okay") {
                                final Trimmer _trimmer = Trimmer();
                                await _trimmer.loadVideo(
                                    videoFile: File(pickedFile.path));

                                File trimmedVideo =
                                    await Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                  return VideoTrimmer(
                                    trimmer: _trimmer,
                                    media: File(pickedFile.path),
                                  );
                                }));
                                if (trimmedVideo != null) {
                                  pr.show();
                                  await uploadMediaReply(trimmedVideo, "video");
                                  pr.hide();
                                } else {
                                  pr.show();
                                  await uploadMediaReply(
                                      File(pickedFile.path), "video");
                                  pr.hide();
                                }
                              }
                            }
                          }
                        }
                      },
                    ),
                    ModalTile(
                      title: "Gallery",
                      subtitle: "Select media file from gallery",
                      icon: 'assets/icons/album.png',
                      onTap: () async {
                        var obj = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GalleryPick(
                                      isOnlyImage: false,
                                      isSingle: true,
                                      isPano: false,
                                    )));
                        if (obj != null) {
                          if (obj["type"] == "gallery") {
                            List<AssetEntity> assetentity = obj["mediaList"];

                            assetentity.forEach((element) {
                              element.file.then((value) async {
                                if (element.type.toString() ==
                                    "AssetType.image") {
                                  File croppedImage = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ImageCropper(
                                                image: value,
                                              )));

                                  if (croppedImage != null) {
                                    pr.show();
                                    await uploadMediaReply(
                                        croppedImage, "image");
                                    pr.hide();
                                  } else {
                                    pr.show();
                                    await uploadMediaReply(value, "image");

                                    pr.hide();
                                  }
                                } else {
                                  await checkVideoDurations(value);

                                  if (videoStatus == "okay") {
                                    final Trimmer _trimmer = Trimmer();
                                    await _trimmer.loadVideo(videoFile: value);

                                    File trimmedVideo = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) {
                                      return VideoTrimmer(
                                        trimmer: _trimmer,
                                        media: value,
                                      );
                                    }));
                                    if (trimmedVideo != null) {
                                      pr.show();
                                      await uploadMediaReply(
                                          trimmedVideo, "video");

                                      pr.hide();
                                    } else {
                                      pr.show();
                                      await uploadMediaReply(value, "video");

                                      pr.hide();
                                    }
                                  }
                                }
                              });
                            });
                          }
                          if (obj["type"] == "camPhoto") {
                            File croppedImage = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ImageCropper(
                                          image: File(obj["mediaFile"].path),
                                        )));

                            if (croppedImage != null) {
                              pr.show();
                              await uploadMediaReply(croppedImage, "image");

                              pr.hide();
                            } else {
                              pr.show();
                              await uploadMediaReply(
                                  File(obj["mediaFile"].path), "image");

                              pr.hide();
                            }
                          }

                          if (obj["type"] == "camVideo") {
                            await checkVideoDurations(
                                File(obj["mediaFile"].path));

                            if (videoStatus == "okay") {
                              final Trimmer _trimmer = Trimmer();
                              await _trimmer.loadVideo(
                                  videoFile: File(obj["mediaFile"].path));

                              File trimmedVideo = await Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return VideoTrimmer(
                                  trimmer: _trimmer,
                                  media: File(obj["mediaFile"].path),
                                );
                              }));
                              if (trimmedVideo != null) {
                                pr.show();
                                await uploadMediaReply(trimmedVideo, "video");

                                pr.hide();
                              } else {
                                pr.show();
                                await uploadMediaReply(
                                    File(obj["mediaFile"].path), "video");

                                pr.hide();
                              }
                            }
                          }
                        }
                      },
                    ),
                    ModalTile(
                      title: "Panaroma image",
                      subtitle: "Select 360 panaroma images",
                      icon: 'assets/icons/pana.png',
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
                          pr.show();
                          if (obj["type"] == "gallery") {
                            AssetEntity assetentity = obj["mediaList"][0];

                            assetentity.file.then((value) async {
                              await uploadMediaReply(value, "pano");

                              pr.hide();
                            });
                          } else {
                            AssetEntity assetentity = obj["mediaList"][0];

                            assetentity.file.then((value) async {
                              await uploadMediaReply(value, "pano");

                              pr.hide();
                            });
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
      resizeToAvoidBottomPadding: true,
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
          "Reply to " + widget.reviewOwner + " 's review",
          style: TextStyle(
              color: Colors.grey[700],
              fontFamily: "Roboto",
              fontSize: 18,
              fontWeight: FontWeight.w400),
        ),
      ),
      body: isLoading
          ? Container(
              color: Colors.white,
              child: Center(child: SpinKitCircle(color: Pallete.mainAppColor)),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: StreamBuilder(
                    stream: _grocService.streamSingleGrocery(widget.id),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                          color: Colors.white,
                          child: Center(
                              child:
                                  SpinKitCircle(color: Pallete.mainAppColor)),
                        );
                      }
                      if (snapshot.data.documents == null) {
                        return Center(
                            child: Image.asset(
                          'assets/icons/reply.png',
                          width: width * 0.3,
                          color: Colors.grey,
                        ));
                      } else if (snapshot.data.documents.length == 0) {
                        return Center(
                            child: Image.asset(
                          'assets/icons/reply.png',
                          width: width * 0.3,
                          color: Colors.grey,
                        ));
                      } else {
                        List replys = [];

                        Grocery groc =
                            Grocery.fromDocument(snapshot.data.documents[0]);

                        if (json.decode(groc.items[widget.index])["review"] !=
                            null) {
                          if (json.decode(groc.items[widget.index])["review"]
                                  [widget.reviewIndex]["replys"] !=
                              null) {
                            replys =
                                json.decode(groc.items[widget.index])["review"]
                                    [widget.reviewIndex]["replys"];
                          }
                        }

                        return replys.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: replys.length,
                                itemBuilder: (context, index) {
                                  return ReviewDisplay(
                                    currentUserId: widget.currentUserId,
                                    docId: widget.docId,
                                    feedService: _activityFeedService,
                                    height: height,
                                    id: widget.id,
                                    indexItem: widget.index,
                                    listIndex: index,
                                    obj: replys[index],
                                    owner: User.fromDocument(
                                      all.firstWhere(
                                          (e) =>
                                              e["id"] ==
                                              replys[index]["userId"],
                                          orElse: () => null),
                                    ),
                                    reviewOwnerId: widget.reviewOwnerId,
                                    groc: _grocService,
                                    reviewIndex: widget.reviewIndex,
                                    width: width,
                                    length: replys.length,
                                  );
                                })
                            : Center(
                                child: Image.asset(
                                'assets/icons/reply.png',
                                width: width * 0.3,
                                color: Colors.grey,
                              ));
                      }
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        if (onTapTextfield) {
                          setState(() {
                            onTapTextfield = false;
                          });
                        } else {
                          chatMenu(context);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(
                          2,
                        ),
                        decoration: new BoxDecoration(
                            color: Pallete.mainAppColor,
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(40.0),
                              topRight: const Radius.circular(40.0),
                              bottomLeft: const Radius.circular(40.0),
                              bottomRight: const Radius.circular(40.0),
                            )),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image(
                              image: AssetImage(
                                onTapTextfield
                                    ? 'assets/icons/up.png'
                                    : 'assets/icons/menu.png',
                              ),
                              height: 20,
                              width: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTapTextfield
                        ? SizedBox.shrink()
                        : SizedBox(
                            width: 5,
                          ),
                    onTapTextfield
                        ? SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(
                              right: 4.0,
                              top: 4.0,
                              bottom: 4.0,
                              left: 4.0,
                            ),
                            child: GestureDetector(
                              onTap: () async {
                                var obj = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GalleryPick(
                                              isOnlyImage: false,
                                              isSingle: true,
                                              isPano: false,
                                            )));
                                if (obj != null) {
                                  if (obj["type"] == "gallery") {
                                    List<AssetEntity> assetentity =
                                        obj["mediaList"];

                                    assetentity.forEach((element) {
                                      element.file.then((value) async {
                                        if (element.type.toString() ==
                                            "AssetType.image") {
                                          File croppedImage =
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ImageCropper(
                                                            image: value,
                                                          )));

                                          if (croppedImage != null) {
                                            pr.show();
                                            await uploadMediaReply(
                                                croppedImage, "image");

                                            pr.hide();
                                          } else {
                                            pr.show();
                                            await uploadMediaReply(
                                                value, "image");

                                            pr.hide();
                                          }
                                        } else {
                                          await checkVideoDurations(value);

                                          if (videoStatus == "okay") {
                                            final Trimmer _trimmer = Trimmer();
                                            await _trimmer.loadVideo(
                                                videoFile: value);

                                            File trimmedVideo =
                                                await Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                              return VideoTrimmer(
                                                trimmer: _trimmer,
                                                media: value,
                                              );
                                            }));
                                            if (trimmedVideo != null) {
                                              pr.show();
                                              await uploadMediaReply(
                                                  trimmedVideo, "video");

                                              pr.hide();
                                            } else {
                                              pr.show();
                                              await uploadMediaReply(
                                                  value, "video");

                                              pr.hide();
                                            }
                                          }
                                        }
                                      });
                                    });
                                  }
                                  if (obj["type"] == "camPhoto") {
                                    File croppedImage = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ImageCropper(
                                                  image: File(
                                                      obj["mediaFile"].path),
                                                )));

                                    if (croppedImage != null) {
                                      pr.show();
                                      await uploadMediaReply(
                                          croppedImage, "image");

                                      pr.hide();
                                    } else {
                                      pr.show();
                                      await uploadMediaReply(
                                          File(obj["mediaFile"].path), "image");

                                      pr.hide();
                                    }
                                  }

                                  if (obj["type"] == "camVideo") {
                                    await checkVideoDurations(
                                        File(obj["mediaFile"].path));

                                    if (videoStatus == "okay") {
                                      final Trimmer _trimmer = Trimmer();
                                      await _trimmer.loadVideo(
                                          videoFile:
                                              File(obj["mediaFile"].path));

                                      File trimmedVideo = await Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) {
                                        return VideoTrimmer(
                                          trimmer: _trimmer,
                                          media: File(obj["mediaFile"].path),
                                        );
                                      }));
                                      if (trimmedVideo != null) {
                                        pr.show();
                                        await uploadMediaReply(
                                            trimmedVideo, "video");

                                        pr.hide();
                                      } else {
                                        pr.show();
                                        await uploadMediaReply(
                                            File(obj["mediaFile"].path),
                                            "video");

                                        pr.hide();
                                      }
                                    }
                                  }
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(
                                  2,
                                ),
                                decoration: new BoxDecoration(
                                    color: Pallete.mainAppColor,
                                    borderRadius: new BorderRadius.only(
                                      topLeft: const Radius.circular(40.0),
                                      topRight: const Radius.circular(40.0),
                                      bottomLeft: const Radius.circular(40.0),
                                      bottomRight: const Radius.circular(40.0),
                                    )),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image(
                                      image: AssetImage(
                                        'assets/icons/album.png',
                                      ),
                                      height: 20,
                                      width: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      width: onTapTextfield ? width * 0.7 : width * 0.54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Color.fromRGBO(129, 165, 168, 1),
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
                        padding: const EdgeInsets.only(
                          left: 0,
                          bottom: 0,
                          top: 0,
                          right: 0,
                        ),
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          maxLines: maxLines == 1 ? null : maxLines,
                          autofocus: true,
                          maxLengthEnforced: true,
                          onChanged: (value) {
                            if (value.length > 100) {
                              setState(() {
                                maxLines = 5;
                              });
                            }

                            if (value.length < 10) {
                              setState(() {
                                maxLines = 1;
                                onTapTextfield = false;
                              });
                            } else {
                              setState(() {
                                onTapTextfield = true;
                              });
                            }
                          },
                          onTap: () {
                            setState(() {
                              onTapTextfield = true;
                            });
                          },
                          controller: replyController,
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                            fontSize: 19,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: "Type the reply",
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Color.fromRGBO(129, 165, 168, 1),
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (replyController.text.trim() != "") {
                          pr.show();
                          await _grocService.addReplyToGroceryItemReview(
                              widget.index,
                              widget.docId,
                              null,
                              widget.currentUserId,
                              widget.reviewIndex,
                              replyController.text.trim());
                          if (widget.currentUserId != widget.ownerId) {
                            await _activityFeedService.createActivityFeed(
                              widget.currentUserId,
                              widget.ownerId,
                              widget.docId,
                              "review_reply",
                              widget.index,
                              widget.reviewIndex,
                              allReplays.length,
                            );
                          }
                          setState(() {
                            replyController.clear();
                          });
                          pr.hide();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: new BoxDecoration(
                              color: Pallete.mainAppColor,
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(40.0),
                                topRight: const Radius.circular(40.0),
                                bottomLeft: const Radius.circular(40.0),
                                bottomRight: const Radius.circular(40.0),
                              ),
                              border: Border.all(
                                color: Colors.grey,
                                width: 5,
                              )),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image(
                              image: AssetImage(
                                'assets/icons/reply.png',
                              ),
                              color: Colors.white,
                              height: 50,
                              width: 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
    );
  }
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Function onTap;

  const ModalTile({
    @required this.title,
    @required this.subtitle,
    @required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        mini: false,
        onTap: onTap,
        leading: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), color: Colors.white),
          padding: EdgeInsets.all(10),
          child: Image.asset(
            icon,
            width: 38,
            height: 38,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class ReviewDisplay extends StatelessWidget {
  final obj;
  final String reviewOwnerId;
  final String id;
  final String docId;
  final User owner;
  final double width;
  final int indexItem;
  final double height;
  final String currentUserId;
  final int reviewIndex;
  final GroceryService groc;
  final int listIndex;
  final int length;
  final ActivityFeedService feedService;

  const ReviewDisplay(
      {this.obj,
      this.reviewOwnerId,
      this.id,
      this.docId,
      this.indexItem,
      this.currentUserId,
      this.width,
      this.height,
      this.owner,
      this.length,
      this.reviewIndex,
      this.groc,
      this.feedService,
      this.listIndex,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List replyMedia = [];
    List likes = [];
    List dislikes = [];

    if (obj["media"] != null) {
      replyMedia = obj["media"];
    }
    if (obj["reactions"] != null) {
      obj["reactions"].forEach((ele) {
        if (ele["reaction"] == "like") {
          likes.add(ele);
        }

        if (ele["reaction"] == "dislike") {
          dislikes.add(ele);
        }
      });
    }

    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 20,
            ),
            child: InkWell(
              onTap: () {},
              child: Row(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40.0),
                        border: Border.all(
                          color: Pallete.mainAppColor,
                          width: 3,
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Hero(
                        transitionOnUserGestures: true,
                        tag: owner.username + listIndex.toString(),
                        child: CircleAvatar(
                          maxRadius: 15,
                          backgroundColor: Color(0xffe0e0e0),
                          backgroundImage: owner.thumbnailUserPhotoUrl == null
                              ? AssetImage('assets/profilephoto.png')
                              : NetworkImage(owner.thumbnailUserPhotoUrl),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: <Widget>[
                      Text(owner.username,
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.black.withOpacity(0.7),
                              fontWeight: FontWeight.w500)),
                      Text(
                        timeago.format(DateTime.parse(obj["timestamp"])),
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  currentUserId == owner.id
                      ? Padding(
                          padding: EdgeInsets.only(
                            left: width * 0.4,
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              AwesomeDialog(
                                context: context,
                                animType: AnimType.SCALE,
                                dialogType: DialogType.NO_HEADER,
                                body: Center(
                                  child: Text(
                                    'Are you sure to continue?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                btnOkColor: Pallete.mainAppColor,
                                btnCancelColor: Pallete.mainAppColor,
                                btnOkText: 'Yes',
                                btnCancelText: 'No',
                                btnOkOnPress: () async {
                                  await groc.deleteGroceryItemReviewReply(
                                      indexItem, docId, reviewIndex, listIndex);
                                  await feedService.removeReviewReplyFromFeed(
                                      reviewOwnerId,
                                      owner.id,
                                      docId,
                                      indexItem,
                                      reviewIndex,
                                      listIndex);
                                  Fluttertoast.showToast(
                                      msg: "A review's reply removed",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      backgroundColor: Pallete.mainAppColor,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                },
                                btnCancelOnPress: () {},
                              )..show();
                            },
                            child: Image.asset(
                              'assets/icons/delete.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          replyMedia.isNotEmpty
              ? SizedBox(
                  height: height * 0.20,
                  child: ListView.builder(
                      itemCount: replyMedia.length,
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
                            child: json.decode(replyMedia[index])["type"] ==
                                    "image"
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NetworkFileFullScreen(
                                                    url: json.decode(
                                                            replyMedia[index])[
                                                        "url"],
                                                    type: "image",
                                                  )));
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: FancyShimmerImage(
                                        imageUrl: json
                                            .decode(replyMedia[index])["thumb"],
                                        boxFit: BoxFit.cover,
                                        shimmerBackColor: Color(0xffe0e0e0),
                                        shimmerBaseColor: Color(0xffe0e0e0),
                                        shimmerHighlightColor: Colors.grey[200],
                                      ),
                                    ),
                                  )
                                : json.decode(replyMedia[index])["type"] ==
                                        "video"
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Stack(
                                          children: <Widget>[
                                            FancyShimmerImage(
                                              imageUrl: json.decode(
                                                  replyMedia[index])["thumb"],
                                              boxFit: BoxFit.cover,
                                              shimmerBackColor:
                                                  Color(0xffe0e0e0),
                                              shimmerBaseColor:
                                                  Color(0xffe0e0e0),
                                              shimmerHighlightColor:
                                                  Colors.grey[200],
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            NetworkFileFullScreen(
                                                              url: json.decode(
                                                                      replyMedia[
                                                                          index])[
                                                                  "url"],
                                                              type: "video",
                                                            )));
                                              },
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Image.asset(
                                                  'assets/icons/play.png',
                                                  color: Colors.white,
                                                  width: 60,
                                                  height: 60,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: width * 0.3,
                                              height: height * 0.15,
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      NetworkFileFullScreen(
                                                        url: json.decode(
                                                            replyMedia[
                                                                index])["url"],
                                                        type: "pano",
                                                      )));
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Stack(
                                            children: <Widget>[
                                              FancyShimmerImage(
                                                imageUrl: json.decode(
                                                    replyMedia[index])["thumb"],
                                                boxFit: BoxFit.cover,
                                                shimmerBackColor:
                                                    Color(0xffe0e0e0),
                                                shimmerBaseColor:
                                                    Color(0xffe0e0e0),
                                                shimmerHighlightColor:
                                                    Colors.grey[200],
                                              ),
                                              Container(
                                                width: width * 0.3,
                                                height: height * 0.20,
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                              ),
                                              Align(
                                                alignment: Alignment.center,
                                                child: Animator(
                                                  duration: Duration(
                                                      milliseconds: 2000),
                                                  tween: Tween(
                                                      begin: 1.2, end: 1.3),
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
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                          ),
                        );
                      }),
                )
              : Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: ReadMoreText(
                    obj["reply"],
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    trimLines: 6,
                    colorClickableText: Pallete.mainAppColor,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: '...Show more',
                    trimExpandedText: ' show less',
                  ),
                ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      await groc.setReactionGrocItemToReviewReply(indexItem,
                          docId, currentUserId, reviewIndex, listIndex, "like");
                      if (currentUserId != owner.id) {
                        await feedService.createActivityFeed(
                          currentUserId,
                          owner.id,
                          docId,
                          "review_reply_like",
                          indexItem,
                          reviewIndex,
                          listIndex,
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: obj["reactions"] == null
                              ? null
                              : obj["reactions"].firstWhere(
                                              (element) =>
                                                  element["userId"] ==
                                                  currentUserId,
                                              orElse: () => null) !=
                                          null &&
                                      obj["reactions"][obj["reactions"]
                                              .indexWhere((element) =>
                                                  element["userId"] ==
                                                  currentUserId)]["reaction"] ==
                                          "like"
                                  ? Pallete.mainAppColor
                                  : null,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: obj["reactions"] == null
                                ? Colors.black
                                : obj["reactions"].firstWhere(
                                                (element) =>
                                                    element["userId"] ==
                                                    currentUserId,
                                                orElse: () => null) !=
                                            null &&
                                        obj["reactions"][obj["reactions"]
                                                    .indexWhere((element) =>
                                                        element["userId"] ==
                                                        currentUserId)]
                                                ["reaction"] ==
                                            "like"
                                    ? Pallete.mainAppColor
                                    : Colors.black,
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/icons/thumbup.png',
                          width: 20,
                          height: 20,
                          color: obj["reactions"] == null
                              ? null
                              : obj["reactions"].firstWhere(
                                              (element) =>
                                                  element["userId"] ==
                                                  currentUserId,
                                              orElse: () => null) !=
                                          null &&
                                      obj["reactions"][obj["reactions"]
                                              .indexWhere((element) =>
                                                  element["userId"] ==
                                                  currentUserId)]["reaction"] ==
                                          "like"
                                  ? Colors.white
                                  : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(obj["reactions"] == null
                      ? 0.toString() + " likes"
                      : likes.length.toString() + " likes"),
                ],
              ),
              Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      await groc.setReactionGrocItemToReviewReply(
                          indexItem,
                          docId,
                          currentUserId,
                          reviewIndex,
                          listIndex,
                          "dislike");
                      if (currentUserId != owner.id) {
                        await feedService.createActivityFeed(
                          currentUserId,
                          owner.id,
                          docId,
                          "review_reply_dislike",
                          indexItem,
                          reviewIndex,
                          listIndex,
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: obj["reactions"] == null
                              ? null
                              : obj["reactions"].firstWhere(
                                              (element) =>
                                                  element["userId"] ==
                                                  currentUserId,
                                              orElse: () => null) !=
                                          null &&
                                      obj["reactions"][obj["reactions"]
                                              .indexWhere((element) =>
                                                  element["userId"] ==
                                                  currentUserId)]["reaction"] ==
                                          "dislike"
                                  ? Colors.red
                                  : null,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: obj["reactions"] == null
                                ? Colors.black
                                : obj["reactions"].firstWhere(
                                                (element) =>
                                                    element["userId"] ==
                                                    currentUserId,
                                                orElse: () => null) !=
                                            null &&
                                        obj["reactions"][obj["reactions"]
                                                    .indexWhere((element) =>
                                                        element["userId"] ==
                                                        currentUserId)]
                                                ["reaction"] ==
                                            "dislike"
                                    ? Colors.red
                                    : Colors.black,
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/icons/thumbdown.png',
                          width: 20,
                          height: 20,
                          color: obj["reactions"] == null
                              ? null
                              : obj["reactions"].firstWhere(
                                              (element) =>
                                                  element["userId"] ==
                                                  currentUserId,
                                              orElse: () => null) !=
                                          null &&
                                      obj["reactions"][obj["reactions"]
                                              .indexWhere((element) =>
                                                  element["userId"] ==
                                                  currentUserId)]["reaction"] ==
                                          "dislike"
                                  ? Colors.white
                                  : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(obj["reactions"] == null
                      ? 0.toString() + " dislikes"
                      : dislikes.length.toString() + " dislikes"),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          listIndex != length - 1
              ? Divider(
                  color: Colors.black.withOpacity(0.1),
                  thickness: 2.0,
                )
              : SizedBox.shrink(),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
