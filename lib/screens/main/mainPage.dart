import 'package:animator/animator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/models/resturant.dart';
import 'package:nearby/screens/main/sub/select_category.dart';
import 'package:nearby/services/resturant_service.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/utils/shimmers/card_row_shimmer.dart';
import 'package:nearby/utils/shimmers/main_window.dart';
import 'package:nearby/widgets/services_categories.dart';

import 'fetch&display/rest/rest_detail_view.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ResturantService _resturantService = ResturantService();

  int restCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getResturantCount();
  }

  getResturantCount() async {
    QuerySnapshot qSnap = await _resturantService.getAllResturant();
    setState(() {
      restCount = qSnap.documents.length;
      isLoading = false;
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
          padding: const EdgeInsets.only(
            left: 20,
            bottom: 10,
          ),
          child: Image.asset(
            'assets/logo.png',
            width: 30,
            height: 30,
            color: Pallete.mainAppColor,
          ),
        ),
        centerTitle: false,
        title: Text(
          'Home city',
          style: TextStyle(
              color: Colors.grey[700],
              fontFamily: "Roboto",
              fontSize: 25,
              fontWeight: FontWeight.w400),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              right: 20,
              bottom: 10,
            ),
            child: Icon(
              Icons.search,
              size: 40,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 20,
              bottom: 10,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SelectCategory();
                }));
              },
              child: Image.asset(
                'assets/icons/plus.png',
                width: 30,
                height: 30,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: isLoading
            ? mainWindow(context)
            : Column(
                children: <Widget>[
                  Divider(),
                  MainCategory(
                    restCount: restCount,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Popular resturants & cafes",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontFamily: "Roboto",
                                fontSize: 22,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            "more",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 18,
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ),
                  restCount > 0
                      ? StreamBuilder(
                          stream: _resturantService.streamResturant(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                              return Container(
                                color: Colors.white,
                                child: Center(
                                    child: SpinKitCircle(
                                        color: Pallete.mainAppColor)),
                              );
                            }
                            if (snapshot.data.documents.length == 0) {
                              return cardRow(context);
                            } else {
                              List<Resturant> popularRests = [];
                              List<String> docIds = [];

                              snapshot.data.documents.forEach((doc) {
                                Resturant rest = Resturant.fromDocument(doc);
                                popularRests.add(rest);
                                docIds.add(doc.documentID);
                              });

                              return SizedBox(
                                height: height * 0.4,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: popularRests.length,
                                    itemBuilder: (context, index) =>
                                        TrendingResturantsCards(
                                          rest: popularRests[index],
                                          docId: docIds[index],
                                        )),
                              );
                            }
                          },
                        )
                      : SizedBox.shrink(),
                ],
              ),
      ),
    );
  }
}

class TrendingResturantsCards extends StatelessWidget {
  final Resturant rest;
  final String docId;

  const TrendingResturantsCards({this.rest, this.docId, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ResturantDetailView(
                      rest: rest,
                      docId: docId,
                    )));
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            children: <Widget>[
              FancyShimmerImage(
                imageUrl: rest.initialImage,
                boxFit: BoxFit.cover,
                shimmerBackColor: Color(0xffe0e0e0),
                shimmerBaseColor: Color(0xffe0e0e0),
                shimmerHighlightColor: Colors.grey[200],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {},
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
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.235,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: 140,
                  decoration: new BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: new BorderRadius.all(Radius.circular(0.0))),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        rest.restName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        rest.address,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.call,
                            color: Colors.grey,
                            size: 25,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            rest.telephone1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                            ),
                          ),
                        ],
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
