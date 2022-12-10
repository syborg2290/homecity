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
import 'package:nearby/models/grocery.dart';
import 'package:nearby/screens/main/sub/grocery/add_grocery.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/services/bookmark_service.dart';
import 'package:nearby/services/grocery_service.dart';
import 'package:nearby/utils/maps/route_map.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/utils/rate_algorithm.dart';

import 'groc_item_view.dart';
import 'grocery_details.dart';
import 'grocery_filter.dart';
import 'grocery_serach.dart';

class GrocerysMain extends StatefulWidget {
  GrocerysMain({Key key}) : super(key: key);

  @override
  _GrocerysMainState createState() => _GrocerysMainState();
}

class _GrocerysMainState extends State<GrocerysMain> {
  GroceryService _groceryService = GroceryService();
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
          "Groceries",
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
                        builder: (context) => GrocSearch(
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
                    MaterialPageRoute(builder: (context) => GroceryFilter()));
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
                    MaterialPageRoute(builder: (context) => AddGrocery()));
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
              stream: _groceryService.streamGrocery(),
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
                        'assets/icons/canned-food.png',
                        width: width * 0.7,
                        color: Colors.grey,
                      ),
                      Text(
                        "Groceries not available yet",
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
                        'assets/icons/canned-food.png',
                        width: width * 0.7,
                        color: Colors.grey,
                      ),
                      Text(
                        "Groceries not available yet",
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
                  List<Grocery> allGroceries = [];
                  List allDocId = [];
                  List<Grocery> nearbyGroceries = [];
                  List nearbyDocId = [];
                  List nearbyItems = [];
                  List<Grocery> topRatedGroceries = [];
                  List topRatedDocId = [];
                  List topRatedItems = [];

                  snapshot.data.documents.forEach((doc) {
                    Grocery _groc = Grocery.fromDocument(doc);
                    allGroceries.add(_groc);
                    allDocId.add(doc.documentID);
                    topRatedGroceries.add(_groc);
                    var docIdObj = {
                      "id": _groc.id,
                      "docId": doc.documentID,
                    };
                    topRatedDocId.add(docIdObj);
                    List menuTopRated = _groc.items;
                    menuTopRated.forEach((element) {
                      var objRated = json.decode(element);
                      var updatedObj = {
                        "id": objRated["id"],
                        "grocId": _groc.id,
                        "restOwnerId": _groc.ownerId,
                        "docId": doc.documentID,
                        "index": menuTopRated.indexWhere((element) =>
                            json.decode(element)["id"] == objRated["id"]),
                        "initialImage": objRated["initialImage"],
                        "item_type": objRated["item_type"],
                        "item_name": objRated["item_name"],
                        "status": objRated["status"],
                        "price": objRated["price"],
                        "about": objRated["about"],
                        "brand": objRated["brand"],
                        "gallery": objRated["gallery"],
                        "total_ratings": objRated["total_ratings"],
                        "ratings": objRated["ratings"],
                        "review": objRated["review"],
                      };

                      topRatedItems.add(updatedObj);
                    });

                    bool contains = PolyUtils.containsLocationPoly(
                        Point(_groc.latitude, _groc.longitude), polygon);
                    if (contains) {
                      nearbyGroceries.add(_groc);
                      nearbyDocId.add(doc.documentID);
                      List menu = _groc.items;
                      menu.forEach((element) {
                        var obj = json.decode(element);

                        var updatedObj = {
                          "id": obj["id"],
                          "grocId": _groc.id,
                          "restOwnerId": _groc.ownerId,
                          "docId": doc.documentID,
                          "index": menuTopRated.indexWhere((element) =>
                              json.decode(element)["id"] == obj["id"]),
                          "initialImage": obj["initialImage"],
                          "item_type": obj["item_type"],
                          "item_name": obj["item_name"],
                          "status": obj["status"],
                          "price": obj["price"],
                          "about": obj["about"],
                          "brand": obj["brand"],
                          "gallery": obj["gallery"],
                          "total_ratings": obj["total_ratings"],
                          "ratings": obj["ratings"],
                          "review": obj["review"],
                        };

                        nearbyItems.add(updatedObj);
                      });
                    }
                  });

                  if (topRatedGroceries.length > 1) {
                    topRatedGroceries.sort(
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
                        nearbyGroceries.isNotEmpty
                            ? SizedBox(
                                height: 20,
                              )
                            : SizedBox.shrink(),
                        nearbyGroceries.isNotEmpty
                            ? Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Nearby groceries & markets",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey[900],
                                      fontFamily: "Roboto",
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800),
                                ),
                              )
                            : SizedBox.shrink(),
                        nearbyGroceries.isNotEmpty
                            ? SizedBox(
                                height: 10,
                              )
                            : SizedBox.shrink(),
                        nearbyGroceries.isNotEmpty
                            ? SizedBox(
                                height: height * 0.33,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: nearbyGroceries.length,
                                    itemBuilder: (context, index) =>
                                        NearbyGroceriesCards(
                                          groc: nearbyGroceries[index],
                                          docId: nearbyDocId[index],
                                          currentUserId: currentUserId,
                                          index: index,
                                          rate: nearbyGroceries[index]
                                                      .totalratings ==
                                                  0.0
                                              ? 0.0
                                              : rateAlgorithm(
                                                  nearbyGroceries[index]
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
                                  "Nearby items",
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
                                        NearbyItems(
                                          item: nearbyItems[index],
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
                        topRatedGroceries.isNotEmpty
                            ? SizedBox(
                                height: 20,
                              )
                            : SizedBox.shrink(),
                        topRatedGroceries.isNotEmpty
                            ? Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Popular groceries & markets",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey[900],
                                      fontFamily: "Roboto",
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800),
                                ),
                              )
                            : SizedBox.shrink(),
                        topRatedGroceries.isNotEmpty
                            ? SizedBox(
                                height: 10,
                              )
                            : SizedBox.shrink(),
                        topRatedGroceries.isNotEmpty
                            ? SizedBox(
                                height: height * 0.33,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: topRatedGroceries.length,
                                    itemBuilder: (context, index) =>
                                        TopRatedGroceryCards(
                                          groc: topRatedGroceries[index],
                                          docId: topRatedDocId[topRatedDocId
                                              .indexWhere((element) =>
                                                  element["id"] ==
                                                  topRatedGroceries[index]
                                                      .id)]["docId"],
                                          currentUserId: currentUserId,
                                          index: index,
                                          rate: topRatedGroceries[index]
                                                      .totalratings ==
                                                  0.0
                                              ? 0.0
                                              : rateAlgorithm(
                                                  topRatedGroceries[index]
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
                                  "Popular items",
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
                                        TopRatedItems(
                                          item: topRatedItems[index],
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
                        allGroceries.isNotEmpty
                            ? SizedBox(
                                height: 20,
                              )
                            : SizedBox.shrink(),
                        allGroceries.isNotEmpty
                            ? Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "All groceries & markets",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey[900],
                                      fontFamily: "Roboto",
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800),
                                ),
                              )
                            : SizedBox.shrink(),
                        allGroceries.isNotEmpty
                            ? SizedBox(
                                height: 10,
                              )
                            : SizedBox.shrink(),
                        allGroceries.isNotEmpty
                            ? allGroceries.length == 1
                                ? GroceryCards(
                                    bookmarkService: _bookmarkService,
                                    currentUserId: currentUserId,
                                    docId: allDocId[0],
                                    index: 0,
                                    groc: allGroceries[0],
                                    rate: allGroceries[0].totalratings == 0.0
                                        ? 0.0
                                        : rateAlgorithm(
                                            allGroceries[0]
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
                                          allGroceries.length, (index) {
                                        return GroceryCards(
                                          bookmarkService: _bookmarkService,
                                          currentUserId: currentUserId,
                                          docId: allDocId[index],
                                          index: index,
                                          singleIndex: allGroceries.length == 0
                                              ? true
                                              : false,
                                          groc: allGroceries[index],
                                          rate: allGroceries[index]
                                                      .totalratings ==
                                                  0.0
                                              ? 0.0
                                              : rateAlgorithm(
                                                  allGroceries[index]
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

class NearbyGroceriesCards extends StatelessWidget {
  final Grocery groc;
  final String docId;
  final int index;
  final double rate;
  final String currentUserId;
  final BookmarkService bookmarkService;

  const NearbyGroceriesCards(
      {this.rate,
      this.groc,
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
                builder: (context) => GroceryDetailView(
                      groc: groc,
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
                imageUrl: groc.initialImage,
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
                              currentUserId, "grocery", docId, null);
                          Fluttertoast.showToast(
                              msg: "Added to the bookmark list",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Pallete.mainAppColor,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      heroTag: index.toString() + "groceryNearby",
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
                                  latitude: groc.latitude,
                                  longitude: groc.longitude,
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
                        groc.grocName,
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
                        groc.address,
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

class TopRatedGroceryCards extends StatelessWidget {
  final Grocery groc;
  final String docId;
  final int index;
  final double rate;
  final String currentUserId;
  final BookmarkService bookmarkService;

  const TopRatedGroceryCards(
      {this.rate,
      this.groc,
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
                builder: (context) => GroceryDetailView(
                      groc: groc,
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
                imageUrl: groc.initialImage,
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
                              currentUserId, "grocery", docId, null);
                          Fluttertoast.showToast(
                              msg: "Added to the bookmark list",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Pallete.mainAppColor,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      heroTag: index.toString() + "groceryTopRated",
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
                                  latitude: groc.latitude,
                                  longitude: groc.longitude,
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
                        groc.grocName,
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
                        groc.address,
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

class GroceryCards extends StatelessWidget {
  final Grocery groc;
  final String docId;
  final int index;
  final bool singleIndex;
  final double rate;
  final String currentUserId;
  final BookmarkService bookmarkService;

  const GroceryCards(
      {this.rate,
      this.groc,
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
                builder: (context) => GroceryDetailView(
                      groc: groc,
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
                imageUrl: groc.initialImage,
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
                              currentUserId, "grocery", docId, null);
                          Fluttertoast.showToast(
                              msg: "Added to the bookmark list",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Pallete.mainAppColor,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      heroTag: index.toString() + "grocery",
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
                                  latitude: groc.latitude,
                                  longitude: groc.longitude,
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
                      : MediaQuery.of(context).size.height * 0.14,
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
                        groc.grocName,
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
                        groc.address,
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

class NearbyItems extends StatelessWidget {
  final item;
  final String currentUserId;
  final String docId;
  final String id;
  final String ownerId;
  final int index;
  final int listIndex;
  final double rate;
  final BookmarkService bookmarkService;

  const NearbyItems(
      {this.item,
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
                builder: (context) => GrocItemView(
                      grocItem: item,
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
                imageUrl: item["initialImage"],
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
                            currentUserId, "grocery_item", docId, index);
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
                        item["item_name"],
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
                        item["price"] + " LKR",
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

class TopRatedItems extends StatelessWidget {
  final item;
  final String currentUserId;
  final String docId;
  final String id;
  final String ownerId;
  final int index;
  final int listIndex;
  final double rate;
  final BookmarkService bookmarkService;

  const TopRatedItems(
      {this.item,
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
                builder: (context) => GrocItemView(
                      grocItem: item,
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
                imageUrl: item["initialImage"],
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
                            currentUserId, "grocery_item", docId, index);
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
                        item["item_name"],
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
                        item["price"] + " LKR",
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
