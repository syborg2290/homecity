import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/screens/main/sub/vehicles/rent/rent_vehicle_form.dart';
import 'package:nearby/utils/pallete.dart';

class VehicleViews extends StatefulWidget {
  final List vehicles;
  VehicleViews({this.vehicles, Key key}) : super(key: key);

  @override
  _VehicleViewsState createState() => _VehicleViewsState();
}

class _VehicleViewsState extends State<VehicleViews> {
  List vehicles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      vehicles = widget.vehicles;
      isLoading = false;
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
              "New vehicles",
              style: TextStyle(
                  color: Colors.grey[700],
                  fontFamily: "Roboto",
                  fontSize: 20,
                  fontWeight: FontWeight.w400),
            ),
          ),
          body: isLoading
              ? Center(child: SpinKitCircle(color: Pallete.mainAppColor))
              : GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  children: List.generate(vehicles.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 5,
                        right: 5,
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          var obj = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RentVehiForm(
                                        type: vehicles[index]["item_type"],
                                        obj: vehicles[index],
                                      )));
                          if (obj != null) {
                            setState(() {
                              vehicles[index] = obj;
                            });
                          }
                        },
                        child: Container(
                          width: width * 0.25,
                          height: height * 0.1,
                          child: Card(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: Container(
                              width: width * 0.25,
                              height: height * 0.1,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: FileImage(
                                    vehicles[index]["initialImage"],
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4)),
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: () {
                                            if (vehicles.length == 1) {
                                              setState(() {
                                                vehicles.removeAt(index);
                                              });
                                              Navigator.pop(context, vehicles);
                                            } else {
                                              setState(() {
                                                vehicles.removeAt(index);
                                              });
                                            }
                                          },
                                          child: Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Image.asset(
                                                  'assets/icons/close.png',
                                                  width: 40,
                                                  height: 40,
                                                  color: Colors.black,
                                                ),
                                              )),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: height * 0.04,
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            vehicles[index]["vehi_name"],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 22,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            vehicles[index]["item_type"],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 19,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            vehicles[index]["price"] +
                                                " LKR per 1 km",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
                  }))),
    );
  }
}
