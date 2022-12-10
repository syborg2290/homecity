import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/utils/pallete.dart';

import 'add_items.dart';

class HardwareItemsView extends StatefulWidget {
  final List items;
  HardwareItemsView({this.items, Key key}) : super(key: key);

  @override
  _HardwareItemsViewState createState() => _HardwareItemsViewState();
}

class _HardwareItemsViewState extends State<HardwareItemsView> {
  List items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      items = widget.items;
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
        Navigator.pop(context, items);
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
                  Navigator.pop(context, items);
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
              "Items",
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
                  children: List.generate(items.length, (index) {
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
                                  builder: (context) => AddHardwareItems(
                                        type: items[index]['item_type'],
                                        obj: items[index],
                                      )));
                          if (obj != null) {
                            setState(() {
                              items[index] = obj;
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
                                    items[index]["initialImage"],
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
                                            if (items.length == 1) {
                                              setState(() {
                                                items.removeAt(index);
                                              });
                                              Navigator.pop(context, items);
                                            } else {
                                              setState(() {
                                                items.removeAt(index);
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
                                            items[index]["item_name"],
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
                                            items[index]["item_type"],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 19,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            items[index]["price"] + " LKR",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
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
