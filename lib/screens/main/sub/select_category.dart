import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/screens/main/sub/apparel/main_services.dart';
import 'package:nearby/screens/main/sub/bar&nightlife/main_types.dart';
import 'package:nearby/screens/main/sub/education/education_main_types.dart';
import 'package:nearby/screens/main/sub/electronics/select_services.dart';
import 'package:nearby/screens/main/sub/events/events_type.dart';
import 'package:nearby/screens/main/sub/furnitureNhome/add_furmitureNHome.dart';
import 'package:nearby/screens/main/sub/grocery/add_grocery.dart';
import 'package:nearby/screens/main/sub/place/place_type.dart';
import 'package:nearby/screens/main/sub/properties/property_category.dart';
import 'package:nearby/screens/main/sub/resturant/add_resturant.dart';
import 'package:nearby/screens/main/sub/saloonsnProducts/main_category.dart';
import 'package:nearby/screens/main/sub/sportsNwellNess/add_sportsNwellness.dart';
import 'package:nearby/screens/main/sub/stays/add_stays.dart';
import 'package:nearby/screens/main/sub/vehicles/vehicle_service_type.dart';
import 'package:nearby/utils/pallete.dart';

import 'hardware/main_Services.dart';
import 'musicl_instruments/main_services.dart';

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
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 5,
                  children: List.generate(myData.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        if (myData[index]['service'] == "Resturants & cafes") {
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

                        if (myData[index]['service'] == "Groceries & markets") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddGrocery()));
                        }

                        if (myData[index]['service'] == "Events") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EventType()));
                        }
                        if (myData[index]['service'] == "Apparel & fashions") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainApparelServices()));
                        }
                        if (myData[index]['service'] == "Vehicle services") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VehiServiceType()));
                        }
                        if (myData[index]['service'] == "Night-life") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NightLifeType()));
                        }
                        if (myData[index]['service'] == "Stays") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Addstays()));
                        }

                        if (myData[index]['service'] == "Education") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EducationTypes()));
                        }
                        if (myData[index]['service'] ==
                            "Electronics & repairs") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SelectServices()));
                        }
                        if (myData[index]['service'] ==
                            "Beauty salons & products") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SaloonsMain()));
                        }

                        if (myData[index]['service'] ==
                            "Properties & renting") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PropertyCategory()));
                        }

                        if (myData[index]['service'] == "Home & furnitures") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddFurnitureNHome()));
                        }

                        if (myData[index]['service'] ==
                            "Hardware,tools & materials") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HardwareNToolsServices()));
                        }

                        if (myData[index]['service'] ==
                            "Music instruments & services") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MusicMainServices()));
                        }

                        if (myData[index]['service'] ==
                            "Sports,wellness & outdoors") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddSportsNwellness()));
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.all(
                          5,
                        ),
                        child: Container(
                          width: width * 0.2,
                          height: height * 0.1,
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 3,
                            margin: EdgeInsets.all(0),
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
