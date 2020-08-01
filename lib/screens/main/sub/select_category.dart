import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/screens/main/sub/place/place_type.dart';
import 'package:nearby/screens/main/sub/resturant/add_resturant.dart';
import 'package:nearby/utils/pallete.dart';

class SelectCategory extends StatefulWidget {
  SelectCategory({Key key}) : super(key: key);

  @override
  _SelectCategoryState createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
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
              .loadString('assets/json/services.json'),
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
                        if (myData[index]['service'] == "Resturants") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddResturant(
                                        type: myData[index]['service'],
                                      )));
                        }

                        if (myData[index]['service'] == "Places") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PlaceType()));
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
                                          myData[index]['service'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Pallete.mainAppColor,
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
                                          color: Pallete.mainAppColor,
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
