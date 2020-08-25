import 'dart:convert';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/models/resturant.dart';
import 'package:nearby/services/resturant_service.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/utils/rate_algorithm.dart';

import 'menu_item_detail.dart';

class ExploreMoreMenuTypes extends StatefulWidget {
  final String restDocId;
  final String currentUserId;
  final String restOwnerId;
  final String id;
  ExploreMoreMenuTypes(
      {this.restDocId, this.id, this.restOwnerId, this.currentUserId, Key key})
      : super(key: key);

  @override
  _ExploreMoreMenuTypesState createState() => _ExploreMoreMenuTypesState();
}

class _ExploreMoreMenuTypesState extends State<ExploreMoreMenuTypes> {
  String current = "All";
  ResturantService _resturantService = ResturantService();

  @override
  void initState() {
    super.initState();
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
        centerTitle: false,
        title: Text(
          'Explore food menu',
          style: TextStyle(
              color: Colors.grey[700],
              fontFamily: "Roboto",
              fontSize: 20,
              fontWeight: FontWeight.w400),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder(
                  future: DefaultAssetBundle.of(context)
                      .loadString("assets/json/explore_Foods.json"),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                          child: SpinKitCircle(color: Pallete.mainAppColor));
                    }
                    List myData = json.decode(snapshot.data);

                    return SizedBox(
                      height: height * 0.07,
                      child: ListView.builder(
                          itemCount: myData.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    current = myData[index]['category_name'];
                                  });
                                },
                                child: Chip(
                                  backgroundColor:
                                      current == myData[index]['category_name']
                                          ? Pallete.mainAppColor
                                          : null,
                                  label: Text(
                                    myData[index]['category_name'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                    );
                  }),
            ),
            SizedBox(
              height: 10,
            ),
            StreamBuilder(
              stream: _resturantService.streamSingleRest(widget.id),
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
                    if (current == "All") {
                      menu.add(item);
                    } else {
                      if (json.decode(item)["item_type"] == current) {
                        menu.add(item);
                      }
                    }
                  });

                  return menu.isEmpty
                      ? Padding(
                          padding: EdgeInsets.only(top: height * 0.2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                'assets/icons/fast-food.png',
                                color: Colors.grey,
                                width: width * 0.4,
                                height: height * 0.2,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Empty foods",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 30,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.count(
                          physics: ScrollPhysics(),
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          children: List.generate(menu.length, (index) {
                            int total = 0;

                            List ratings = json.decode(menu[index])["ratings"];
                            if (ratings != null) {
                              if (ratings.isNotEmpty) {
                                ratings.forEach((element) {
                                  total = total + element["rate"];
                                });
                              }
                            }

                            return ResturantMenuItems(
                              restMenu: json.decode(menu[index]),
                              currentUserId: widget.currentUserId,
                              docId: widget.restDocId,
                              index: index,
                              id: widget.id,
                              ownerId: widget.restOwnerId,
                              rate: total == 0 ? 0.0 : rateAlgorithm(total),
                            );
                          }));
                }
              },
            )
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

  const ResturantMenuItems(
      {this.restMenu,
      this.id,
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
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            children: <Widget>[
              FancyShimmerImage(
                imageUrl: restMenu["initialImage"],
                boxFit: BoxFit.cover,
                shimmerBackColor: Color(0xffe0e0e0),
                shimmerBaseColor: Color(0xffe0e0e0),
                shimmerHighlightColor: Colors.grey[200],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 45,
                  height: 45,
                  child: FloatingActionButton(
                    onPressed: () {},
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
                  top: MediaQuery.of(context).size.height * 0.12,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
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
                          fontSize: 15,
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
