import 'package:animator/animator.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearby/models/place.dart';
import 'package:nearby/screens/main/fetch&display/places/place_details_page.dart';
import 'package:nearby/services/bookmark_service.dart';
import 'package:nearby/services/place_service.dart';
import 'package:nearby/utils/maps/route_map.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/utils/rate_algorithm.dart';

class FilteredPlace extends StatefulWidget {
  final List<Place> list;
  final String currentUserId;
  FilteredPlace({this.list, this.currentUserId, Key key}) : super(key: key);

  @override
  _FilteredPlaceState createState() => _FilteredPlaceState();
}

class _FilteredPlaceState extends State<FilteredPlace> {
  BookmarkService _bookmarkService = BookmarkService();
  PlaceService _placeService = PlaceService();
  List docIds = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    if (widget.list.isEmpty) {
      setState(() {
        isLoading = false;
      });
    } else {
      widget.list.forEach((element) {
        _placeService.fetchSinglePlace(element.id).then((value) {
          setState(() {
            docIds.add(value.documents[0].documentID);
            isLoading = false;
          });
        });
      });
    }
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
      body: isLoading
          ? Container(
              color: Colors.white,
              child: Center(child: SpinKitCircle(color: Pallete.mainAppColor)),
            )
          : GridView.count(
              physics: ScrollPhysics(),
              crossAxisCount: 2,
              shrinkWrap: true,
              children: List.generate(widget.list.length, (index) {
                return PlaceCards(
                  bookmarkService: _bookmarkService,
                  currentUserId: widget.currentUserId,
                  singleIndex: false,
                  place: widget.list[index],
                  index: index,
                  rate: widget.list[index].totalratings == 0.0
                      ? 0.0
                      : rateAlgorithm(widget.list[index].totalratings.toInt()),
                );
              })),
    );
  }
}

class PlaceCards extends StatelessWidget {
  final Place place;
  final String docId;
  final int index;
  final bool singleIndex;
  final double rate;
  final String currentUserId;
  final BookmarkService bookmarkService;

  const PlaceCards(
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
