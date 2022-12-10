import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nearby/screens/main/sub/education/pre-school/add_Pre_School.dart';
import 'package:nearby/screens/main/sub/education/higher/add_higher.dart';
import 'package:nearby/screens/main/sub/education/private-school/add_private_school.dart';
import 'package:nearby/screens/main/sub/education/vocational/add_vocational.dart';
import 'package:nearby/screens/main/sub/education/higher/higher_education_types.dart';
import 'package:nearby/screens/main/sub/education/tution/tution_subject.dart';
import 'package:nearby/utils/pallete.dart';

class EducationTypes extends StatefulWidget {
  EducationTypes({Key key}) : super(key: key);

  @override
  _EducationTypesState createState() => _EducationTypesState();
}

class _EducationTypesState extends State<EducationTypes> {
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
          'Select a category',
          style: TextStyle(
              color: Colors.grey[700],
              fontFamily: "Roboto",
              fontSize: 20,
              fontWeight: FontWeight.w400),
        ),
      ),
      body: FutureBuilder(
          future: DefaultAssetBundle.of(context)
              .loadString('assets/json/education.json'),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: SpinKitCircle(color: Pallete.mainAppColor));
            }
            List myData = json.decode(snapshot.data);

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  children: List.generate(myData.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        if (myData[index]['category_name'] == "Pre-school") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PreSchool(
                                        type: myData[index]['category_name'],
                                      )));
                        }
                        if (myData[index]['category_name'] ==
                            "Private school") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PrivateSchool(
                                        type: myData[index]['category_name'],
                                      )));
                        }
                        if (myData[index]['category_name'] == "Tution") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TutionSubject(
                                        type: myData[index]['category_name'],
                                      )));
                        }
                        if (myData[index]['category_name'] ==
                            "Higher education") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddHigherEducation(
                                        type: myData[index]['category_name'],
                                      )));
                        }
                        if (myData[index]['category_name'] ==
                            "Vocational education") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddVocational(
                                        type: myData[index]['category_name'],
                                      )));
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
                              child: Column(
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          myData[index]['category_name'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.6),
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
    );
  }
}
