import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:simple_image_crop/simple_image_crop.dart';

class ImageCropper extends StatefulWidget {
  final File image;
  ImageCropper({this.image, Key key}) : super(key: key);

  @override
  _ImageCropperState createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  final imgCropKey = GlobalKey<ImgCropState>();

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
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8, top: 5),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                border: Border.all(
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.all(Radius.circular(height * 0.1))),
            child: IconButton(
                icon: Image.asset(
                  'assets/icons/close.png',
                  width: width * 0.08,
                  height: height * 0.08,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        color: Colors.black,
        child: ImgCrop(
          key: imgCropKey,
          chipRadius: 150, // crop area radius
          chipShape: 'rect', // crop type "circle" or "rect"
          image: FileImage(widget.image), // you selected image file
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final crop = imgCropKey.currentState;
          File croppedFile =
              await crop.cropCompleted(widget.image, pictureQuality: 900);
          Navigator.pop(context, croppedFile);
        },
        backgroundColor: Pallete.mainAppColor,
        child: Image.asset(
          'assets/icons/crop.png',
          width: width * 0.07,
          height: height * 0.07,
          color: Colors.white,
        ),
      ),
    );
  }
}
