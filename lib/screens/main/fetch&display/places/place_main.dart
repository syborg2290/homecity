import 'dart:math';
import 'package:animator/animator.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_utils/poly_utils.dart';
import 'package:nearby/models/place.dart';
import 'package:nearby/screens/main/fetch&display/places/place_details_page.dart';
import 'package:nearby/screens/main/fetch&display/places/place_filter.dart';
import 'package:nearby/screens/main/fetch&display/places/place_serach.dart';
import 'package:nearby/screens/main/sub/place/place_type.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/services/bookmark_service.dart';
import 'package:nearby/services/place_service.dart';
import 'package:nearby/utils/maps/route_map.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/utils/rate_algorithm.dart';

class PlaceMainView extends StatefulWidget {
  PlaceMainView({Key key}) : super(key: key);

  @override
  _PlaceMainViewState createState() => _PlaceMainViewState();
}

class _PlaceMainViewState extends State<PlaceMainView> {
  PlaceService _placeService = PlaceService();
  AuthServcies _auth = AuthServcies();
  BookmarkService _bookmarkService = BookmarkService();
  Geodesy geodesy = Geodesy();
  List<Point> polygon = [];
  bool isLoading = true;
  String currentUserId;
  double currentLatitude;
  double currentLongitude;

  @override
  void initState() {
    super.initState();

    _auth.getCurrentUser().then((fUser) {
      setState(() {
        currentUserId = fUser.uid;
      });
    });
    getCurrentLocation();
  }

  getCurrentLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    List<Placemark> list = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    for (var i = 0; i <= 360; i++) {
      LatLng distinationPoint = geodesy.destinationPointByDistanceAndBearing(
          LatLng(position.latitude, position.longitude), 30000, i.toDouble());
      setState(() {
        polygon
            .add(Point(distinationPoint.latitude, distinationPoint.longitude));
      });
    }

