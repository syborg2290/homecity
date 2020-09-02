import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearby/models/grocery.dart';
import 'package:nearby/services/grocery_service.dart';
import 'package:nearby/utils/compress_media.dart';
import 'package:nearby/utils/full_screen_network_file.dart';
import 'package:nearby/utils/image_cropper.dart';
import 'package:nearby/utils/media_picker/gallery_pick.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/utils/video_trimmer.dart';
import 'package:nearby/utils/videoplayers/fileVideoPlayer.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';

class GroceryGallery extends StatefulWidget {
  final String currentUserId;
  final String docid;
  final String id;
  final String groceryOwnerId;
  GroceryGallery(
      {this.currentUserId, this.docid, this.id, this.groceryOwnerId, Key key})
      : super(key: key);

  @override
  _GroceryGalleryState createState() => _GroceryGalleryState();
}

class _GroceryGalleryState extends State<GroceryGallery> {
  VideoPlayerController _videocontroller;
  GroceryService _groceryService = GroceryService();
  ProgressDialog pr;
  String status = "okay";

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
                Text("Updating gallery...",
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

  uploadMediaReply(File upload, String type) async {
    if (type == "image") {
      String downUrl = await _groceryService
          .uploadImageGroc(await compressImageFile(upload, 70));
      String thumbUrl = await _groceryService
          .uploadImageGrocThumbnail(await compressImageFile(upload, 40));
      var obj = {
        "url": downUrl,
        "thumb": thumbUrl,
        "type": "image",
        "ownerId": widget.currentUserId,
      };

      await _groceryService.updateGroceryGallery(
        widget.docid,
        json.encode(obj),
      );
    } else {
      String downUrl = await _groceryService
          .uploadVideoToGroc(await compressVideoFile(upload));
      String thumbUrl = await _groceryService
          .uploadVideoToGrocThumb(await getThumbnailForVideo(upload));
      var obj = {
        "url": downUrl,
        "thumb": thumbUrl,
        "type": "video",
        "ownerId": widget.currentUserId,
      };

      await _groceryService.updateGroceryGallery(
        widget.docid,
        json.encode(obj),
      );
    }
  }

  checkVideoDurations(
    File video,
  ) async {
    _videocontroller = VideoPlayerController.file(video)
      ..initialize().then((_) {
        if (_videocontroller.value.duration.inSeconds > 300) {
          setState(() {
            status = "not_okay";
          });
          videoTrimDialog(
              _videocontroller.value.duration.inMinutes.toString(), video);
        } else {
          setState(() {
            status = "okay";
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
                                isSingle: true,
                                isPano: false,
                              )));
                  if (obj != null) {
                    if (obj["type"] == "gallery") {
                      List<AssetEntity> assetentity = obj["mediaList"];

                      assetentity.forEach((element) {
                        element.file.then((value) async {
                          if (element.type.toString() == "AssetType.image") {
                            File croppedImage = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ImageCropper(
                                          image: value,
                                        )));

                            if (croppedImage != null) {
                              pr.show();
                              await uploadMediaReply(croppedImage, "image");
                              pr.hide();
                            } else {
                              pr.show();
                              await uploadMediaReply(value, "image");

                              pr.hide();
                            }
                          } else {
                            await checkVideoDurations(value);

                            if (status == "okay") {
                              final Trimmer _trimmer = Trimmer();
                              await _trimmer.loadVideo(videoFile: value);

                              File trimmedVideo = await Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return VideoTrimmer(
                                  trimmer: _trimmer,
                                  media: value,
                                );
                              }));
                              if (trimmedVideo != null) {
                                pr.show();
                                await uploadMediaReply(trimmedVideo, "video");

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
                      await checkVideoDurations(File(obj["mediaFile"].path));

                      if (status == "okay") {
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
                }),
          )
        ],
      ),
      body: StreamBuilder(
        stream: _groceryService.streamSingleGrocery(widget.id),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: SpinKitCircle(color: Pallete.mainAppColor));
          } else if (snapshot.data.documents == null) {
            return Center(child: SpinKitCircle(color: Pallete.mainAppColor));
          } else if (snapshot.data.documents.length == 0) {
            return Center(child: SpinKitCircle(color: Pallete.mainAppColor));
          } else {
            Grocery restSnap = Grocery.fromDocument(snapshot.data.documents[0]);
            List gallery = [];
            if (restSnap.gallery != null) {
              gallery = restSnap.gallery;
            }

            return gallery.isEmpty
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset(
                      'assets/icons/album.png',
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ))
                : GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    children: List.generate(gallery.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NetworkFileFullScreen(
                                        url: json.decode(gallery[index])["url"],
                                        type:
                                            json.decode(gallery[index])["type"],
                                      )));
                        },
                        child: Stack(
                          children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: json.decode(
                                                gallery[index])["type"] ==
                                            "image"
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: FancyShimmerImage(
                                              imageUrl: json.decode(
                                                  gallery[index])["thumb"],
                                              boxFit: BoxFit.cover,
                                              shimmerBackColor:
                                                  Color(0xffe0e0e0),
                                              shimmerBaseColor:
                                                  Color(0xffe0e0e0),
                                              shimmerHighlightColor:
                                                  Colors.grey[200],
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Stack(
                                              children: <Widget>[
                                                FancyShimmerImage(
                                                  imageUrl: json.decode(
                                                      gallery[index])["thumb"],
                                                  boxFit: BoxFit.cover,
                                                  shimmerBackColor:
                                                      Color(0xffe0e0e0),
                                                  shimmerBaseColor:
                                                      Color(0xffe0e0e0),
                                                  shimmerHighlightColor:
                                                      Colors.grey[200],
                                                ),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Image.asset(
                                                    'assets/icons/play.png',
                                                    color: Colors.white,
                                                    width: 60,
                                                    height: 60,
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ))),
                            widget.currentUserId == widget.groceryOwnerId ||
                                    widget.currentUserId ==
                                        json.decode(gallery[index])["ownerId"]
                                ? Align(
                                    alignment: Alignment.topRight,
                                    child: GestureDetector(
                                      onTap: () async {
                                        await _groceryService
                                            .deleteGroceryGalleryMedia(
                                                index, widget.docid);
                                        Fluttertoast.showToast(
                                            msg: "Gallery item removed",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            backgroundColor:
                                                Pallete.mainAppColor,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                      },
                                      child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.8),
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset(
                                              'assets/icons/delete.png',
                                              color: Colors.white,
                                            ),
                                          )),
                                    ),
                                  )
                                : SizedBox.shrink()
                          ],
                        ),
                      );
                    }));
          }
        },
      ),
    );
  }
}
