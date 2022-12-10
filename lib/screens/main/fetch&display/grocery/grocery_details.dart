import 'dart:convert';

import 'package:animator/animator.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearby/models/grocery.dart';
import 'package:nearby/services/activity_feed_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/services/bookmark_service.dart';
import 'package:nearby/services/grocery_service.dart';
import 'package:nearby/utils/maps/route_map.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/utils/rate_algorithm.dart';
import 'package:nearby/utils/videoplayers/network_player.dart';
import 'package:nearby/utils/full_screen_network_file.dart';
import 'package:intl/intl.dart' as dd;
import 'package:pie_chart/pie_chart.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'explore_items.dart';
import 'groc_item_detail.dart';
import 'grocery_gallery.dart';
import 'grocery_review.dart';

class GroceryDetailView extends StatefulWidget {
  final Grocery groc;
  final String docId;
  GroceryDetailView({this.groc, this.docId, Key key}) : super(key: key);

  @override
  _GroceryDetailViewState createState() => _GroceryDetailViewState();
}

class _GroceryDetailViewState extends State<GroceryDetailView> {
  List grocGallery = [];
  String currentMedia;
  int currentMediaIndex = 0;
  AuthServcies _authServcies = AuthServcies();
  GroceryService _groceryService = GroceryService();
  ActivityFeedService _activityFeedService = ActivityFeedService();
  BookmarkService _bookmarkService = BookmarkService();
  String currentUserId;
  final format = dd.DateFormat("HH:mm");