    setState(() {
      currentLatitude = position.latitude;
      currentLongitude = position.longitude;
      isLoading = false;
    });
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
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          "Places",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 20,
          ),
        ),
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
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              right: 20,
              bottom: 10,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PlaceSearch(
                              currentUserId: currentUserId,
                            )));
              },
              child: Icon(
                Icons.search,
                size: 40,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 20,
              bottom: 10,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PlaceFilterPage()));
              },
              child: Image.asset(
                'assets/icons/filter.png',
                width: 30,
                height: 30,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 20,
              bottom: 10,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PlaceType()));
              },
              child: Image.asset(
                'assets/icons/plus.png',
                width: 30,
                height: 30,
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Container(
              color: Colors.white,
              child: Center(child: SpinKitCircle(color: Pallete.mainAppColor)),
            )
          : StreamBuilder(
              stream: _placeService.streamPlaces(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    color: Colors.white,
                    child: Center(
                        child: SpinKitCircle(color: Pallete.mainAppColor)),
                  );
                }
                if (snapshot.data.documents == null) {
                  return Center(
                      child: Column(
                    children: [
                      Image.asset(
                        'assets/icons/place.png',
                        width: width * 0.7,
                        color: Colors.grey,
                      ),
                      Text(
                        "Places not available yet",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey,
                            fontFamily: "Roboto",
                            fontSize: 25,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ));
                } else if (snapshot.data.documents.length == 0) {
                  return Center(
                      child: Column(
                    children: [
                      Image.asset(
                        'assets/icons/place.png',
                        width: width * 0.7,
                        color: Colors.grey,
                      ),
                      Text(
                        "Places not available yet",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey,
                            fontFamily: "Roboto",
                            fontSize: 25,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ));
                } else {
                  List<Place> allPlaces = [];
                  List allDocId = [];
                  List<Place> nearbyPlaces = [];
                  List nearbyDocId = [];

                  List<Place> topRatedPlace = [];
                  List topRatedDocId = [];

                  snapshot.data.documents.forEach((doc) {
                    Place _rest = Place.fromDocument(doc);
                    allPlaces.add(_rest);
                    allDocId.add(doc.documentID);
                    topRatedPlace.add(_rest);
                    var docIdObj = {
                      "id": _rest.id,
                      "docId": doc.documentID,
                    };
                    topRatedDocId.add(docIdObj);

                    bool contains = PolyUtils.containsLocationPoly(
                        Point(_rest.latitude, _rest.longitude), polygon);
                    if (contains) {
                      nearbyPlaces.add(_rest);
                      nearbyDocId.add(doc.documentID);
                    }
                  });

                  if (topRatedPlace.length > 1) {
                    topRatedPlace.sort(
                        (b, a) => a.totalratings.compareTo(b.totalratings));
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        nearbyPlaces.isNotEmpty
                            ? SizedBox(
                                height: 20,
                              )
                            : SizedBox.shrink(),
                        nearbyPlaces.isNotEmpty
                            ? Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Nearby places",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey[900],
                                      fontFamily: "Roboto",
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800),
                                ),
                              )
                            : SizedBox.shrink(),
                        nearbyPlaces.isNotEmpty
                            ? SizedBox(
                                height: 10,
                              )
                            : SizedBox.shrink(),
                        nearbyPlaces.isNotEmpty
                            ? SizedBox(
                                height: height * 0.33,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: nearbyPlaces.length,
                                  itemBuilder: (context, index) =>
                                      NearbyPlaceCards(
                                    place: nearbyPlaces[index],
                                    docId: nearbyDocId[index],
                                    currentUserId: currentUserId,
                                    index: index,
                                    rate:
                                        nearbyPlaces[index].totalratings == 0.0
                                            ? 0.0
                                            : rateAlgorithm(nearbyPlaces[index]
                                                .totalratings
                                                .toInt()),
                                    bookmarkService: _bookmarkService,
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                        topRatedPlace.isNotEmpty
                            ? SizedBox(
                                height: 20,
                              )
                            : SizedBox.shrink(),
                        topRatedPlace.isNotEmpty
                            ? Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Popular places",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey[900],
                                      fontFamily: "Roboto",
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800),
                                ),
                              )
                            : SizedBox.shrink(),
                        topRatedPlace.isNotEmpty
                            ? SizedBox(
                                height: 10,
                              )
                            : SizedBox.shrink(),
                        topRatedPlace.isNotEmpty
                            ? SizedBox(
                                height: height * 0.33,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: topRatedPlace.length,
                                  itemBuilder: (context, index) =>
                                      TopRatedPlaceCards(
                                    place: topRatedPlace[index],
                                    docId: topRatedDocId[
                                        topRatedDocId.indexWhere((element) =>
                                            element["id"] ==
                                            topRatedPlace[index].id)]["docId"],
                                    currentUserId: currentUserId,
                                    index: index,
                                    rate:
                                        topRatedPlace[index].totalratings == 0.0
                                            ? 0.0
                                            : rateAlgorithm(topRatedPlace[index]
                                                .totalratings
                                                .toInt()),
                                    bookmarkService: _bookmarkService,
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                        allPlaces.isNotEmpty
                            ? SizedBox(
                                height: 20,
                              )
                            : SizedBox.shrink(),
                        allPlaces.isNotEmpty
                            ? Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "All places",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey[900],
                                      fontFamily: "Roboto",
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800),
                                ),
                              )
                            : SizedBox.shrink(),
                        allPlaces.isNotEmpty
                            ? SizedBox(
                                height: 10,
                              )
                            : SizedBox.shrink(),
                        allPlaces.isNotEmpty
                            ? allPlaces.length == 1
                                ? PlacesCards(
                                    bookmarkService: _bookmarkService,
                                    currentUserId: currentUserId,
                                    docId: allDocId[0],
                                    index: 0,
                                    place: allPlaces[0],
                                    rate: allPlaces[0].totalratings == 0.0
                                        ? 0.0
                                        : rateAlgorithm(
                                            allPlaces[0].totalratings.toInt(),
                                          ),
                                  )
                                : Flexible(
                                    child: GridView.count(
                                      physics: ScrollPhysics(),
                                      crossAxisCount: 2,
                                      shrinkWrap: true,
                                      children: List.generate(allPlaces.length,
                                          (index) {
                                        return PlacesCards(
                                          bookmarkService: _bookmarkService,
                                          currentUserId: currentUserId,
                                          docId: allDocId[index],
                                          index: index,
                                          singleIndex: allPlaces.length == 0
                                              ? true
                                              : false,
                                          place: allPlaces[index],
                                          rate: allPlaces[index].totalratings ==
                                                  0.0
                                              ? 0.0
                                              : rateAlgorithm(
                                                  allPlaces[index]
                                                      .totalratings
                                                      .toInt(),
                                                ),
                                        );
                                      }),
                                    ),
                                  )
                            : SizedBox.shrink(),
                      ],
                    ),
                  );
                }
              },
            ),
    );
  }
}

