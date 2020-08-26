import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:video_trimmer/trim_editor.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:video_trimmer/video_viewer.dart';

class VideoTrimmer extends StatefulWidget {
  final Trimmer trimmer;
  final File media;

  VideoTrimmer({this.trimmer, this.media, Key key}) : super(key: key);

  @override
  _VideoTrimmerState createState() => _VideoTrimmerState();
}

class _VideoTrimmerState extends State<VideoTrimmer> {
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  bool _progressVisibility = false;

  @override
  void initState() {
    super.initState();
  }

  Future<String> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String _value;

    await widget.trimmer
        .saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
    )
        .then((value) {
      setState(() {
        _progressVisibility = false;
        _value = value;
      });
    });

    return _value;
  }

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
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                border: Border.all(
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.all(Radius.circular(height * 0.09))),
            child: IconButton(
                icon: Image.asset(
                  'assets/icons/close.png',
                  width: width * 0.07,
                  height: height * 0.07,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                AspectRatio(
                    aspectRatio: 12 / 16,
                    child: Stack(
                      children: <Widget>[
                        VideoViewer(),
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                border: Border.all(
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(height * 0.09))),
                            child: Visibility(
                              visible: _progressVisibility,
                              child: Center(
                                  child: SpinKitCircle(
                                      color: Pallete.mainAppColor)),
                            ),
                          ),
                        ),
                      ],
                    )),
                Center(
                  child: TrimEditor(
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    onChangeStart: (value) {
                      _startValue = value;
                    },
                    onChangeEnd: (value) {
                      _endValue = value;
                    },
                    onChangePlaybackState: (value) {
                      if (!mounted) {
                        return;
                      }
                      setState(() {
                        _isPlaying = value;
                      });
                    },
                  ),
                ),
                FlatButton(
                  child: _isPlaying
                      ? Icon(
                          Icons.pause,
                          size: 80.0,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.play_arrow,
                          size: 80.0,
                          color: Colors.white,
                        ),
                  onPressed: () async {
                    bool playbackState =
                        await widget.trimmer.videPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    if (!mounted) {
                      return;
                    }
                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _progressVisibility
            ? null
            : () async {
                String outputPath = await _saveVideo();

                if (File(outputPath).existsSync()) {
                  Navigator.pop(context, File(outputPath));
                }
              },
        backgroundColor: Pallete.mainAppColor,
        child: Image.asset(
          'assets/icons/cut.png',
          width: width * 0.07,
          height: height * 0.07,
          color: Colors.white,
        ),
      ),
    );
  }
}
