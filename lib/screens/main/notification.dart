import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/models/activity_feed.dart';
import 'package:nearby/models/user.dart';
import 'package:nearby/services/activity_feed_service.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:timeago/timeago.dart' as timeago;

class Notify extends StatefulWidget {
  Notify({Key key}) : super(key: key);

  @override
  _NotifyState createState() => _NotifyState();
}

class _NotifyState extends State<Notify> {
  ActivityFeedService _activityFeedService = ActivityFeedService();
  String currentUserId;
  AuthServcies _authServcies = AuthServcies();
  List<DocumentSnapshot> all = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _authServcies.getCurrentUser().then((fUser) {
      setState(() {
        currentUserId = fUser.uid;
      });
    });

    _authServcies.getAllUsers().then((allUser) {
      setState(() {
        all = allUser;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var orientation = MediaQuery.of(context).orientation;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Container(
              color: Colors.white,
              child: Center(child: SpinKitCircle(color: Pallete.mainAppColor)),
            )
          : Container(
              child: StreamBuilder(
                stream: _activityFeedService.streamActivityFeed(currentUserId),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                        child: SpinKitCircle(color: Pallete.mainAppColor));
                  } else {
                    if (snapshot.data.documents.length == 0) {
                      return Center(
                        child: EmptyListWidget(
                            title: 'No Notification',
                            subTitle: 'No  notification available yet',
                            image: 'assets/icons/bell.png',
                            titleTextStyle: Theme.of(context)
                                .typography
                                .dense
                                .display1
                                .copyWith(color: Color(0xff9da9c7)),
                            subtitleTextStyle: Theme.of(context)
                                .typography
                                .dense
                                .body2
                                .copyWith(color: Color(0xffabb8d6))),
                      );
                    } else {
                      List<ActivityFeed> feedItems = [];

                      snapshot.data.documents.forEach((doc) {
                        feedItems.add(ActivityFeed.fromDocument(doc));
                      });
                      return ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: feedItems.length,
                          itemBuilder: (context, index) {
                            return NotificationFeed(
                              feed: feedItems[index],
                              height: height,
                              width: width,
                              owner: User.fromDocument(
                                all.firstWhere(
                                    (e) => e["id"] == feedItems[index].userId,
                                    orElse: () => null),
                              ),
                            );
                          });
                    }
                  }
                },
              ),
            ),
    );
  }
}

class NotificationFeed extends StatelessWidget {
  final ActivityFeed feed;
  final double width;
  final double height;
  final User owner;

  const NotificationFeed(
      {this.feed, this.owner, this.width, this.height, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String activityItemText = "";

    if (feed.type == "rate_shop") {
      activityItemText = "rated on your shop";
    }

    if (feed.type == "review_shop") {
      activityItemText = "put a review on your shop";
    }

    if (feed.type == "rate_item") {
      activityItemText = "rated on your shop item";
    }

    if (feed.type == "review_item") {
      activityItemText = "put a review on your shop item";
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0, top: 10),
      child: ListTile(
        title: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                  text: owner.username,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  )),
              TextSpan(
                  text: ' $activityItemText',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  )),
            ],
          ),
        ),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.black.withOpacity(0.8),
          backgroundImage: owner.thumbnailUserPhotoUrl == null
              ? AssetImage('assets/profilephoto.png')
              : NetworkImage(owner.thumbnailUserPhotoUrl),
        ),
        subtitle: Text(
          timeago.format(feed.timestamp.toDate()),
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: GestureDetector(
            onTap: () async {
              // await deleteActivityFeed(
              //   userId,
              //   documentId,
              // );
              // Fluttertoast.showToast(
              //     msg: "Feed item removed",
              //     toastLength: Toast.LENGTH_SHORT,
              //     gravity: ToastGravity.CENTER,
              //     backgroundColor: Palette.appColor,
              //     textColor: Colors.white,
              //     fontSize: 16.0);
            },
            child: Image.asset(
              'assets/Icons/close.png',
              width: 30,
              height: 30,
            ),
          ),
        ),
      ),
    );
  }
}
