import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'landscape_videoplayer_controller.dart';

class NetworkPlayer extends StatefulWidget {
  final String url;
  NetworkPlayer({this.url, Key key}) : super(key: key);

  @override
  _NetworkPlayerState createState() => _NetworkPlayerState();
}

class _NetworkPlayerState extends State<NetworkPlayer> {
  FlickManager flickManager;
  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlickVideoPlayer(
        flickManager: flickManager,
        preferredDeviceOrientation: [
          DeviceOrientation.portraitDown,
          DeviceOrientation.portraitUp
        ],
        systemUIOverlay: [],
        flickVideoWithControls: FlickVideoWithControls(
          controls: LandscapePlayerControls(
            fontSize: 20,
            iconSize: 30,
          ),
        ),
      ),
    );
  }
}
