import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/utils/pallete.dart';

class MainCategory extends StatefulWidget {
  final int restCount;
  MainCategory({this.restCount, Key key}) : super(key: key);

  @override
  _MainCategoryState createState() => _MainCategoryState();
}

class _MainCategoryState extends State<MainCategory> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Padding(
        padding: EdgeInsets.only(top: 0),
        child: Container(
          height: height * 0.2,
          color: Colors.white,
          child: FutureBuilder(
              future: DefaultAssetBundle.of(context)
                  .loadString('assets/json/services.json'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SpinKitCircle(color: Pallete.mainAppColor);
                }
                List myData = json.decode(snapshot.data);
                // myData.shuffle();

                return ListView.builder(
                    itemCount: myData.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 5,
                            right: 5,
                          ),
                          child: Container(
                            width: width * 0.28,
                            height: height * 0.2,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.6),
                                  width: 1,
                                )),
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      myData[index]['service'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.6),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Image.asset(
                                    myData[index]['image_path'],
                                    width: 50,
                                    height: 50,
                                    color: Colors.black.withOpacity(0.6),
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  myData[index]['service'] ==
                                          "Resturants & cafes"
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: Pallete.mainAppColor,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              widget.restCount.toString(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ))
                                      : SizedBox.shrink(),
                                ],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 2,
                              margin: EdgeInsets.all(0),
                            ),
                          ),
                        ),
                      );
                    });
              }),
        ));
  }
}
