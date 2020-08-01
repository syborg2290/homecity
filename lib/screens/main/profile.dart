import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby/utils/pallete.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId, Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: height * 0.06,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 30,
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(height * 0.09),
                      border: Border.all(
                        color: Pallete.mainAppColor,
                        width: 3,
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CircleAvatar(
                      radius: height * 0.07,
                      backgroundImage: AssetImage("assets/profilephoto.png"),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  children: <Widget>[
                    Center(
                      child: Text(
                        "kasun gamage",
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontFamily: "Roboto",
                            fontSize: 22,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {},
                      child: Text(
                        "Show profile",
                        style: TextStyle(
                          color: Pallete.mainAppColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
