import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/screens/main/sub/vehicles/rent/rent_vehicle_form.dart';
import 'package:nearby/screens/main/sub/vehicles/rent/rent_vehicles_view.dart';
import 'package:nearby/utils/pallete.dart';

class RentTypes extends StatefulWidget {
  final List vehicles;
  RentTypes({this.vehicles, Key key}) : super(key: key);

  @override
  _RentTypesState createState() => _RentTypesState();
}

class _RentTypesState extends State<RentTypes> {
  List vehicles = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      vehicles = widget.vehicles;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, vehicles);
        return false;
      },
      child: Scaffold(
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
                Navigator.pop(context, vehicles);
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
            'Types',
            style: TextStyle(
                color: Colors.grey[700],
                fontFamily: "Roboto",
                fontSize: 20,
                fontWeight: FontWeight.w400),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                onPressed: () async {
                  if (vehicles.isNotEmpty) {
                    List reItems = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VehicleViews(
                                  vehicles: vehicles,
                                )));
                    if (reItems != null) {
                      setState(() {
                        vehicles = reItems;
                      });
                    }
                  }
                },
                child: Center(
                    child: Text("New vehicles - " + vehicles.length.toString(),
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
        body: FutureBuilder(
            future: DefaultAssetBundle.of(context)
                .loadString('assets/json/rent_types.json'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                    child: SpinKitCircle(color: Pallete.mainAppColor));
              }
              List myData = json.decode(snapshot.data);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    children: List.generate(myData.length, (index) {
                      return GestureDetector(
                        onTap: () async {
                          var obj = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RentVehiForm(
                                        type: myData[index]['category_name'],
                                      )));
                          if (obj != null) {
                            setState(() {
                              vehicles.add(obj);
                            });
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 5,
                            right: 5,
                          ),
                          child: Container(
                            width: width * 0.25,
                            height: height * 0.2,
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      myData[index]['category_name'],
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
                              elevation: 5,
                              margin: EdgeInsets.all(5),
                            ),
                          ),
                        ),
                      );
                    })),
              );
            }),
      ),
    );
  }
}
