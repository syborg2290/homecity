import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/utils/pallete.dart';

class CustomizeStay extends StatefulWidget {
  final obj;
  CustomizeStay({this.obj, Key key}) : super(key: key);

  @override
  _CustomizeStayState createState() => _CustomizeStayState();
}

class _CustomizeStayState extends State<CustomizeStay> {
  TextEditingController _beds = TextEditingController();
  TextEditingController _bedRooms = TextEditingController();
  TextEditingController _bathrooms = TextEditingController();
  TextEditingController _guestCount = TextEditingController();
  List feature = [];

  @override
  void initState() {
    super.initState();
    if (widget.obj != null) {
      setState(() {
        _beds.text = widget.obj["beds"];
        _bedRooms.text = widget.obj["bedsRooms"];
        _bathrooms.text = widget.obj["guests"];
        _guestCount.text = widget.obj["bathrooms"];
        feature = widget.obj["features"];
      });
    }
  }

  Widget textBoxContainer(TextEditingController _contro, String hint, int lines,
      double width, bool autoFocus, TextInputType typeText) {
    return Container(
      width: width * 0.5,
      child: TextField(
        controller: _contro,
        maxLines: lines,
        autofocus: autoFocus,
        keyboardType: typeText,
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: TextStyle(fontSize: 18, color: Colors.grey.shade500),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade500,
            ),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Pallete.mainAppColor,
              )),
        ),
      ),
    );
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
          "beds": _beds.text.trim(),
          "bedsRooms": _bedRooms.text.trim(),
          "guests": _guestCount.text.trim(),
          "bathrooms": _bathrooms.text.trim(),
          "features": feature,
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
                  "beds": _beds.text.trim(),
                  "bedsRooms": _bedRooms.text.trim(),
                  "guests": _guestCount.text.trim(),
                  "bathrooms": _bathrooms.text.trim(),
                  "features": feature,
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
            "Customize stay",
            style: TextStyle(
                color: Colors.grey[700],
                fontFamily: "Roboto",
                fontSize: 20,
                fontWeight: FontWeight.w400),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    "Max guests",
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontFamily: "Roboto",
                        fontSize: 20,
                        fontWeight: FontWeight.w800),
                  ),
                  textBoxContainer(_guestCount, "Count", 1, width, false,
                      TextInputType.number),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    "Bed rooms",
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontFamily: "Roboto",
                        fontSize: 20,
                        fontWeight: FontWeight.w800),
                  ),
                  textBoxContainer(_bedRooms, "Count", 1, width, false,
                      TextInputType.number),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    "Beds          ",
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontFamily: "Roboto",
                        fontSize: 20,
                        fontWeight: FontWeight.w800),
                  ),
                  textBoxContainer(
                      _beds, "Count", 1, width, false, TextInputType.number),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    "Bathrooms",
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontFamily: "Roboto",
                        fontSize: 20,
                        fontWeight: FontWeight.w800),
                  ),
                  textBoxContainer(_bathrooms, "Count", 1, width, false,
                      TextInputType.number),
                ],
              ),
              Divider(),
              SizedBox(
                height: 20,
              ),
              Text(
                "Features",
                style: TextStyle(
                    color: Colors.grey[700],
                    fontFamily: "Roboto",
                    fontSize: 30,
                    fontWeight: FontWeight.w800),
              ),
              SizedBox(
                height: 20,
              ),
              FutureBuilder(
                  future: DefaultAssetBundle.of(context)
                      .loadString("assets/json/stay_features.json"),
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
                                if (feature
                                    .contains(myData[index]['category_name'])) {
                                  setState(() {
                                    feature
                                        .remove(myData[index]['category_name']);
                                  });
                                } else {
                                  setState(() {
                                    feature.add(myData[index]['category_name']);
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
                                  height: height * 0.08,
                                  child: Card(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: Container(
                                      width: width * 0.25,
                                      height: height * 0.08,
                                      color: feature.contains(
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
                                                    color: feature.contains(
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
                                                  color: feature.contains(
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
