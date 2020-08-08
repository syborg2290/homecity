import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/utils/pallete.dart';

class CustomRepair extends StatefulWidget {
  final customize;
  CustomRepair({this.customize, Key key}) : super(key: key);

  @override
  _CustomRepairState createState() => _CustomRepairState();
}

class _CustomRepairState extends State<CustomRepair> {
  List tech = [];
  List vehiTypes = [];
  List remoTypes = [];

  @override
  void initState() {
    super.initState();
    if (widget.customize != null) {
      setState(() {
        tech = widget.customize["tech"];
        vehiTypes = widget.customize["types"];
        remoTypes = widget.customize["repairandModi"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return WillPopScope(
      onWillPop: () async {
        var obj = {
          "tech": tech,
          "types": vehiTypes,
          "repairandModi": remoTypes,
        };
        Navigator.pop(context, obj);
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
                var obj = {
                  "tech": tech,
                  "types": vehiTypes,
                  "repairandModi": remoTypes,
                };
                Navigator.pop(context, obj);
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
            'Customize repair & modification',
            style: TextStyle(
                color: Colors.grey[700],
                fontFamily: "Roboto",
                fontSize: 18,
                fontWeight: FontWeight.w400),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  "Vehicle tech",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              FutureBuilder(
                  future: DefaultAssetBundle.of(context).loadString(
                      "assets/json/customize_repair/vehi_tech.json"),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                          child: SpinKitCircle(color: Pallete.mainAppColor));
                    }
                    List myData = json.decode(snapshot.data);

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.count(
                          physics: ScrollPhysics(),
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          children: List.generate(myData.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                if (tech
                                    .contains(myData[index]['category_name'])) {
                                  setState(() {
                                    tech.remove(myData[index]['category_name']);
                                  });
                                } else {
                                  setState(() {
                                    tech.add(myData[index]['category_name']);
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
                                  height: height * 0.1,
                                  child: Card(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: Container(
                                      width: width * 0.25,
                                      height: height * 0.1,
                                      color: tech.contains(
                                              myData[index]['category_name'])
                                          ? Pallete.mainAppColor
                                          : Colors.white,
                                      child: Column(
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  myData[index]
                                                      ['category_name'],
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: tech.contains(myData[
                                                                index]
                                                            ['category_name'])
                                                        ? Colors.white
                                                        : Colors.black
                                                            .withOpacity(0.6),
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
                                                  color: tech.contains(
                                                          myData[index]
                                                              ['category_name'])
                                                      ? Colors.white
                                                      : Colors.black
                                                          .withOpacity(0.6),
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
              SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  "Vehicle types",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              FutureBuilder(
                  future: DefaultAssetBundle.of(context).loadString(
                      "assets/json/customize_repair/vehi_types.json"),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                          child: SpinKitCircle(color: Pallete.mainAppColor));
                    }
                    List myData = json.decode(snapshot.data);

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.count(
                          physics: ScrollPhysics(),
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          children: List.generate(myData.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                if (vehiTypes
                                    .contains(myData[index]['category_name'])) {
                                  setState(() {
                                    vehiTypes
                                        .remove(myData[index]['category_name']);
                                  });
                                } else {
                                  setState(() {
                                    vehiTypes
                                        .add(myData[index]['category_name']);
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
                                  height: height * 0.1,
                                  child: Card(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: Container(
                                      width: width * 0.25,
                                      height: height * 0.1,
                                      color: vehiTypes.contains(
                                              myData[index]['category_name'])
                                          ? Pallete.mainAppColor
                                          : Colors.white,
                                      child: Column(
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  myData[index]
                                                      ['category_name'],
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: vehiTypes.contains(
                                                            myData[index][
                                                                'category_name'])
                                                        ? Colors.white
                                                        : Colors.black
                                                            .withOpacity(0.6),
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
                                                  color: vehiTypes.contains(
                                                          myData[index]
                                                              ['category_name'])
                                                      ? Colors.white
                                                      : Colors.black
                                                          .withOpacity(0.6),
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
              SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  "Common repairs & modifications",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              FutureBuilder(
                  future: DefaultAssetBundle.of(context).loadString(
                      "assets/json/customize_repair/vehi_modie.json"),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                          child: SpinKitCircle(color: Pallete.mainAppColor));
                    }
                    List myData = json.decode(snapshot.data);

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.count(
                          physics: ScrollPhysics(),
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          children: List.generate(myData.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                if (remoTypes
                                    .contains(myData[index]['category_name'])) {
                                  setState(() {
                                    remoTypes
                                        .remove(myData[index]['category_name']);
                                  });
                                } else {
                                  setState(() {
                                    remoTypes
                                        .add(myData[index]['category_name']);
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
                                  height: height * 0.1,
                                  child: Card(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: Container(
                                      width: width * 0.25,
                                      height: height * 0.1,
                                      color: remoTypes.contains(
                                              myData[index]['category_name'])
                                          ? Pallete.mainAppColor
                                          : Colors.white,
                                      child: Column(
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  myData[index]
                                                      ['category_name'],
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: remoTypes.contains(
                                                            myData[index][
                                                                'category_name'])
                                                        ? Colors.white
                                                        : Colors.black
                                                            .withOpacity(0.6),
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
                                                  color: remoTypes.contains(
                                                          myData[index]
                                                              ['category_name'])
                                                      ? Colors.white
                                                      : Colors.black
                                                          .withOpacity(0.6),
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
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