class NearbyPlaceCards extends StatelessWidget {
  final Place place;
  final String docId;
  final int index;
  final double rate;
  final String currentUserId;
  final BookmarkService bookmarkService;

  const NearbyPlaceCards(
      {this.rate,
      this.place,
      this.index,
      this.currentUserId,
      this.bookmarkService,
      this.docId,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PlaceDetails(
                      place: place,
                      docId: docId,
                    )));
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: Colors.black.withOpacity(0.8),
          child: Stack(
            children: <Widget>[
              FancyShimmerImage(
                imageUrl: place.intialImage,
                boxFit: BoxFit.cover,
                shimmerBackColor: Color(0xffe0e0e0),
                shimmerBaseColor: Color(0xffe0e0e0),
                shimmerHighlightColor: Colors.grey[200],
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.17,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 45,
                    height: 45,
                    child: FloatingActionButton(
                      onPressed: () async {
                        bool statusBook = await bookmarkService
                            .checkBookmarkAlreadyIn(currentUserId, docId, null);
                        if (statusBook) {
                          Fluttertoast.showToast(
                              msg: "Already in the bookmark list",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Pallete.mainAppColor,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          await bookmarkService.addToBookmark(
                              currentUserId, "place", docId, null);
                          Fluttertoast.showToast(
                              msg: "Added to the bookmark list",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Pallete.mainAppColor,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      heroTag: index.toString() + "placeNearby",
                      backgroundColor: Pallete.mainAppColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/icons/bookmark.png',
                          color: Colors.white,
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RouteMap(
                                  latitude: place.latitude,
                                  longitude: place.longitude,
                                )));
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: new BoxDecoration(
                        color: Pallete.mainAppColor,
                        borderRadius:
                            new BorderRadius.all(Radius.circular(30.0))),
                    child: Center(
                        child: Animator(
                      duration: Duration(milliseconds: 1000),
                      tween: Tween(begin: 1.1, end: 1.5),
                      curve: Curves.easeInCirc,
                      cycles: 0,
                      builder: (anim) => Center(
                        child: Transform.scale(
                          scale: anim.value,
                          child: Image.asset('assets/icons/direction.png',
                              width: 25, height: 25, color: Colors.white),
                        ),
                      ),
                    )),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.17,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 110,
                  decoration: new BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: new BorderRadius.all(Radius.circular(0.0))),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        place.placeName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        place.type,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        place.district,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      RatingBar(
                        initialRating: rate == 0.0 ? 0.0 : rate,
                        minRating: 0,
                        itemSize: 16,
                        unratedColor: Colors.grey,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        glow: true,
                        tapOnlyMode: true,
                        glowColor: Colors.white,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          MaterialIcons.star,
                          color: Pallete.mainAppColor,
                        ),
                        onRatingUpdate: (rating) {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(10),
        ),
      ),
    );
  }
}

class TopRatedPlaceCards extends StatelessWidget {
  final Place place;
  final String docId;
  final int index;
  final double rate;
  final String currentUserId;
  final BookmarkService bookmarkService;

  const TopRatedPlaceCards(
      {this.rate,
      this.place,
      this.index,
      this.currentUserId,
      this.bookmarkService,
      this.docId,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PlaceDetails(
                      place: place,
                      docId: docId,
                    )));
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: Colors.black.withOpacity(0.8),
          child: Stack(
            children: <Widget>[
              FancyShimmerImage(
                imageUrl: place.intialImage,
                boxFit: BoxFit.cover,
                shimmerBackColor: Color(0xffe0e0e0),
                shimmerBaseColor: Color(0xffe0e0e0),
                shimmerHighlightColor: Colors.grey[200],
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.17,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 45,
                    height: 45,
                    child: FloatingActionButton(
                      onPressed: () async {
                        bool statusBook = await bookmarkService
                            .checkBookmarkAlreadyIn(currentUserId, docId, null);
                        if (statusBook) {
                          Fluttertoast.showToast(
                              msg: "Already in the bookmark list",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Pallete.mainAppColor,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          await bookmarkService.addToBookmark(
                              currentUserId, "place", docId, null);
                          Fluttertoast.showToast(
                              msg: "Added to the bookmark list",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Pallete.mainAppColor,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      heroTag: index.toString() + "placeTopRated",
                      backgroundColor: Pallete.mainAppColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/icons/bookmark.png',
                          color: Colors.white,
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RouteMap(
                                  latitude: place.latitude,
                                  longitude: place.longitude,
                                )));
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: new BoxDecoration(
                        color: Pallete.mainAppColor,
                        borderRadius:
                            new BorderRadius.all(Radius.circular(30.0))),
                    child: Center(
                        child: Animator(
                      duration: Duration(milliseconds: 1000),
                      tween: Tween(begin: 1.1, end: 1.5),
                      curve: Curves.easeInCirc,
                      cycles: 0,
                      builder: (anim) => Center(
                        child: Transform.scale(
                          scale: anim.value,
                          child: Image.asset('assets/icons/direction.png',
                              width: 25, height: 25, color: Colors.white),
                        ),
                      ),
                    )),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.17,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 110,
                  decoration: new BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: new BorderRadius.all(Radius.circular(0.0))),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        place.placeName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        place.type,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        place.district,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      RatingBar(
                        initialRating: rate == 0.0 ? 0.0 : rate,
                        minRating: 0,
                        itemSize: 16,
                        unratedColor: Colors.grey,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        glow: true,
                        tapOnlyMode: true,
                        glowColor: Colors.white,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          MaterialIcons.star,
                          color: Pallete.mainAppColor,
                        ),
                        onRatingUpdate: (rating) {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(10),
        ),
      ),
    );
  }
}

class PlacesCards extends StatelessWidget {
  final Place place;
  final String docId;
  final int index;
  final bool singleIndex;
  final double rate;
  final String currentUserId;
  final BookmarkService bookmarkService;

  const PlacesCards(
      {this.rate,
      this.place,
      this.index,
      this.singleIndex,
      this.currentUserId,
      this.bookmarkService,
      this.docId,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PlaceDetails(
                      place: place,
                      docId: docId,
                    )));
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: Colors.black.withOpacity(0.8),
          child: Stack(
            children: <Widget>[
              FancyShimmerImage(
                imageUrl: place.intialImage,
                boxFit: BoxFit.cover,
                shimmerBackColor: Color(0xffe0e0e0),
                shimmerBaseColor: Color(0xffe0e0e0),
                shimmerHighlightColor: Colors.grey[200],
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.height * 0.27,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 40,
                    height: 40,
                    child: FloatingActionButton(
                      onPressed: () async {
                        bool statusBook = await bookmarkService
                            .checkBookmarkAlreadyIn(currentUserId, docId, null);
                        if (statusBook) {
                          Fluttertoast.showToast(
                              msg: "Already in the bookmark list",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Pallete.mainAppColor,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          await bookmarkService.addToBookmark(
                              currentUserId, "place", docId, null);
                          Fluttertoast.showToast(
                              msg: "Added to the bookmark list",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Pallete.mainAppColor,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      heroTag: index.toString() + "place",
                      backgroundColor: Pallete.mainAppColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/icons/bookmark.png',
                          color: Colors.white,
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RouteMap(
                                  latitude: place.latitude,
                                  longitude: place.longitude,
                                )));
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: new BoxDecoration(
                        color: Pallete.mainAppColor,
                        borderRadius:
                            new BorderRadius.all(Radius.circular(30.0))),
                    child: Center(
                        child: Animator(
                      duration: Duration(milliseconds: 1000),
                      tween: Tween(begin: 1.1, end: 1.5),
                      curve: Curves.easeInCirc,
                      cycles: 0,
                      builder: (anim) => Center(
                        child: Transform.scale(
                          scale: anim.value,
                          child: Image.asset('assets/icons/direction.png',
                              width: 25, height: 25, color: Colors.white),
                        ),
                      ),
                    )),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: singleIndex == true
                      ? MediaQuery.of(context).size.height * 0.17
                      : MediaQuery.of(context).size.height * 0.12,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: singleIndex == true ? 100 : 100,
                  decoration: new BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: new BorderRadius.all(Radius.circular(0.0))),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        place.placeName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        place.type,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      RatingBar(
                        initialRating: rate == 0.0 ? 0.0 : rate,
                        minRating: 0,
                        itemSize: 16,
                        unratedColor: Colors.grey,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        glow: true,
                        tapOnlyMode: true,
                        glowColor: Colors.white,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          MaterialIcons.star,
                          color: Pallete.mainAppColor,
                        ),
                        onRatingUpdate: (rating) {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(10),
        ),
      ),
    );
  }
}
