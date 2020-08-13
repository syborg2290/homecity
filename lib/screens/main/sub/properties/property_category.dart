import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/screens/main/sub/properties/add_annexes.dart';
import 'package:nearby/screens/main/sub/properties/add_apartment.dart';
import 'package:nearby/screens/main/sub/properties/add_commercial.dart';
import 'package:nearby/screens/main/sub/properties/add_houses.dart';
import 'package:nearby/screens/main/sub/properties/add_land.dart';
import 'package:nearby/utils/pallete.dart';

class PropertyCategory extends StatefulWidget {
  PropertyCategory({Key key}) : super(key: key);

  @override
  _PropertyCategoryState createState() => _PropertyCategoryState();
}

class _PropertyCategoryState extends State<PropertyCategory> {
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
          'Select a category',
          style: TextStyle(
              color: Colors.grey[700],
              fontFamily: "Roboto",
              fontSize: 20,
              fontWeight: FontWeight.w400),
        ),
      ),
      body: FutureBuilder(
          future: DefaultAssetBundle.of(context)
              .loadString('assets/json/properties.json'),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: SpinKitCircle(color: Pallete.mainAppColor));
            }
            List myData = json.decode(snapshot.data);

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  children: List.generate(myData.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        if (myData[index]['category_name'] == "Land") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddLand(
                                        type: myData[index]['category_name'],
                                      )));
                        }

                        if (myData[index]['category_name'] == "Houses") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddHouses(
                                        type: myData[index]['category_name'],
                                      )));
                        }

                        if (myData[index]['category_name'] == "Apartments") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddApartment(
                                        type: myData[index]['category_name'],
                                      )));
                        }

                        if (myData[index]['category_name'] ==
                            "Rooms & annexes") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddAnexes(
                                        type: myData[index]['category_name'],
                                      )));
                        }

                        if (myData[index]['category_name'] ==
                            "Commercial property") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddCommercialProperty(
                                        type: myData[index]['category_name'],
                                      )));
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 5,
                          right: 5,
                        ),
                        child: Container(
                          width: width * 0.25,
                          height: height * 0.1,
                          child: Card(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: Container(
                              width: width * 0.25,
                              height: height * 0.1,
                              child: Column(
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          myData[index]['category_name'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Image.asset(
                                          myData[index]['image_path'],
                                          width: 80,
                                          height: 80,
                                          color: Colors.black.withOpacity(0.6),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 5,
                            margin: EdgeInsets.all(5),
                          ),
                        ),
                      ),
                    );
                  })),
            );
          }),
    );
  }
}
