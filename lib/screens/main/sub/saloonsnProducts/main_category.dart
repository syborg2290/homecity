import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby/screens/main/sub/saloonsnProducts/add_saloonnproducts.dart';

class SaloonsMain extends StatefulWidget {
  SaloonsMain({Key key}) : super(key: key);

  @override
  _SaloonsMainState createState() => _SaloonsMainState();
}

class _SaloonsMainState extends State<SaloonsMain> {
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
          'Saloons & beauty products',
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
                            builder: (context) => BeautySaloons(
                                  category: "any",
                                  type: "Saloon & beauty products center",
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
                          child: Image.asset('assets/icons/any_saloons.png',
                              width: width * 0.3,
                              height: height * 0.1,
                              color: Colors.grey[700]),
                        ),
                        Text(
                          "Any service",
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
                            builder: (context) => BeautySaloons(
                                  category: "saloon",
                                  type: "Saloon & beauty products center",
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
                          child: Image.asset('assets/icons/salon.png',
                              width: width * 0.3,
                              height: height * 0.1,
                              color: Colors.grey[700]),
                        ),
                        Text(
                          "Beauty Saloons",
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
                            builder: (context) => BeautySaloons(
                                  category: "products",
                                  type: "Saloon & beauty products center",
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
                          child: Image.asset('assets/icons/makeup.png',
                              width: width * 0.3,
                              height: height * 0.1,
                              color: Colors.grey[700]),
                        ),
                        Text(
                          "Products & items",
                          textAlign: TextAlign.center,
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
