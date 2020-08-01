import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby/screens/main/sub/select_category.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:nearby/widgets/services_categories.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
          padding: const EdgeInsets.only(
            left: 20,
            bottom: 10,
          ),
          child: Image.asset(
            'assets/logo.png',
            width: 30,
            height: 30,
            color: Pallete.mainAppColor,
          ),
        ),
        centerTitle: false,
        title: Text(
          'Home city',
          style: TextStyle(
              color: Colors.grey[700],
              fontFamily: "Roboto",
              fontSize: 25,
              fontWeight: FontWeight.w400),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              right: 20,
              bottom: 10,
            ),
            child: Icon(
              Icons.search,
              size: 40,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 20,
              bottom: 10,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SelectCategory();
                }));
              },
              child: Image.asset(
                'assets/icons/plus.png',
                width: 30,
                height: 30,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Divider(),
            MainCategory(),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
