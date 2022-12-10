import 'dart:convert';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/models/grocery.dart';
import 'package:nearby/services/activity_feed_service.dart';
import 'package:nearby/services/grocery_service.dart';
import 'package:nearby/utils/full_screen_network_file.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/utils/rate_algorithm.dart';
import 'package:nearby/utils/videoplayers/network_player.dart';
import 'package:intl/intl.dart' as dd;
import 'package:pie_chart/pie_chart.dart';
import 'package:readmore/readmore.dart';

import 'groc_item_gallery.dart';
import 'grocery_item_reviews.dart';

class GrocItemDetail extends StatefulWidget {
  final grocItem;
  final String docId;
  final String id;
  final int index;
  final String currentUserId;
  final String ownerId;

  GrocItemDetail(
      {this.grocItem,
      this.id,
      this.index,
      this.currentUserId,
      this.docId,
      this.ownerId,
      Key key})
      : super(key: key);

  @override
  _GrocItemDetailState createState() => _GrocItemDetailState();
}

class _GrocItemDetailState extends State<GrocItemDetail> {
  List grocGallery = [];
  String currentMedia;
  int currentMediaIndex = 0;
  GroceryService _grocService = GroceryService();
  ActivityFeedService _activityFeedService = ActivityFeedService();
  final format = dd.DateFormat("HH:mm");

  @override
  void initState() {
    super.initState();
    if (widget.grocItem["gallery"].isNotEmpty) {
      setState(() {
        currentMedia = widget.grocItem["gallery"][0];
      });
      widget.grocItem["gallery"].forEach((element) {
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
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            grocGallery.isEmpty
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NetworkFileFullScreen(
                                    type: "image",
                                    url: widget.grocItem["initialImage"],
                                  )));
                    },
                    child: Container(
                      width: width,
                      height: height * 0.4,
                      child: FancyShimmerImage(
                        imageUrl: widget.grocItem["initialImage"],
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
                  widget.grocItem["item_name"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontFamily: "Roboto",
                      fontSize: 40,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  "( " + widget.grocItem["item_type"] + " )",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontFamily: "Roboto",
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                widget.grocItem["brand"] != ""
                    ? SizedBox(
                        height: 20,
                      )
                    : SizedBox.shrink(),
                widget.grocItem["brand"] != ""
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Brand - ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 25,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            widget.grocItem["brand"],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
                SizedBox(
                  height: 20,
                ),
                Text(
                  widget.grocItem["price"] + " LKR ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 25,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
                ),
                widget.grocItem["about"] != ""
                    ? Text(
                        "About the item",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey[800],
                            fontFamily: "Roboto",
                            fontSize: 25,
                            fontWeight: FontWeight.w800),
                      )
                    : SizedBox.shrink(),
                widget.grocItem["about"] != ""
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ReadMoreText(
                          widget.grocItem["about"].toString().toLowerCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black.withOpacity(0.6),
                          ),
                          trimLines: 6,
                          colorClickableText: Pallete.mainAppColor,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: '...Show more',
                          trimExpandedText: ' show less',
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
            SizedBox(
              height: 20,
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
              stream: _grocService.streamSingleGrocery(widget.id),
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
                  List menu = grocSnap.items;

                  List ratings = json.decode(menu[widget.index])["ratings"];

                  if (ratings != null) {
                    if (ratings.isNotEmpty) {
                      ratings.forEach((element) {
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
              allowHalfRating: false,
              glow: true,
              glowColor: Colors.white,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                MaterialIcons.star,
                color: Pallete.mainAppColor,
              ),
              onRatingUpdate: (rating) async {
                await _grocService.setRatingsToItem(
                    widget.index, widget.docId, rating, widget.currentUserId);
                if (widget.currentUserId != widget.ownerId) {
                  await _activityFeedService.createActivityFeed(
                    widget.currentUserId,
                    widget.ownerId,
                    widget.docId,
                    "rate_item",
                    widget.index,
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
                            builder: (context) => AllGrocItemsReviews(
                                  currentUserId: widget.currentUserId,
                                  docId: widget.docId,
                                  id: widget.id,
                                  index: widget.index,
                                  grocOwnerId: widget.ownerId,
                                )));
                  },
                  child: Center(
                    child: Text(
                      'Post a review & see all reviews',
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
                            builder: (context) => GroceryItemGallery(
                                  currentUserId: widget.currentUserId,
                                  docid: widget.docId,
                                  id: widget.id,
                                  index: widget.index,
                                  grocOwnerId: widget.ownerId,
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
