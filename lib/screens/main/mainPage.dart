import 'package:animator/animator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearby/models/resturant.dart';
import 'package:nearby/screens/main/sub/select_category.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/services/bookmark_service.dart';
import 'package:nearby/services/resturant_service.dart';
import 'package:nearby/utils/maps/route_map.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/utils/rate_algorithm.dart';
import 'package:nearby/utils/shimmers/card_row_shimmer.dart';
import 'package:nearby/utils/shimmers/main_window.dart';
import 'package:nearby/widgets/services_categories.dart';

import 'fetch&display/rest/rest_detail_view.dart';
import 'fetch&display/rest/resturants_main.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ResturantService _resturantService = ResturantService();
  BookmarkService _bookmarkService = BookmarkService();
  AuthServcies _authServcies = AuthServcies();
  String currentUserId;
  int restCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _authServcies.getCurrentUser().then((fUser) {
      setState(() {
        currentUserId = fUser.uid;
      });
    });
    getResturantCount();
  }

  getResturantCount() async {
    QuerySnapshot qSnap = await _resturantService.getAllResturant();
    setState(() {
      restCount = qSnap.documents.length;
      isLoading = false;
    });
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
          padding: const EdgeInsets.only(
            left: 20,
            bottom: 10,
          ),
          child: Image.asset(
            'assets/logo.png',
            width: 30,
            height: 30,
            color: Pallete.mainAppColor,
          ),
        ),
        centerTitle: false,
        title: Text(
          'Home city',
          style: TextStyle(
              color: Colors.grey[700],
              fontFamily: "Roboto",
              fontSize: 25,
              fontWeight: FontWeight.w400),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SelectCategory();
                }));
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
      body: SingleChildScrollView(
        child: isLoading
            ? mainWindow(context)
            : Column(
                children: <Widget>[
                  Divider(),
                  MainCategory(
                    restCount: restCount,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  StreamBuilder(
                    stream: _resturantService.streamResturant(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                          color: Colors.white,
                          child: Center(
                              child:
                                  SpinKitCircle(color: Pallete.mainAppColor)),
                        );
                      }
                      if (snapshot.data.documents == null) {
                        return SizedBox.shrink();
                      } else if (snapshot.data.documents.length == 0) {
                        return SizedBox.shrink();
                      } else {
                        List<Resturant> popularRests = [];
                        List docIds = [];

                        snapshot.data.documents.forEach((doc) {
                          Resturant rest = Resturant.fromDocument(doc);

                          popularRests.add(rest);
                          var docIdObj = {
                            "id": rest.id,
                            "docId": doc.documentID,
                          };
                          docIds.add(docIdObj);
                          if (popularRests.length > 1) {
                            popularRests.sort((b, a) =>
                                a.totalratings.compareTo(b.totalratings));
                          }
                        });

                        return popularRests.isEmpty
                            ? cardRow(context)
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            "Popular resturants & cafes",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontFamily: "Roboto",
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ResturantsMain()));
                                            },
                                            child: Text(
                                              "more",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w900),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.4,
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: popularRests.length,
                                        itemBuilder: (context, index) =>
                                            TrendingResturantsCards(
                                              rest: popularRests[index],
                                              docId: docIds[docIds.indexWhere(
                                                  (element) =>
                                                      element["id"] ==
                                                      popularRests[index]
                                                          .id)]["docId"],
                                              currentUserId: currentUserId,
                                              index: index,
                                              rate: popularRests[index]
                                                          .totalratings ==
                                                      0
                                                  ? 0.0
                                                  : rateAlgorithm(
                                                      popularRests[index]
                                                          .totalratings
                                                          .toInt()),
                                              bookmarkService: _bookmarkService,
                                            )),
                                  ),
                                ],
                              );
                      }
                    },
                  ),
                ],
              ),
      ),
    );
  }
}

class TrendingResturantsCards extends StatelessWidget {
  final Resturant rest;
  final String docId;
  final int index;
  final double rate;
  final String currentUserId;
  final BookmarkService bookmarkService;

  const TrendingResturantsCards(
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
                  top: MediaQuery.of(context).size.height * 0.27,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: 100,
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