  @override
  void initState() {
    super.initState();
    _authServcies.getCurrentUser().then((fUser) {
      setState(() {
        currentUserId = fUser.uid;
      });
    });
    if (widget.groc.gallery.isNotEmpty) {
      setState(() {
        currentMedia = widget.groc.gallery[0];
      });
      widget.groc.gallery.forEach((element) {
        setState(() {
          grocGallery.add(element);
        });
      });
    }
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
                    Navigator.pop(context);
                  }),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: 45,
                      height: 45,
                      child: FloatingActionButton(
                        onPressed: () async {
                          bool statusBook =
                              await _bookmarkService.checkBookmarkAlreadyIn(
                                  currentUserId, widget.docId, null);
                          if (statusBook) {
                            Fluttertoast.showToast(
                                msg: "Already in the bookmark list",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: Pallete.mainAppColor,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          } else {
                            await _bookmarkService.addToBookmark(
                                currentUserId, "grocery", widget.docId, null);
                            Fluttertoast.showToast(
                                msg: "Added to the bookmark list",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: Pallete.mainAppColor,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        },
                        heroTag: "grocery",
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
                                    latitude: widget.groc.latitude,
                                    longitude: widget.groc.longitude,
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
              ],
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
            grocGallery.isEmpty
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NetworkFileFullScreen(
                                    type: "image",
                                    url: widget.groc.initialImage,
                                  )));
                    },
                    child: Container(
                      width: width,
                      height: height * 0.4,
                      child: FancyShimmerImage(
                        imageUrl: widget.groc.initialImage,
                        boxFit: BoxFit.cover,
                        shimmerBackColor: Color(0xffe0e0e0),
                        shimmerBaseColor: Color(0xffe0e0e0),
                        shimmerHighlightColor: Colors.grey[200],
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NetworkFileFullScreen(
                                    type: json.decode(currentMedia)["type"],
                                    url: json.decode(currentMedia)["url"],
                                  )));
                    },
                    child: Container(
                      width: width,
                      height: height * 0.4,
                      child: json.decode(currentMedia)["type"] == "image"
                          ? FancyShimmerImage(
                              imageUrl: json.decode(currentMedia)["url"],
                              boxFit: BoxFit.cover,
                              shimmerBackColor: Color(0xffe0e0e0),
                              shimmerBaseColor: Color(0xffe0e0e0),
                              shimmerHighlightColor: Colors.grey[200],
                            )
                          : Stack(
                              children: <Widget>[
                                NetworkPlayer(
                                  url: json.decode(currentMedia)["url"],
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 60,
                                      right: 20,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.8),
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(height * 0.09))),
                                      child: IconButton(
                                          icon: Image.asset(
                                            'assets/icons/full-screen.png',
                                            width: width * 0.07,
                                            height: height * 0.07,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        NetworkFileFullScreen(
                                                          type: json.decode(
                                                                  currentMedia)[
                                                              "type"],
                                                          url: json.decode(
                                                                  currentMedia)[
                                                              "url"],
                                                        )));
                                          }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
            SizedBox(
              height: 5,
            ),
            grocGallery.length > 1
                ? SizedBox(
                    height: height * 0.15,
                    child: ListView.builder(
                        itemCount: grocGallery.length,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Stack(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      currentMedia = grocGallery[index];
                                      currentMediaIndex = index;
                                    });
                                  },
                                  child: Container(
                                    width: width * 0.3,
                                    height: height * 0.15,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: FancyShimmerImage(
                                        imageUrl: json.decode(
                                            grocGallery[index])["thumb"],
                                        boxFit: BoxFit.cover,
                                        shimmerBackColor: Color(0xffe0e0e0),
                                        shimmerBaseColor: Color(0xffe0e0e0),
                                        shimmerHighlightColor: Colors.grey[200],
                                      ),
                                    ),
                                  ),
                                ),
                                json.decode(currentMedia)["type"] == "video"
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                          top: height * 0.03,
                                          left: width * 0.07,
                                        ),
                                        child: Image.asset(
                                          'assets/icons/play.png',
                                          color: Colors.white,
                                          width: 60,
                                          height: 60,
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                currentMediaIndex == index
                                    ? Container(
                                        width: width * 0.3,
                                        height: height * 0.15,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.4),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          );
                        }),
                  )
                : SizedBox.shrink(),
            SizedBox(
              height: 20,
            ),
            Column(
              children: <Widget>[
                Text(
                  widget.groc.grocName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontFamily: "Roboto",
                      fontSize: 30,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  widget.groc.address,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                widget.groc.email != ""
                    ? SizedBox(
                        height: 10,
                      )
                    : SizedBox.shrink(),
                widget.groc.email != ""
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.email,
                            color: Colors.black,
                            size: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              final Uri _emailLaunchUri = Uri(
                                  scheme: 'mailto',
                                  path: widget.groc.email,
                                  queryParameters: {
                                    'subject': 'email subject'
                                  });

                              launch(_emailLaunchUri.toString());
                            },
                            child: Text(
                              widget.groc.email,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
                widget.groc.telephone1 != ""
                    ? SizedBox(
                        height: 10,
                      )
                    : SizedBox.shrink(),
                widget.groc.telephone1 != ""
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.call,
                            color: Colors.black,
                            size: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () async {
                              var url = "tel:" + widget.groc.telephone1;
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: Text(
                              widget.groc.telephone1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          )
                        ],
                      )
                    : SizedBox.shrink(),
                widget.groc.telephone2 != ""
                    ? SizedBox(
                        height: 10,
                      )
                    : SizedBox.shrink(),
                widget.groc.telephone2 != ""
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.call,
                            color: Colors.black,
                            size: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () async {
                              var url = "tel:" + widget.groc.telephone2;
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: Text(
                              widget.groc.telephone2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Chip(
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Open - ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontFamily: "Roboto",
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            format.format(widget.groc.openingTime.toDate()),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "  ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontFamily: "Roboto",
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Chip(
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Close - ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontFamily: "Roboto",
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            format.format(widget.groc.closingTime.toDate()),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                widget.groc.about != ""
                    ? SizedBox(
                        height: 20,
                      )
                    : SizedBox.shrink(),
                widget.groc.about != ""
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "About the shop",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 30,
                              fontWeight: FontWeight.w700),
                        ),
                      )
                    : SizedBox.shrink(),
                widget.groc.about != ""
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ReadMoreText(
                          widget.groc.about,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 20,
                          ),
                          trimLines: 6,
                          colorClickableText: Pallete.mainAppColor,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: '...Show more',
                          trimExpandedText: ' show less',
                        ),
                      )
                    : SizedBox.shrink(),
                widget.groc.specialHolidayshoursOfClosing != ""
                    ? SizedBox(
                        height: 20,
                      )
                    : SizedBox.shrink(),
                widget.groc.specialHolidayshoursOfClosing != ""
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Special hours and holidays that close the shop",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                      )
                    : SizedBox.shrink(),
                widget.groc.specialHolidayshoursOfClosing != ""
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "* " +
                              widget.groc.specialHolidayshoursOfClosing +
                              ".",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 20,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
                SizedBox(
                  height: 20,
                ),
                Divider(),
                widget.groc.items.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text(
                              "Grocery items",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontFamily: "Roboto",
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ExploreMoreTypes(
                                              currentUserId: currentUserId,
                                              id: widget.groc.id,
                                              grocDocId: widget.docId,
                                              grocOwnerId: widget.groc.ownerId,
                                            )));
                              },
                              child: Text(
                                "explore more",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontFamily: "Roboto",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
                widget.groc.items.isNotEmpty
                    ? StreamBuilder(
                        stream:
                            _groceryService.streamSingleGrocery(widget.groc.id),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                                child:
                                    SpinKitCircle(color: Pallete.mainAppColor));
                          } else if (snapshot.data.documents == null) {
                            return Center(
                                child:
                                    SpinKitCircle(color: Pallete.mainAppColor));
                          } else if (snapshot.data.documents.length == 0) {
                            return Center(
                                child:
                                    SpinKitCircle(color: Pallete.mainAppColor));
                          } else {
                            Grocery grocSnap = Grocery.fromDocument(
                                snapshot.data.documents[0]);
                            List<dynamic> grocitems = [];

                            grocSnap.items.forEach((item) {
                              grocitems.add(json.decode(item));
                            });

                            return SizedBox(
                              height: height * 0.3,
                              child: ListView.builder(
                                  itemCount: grocitems.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    int total = 0;

                                    List ratings = grocitems[index]["ratings"];
                                    if (ratings != null) {
                                      if (ratings.isNotEmpty) {
                                        ratings.forEach((element) {
                                          total = total + element["rate"];
                                        });
                                      }
                                    }

                                    return GroceryMenuItems(
                                      grocItems: grocitems[index],
                                      currentUserId: currentUserId,
                                      docId: widget.docId,
                                      index: index,
                                      id: widget.groc.id,
                                      ownerId: widget.groc.ownerId,
                                      rate: total == 0
                                          ? 0.0
                                          : rateAlgorithm(total),
                                      bookmarkService: _bookmarkService,
                                    );
                                  }),
                            );
                          }
                        },
                      )
                    : SizedBox.shrink(),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Rates & reviews",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontFamily: "Roboto",
                      fontSize: 25,
                      fontWeight: FontWeight.w800),
                ),
                SizedBox(
                  height: 20,
                ),
                StreamBuilder(
                  stream: _groceryService.streamSingleGrocery(widget.groc.id),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                          child: SpinKitCircle(color: Pallete.mainAppColor));
                    } else if (snapshot.data.documents == null) {
                      return Center(
                          child: SpinKitCircle(color: Pallete.mainAppColor));
                    } else if (snapshot.data.documents.length == 0) {
                      return Center(
                          child: SpinKitCircle(color: Pallete.mainAppColor));
                    } else {
                      int total = 0;
                      int no1 = 0;
                      int no2 = 0;
                      int no3 = 0;
                      int no4 = 0;
                      int no5 = 0;
                      Grocery grocSnap =
                          Grocery.fromDocument(snapshot.data.documents[0]);

                      if (grocSnap.ratings != null) {
                        if (grocSnap.ratings.isNotEmpty) {
                          grocSnap.ratings.forEach((element) {
                            total = total + element["rate"];
                            if (element["rate"] == 1) {
                              no1 = no1 + 1;
                            }
                            if (element["rate"] == 2) {
                              no2 = no2 + 1;
                            }
                            if (element["rate"] == 3) {
                              no3 = no3 + 1;
                            }
                            if (element["rate"] == 4) {
                              no4 = no4 + 1;
                            }
                            if (element["rate"] == 5) {
                              no5 = no5 + 1;
                            }
                          });
                        }
                      }

                      return Column(
                        children: <Widget>[
                          RatingBar(
                            initialRating:
                                total == 0 ? 0.0 : rateAlgorithm(total),
                            minRating: 0,
                            itemSize: 40,
                            unratedColor: Colors.grey[300],
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
                          Text(
                            total == 0
                                ? 0.0.toString()
                                : rateAlgorithm(total).toString(),
                            style: TextStyle(
                                color: Colors.grey[800],
                                fontFamily: "Roboto",
                                fontSize: 50,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ReviewsChart(
                              no1: no1,
                              no2: no2,
                              no3: no3,
                              no4: no4,
                              no5: no5,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                Divider(),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Rate your experience",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: "Roboto",
                      fontSize: 20,
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 10,
                ),
                RatingBar(
                  initialRating: 0,
                  minRating: 0,
                  itemSize: 60,
                  unratedColor: Colors.grey[300],
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  glow: true,
                  glowColor: Colors.white,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    MaterialIcons.star,
                    color: Pallete.mainAppColor,
                  ),
                  onRatingUpdate: (rating) async {
                    await _groceryService.setRatingsToGrocery(
                        widget.docId, rating, currentUserId);
                    if (currentUserId != widget.groc.ownerId) {
                      await _activityFeedService.createActivityFeed(
                        currentUserId,
                        widget.groc.ownerId,
                        widget.docId,
                        "rate_shop",
                        null,
                        null,
                        null,
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 50.0,
                  width: width * 0.7,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.black,
                            style: BorderStyle.solid,
                            width: 1.0),
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(3.0)),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GroceryReviewDisplay(
                                      currentUserId: currentUserId,
                                      docId: widget.docId,
                                      id: widget.groc.id,
                                      grocOwnerId: widget.groc.ownerId,
                                    )));
                      },
                      child: Center(
                        child: Text(
                          'Write & see all reviews',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 50.0,
                  width: width * 0.7,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.black,
                            style: BorderStyle.solid,
                            width: 1.0),
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(3.0)),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GroceryGallery(
                                      currentUserId: currentUserId,
                                      docid: widget.docId,
                                      id: widget.groc.id,
                                      groceryOwnerId: widget.groc.ownerId,
                                    )));
                      },
                      child: Center(
                        child: Text(
                          'Add to gallery',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ]),
        ));
  }
}

