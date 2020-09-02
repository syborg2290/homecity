import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearby/services/bookmark_service.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/utils/rate_algorithm.dart';

import 'groc_item_view.dart';


class FilteredItems extends StatefulWidget {
  final List list;
  final String currentUserId;
  FilteredItems({this.list, this.currentUserId, Key key}) : super(key: key);

  @override
  _FilteredItemsState createState() => _FilteredItemsState();
}

class _FilteredItemsState extends State<FilteredItems> {
  BookmarkService _bookmarkService = BookmarkService();

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
        centerTitle: true,
        title: Text(
          "Your filter",
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
      ),
      body: GridView.count(
          physics: ScrollPhysics(),
          crossAxisCount: 2,
          shrinkWrap: true,
          children: List.generate(widget.list.length, (index) {
            return MenuItems(
              bookmarkService: _bookmarkService,
              currentUserId: widget.currentUserId,
              index: widget.list[index]["index"],
              rate: widget.list[index]["total_ratings"] == 0.0
                  ? 0.0
                  : rateAlgorithm(widget.list[index]["total_ratings"].toInt()),
              docId: widget.list[index]["docId"],
              id: widget.list[index]["grocId"],
              listIndex: index,
              ownerId: widget.list[index]["grocOwnerId"],
              restMenu: widget.list[index],
            );
          })),
    );
  }
}

class MenuItems extends StatelessWidget {
  final restMenu;
  final String currentUserId;
  final String docId;
  final String id;
  final String ownerId;
  final int index;
  final int listIndex;
  final double rate;
  final BookmarkService bookmarkService;

  const MenuItems(
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
                builder: (context) => GrocItemView(
                      grocItem: restMenu,
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
