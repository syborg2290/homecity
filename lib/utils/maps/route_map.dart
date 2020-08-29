import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as lo;
import 'package:nearby/config/settings.dart';
import 'dart:ui' as ui;

import 'package:nearby/utils/pallete.dart';
import 'package:permission_handler/permission_handler.dart';

class RouteMap extends StatefulWidget {
  final double longitude;
  final double latitude;
  RouteMap({this.longitude, this.latitude, Key key}) : super(key: key);

  @override
  _RouteMapState createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  GoogleMapController _controller;
  MapType _currentType = MapType.normal;
  LatLng _center;
  Set<Marker> _markers = Set();
  LatLng _lastMapPosition;
  StreamSubscription _locationSubscription;
  lo.Location _locationTracker = lo.Location();
  Set<Polyline> _polylines = Set();
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  double latitude;
  double longitude;
  bool isLoading = true;
  Set<Circle> circles = Set();
  double total_distance = 0.0;
  double current_speed = 0.0;
  double totalTime = 0.0;

  @override
  void initState() {
    super.initState();

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

  setInitialMarker(double latitude, double longitude) async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/icons/user_location.png', 150);

    final Uint8List markerShopIcon =
        await getBytesFromAsset('assets/icons/dot.png', 100);

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("location0"),
          position: LatLng(latitude, longitude),
          // rotation: newLocalData.heading,
          icon: BitmapDescriptor.fromBytes(markerIcon),
          flat: true,
          anchor: Offset(1.0, 1.0),
          zIndex: 2,
          draggable: false,
        ),
      );

      _markers.add(
        Marker(
          markerId: MarkerId("location3"),
          position: LatLng(widget.latitude, widget.longitude),
          // rotation: newLocalData.heading,
          icon: BitmapDescriptor.fromBytes(markerShopIcon),
          flat: true,
          anchor: Offset(1.0, 1.0),
          zIndex: 2,
          draggable: false,
        ),
      );
    });
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
    changeMapMode();
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/icons/user_location.png', 150);
    final Uint8List markerShopIcon =
        await getBytesFromAsset('assets/icons/dot.png', 100);
    try {
      _locationTracker.getLocation().then((value) async {
        setState(() {});
      });

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }
      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) async {
        if (_controller != null) {
          var _distanceInMeters = await Geolocator().distanceBetween(
            widget.latitude,
            widget.longitude,
            newLocalData.latitude,
            newLocalData.longitude,
          );

          var geolocator = Geolocator();
          var options = LocationOptions(
              accuracy: LocationAccuracy.high, distanceFilter: 10);

          geolocator.getPositionStream(options).listen((position) {
            var speedInMps = position.speed; // this is your speed
            if (!mounted) {
              return; // Just do nothing if the widget is disposed.
            }
            setState(() {
              current_speed = speedInMps * 3.6;
              totalTime = ((_distanceInMeters / speedInMps)).toDouble();
            });
          });
          if (!mounted) {
            return; // Just do nothing if the widget is disposed.
          }
          setState(() {
            total_distance = _distanceInMeters;
            _markers.add(Marker(
              markerId: MarkerId("location1"),
              position: LatLng(newLocalData.latitude, newLocalData.longitude),
              // rotation: newLocalData.heading,
              icon: BitmapDescriptor.fromBytes(markerIcon),
              flat: true,
              anchor: Offset(1.0, 1.0),
              zIndex: 2,
              draggable: false,
            ));

            _markers.add(
              Marker(
                markerId: MarkerId("location2"),
                position: LatLng(widget.latitude, widget.longitude),
                // rotation: newLocalData.heading,
                icon: BitmapDescriptor.fromBytes(markerShopIcon),
                flat: true,
                anchor: Offset(1.0, 1.0),
                zIndex: 2,
                draggable: false,
                infoWindow: InfoWindow(
                  title: (total_distance / 1000).round() < 1
                      ? ((total_distance).round()).toString() +
                          " M away from your location"
                      : ((total_distance / 1000).round()).toString() +
                          " km away from your location",
                ),
              ),
            );

            circles.add(Circle(
              circleId: CircleId("circle111"),
              center: LatLng(newLocalData.latitude, newLocalData.longitude),
              strokeColor: Colors.yellow,
              zIndex: 1,
              fillColor: Colors.blue.withAlpha(70),
              radius: newLocalData.accuracy,
            ));
          });
          await setPolylines(newLocalData.latitude, newLocalData.longitude,
              widget.latitude, widget.longitude);
        }
      });

      var _distanceInMeters2 = await Geolocator().distanceBetween(
        widget.latitude,
        widget.longitude,
        latitude,
        longitude,
      );
      setState(() {
        total_distance = _distanceInMeters2;
        _markers.add(Marker(
          markerId: MarkerId("location0"),
          position: LatLng(latitude, longitude),
          // rotation: newLocalData.heading,
          icon: BitmapDescriptor.fromBytes(markerIcon),
          flat: true,
          anchor: Offset(1.0, 1.0),
          zIndex: 2,
          draggable: false,
        ));

        _markers.add(
          Marker(
            markerId: MarkerId("location3"),
            position: LatLng(widget.latitude, widget.longitude),
            // rotation: newLocalData.heading,
            icon: BitmapDescriptor.fromBytes(markerShopIcon),
            flat: true,
            anchor: Offset(1.0, 1.0),
            zIndex: 2,
            draggable: false,
            infoWindow: InfoWindow(
              title: (total_distance / 1000).round() < 1
                  ? ((total_distance).round()).toString() +
                      " M away from your location"
                  : ((total_distance / 1000).round()).toString() +
                      " km away from your location",
            ),
          ),
        );
      });
      await setPolylines(
          latitude, longitude, widget.latitude, widget.longitude);
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        print("permission denied");
      }
    }
  }

  setPolylines(double _originLatitude, double _originLongitude,
      double _destLatitude, double _destLongitude) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      GoogleServiceApi,
      PointLatLng(_originLatitude, _originLongitude),
      PointLatLng(_destLatitude, _destLongitude),
      avoidFerries: false,
      avoidHighways: false,
      avoidTolls: false,

      // travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    Polyline polyline = Polyline(
      polylineId: PolylineId("poly1"),
      color: Colors.red,
      points: polylineCoordinates,
      width: 5,
      geodesic: true,
    );
    if (!mounted) {
      return; // Just do nothing if the widget is disposed.
    }
    setState(() {
      _polylines.add(polyline);
    });
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
                  },
                  polylines: _polylines,
                  circles: circles,
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