class GroceryMenuItems extends StatelessWidget {
  final grocItems;
  final String currentUserId;
  final String docId;
  final String id;
  final String ownerId;
  final int index;
  final double rate;
  final BookmarkService bookmarkService;

  const GroceryMenuItems(
      {this.grocItems,
      this.id,
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
                builder: (context) => GrocItemDetail(
                      grocItem: grocItems,
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
                imageUrl: grocItems["initialImage"],
                boxFit: BoxFit.cover,
                shimmerBackColor: Color(0xffe0e0e0),
                shimmerBaseColor: Color(0xffe0e0e0),
                shimmerHighlightColor: Colors.grey[200],
                height: MediaQuery.of(context).size.height * 0.17,
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
                    heroTag: index,
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
                  top: MediaQuery.of(context).size.height * 0.17,
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
                        grocItems["item_name"],
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
                        grocItems["price"] + " LKR",
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

class ReviewsChart extends StatelessWidget {
  final int no1;
  final int no2;
  final int no3;
  final int no4;
  final int no5;
  const ReviewsChart(
      {this.no1, this.no2, this.no3, this.no4, this.no5, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = Map();
    List<Color> colorList = [
      Colors.yellow,
      Colors.red,
      Colors.blue,
      Colors.greenAccent,
      Colors.indigo,
    ];

    dataMap.putIfAbsent("1 star", () => no1.toDouble());
    dataMap.putIfAbsent("2 star", () => no2.toDouble());
    dataMap.putIfAbsent("3 star", () => no3.toDouble());
    dataMap.putIfAbsent("4 star", () => no4.toDouble());
    dataMap.putIfAbsent("5 star", () => no5.toDouble());

    return PieChart(
      dataMap: dataMap,
      animationDuration: Duration(milliseconds: 800),
      chartLegendSpacing: 32.0,
      chartRadius: MediaQuery.of(context).size.width / 2.0,
      showChartValuesInPercentage: true,
      showChartValues: true,
      showChartValuesOutside: false,
      chartValueBackgroundColor: Colors.grey[200],
      colorList: colorList,
      showLegends: true,
      legendPosition: LegendPosition.right,
      decimalPlaces: 1,
      showChartValueLabel: true,
      initialAngle: 0,
      chartValueStyle: defaultChartValueStyle.copyWith(
        color: Colors.blueGrey[900].withOpacity(0.9),
      ),
      chartType: ChartType.ring,
    );
  }
}
