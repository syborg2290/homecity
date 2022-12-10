import 'dart:convert';

import 'package:animator/animator.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearby/screens/main/fetch&display/rest/resturant_gallery.dart';
import 'package:nearby/services/activity_feed_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/models/resturant.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/services/bookmark_service.dart';
import 'package:nearby/services/resturant_service.dart';
import 'package:nearby/utils/maps/route_map.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/utils/rate_algorithm.dart';
import 'package:nearby/utils/videoplayers/network_player.dart';
import 'package:nearby/utils/full_screen_network_file.dart';
import 'package:intl/intl.dart' as dd;
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'display_rest_reviews.dart';
import 'explore_menu_types.dart';
import 'menu_item_detail.dart';

class ResturantDetailView extends StatefulWidget {
  final Resturant rest;
  final String docId;
  ResturantDetailView({this.rest, this.docId, Key key}) : super(key: key);

  @override
  _ResturantDetailViewState createState() => _ResturantDetailViewState();
}

class _ResturantDetailViewState extends State<ResturantDetailView> {
  List restGallery = [];
  String currentMedia;
  int currentMediaIndex = 0;
  AuthServcies _authServcies = AuthServcies();
  ResturantService _resturantService = ResturantService();
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
    if (widget.rest.gallery.isNotEmpty) {
      setState(() {
        currentMedia = widget.rest.gallery[0];
      });
      widget.rest.gallery.forEach((element) {
        setState(() {
          restGallery.add(element);
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
                borderRadius: BorderRadius.all(Radius.circular(height * 0.09))),
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
                              currentUserId, "rest_main", widget.docId, null);
                          Fluttertoast.showToast(
                              msg: "Added to the bookmark list",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Pallete.mainAppColor,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      heroTag: "rest&cafes",
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
                                  latitude: widget.rest.latitude,
                                  longitude: widget.rest.longitude,
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
        child: Column(
          children: <Widget>[
            restGallery.isEmpty
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NetworkFileFullScreen(
                                    type: "image",
                                    url: widget.rest.initialImage,
                                  )));
                    },
                    child: Container(
                      width: width,
                      height: height * 0.4,
                      child: FancyShimmerImage(
                        imageUrl: widget.rest.initialImage,
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
            restGallery.length > 1
                ? SizedBox(
                    height: height * 0.15,
                    child: ListView.builder(
                        itemCount: restGallery.length,
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
                                      currentMedia = restGallery[index];
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
                                            restGallery[index])["thumb"],
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
                  widget.rest.restName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontFamily: "Roboto",
                      fontSize: 30,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  widget.rest.address,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                widget.rest.email != ""
                    ? SizedBox(
                        height: 10,
                      )
                    : SizedBox.shrink(),
                widget.rest.email != ""
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
                                  path: widget.rest.email,
                                  queryParameters: {
                                    'subject': 'email subject'
                                  });

                              launch(_emailLaunchUri.toString());
                            },
                            child: Text(
                              widget.rest.email,
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
                widget.rest.website != ""
                    ? SizedBox(
                        height: 10,
                      )
                    : SizedBox.shrink(),
                widget.rest.website != ""
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/icons/internet.png',
                            width: 20,
                            height: 20,
                            color: Colors.black,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () async {
                              var url = "https://" + widget.rest.website;
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: Text(
                              widget.rest.website,
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
              ],
            ),
            widget.rest.telephone1 != ""
                ? SizedBox(
                    height: 10,
                  )
                : SizedBox.shrink(),
            widget.rest.telephone1 != ""
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
                          var url = "tel:" + widget.rest.telephone1;
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        child: Text(
                          widget.rest.telephone1,
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
            widget.rest.telephone2 != ""
                ? SizedBox(
                    height: 10,
                  )
                : SizedBox.shrink(),
            widget.rest.telephone2 != ""
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
                          var url = "tel:" + widget.rest.telephone2;
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        child: Text(
                          widget.rest.telephone2,
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
                        format.format(widget.rest.openingTime.toDate()),
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
                        format.format(widget.rest.closingTime.toDate()),
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
            SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        border: Border.all(color: Colors.black)),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        'assets/icons/dining.png',
                        width: 40,
                        height: 40,
                        color: widget.rest.serviceType.contains("Dine-in") ||
                                widget.rest.serviceType.contains("Any")
                            ? Colors.black
                            : Colors.grey.withOpacity(0.4),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        border: Border.all(
                          color: Colors.black,
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        'assets/icons/takeaway.png',
                        width: 40,
                        height: 40,
                        color: widget.rest.serviceType.contains("Take-away") ||
                                widget.rest.serviceType.contains("Any")
                            ? Colors.black
                            : Colors.grey.withOpacity(0.4),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        border: Border.all(
                          color: Colors.black,
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        'assets/icons/delivery.png',
                        width: 40,
                        height: 40,
                        color: widget.rest.serviceType.contains("Delivery") ||
                                widget.rest.serviceType.contains("Any")
                            ? Colors.black
                            : Colors.grey.withOpacity(0.4),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        border: Border.all(
                          color: Colors.black,
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        'assets/icons/wifi.png',
                        width: 40,
                        height: 40,
                        color: widget.rest.serviceType.contains("Wifi") ||
                                widget.rest.serviceType.contains("Any")
                            ? Colors.black
                            : Colors.grey.withOpacity(0.4),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        border: Border.all(
                          color: Colors.black,
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        'assets/icons/car_park.png',
                        width: 40,
                        height: 40,
                        color: widget.rest.serviceType.contains("Parking") ||
                                widget.rest.serviceType.contains("Any")
                            ? Colors.black
                            : Colors.grey.withOpacity(0.4),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        border: Border.all(
                          color: Colors.black,
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        'assets/icons/wine.png',
                        width: 40,
                        height: 40,
                        color: widget.rest.serviceType.contains("Drinks") ||
                                widget.rest.serviceType.contains("Any")
                            ? Colors.black
                            : Colors.grey.withOpacity(0.4),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        border: Border.all(
                          color: Colors.black,
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        'assets/icons/birthday.png',
                        width: 40,
                        height: 40,
                        color:
                            widget.rest.serviceType.contains("Celebrations") ||
                                    widget.rest.serviceType.contains("Any")
                                ? Colors.black
                                : Colors.grey.withOpacity(0.4),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            widget.rest.deliveryrRange == null
                ? SizedBox.shrink()
                : widget.rest.deliveryrRange == ""
                    ? SizedBox.shrink()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Delivery range - ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            "Around " + widget.rest.deliveryrRange + " KM",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
            widget.rest.aboutRest != ""
                ? SizedBox(
                    height: 20,
                  )
                : SizedBox.shrink(),
            widget.rest.aboutRest != ""
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
            widget.rest.aboutRest != ""
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ReadMoreText(
                      widget.rest.aboutRest,
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
            widget.rest.specialHolidayshoursOfClosing != ""
                ? SizedBox(
                    height: 20,
                  )
                : SizedBox.shrink(),
            widget.rest.specialHolidayshoursOfClosing != ""
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
            widget.rest.specialHolidayshoursOfClosing != ""
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "* " + widget.rest.specialHolidayshoursOfClosing + ".",
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
            widget.rest.menu.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          "Menu items",
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
                                    builder: (context) => ExploreMoreMenuTypes(
                                          currentUserId: currentUserId,
                                          id: widget.rest.id,
                                          restDocId: widget.docId,
                                          restOwnerId: widget.rest.ownerId,
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
            widget.rest.menu.isNotEmpty
                ? StreamBuilder(
                    stream: _resturantService.streamSingleRest(widget.rest.id),
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
                        Resturant restSnap =
                            Resturant.fromDocument(snapshot.data.documents[0]);
                        List<dynamic> menu = [];

                        restSnap.menu.forEach((item) {
                          menu.add(json.decode(item));
                        });

                        return SizedBox(
                          height: height * 0.3,
                          child: ListView.builder(
                              itemCount: menu.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                int total = 0;

                                List ratings = menu[index]["ratings"];
                                if (ratings != null) {
                                  if (ratings.isNotEmpty) {
                                    ratings.forEach((element) {
                                      total = total + element["rate"];
                                    });
                                  }
                                }

                                return ResturantMenuItems(
                                  restMenu: menu[index],
                                  currentUserId: currentUserId,
                                  docId: widget.docId,
                                  index: index,
                                  id: widget.rest.id,
                                  ownerId: widget.rest.ownerId,
                                  rate: total == 0 ? 0.0 : rateAlgorithm(total),
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
              stream: _resturantService.streamSingleRest(widget.rest.id),
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
                  Resturant restSnap =
                      Resturant.fromDocument(snapshot.data.documents[0]);

                  if (restSnap.ratings != null) {
                    if (restSnap.ratings.isNotEmpty) {
                      restSnap.ratings.forEach((element) {
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
                        initialRating: total == 0 ? 0.0 : rateAlgorithm(total),
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
                await _resturantService.setRatingsToResturant(
                    widget.docId, rating, currentUserId);
                if (currentUserId != widget.rest.ownerId) {
                  await _activityFeedService.createActivityFeed(
                    currentUserId,
                    widget.rest.ownerId,
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
                            builder: (context) => RestReviewDisplay(
                                  currentUserId: currentUserId,
                                  docId: widget.docId,
                                  id: widget.rest.id,
                                  restOwnerId: widget.rest.ownerId,
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
                            builder: (context) => ResturantGallery(
                                  currentUserId: currentUserId,
                                  docid: widget.docId,
                                  id: widget.rest.id,
                                  restOwnerId: widget.rest.ownerId,
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
      ),
    );
  }
}

class ResturantMenuItems extends StatelessWidget {
  final restMenu;
  final String currentUserId;
  final String docId;
  final String id;
  final String ownerId;
  final int index;
  final double rate;
  final BookmarkService bookmarkService;

  const ResturantMenuItems(
      {this.restMenu,
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
                builder: (context) => MenuItemDetail(
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
