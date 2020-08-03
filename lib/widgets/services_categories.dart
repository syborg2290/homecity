import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/utils/pallete.dart';

class MainCategory extends StatefulWidget {
  MainCategory({Key key}) : super(key: key);

  @override
  _MainCategoryState createState() => _MainCategoryState();
}

class _MainCategoryState extends State<MainCategory> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var orientation = MediaQuery.of(context).orientation;

    return Padding(
        padding: EdgeInsets.only(top: 0),
        child: Container(
          height: height * 0.17,
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
                        onTap: () {
                          // if (myData[index]['category_name'] == "Garages") {
                          //   Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => Garages(
                          //             currentUser: widget.currentUser,
                          //           )));
                          // }
                          // if (myData[index]['category_name'] == "Parkings") {
                          //   Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => Parking()));
                          // }
                          // if (myData[index]['category_name'] ==
                          //     "Service centers") {
                          //   Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => ServiceCenters()));
                          // }
                          // if (myData[index]['category_name'] ==
                          //     "Spare parts/accessories") {
                          //   Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => SpareParts()));
                          // }
                          // if (myData[index]['category_name'] ==
                          //     "Emergency vehicles") {
                          //   Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => EmergencyTruck()));
                          // }
                          // if (myData[index]['category_name'] ==
                          //     "Vehicle Modifications") {
                          //   Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => VehicleModify()));
                          // }
                          // if (myData[index]['category_name'] ==
                          //     "Tire services & shops") {
                          //   Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => TireService()));
                          // }
                          // if (myData[index]['category_name'] ==
                          //     "Hiring vehicles") {
                          //   Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => HireVehicles()));
                          // }
                          // if (myData[index]['category_name'] ==
                          //     "Renting vehicles") {
                          //   Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => RentVehicles()));
                          // }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 5,
                            right: 5,
                          ),
                          child: Container(
                            width: width * 0.28,
                            height: height * 0.17,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: Pallete.mainAppColor,
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
                                        color: Pallete.mainAppColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Image.asset(
                                    myData[index]['image_path'],
                                    width: 50,
                                    height: 50,
                                    color: Pallete.mainAppColor,
                                    fit: BoxFit.contain,
                                  ),
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
