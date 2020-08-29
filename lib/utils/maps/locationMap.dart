import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:location/location.dart' as lo;
import 'dart:ui' as ui;

import 'package:permission_handler/permission_handler.dart';

class LocationMap extends StatefulWidget {
  final List<double> locationCoord;
  final bool isFromFeed;
  LocationMap({this.locationCoord, this.isFromFeed, Key key}) : super(key: key);

  @override
  _LocationMapState createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  GoogleMapController _controller;
  MapType _currentType = MapType.normal;
  LatLng _center;
  Set<Marker> _markers = Set();
  LatLng _lastMapPosition;
  lo.Location _locationTracker = lo.Location();
  double latitude;
  double longitude;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    if (widget.locationCoord != null) {
      if (!mounted) return;
      setState(() {
        _center = LatLng(widget.locationCoord[0], widget.locationCoord[1]);
        _lastMapPosition =
            LatLng(widget.locationCoord[0], widget.locationCoord[1]);

        latitude = widget.locationCoord[0];
        longitude = widget.locationCoord[1];
        isLoading = false;
      });
    } else {
      Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .then((position) {
        if (!mounted) return;
        setState(() {
          _center = LatLng(position.latitude, position.longitude);
          _lastMapPosition = LatLng(position.latitude, position.longitude);

          latitude = position.latitude;
          longitude = position.longitude;
          isLoading = false;
        });
      });
    }
  }

  changeMapMode() {
    getJsonFile('assets/json/map_style.json').then(setMapStyle);
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void setMapStyle(String mapStyle) {
    _controller.setMapStyle(mapStyle);
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  setCoord() async {
    // _locationTracker.getLocation().then((value) {
    //   if (!mounted) return;
    //   setState(() {});
    // });

    changeMapMode();
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/icons/dot.png', 100);
    _markers.add(
      Marker(
        markerId: MarkerId("location1"),
        position: LatLng(latitude, longitude),
        // rotation: newLocalData.heading,
        icon: BitmapDescriptor.fromBytes(markerIcon),
        flat: true,
        anchor: Offset(1.0, 1.0),
        zIndex: 2,
        draggable: true,
        onDragEnd: (value) {
          setState(() {
            latitude = value.latitude;
            longitude = value.longitude;
            _lastMapPosition = LatLng(value.latitude, value.longitude);
          });
        },
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  checkLocationPermission() async {
    var statusIn = await Permission.locationWhenInUse.status;
    if (statusIn.isUndetermined) {
      var statusInRe = await Permission.locationWhenInUse.request();
      if (statusInRe.isGranted) {}
    }

    if (statusIn.isGranted) {
    } else {
      var statusReIn2 = await Permission.locationWhenInUse.request();
      if (statusReIn2.isGranted) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var orientation = MediaQuery.of(context).orientation;

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
                color: Colors.black.withOpacity(0.5),
                border: Border.all(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.all(Radius.circular(60))),
            child: IconButton(
                icon: Image.asset(
                  'assets/icons/left-arrow.png',
                  width: width * 0.07,
                  height: height * 0.07,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
        ),
        actions: <Widget>[
          widget.isFromFeed
              ? SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                    onPressed: () {
                      List<double> locationCoord = [];
                      locationCoord.add(latitude);
                      locationCoord.add(longitude);
                      Navigator.pop(context, locationCoord);
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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: SpinKitDoubleBounce(
                color: Pallete.mainAppColor,
                size: 60,
              ),
            )
          : Stack(
              children: <Widget>[
                GoogleMap(
                  mapType: _currentType,
                  compassEnabled: false,
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                      target: _center, bearing: 0.0, tilt: 10, zoom: 8.0),
                  markers: _markers,
                  onCameraMove: _onCameraMove,
                  onMapCreated: (controller) async {
                    _controller = controller;
                    await checkLocationPermission();
                    await setCoord();
                    // await updateLocation();
                  },
                  buildingsEnabled: true,
                  myLocationButtonEnabled: true,
                  trafficEnabled: true,
                  rotateGesturesEnabled: true,
                  indoorViewEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  mapToolbarEnabled: false,
                ),
              ],
            ),
    );
  }
}
