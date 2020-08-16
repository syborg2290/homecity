import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby/utils/videoplayers/landscape_videoplayer_controller.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class NetworkFileFullScreen extends StatefulWidget {
  final String url;
  final String type;
  NetworkFileFullScreen({this.url, this.type, Key key}) : super(key: key);

  @override
  _NetworkFileFullScreenState createState() => _NetworkFileFullScreenState();
}

class _NetworkFileFullScreenState extends State<NetworkFileFullScreen> {
  FlickManager flickManager;

  @override
  void initState() {
    super.initState();

    if (widget.type == "video") {
      flickManager = FlickManager(
          videoPlayerController: VideoPlayerController.network(
            widget.url,
          ),
          autoPlay: true,
          autoInitialize: true,
          onVideoEnd: () {
            setState(() {
              flickManager.flickControlManager.replay();
            });
          });
    }
  }

  @override
  void dispose() {
    if (widget.type == "video") {
      flickManager.dispose();
    }

    super.dispose();
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
                  borderRadius:
                      BorderRadius.all(Radius.circular(height * 0.09))),
              child: IconButton(
                  icon: Image.asset(
                    'assets/icons/left-arrow.png',
                    width: width * 0.07,
                    height: height * 0.07,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    SystemChrome.setEnabledSystemUIOverlays(
                        SystemUiOverlay.values);
                    SystemChrome.setPreferredOrientations(
                        [DeviceOrientation.portraitUp]);
                    Navigator.pop(context);
                  }),
            ),
          ),
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: widget.type == "image"
            ? Center(
                child: AspectRatio(
                    aspectRatio: 11 / 16,
                    child: PhotoView(
                      imageProvider: NetworkImage(widget.url),
                    )),
              )
            : Container(
                child: FlickVideoPlayer(
                  flickManager: flickManager,
                  preferredDeviceOrientation: [
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.landscapeRight,
                  ],
                  systemUIOverlay: [],
                  flickVideoWithControls: FlickVideoWithControls(
                    controls: LandscapePlayerControls(),
                  ),
                ),
              ));
  }
}
