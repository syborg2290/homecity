import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearby/models/bookmarks.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/services/bookmark_service.dart';
import 'package:nearby/utils/pallete.dart';

class BookmarksMain extends StatefulWidget {
  BookmarksMain({Key key}) : super(key: key);

  @override
  _BookmarksMainState createState() => _BookmarksMainState();
}

class _BookmarksMainState extends State<BookmarksMain> {
  String currentUserId;
  AuthServcies _authServcies = AuthServcies();
  BookmarkService _bookmarkService = BookmarkService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _authServcies.getCurrentUser().then((fUser) {
      setState(() {
        currentUserId = fUser.uid;
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
          "Bookmarks",
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
                stream: _bookmarkService.streamBookmarks(currentUserId),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                        child: SpinKitCircle(color: Pallete.mainAppColor));
                  } else {
                    if (snapshot.data.documents.length == 0) {
                      return Center(
                        child: EmptyListWidget(
                            title: 'No Bookmarks',
                            subTitle: 'No bookmarks available yet',
                            image: 'assets/icons/bookmark.png',
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
                      List<Bookmarks> bookmarksItems = [];

                      snapshot.data.documents.forEach((doc) {
                        bookmarksItems.add(Bookmarks.fromDocument(doc));
                      });
                      return ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: bookmarksItems.length,
                          itemBuilder: (context, index) {
                            // return BookmarkCard(
                            //   height: height,
                            //   currentUserId: currentUserId,
                            //   width: width,
                            // );

                            return Text("");
                          });
                    }
                  }
                },
              ),
            ),
    );
  }
}
