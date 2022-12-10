import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'add_apparel.dart';

class MainApparelServices extends StatefulWidget {
  MainApparelServices({Key key}) : super(key: key);

  @override
  _MainServicesApparelState createState() => _MainServicesApparelState();
}

class _MainServicesApparelState extends State<MainApparelServices> {
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
          'Apparel and fashions',
          style: TextStyle(
              color: Colors.grey[700],
              fontFamily: "Roboto",
              fontSize: 20,
              fontWeight: FontWeight.w400),
        ),
      ),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddApparel(
                                  category: "any",
                                )));
                  },
                  child: Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 10,
                    margin: EdgeInsets.all(10),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('assets/icons/jacket.png',
                              width: width * 0.3,
                              height: height * 0.1,
                              color: Colors.grey[700]),
                        ),
                        Text(
                          "Any",
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontFamily: "Roboto",
                              fontSize: 25,
                              fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddApparel(
                                  category: "sell",
                                )));
                  },
                  child: Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 10,
                    margin: EdgeInsets.all(10),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('assets/icons/apparel.png',
                              width: width * 0.3,
                              height: height * 0.1,
                              color: Colors.grey[700]),
                        ),
                        Text(
                          "Only sell",
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontFamily: "Roboto",
                              fontSize: 25,
                              fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddApparel(
                                  category: "tailor",
                                )));
                  },
                  child: Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 10,
                    margin: EdgeInsets.all(10),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('assets/icons/sew.png',
                              width: width * 0.3,
                              height: height * 0.1,
                              color: Colors.grey[700]),
                        ),
                        Text(
                          "Custom tailor",
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontFamily: "Roboto",
                              fontSize: 25,
                              fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddApparel(
                                  category: "rent",
                                )));
                  },
                  child: Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 10,
                    margin: EdgeInsets.all(10),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('assets/icons/suit.png',
                              width: width * 0.3,
                              height: height * 0.1,
                              color: Colors.grey[700]),
                        ),
                        Text(
                          "Rent",
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontFamily: "Roboto",
                              fontSize: 25,
                              fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
