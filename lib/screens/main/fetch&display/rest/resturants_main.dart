import 'dart:convert';
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
import 'package:nearby/models/resturant.dart';
import 'package:nearby/screens/main/fetch&display/rest/rest_detail_view.dart';
import 'package:nearby/screens/main/fetch&display/rest/rest_filter.dart';
import 'package:nearby/screens/main/sub/resturant/add_resturant.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/services/bookmark_service.dart';
import 'package:nearby/services/resturant_service.dart';
import 'package:nearby/utils/maps/route_map.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/utils/rate_algorithm.dart';

import 'menu_item_view.dart';

class ResturantsMain extends StatefulWidget {
  ResturantsMain({Key key}) : super(key: key);

  @override
  _ResturantsMainState createState() => _ResturantsMainState();
}

class _ResturantsMainState extends State<ResturantsMain> {
  ResturantService _resturantService = ResturantService();
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
          "Resturants",
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
            child: Icon(
              Icons.search,
              size: 40,
              color: Colors.black.withOpacity(0.6),
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
                    MaterialPageRoute(builder: (context) => RestFilter()));
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddResturant(
                              type: "Resturants & cafes",
                            )));
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
              stream: _resturantService.streamResturant(),
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
                        'assets/icons/dining.png',
                        width: width * 0.7,
                        color: Colors.grey,
                      ),
                      Text(
                        "Resturants not available yet",
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
                        'assets/icons/dining.png',
                        width: width * 0.7,
                        color: Colors.grey,
                      ),
                      Text(
                        "Resturants not available yet",
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
                  List<Resturant> allResturants = [];
                  List allDocId = [];
                  List<Resturant> nearbyResturants = [];
                  List nearbyDocId = [];
                  List nearbyItems = [];
                  List<Resturant> topRatedResturants = [];
                  List topRatedDocId = [];
                  List topRatedItems = [];

                  snapshot.data.documents.forEach((doc) {
                    Resturant _rest = Resturant.fromDocument(doc);
                    allResturants.add(_rest);
                    allDocId.add(doc.documentID);
                    topRatedResturants.add(_rest);
                    var docIdObj = {
                      "id": _rest.id,
                      "docId": doc.documentID,
                    };
                    topRatedDocId.add(docIdObj);
                    List menuTopRated = _rest.menu;
                    menuTopRated.forEach((element) {
                      var objRated = json.decode(element);
                      var updatedRatedObj = {
                        "id": objRated["id"],
                        "restId": _rest.id,
                        "restOwnerId": _rest.ownerId,
                        "docId": doc.documentID,
                        "index": menuTopRated.indexWhere((element) =>
                            json.decode(element)["id"] == objRated["id"]),
                        "initialImage": objRated["initialImage"],
                        "item_type": objRated["item_type"],
                        "item_name": objRated["item_name"],
                        "price": objRated["price"],
                        "portion_count": objRated["portion_count"],
                        "about": objRated["about"],
                        "foodTake": objRated["foodTake"],
                        "gallery": objRated["gallery"],
                        "total_ratings": objRated["total_ratings"],
                        "ratings": objRated["ratings"],
                        "review": objRated["review"],
                      };
                      topRatedItems.add(updatedRatedObj);
                    });

                    bool contains = PolyUtils.containsLocationPoly(
                        Point(_rest.latitude, _rest.longitude), polygon);
                    if (contains) {
                      nearbyResturants.add(_rest);
                      nearbyDocId.add(doc.documentID);
                      List menu = _rest.menu;
                      menu.forEach((element) {
                        var obj = json.decode(element);
                        var updatedObj = {
                          "id": obj["id"],
                          "restId": _rest.id,
                          "restOwnerId": _rest.ownerId,
                          "docId": doc.documentID,
                          "index": menu.indexWhere((element) =>
                              json.decode(element)["id"] == obj["id"]),
                          "initialImage": obj["initialImage"],
                          "item_type": obj["item_type"],
                          "item_name": obj["item_name"],
                          "price": obj["price"],
                          "portion_count": obj["portion_count"],
                          "about": obj["about"],
                          "foodTake": obj["foodTake"],
                          "gallery": obj["gallery"],
                          "total_ratings": obj["total_ratings"],
                          "ratings": obj["ratings"],
                          "review": obj["review"],
                        };

                        nearbyItems.add(updatedObj);
                      });
                    }
                  });

                  if (topRatedResturants.length > 1) {
                    topRatedResturants.sort(
                        (b, a) => a.totalratings.compareTo(b.totalratings));
                  }

                  if (topRatedItems.length > 1) {
                    topRatedItems.sort((b, a) =>
                        a["total_ratings"].compareTo(b["total_ratings"]));
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        nearbyResturants.isNotEmpty
                            ? SizedBox(
                                height: 20,
                              )
                            : SizedBox.shrink(),
                        nearbyResturants.isNotEmpty
                            ? Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Nearby resturants & cafes",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey[900],
                                      fontFamily: "Roboto",
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800),
                                ),
                              )
                            : SizedBox.shrink(),
                        nearbyResturants.isNotEmpty
                            ? SizedBox(
                                height: 10,
                              )
                            : SizedBox.shrink(),
                        nearbyResturants.isNotEmpty
                            ? SizedBox(
                                height: height * 0.33,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: nearbyResturants.length,
                                    itemBuilder: (context, index) =>
                                        NearbyResturantsCards(
                                          rest: nearbyResturants[index],
                                          docId: nearbyDocId[index],
                                          currentUserId: currentUserId,
                                          index: index,
                                          rate: nearbyResturants[index]
                                                      .totalratings ==
                                                  0.0
                                              ? 0.0
                                              : rateAlgorithm(
                                                  nearbyResturants[index]
                                                      .totalratings
                                                      .toInt()),
                                          bookmarkService: _bookmarkService,
                                        )),
                              )
                            : SizedBox.shrink(),
                        nearbyItems.isNotEmpty
                            ? SizedBox(
                                height: 20,
                              )
                            : SizedBox.shrink(),
                        nearbyItems.isNotEmpty
                            ? Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Nearby food items",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey[900],
                                      fontFamily: "Roboto",
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800),
                                ),
                              )
                            : SizedBox.shrink(),
                        nearbyItems.isNotEmpty
                            ? SizedBox(
                                height: 10,
                              )
                            : SizedBox.shrink(),
                        nearbyItems.isNotEmpty
                            ? SizedBox(
                                height: height * 0.33,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: nearbyItems.length,
                                    itemBuilder: (context, index) =>
                                        NearbyMenuItems(
                                          restMenu: nearbyItems[index],
                                          docId: nearbyItems[index]["docId"],
                                          listIndex: index,
                                          currentUserId: currentUserId,
                                          index: nearbyItems[index]["index"],
                                          rate: nearbyItems[index]
                                                      ["total_ratings"] ==
                                                  0.0
                                              ? 0.0
                                              : rateAlgorithm(nearbyItems[index]
                                                      ["total_ratings"]
                                                  .toInt()),
                                          bookmarkService: _bookmarkService,
                                          id: nearbyItems[index]["restId"],
                                          ownerId: nearbyItems[index]
                                              ["restOwnerId"],
                                        )),
                              )
                            : SizedBox.shrink(),
                        topRatedResturants.isNotEmpty
                            ? SizedBox(
                                height: 20,
                              )
                            : SizedBox.shrink(),
                        topRatedResturants.isNotEmpty
                            ? Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Popular resturants & cafes",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey[900],
                                      fontFamily: "Roboto",
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800),
                                ),
                              )
                            : SizedBox.shrink(),
                        topRatedResturants.isNotEmpty
                            ? SizedBox(
                                height: 10,
                              )
                            : SizedBox.shrink(),
                        topRatedResturants.isNotEmpty
                            ? SizedBox(
                                height: height * 0.33,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: topRatedResturants.length,
                                    itemBuilder: (context, index) =>
                                        TopRatedResturantsCards(
                                          rest: topRatedResturants[index],
                                          docId: topRatedDocId[topRatedDocId
                                              .indexWhere((element) =>
                                                  element["id"] ==
                                                  topRatedResturants[index]
                                                      .id)]["docId"],
                                          currentUserId: currentUserId,
                                          index: index,
                                          rate: topRatedResturants[index]
                                                      .totalratings ==
                                                  0.0
                                              ? 0.0
                                              : rateAlgorithm(
                                                  topRatedResturants[index]
                                                      .totalratings
                                                      .toInt()),
                                          bookmarkService: _bookmarkService,
                                        )),
                              )
                            : SizedBox.shrink(),
                        topRatedItems.isNotEmpty
                            ? SizedBox(
                                height: 20,
                              )
                            : SizedBox.shrink(),
                        topRatedItems.isNotEmpty
                            ? Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Popular food items",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey[900],
                                      fontFamily: "Roboto",
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800),
                                ),
                              )
                            : SizedBox.shrink(),
                        topRatedItems.isNotEmpty
                            ? SizedBox(
                                height: 10,
                              )
                            : SizedBox.shrink(),
                        topRatedItems.isNotEmpty
                            ? SizedBox(
                                height: height * 0.33,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: topRatedItems.length,
                                    itemBuilder: (context, index) =>
                                        TopRatedMenuItems(
                                          restMenu: topRatedItems[index],
                                          docId: topRatedItems[index]["docId"],
                                          currentUserId: currentUserId,
                                          index: topRatedItems[index]["index"],
                                          listIndex: index,
                                          rate: topRatedItems[index]
                                                      ["total_ratings"] ==
                                                  0.0
                                              ? 0.0
                                              : rateAlgorithm(
                                                  topRatedItems[index]
                                                          ["total_ratings"]
                                                      .toInt()),
                                          bookmarkService: _bookmarkService,
                                          id: topRatedItems[index]["restId"],
                                          ownerId: topRatedItems[index]
                                              ["restOwnerId"],
                                        )),
                              )
                            : SizedBox.shrink(),
                        allResturants.isNotEmpty
                            ? SizedBox(
                                height: 20,
                              )
                            : SizedBox.shrink(),
                        allResturants.isNotEmpty
                            ? Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "All resturants & cafes",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey[900],
                                      fontFamily: "Roboto",
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800),
                                ),
                              )
                            : SizedBox.shrink(),
                        allResturants.isNotEmpty
                            ? SizedBox(
                                height: 10,
                              )
                            : SizedBox.shrink(),
                        allResturants.isNotEmpty
                            ? allResturants.length == 1
                                ? ResturantsCards(
                                    bookmarkService: _bookmarkService,
                                    currentUserId: currentUserId,
                                    docId: allDocId[0],
                                    index: 0,
                                    rest: allResturants[0],
                                    rate: allResturants[0].totalratings == 0.0
                                        ? 0.0
                                        : rateAlgorithm(
                                            allResturants[0]
                                                .totalratings
                                                .toInt(),
                                          ),
                                  )
                                : Flexible(
                                    child: GridView.count(
                                      physics: ScrollPhysics(),
                                      crossAxisCount: 2,
                                      shrinkWrap: true,
                                      children: List.generate(
                                          allResturants.length, (index) {
                                        return ResturantsCards(
                                          bookmarkService: _bookmarkService,
                                          currentUserId: currentUserId,
                                          docId: allDocId[index],
                                          index: index,
                                          singleIndex: allResturants.length == 0
                                              ? true
                                              : false,
                                          rest: allResturants[index],
                                          rate: allResturants[index]
                                                      .totalratings ==
                                                  0.0
                                              ? 0.0
                                              : rateAlgorithm(
                                                  allResturants[index]
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

class NearbyResturantsCards extends StatelessWidget {
  final Resturant rest;
  final String docId;
  final int index;
  final double rate;
  final String currentUserId;
  final BookmarkService bookmarkService;

  const NearbyResturantsCards(
      {this.rate,
      this.rest,
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
                builder: (context) => ResturantDetailView(
                      rest: rest,
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
                imageUrl: rest.initialImage,
                boxFit: BoxFit.cover,
                shimmerBackColor: Color(0xffe0e0e0),
                shimmerBaseColor: Color(0xffe0e0e0),
                shimmerHighlightColor: Colors.grey[200],
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.2,
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
                              currentUserId, "rest_main", docId, null);
                          Fluttertoast.showToast(
                              msg: "Added to the bookmark list",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Pallete.mainAppColor,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      heroTag: index.toString() + "rest&cafesNearby",
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
                                  latitude: rest.latitude,
                                  longitude: rest.longitude,
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
                  top: MediaQuery.of(context).size.height * 0.2,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 80,
                  decoration: new BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: new BorderRadius.all(Radius.circular(0.0))),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        rest.restName,
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
                        rest.address,
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

class TopRatedResturantsCards extends StatelessWidget {
  final Resturant rest;
  final String docId;
  final int index;
  final double rate;
  final String currentUserId;
  final BookmarkService bookmarkService;

  const TopRatedResturantsCards(
      {this.rate,
      this.rest,
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
                builder: (context) => ResturantDetailView(
                      rest: rest,
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
                imageUrl: rest.initialImage,
                boxFit: BoxFit.cover,
                shimmerBackColor: Color(0xffe0e0e0),
                shimmerBaseColor: Color(0xffe0e0e0),
                shimmerHighlightColor: Colors.grey[200],
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.2,
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
                              currentUserId, "rest_main", docId, null);
                          Fluttertoast.showToast(
                              msg: "Added to the bookmark list",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Pallete.mainAppColor,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      heroTag: index.toString() + "rest&cafesTopRated",
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
                                  latitude: rest.latitude,
                                  longitude: rest.longitude,
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
                  top: MediaQuery.of(context).size.height * 0.2,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 80,
                  decoration: new BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: new BorderRadius.all(Radius.circular(0.0))),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        rest.restName,
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
                        rest.address,
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

class ResturantsCards extends StatelessWidget {
  final Resturant rest;
  final String docId;
  final int index;
  final bool singleIndex;
  final double rate;
  final String currentUserId;
  final BookmarkService bookmarkService;

  const ResturantsCards(
      {this.rate,
      this.rest,
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
                builder: (context) => ResturantDetailView(
                      rest: rest,
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
                imageUrl: rest.initialImage,
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
                              currentUserId, "rest_main", docId, null);
                          Fluttertoast.showToast(
                              msg: "Added to the bookmark list",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Pallete.mainAppColor,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      heroTag: index.toString() + "rest&cafes",
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
                                  latitude: rest.latitude,
                                  longitude: rest.longitude,
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
                      : MediaQuery.of(context).size.height * 0.13,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: singleIndex == true ? 80 : 100,
                  decoration: new BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: new BorderRadius.all(Radius.circular(0.0))),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        rest.restName,
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
                        rest.address,
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

class NearbyMenuItems extends StatelessWidget {
  final restMenu;
  final String currentUserId;
  final String docId;
  final String id;
  final String ownerId;
  final int index;
  final int listIndex;
  final double rate;
  final BookmarkService bookmarkService;

  const NearbyMenuItems(
      {this.restMenu,
      this.id,
      this.listIndex,
      this.bookmarkService,
      this.index,
      this.ownerId,
      this.currentUserId,
      this.docId,
      this.rate,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MenuItemView(
                      menuItem: restMenu,
                      currentUserId: currentUserId,
                      docId: docId,
                      index: index,
                      id: id,
                      ownerId: ownerId,
                    )));
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Card(
          semanticContainer: true,
          color: Colors.black.withOpacity(0.8),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            children: <Widget>[
              FancyShimmerImage(
                imageUrl: restMenu["initialImage"],
                boxFit: BoxFit.cover,
                shimmerBackColor: Color(0xffe0e0e0),
                shimmerBaseColor: Color(0xffe0e0e0),
                shimmerHighlightColor: Colors.grey[200],
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 45,
                  height: 45,
                  child: FloatingActionButton(
                    onPressed: () async {
                      bool statusBook = await bookmarkService
                          .checkBookmarkAlreadyIn(currentUserId, docId, index);
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
                            currentUserId, "rest_item", docId, index);
                        Fluttertoast.showToast(
                            msg: "Added to the bookmark list",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Pallete.mainAppColor,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    },
                    heroTag: listIndex.toString() + "nearbyItemes",
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
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.2,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 80,
                  decoration: new BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: new BorderRadius.all(Radius.circular(0.0))),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        restMenu["item_name"],
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
                        restMenu["price"] + " LKR",
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

class TopRatedMenuItems extends StatelessWidget {
  final restMenu;
  final String currentUserId;
  final String docId;
  final String id;
  final String ownerId;
  final int index;
  final int listIndex;
  final double rate;
  final BookmarkService bookmarkService;

  const TopRatedMenuItems(
      {this.restMenu,
      this.id,
      this.bookmarkService,
      this.index,
      this.ownerId,
      this.listIndex,
      this.currentUserId,
      this.docId,
      this.rate,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MenuItemView(
                      menuItem: restMenu,
                      currentUserId: currentUserId,
                      docId: docId,
                      index: index,
                      id: id,
                      ownerId: ownerId,
                    )));
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Card(
          semanticContainer: true,
          color: Colors.black.withOpacity(0.8),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            children: <Widget>[
              FancyShimmerImage(
                imageUrl: restMenu["initialImage"],
                boxFit: BoxFit.cover,
                shimmerBackColor: Color(0xffe0e0e0),
                shimmerBaseColor: Color(0xffe0e0e0),
                shimmerHighlightColor: Colors.grey[200],
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 45,
                  height: 45,
                  child: FloatingActionButton(
                    onPressed: () async {
                      bool statusBook = await bookmarkService
                          .checkBookmarkAlreadyIn(currentUserId, docId, index);
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
                            currentUserId, "rest_item", docId, index);
                        Fluttertoast.showToast(
                            msg: "Added to the bookmark list",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Pallete.mainAppColor,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    },
                    heroTag: listIndex.toString() + "TopratedItems",
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
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.2,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 80,
                  decoration: new BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: new BorderRadius.all(Radius.circular(0.0))),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        restMenu["item_name"],
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
                        restMenu["price"] + " LKR",
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
