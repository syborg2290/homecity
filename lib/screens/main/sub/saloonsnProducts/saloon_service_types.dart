import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/utils/pallete.dart';

class SaloonServicesTypes extends StatefulWidget {
  final List services;
  SaloonServicesTypes({this.services, Key key}) : super(key: key);

  @override
  _SaloonServicesTypesState createState() => _SaloonServicesTypesState();
}

class _SaloonServicesTypesState extends State<SaloonServicesTypes> {
  List services = [];

  @override
  void initState() {
    super.initState();
    if (widget.services != null) {
      setState(() {
        services = widget.services;
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
        Navigator.pop(context, services);
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
                Navigator.pop(context, services);
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
            'Customize services',
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
              FutureBuilder(
                  future: DefaultAssetBundle.of(context)
                      .loadString("assets/json/saloon_services.json"),
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
                              onTap: () async {
                                if (services
                                    .contains(myData[index]['category_name'])) {
                                  setState(() {
                                    services
                                        .remove(myData[index]['category_name']);
                                  });
                                } else {
                                  setState(() {
                                    services
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
                                      color: services.contains(
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
                                                    color: services.contains(
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
                                                  color: services.contains(
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
            ],
          ),
        ),
      ),
    );
  }
}
