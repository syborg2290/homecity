import 'dart:convert';

import 'package:animator/animator.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearby/models/grocery.dart';
import 'package:nearby/services/bookmark_service.dart';
import 'package:nearby/services/grocery_service.dart';
import 'package:nearby/utils/maps/route_map.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/utils/rate_algorithm.dart';

import 'groc_item_view.dart';
import 'grocery_details.dart';

class GrocSearch extends StatefulWidget {
  final String currentUserId;
  GrocSearch({this.currentUserId, Key key}) : super(key: key);

  @override
  _GrocSearchState createState() => _GrocSearchState();
}

class _GrocSearchState extends State<GrocSearch> {
  GroceryService _groceryService = GroceryService();
  TextEditingController searchController = TextEditingController();
  BookmarkService _bookmarkService = BookmarkService();
  List search = [];
  List filteredSearch = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _groceryService.getAllGrocery().then((doc) {
      doc.documents.forEach((element) {
        Grocery groc = Grocery.fromDocument(element);
        var objRest = {
          "type": "groceries",
          "groc": groc,
          "docId": element.documentID,
          "name": groc.grocName.toLowerCase(),
        };
        setState(() {
          search.add(objRest);
        });

        groc.items.forEach((menuI) {
          var objItem = {
            "type": "item",
            "index": groc.items.indexWhere(
                (re) => json.decode(re)["id"] == json.decode(menuI)["id"]),
            "groc": groc,
            "docId": element.documentID,
            "item": json.decode(menuI),
            "name": json.decode(menuI)["item_name"].toString().toLowerCase()
          };

          setState(() {
            search.add(objItem);
            isLoading = false;
          });
        });
      });
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
        title: Padding(
          padding: const EdgeInsets.all(0.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  filteredSearch = search
                      .where((fetchRest) =>
                          fetchRest["name"].contains(val.toLowerCase()))
                      .toList();
                });
              },
              controller: searchController,
              autofocus: true,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.6), fontSize: 20.0),
              cursorColor: Colors.black,
              textAlign: TextAlign.justify,
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(
                  fontSize: 18,
                ),
                fillColor: Color(0xffe0e0e0),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 5.0, vertical: 12.0),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    color: Color(0xffe0e0e0),
                    borderRadius: BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                    child: InkWell(
                      onTap: () {},
                      child: Icon(
                        Icons.search,
                        size: 40,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(
                    right: 10,
                  ),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                    child: InkWell(
                      onTap: () {},
                      child: IconButton(
                          icon: Image.asset(
                            'assets/icons/left-arrow.png',
                            width: width * 0.07,
                            height: height * 0.07,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ),
                  ),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        elevation: 0.0,
      ),
      resizeToAvoidBottomInset: false,
      body: isLoading
          ? Container(
              color: Colors.white,
              child: Center(child: SpinKitCircle(color: Pallete.mainAppColor)),
            )
          : search.isEmpty
              ? Center(
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
                ))
              : Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: filteredSearch.isNotEmpty
                      ? GridView.count(
                          physics: ScrollPhysics(),
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          children:
                              List.generate(filteredSearch.length, (index) {
                            if (filteredSearch[index]["type"] == "groceries") {
                              return GroceryCards(
                                bookmarkService: _bookmarkService,
                                currentUserId: widget.currentUserId,
                                singleIndex: false,
                                groc: filteredSearch[index]["groc"],
                                index: index,
                                rate: filteredSearch[index]["groc"]
                                            .totalratings ==
                                        0.0
                                    ? 0.0
                                    : rateAlgorithm(filteredSearch[index]
                                            ["groc"]
                                        .totalratings
                                        .toInt()),
                              );
                            } else {
                              return GrocItems(
                                bookmarkService: _bookmarkService,
                                currentUserId: widget.currentUserId,
                                docId: filteredSearch[index]["docId"],
                                id: filteredSearch[index]["groc"].id,
                                listIndex: index,
                                index: filteredSearch[index]["index"],
                                ownerId: filteredSearch[index]["groc"].ownerId,
                                item: filteredSearch[index]["item"],
                                rate: filteredSearch[index]["item"] == null
                                    ? 0.0
                                    : filteredSearch[index]["item"]
                                                ["total_ratings"] ==
                                            0.0
                                        ? 0.0
                                        : rateAlgorithm(filteredSearch[index]
                                                ["item"]["total_ratings"]
                                            .toInt()),
                              );
                            }
                          }))
                      : GridView.count(
                          physics: ScrollPhysics(),
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          children: List.generate(search.length, (index) {
                            if (search[index]["type"] == "groceries") {
                              return GroceryCards(
                                bookmarkService: _bookmarkService,
                                currentUserId: widget.currentUserId,
                                singleIndex: false,
                                groc: search[index]["groc"],
                                index: index,
                                rate: search[index]["groc"].totalratings == 0.0
                                    ? 0.0
                                    : rateAlgorithm(search[index]["groc"]
                                        .totalratings
                                        .toInt()),
                              );
                            } else {
                              return GrocItems(
                                bookmarkService: _bookmarkService,
                                currentUserId: widget.currentUserId,
                                docId: search[index]["docId"],
                                id: search[index]["groc"].id,
                                listIndex: index,
                                index: search[index]["index"],
                                ownerId: search[index]["groc"].ownerId,
                                item: search[index]["item"],
                                rate: search[index]["item"] == null
                                    ? 0.0
                                    : search[index]["item"]["total_ratings"] ==
                                            0.0
                                        ? 0.0
                                        : rateAlgorithm(search[index]["item"]
                                                ["total_ratings"]
                                            .toInt()),
                              );
                            }
                          })),
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

class GrocItems extends StatelessWidget {
  final item;
  final String currentUserId;
  final String docId;
  final String id;
  final String ownerId;
  final int index;
  final int listIndex;
  final double rate;
  final BookmarkService bookmarkService;

  const GrocItems(
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
                height: MediaQuery.of(context).size.height * 0.25,
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
                  top: MediaQuery.of(context).size.height * 0.12,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 90,
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
