import 'dart:convert';

import 'package:animator/animator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearby/models/resturant.dart';
import 'package:nearby/models/user.dart';
import 'package:nearby/screens/main/fetch&display/rest/restItem_review_replys.dart';
import 'package:nearby/screens/main/fetch&display/rest/write_review_menu_items.dart';
import 'package:nearby/services/activity_feed_service.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/services/resturant_service.dart';
import 'package:nearby/utils/full_screen_network_file.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart' as timeago;

class AllMenuItemsReviews extends StatefulWidget {
  final String currentUserId;
  final String docId;
  final String id;
  final int index;
  final String restOwnerId;
  AllMenuItemsReviews(
      {this.currentUserId,
      this.index,
      this.restOwnerId,
      this.docId,
      this.id,
      Key key})
      : super(key: key);

  @override
  _AllMenuItemsReviewsState createState() => _AllMenuItemsReviewsState();
}

class _AllMenuItemsReviewsState extends State<AllMenuItemsReviews> {
  ResturantService _resturantService = ResturantService();
  ActivityFeedService _activityFeedService = ActivityFeedService();
  AuthServcies _auth = AuthServcies();
  List<DocumentSnapshot> all = [];
  List allReviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _resturantService.fetchSingleRest(widget.id).then((value) {
      DocumentSnapshot doc = value.documents[0];
      Resturant resturant = Resturant.fromDocument(doc);

      setState(() {
        if (json.decode(resturant.menu[widget.index])["review"] != null) {
          allReviews = json.decode(resturant.menu[widget.index])["review"];
        }
      });
    });
    _auth.getAllUsers().then((allUser) {
      setState(() {
        all = allUser;
        isLoading = false;
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
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
              icon: Image.asset(
                'assets/icons/left-arrow.png',
                width: width * 0.07,
                height: height * 0.07,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        centerTitle: true,
        title: Text(
          "",
          style: TextStyle(
              color: Colors.grey[700],
              fontFamily: "Roboto",
              fontSize: 25,
              fontWeight: FontWeight.w400),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WriteMenuItemReview(
                                    currentUserId: widget.currentUserId,
                                    id: widget.id,
                                    index: widget.index,
                                    restId: widget.docId,
                                    restOwnerId: widget.restOwnerId,
                                    listIndex: allReviews.length,
                                  )));
                    },
              child: Center(
                  child: Text("Write a review",
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.white,
                      ))),
              color: Pallete.mainAppColor,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: Pallete.mainAppColor,
                  )),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Container(
              color: Colors.white,
              child: Center(child: SpinKitCircle(color: Pallete.mainAppColor)),
            )
          : StreamBuilder(
              stream: _resturantService.streamSingleRest(widget.id),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    color: Colors.white,
                    child: Center(
                        child: SpinKitCircle(color: Pallete.mainAppColor)),
                  );
                }
                if (snapshot.data.documents == null) {
                  return Padding(
                    padding: EdgeInsets.only(top: height * 0.2),
                    child: Column(
                      children: <Widget>[
                        Center(
                            child: Image.asset(
                          'assets/icons/review.png',
                          width: width * 0.7,
                          color: Colors.grey,
                        )),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Empty reviews",
                          style: TextStyle(
                              color: Colors.grey,
                              fontFamily: "Roboto",
                              fontSize: 40,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.data.documents.length == 0) {
                  return Padding(
                    padding: EdgeInsets.only(top: height * 0.2),
                    child: Column(
                      children: <Widget>[
                        Center(
                            child: Image.asset(
                          'assets/icons/review.png',
                          width: width * 0.7,
                          color: Colors.grey,
                        )),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Empty reviews",
                          style: TextStyle(
                              color: Colors.grey,
                              fontFamily: "Roboto",
                              fontSize: 40,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  );
                } else {
                  List itemReviews = [];

                  Resturant rest =
                      Resturant.fromDocument(snapshot.data.documents[0]);
                  var obj = json.decode(rest.menu[widget.index]);
                  if (obj["review"] != null) {
                    itemReviews = obj["review"];
                    return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: itemReviews.length,
                        itemBuilder: (context, index) => ReviewDisplay(
                              obj: itemReviews[index],
                              owner: User.fromDocument(
                                all.firstWhere(
                                    (e) =>
                                        e["id"] == itemReviews[index]["userId"],
                                    orElse: () => null),
                              ),
                              height: height,
                              width: width,
                              indexItem: widget.index,
                              currentUserId: widget.currentUserId,
                              rest: _resturantService,
                              reviewIndex: index,
                              docId: widget.docId,
                              feedService: _activityFeedService,
                              id: widget.id,
                              length: itemReviews.length,
                              restOwnerId: widget.restOwnerId,
                            ));
                  } else {
                    return Padding(
                      padding: EdgeInsets.only(top: height * 0.2),
                      child: Column(
                        children: <Widget>[
                          Center(
                              child: Image.asset(
                            'assets/icons/review.png',
                            width: width * 0.7,
                            color: Colors.grey,
                          )),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Empty reviews",
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: "Roboto",
                                fontSize: 40,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
            ),
    );
  }
}

class ReviewDisplay extends StatelessWidget {
  final obj;
  final String restOwnerId;
  final String id;
  final String docId;
  final User owner;
  final double width;
  final int indexItem;
  final double height;
  final String currentUserId;
  final int reviewIndex;
  final ResturantService rest;
  final int length;
  final ActivityFeedService feedService;

  const ReviewDisplay(
      {this.obj,
      this.restOwnerId,
      this.id,
      this.docId,
      this.indexItem,
      this.currentUserId,
      this.width,
      this.height,
      this.owner,
      this.reviewIndex,
      this.rest,
      this.length,
      this.feedService,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List reviewMedia = [];
    List likes = [];
    List dislikes = [];
    List replys = [];

    if (obj["media"] != null) {
      reviewMedia = json.decode(obj["media"]);
    }
    if (obj["reactions"] != null) {
      obj["reactions"].forEach((ele) {
        if (ele["reaction"] == "like") {
          likes.add(ele);
        }

        if (ele["reaction"] == "dislike") {
          dislikes.add(ele);
        }
      });
    }

    if (obj["replys"] != null) {
      replys = obj["replys"];
    }

    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 20,
            ),
            child: InkWell(
              onTap: () {},
              child: Row(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40.0),
                        border: Border.all(
                          color: Pallete.mainAppColor,
                          width: 3,
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Hero(
                        transitionOnUserGestures: true,
                        tag: owner.username + reviewIndex.toString(),
                        child: CircleAvatar(
                          maxRadius: 15,
                          backgroundColor: Color(0xffe0e0e0),
                          backgroundImage: owner.thumbnailUserPhotoUrl == null
                              ? AssetImage('assets/profilephoto.png')
                              : NetworkImage(owner.thumbnailUserPhotoUrl),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: <Widget>[
                      Text(owner.username,
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.black.withOpacity(0.7),
                              fontWeight: FontWeight.w500)),
                      Text(
                        timeago.format(DateTime.parse(obj["timestamp"])),
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  currentUserId == owner.id
                      ? Padding(
                          padding: EdgeInsets.only(
                            left: width * 0.4,
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              AwesomeDialog(
                                context: context,
                                animType: AnimType.SCALE,
                                dialogType: DialogType.NO_HEADER,
                                body: Center(
                                  child: Text(
                                    'Are you sure to continue?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                btnOkColor: Pallete.mainAppColor,
                                btnCancelColor: Pallete.mainAppColor,
                                btnOkText: 'Yes',
                                btnCancelText: 'No',
                                btnOkOnPress: () async {
                                  await rest.deleteResturantItemReview(
                                      indexItem, docId, reviewIndex);
                                  await feedService.removeReviewFeeds(
                                    owner.id,
                                    restOwnerId,
                                    docId,
                                    indexItem,
                                    reviewIndex,
                                  );
                                  Fluttertoast.showToast(
                                      msg: "Review removed",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      backgroundColor: Pallete.mainAppColor,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                },
                                btnCancelOnPress: () {},
                              )..show();
                            },
                            child: Image.asset(
                              'assets/icons/delete.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          reviewMedia.isNotEmpty
              ? SizedBox(
                  height: height * 0.20,
                  child: ListView.builder(
                      itemCount: reviewMedia.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: width * 0.35,
                            height: height * 0.20,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10)),
                            child: json.decode(reviewMedia[index])["type"] ==
                                    "image"
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NetworkFileFullScreen(
                                                    url: json.decode(
                                                            reviewMedia[index])[
                                                        "url"],
                                                    type: "image",
                                                  )));
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: FancyShimmerImage(
                                        imageUrl: json.decode(
                                            reviewMedia[index])["thumb"],
                                        boxFit: BoxFit.cover,
                                        shimmerBackColor: Color(0xffe0e0e0),
                                        shimmerBaseColor: Color(0xffe0e0e0),
                                        shimmerHighlightColor: Colors.grey[200],
                                      ),
                                    ),
                                  )
                                : json.decode(reviewMedia[index])["type"] ==
                                        "video"
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Stack(
                                          children: <Widget>[
                                            FancyShimmerImage(
                                              imageUrl: json.decode(
                                                  reviewMedia[index])["thumb"],
                                              boxFit: BoxFit.cover,
                                              shimmerBackColor:
                                                  Color(0xffe0e0e0),
                                              shimmerBaseColor:
                                                  Color(0xffe0e0e0),
                                              shimmerHighlightColor:
                                                  Colors.grey[200],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: height * 0.03,
                                                left: width * 0.07,
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              NetworkFileFullScreen(
                                                                url: json.decode(
                                                                    reviewMedia[
                                                                        index])["url"],
                                                                type: "video",
                                                              )));
                                                },
                                                child: Image.asset(
                                                  'assets/icons/play.png',
                                                  color: Colors.white,
                                                  width: 60,
                                                  height: 60,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: width * 0.3,
                                              height: height * 0.15,
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      NetworkFileFullScreen(
                                                        url: json.decode(
                                                            reviewMedia[
                                                                index])["url"],
                                                        type: "pano",
                                                      )));
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Stack(
                                            children: <Widget>[
                                              FancyShimmerImage(
                                                imageUrl: json.decode(
                                                        reviewMedia[index])[
                                                    "thumb"],
                                                boxFit: BoxFit.cover,
                                                shimmerBackColor:
                                                    Color(0xffe0e0e0),
                                                shimmerBaseColor:
                                                    Color(0xffe0e0e0),
                                                shimmerHighlightColor:
                                                    Colors.grey[200],
                                              ),
                                              Container(
                                                width: width * 0.3,
                                                height: height * 0.20,
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                              ),
                                              Animator(
                                                duration: Duration(
                                                    milliseconds: 2000),
                                                tween:
                                                    Tween(begin: 1.2, end: 1.3),
                                                curve: Curves.bounceIn,
                                                cycles: 0,
                                                builder: (anim) => Center(
                                                  child: Transform.scale(
                                                    scale: anim.value,
                                                    child: Image.asset(
                                                      'assets/icons/arrows.png',
                                                      width: 50,
                                                      height: 50,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                          ),
                        );
                      }),
                )
              : Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: ReadMoreText(
                    obj["review"],
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    trimLines: 6,
                    colorClickableText: Pallete.mainAppColor,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: '...Show more',
                    trimExpandedText: ' show less',
                  ),
                ),
          SizedBox(
            height: 5,
          ),
          reviewMedia.isEmpty
              ? SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ReadMoreText(
                    obj["review"],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    trimLines: 6,
                    colorClickableText: Colors.pink,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: '...Show more',
                    trimExpandedText: ' show less',
                  ),
                ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      await rest.setReactionsToResturantItemReview(
                          indexItem, docId, currentUserId, reviewIndex, "like");
                      if (currentUserId != owner.id) {
                        await feedService.createActivityFeed(
                          currentUserId,
                          owner.id,
                          docId,
                          "review_like",
                          indexItem,
                          reviewIndex,
                          null,
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: obj["reactions"] == null
                              ? null
                              : obj["reactions"].firstWhere(
                                              (element) =>
                                                  element["userId"] ==
                                                  currentUserId,
                                              orElse: () => null) !=
                                          null &&
                                      obj["reactions"][obj["reactions"]
                                              .indexWhere((element) =>
                                                  element["userId"] ==
                                                  currentUserId)]["reaction"] ==
                                          "like"
                                  ? Pallete.mainAppColor
                                  : null,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: obj["reactions"] == null
                                ? Colors.black
                                : obj["reactions"].firstWhere(
                                                (element) =>
                                                    element["userId"] ==
                                                    currentUserId,
                                                orElse: () => null) !=
                                            null &&
                                        obj["reactions"][obj["reactions"]
                                                    .indexWhere((element) =>
                                                        element["userId"] ==
                                                        currentUserId)]
                                                ["reaction"] ==
                                            "like"
                                    ? Pallete.mainAppColor
                                    : Colors.black,
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/icons/thumbup.png',
                          width: 20,
                          height: 20,
                          color: obj["reactions"] == null
                              ? null
                              : obj["reactions"].firstWhere(
                                              (element) =>
                                                  element["userId"] ==
                                                  currentUserId,
                                              orElse: () => null) !=
                                          null &&
                                      obj["reactions"][obj["reactions"]
                                              .indexWhere((element) =>
                                                  element["userId"] ==
                                                  currentUserId)]["reaction"] ==
                                          "like"
                                  ? Colors.white
                                  : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(obj["reactions"] == null
                      ? 0.toString() + " likes"
                      : likes.length.toString() + " likes"),
                ],
              ),
              Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      await rest.setReactionsToResturantItemReview(indexItem,
                          docId, currentUserId, reviewIndex, "dislike");
                      if (currentUserId != owner.id) {
                        await feedService.createActivityFeed(
                          currentUserId,
                          owner.id,
                          docId,
                          "review_dislike",
                          indexItem,
                          reviewIndex,
                          null,
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: obj["reactions"] == null
                              ? null
                              : obj["reactions"].firstWhere(
                                              (element) =>
                                                  element["userId"] ==
                                                  currentUserId,
                                              orElse: () => null) !=
                                          null &&
                                      obj["reactions"][obj["reactions"]
                                              .indexWhere((element) =>
                                                  element["userId"] ==
                                                  currentUserId)]["reaction"] ==
                                          "dislike"
                                  ? Colors.red
                                  : null,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: obj["reactions"] == null
                                ? Colors.black
                                : obj["reactions"].firstWhere(
                                                (element) =>
                                                    element["userId"] ==
                                                    currentUserId,
                                                orElse: () => null) !=
                                            null &&
                                        obj["reactions"][obj["reactions"]
                                                    .indexWhere((element) =>
                                                        element["userId"] ==
                                                        currentUserId)]
                                                ["reaction"] ==
                                            "dislike"
                                    ? Colors.red
                                    : Colors.black,
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/icons/thumbdown.png',
                          width: 20,
                          height: 20,
                          color: obj["reactions"] == null
                              ? null
                              : obj["reactions"].firstWhere(
                                              (element) =>
                                                  element["userId"] ==
                                                  currentUserId,
                                              orElse: () => null) !=
                                          null &&
                                      obj["reactions"][obj["reactions"]
                                              .indexWhere((element) =>
                                                  element["userId"] ==
                                                  currentUserId)]["reaction"] ==
                                          "dislike"
                                  ? Colors.white
                                  : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(obj["reactions"] == null
                      ? 0.toString() + " dislikes"
                      : dislikes.length.toString() + " dislikes"),
                ],
              ),
              Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RestItemReviewReply(
                                    reviewOwner: owner.username,
                                    reviewOwnerId: owner.id,
                                    currentUserId: currentUserId,
                                    docId: docId,
                                    id: id,
                                    index: indexItem,
                                    ownerId: owner.id,
                                    reviewIndex: reviewIndex,
                                  )));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.black,
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/icons/reply.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(obj["replys"] == null
                      ? 0.toString() + " replys"
                      : replys.length.toString() + " replys"),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          reviewIndex != length - 1
              ? Divider(
                  color: Colors.black.withOpacity(0.1),
                  thickness: 2.0,
                )
              : SizedBox.shrink(),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
