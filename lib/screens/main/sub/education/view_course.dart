import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby/screens/main/sub/education/add_course.dart';
import 'package:nearby/utils/pallete.dart';

class ViewCourse extends StatefulWidget {
  final List courses;
  ViewCourse({this.courses, Key key}) : super(key: key);

  @override
  _ViewCourseState createState() => _ViewCourseState();
}

class _ViewCourseState extends State<ViewCourse> {
  List courses = [];

  @override
  void initState() {
    setState(() {
      courses = widget.courses;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, courses);
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
                Navigator.pop(context, courses);
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
            "New courses",
            style: TextStyle(
                color: Colors.grey[700],
                fontFamily: "Roboto",
                fontSize: 18,
                fontWeight: FontWeight.w400),
          ),
        ),
        body: courses.isEmpty
            ? Center(
                child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  'assets/icons/higher.png',
                  color: Colors.black.withOpacity(0.2),
                ),
              ))
            : ListView.builder(
                itemCount: courses.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return Stack(
                    children: <Widget>[
                      Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: width,
                              height: 40,
                              child: Center(
                                child: Text(
                                  courses[index]["Course_name"],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        margin: EdgeInsets.all(10),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              width: 50,
                              height: 50,
                              child: FloatingActionButton(
                                onPressed: () async {
                                  var reExperience = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AddCourse(
                                                obj: courses[index],
                                                category: courses[index]
                                                    ["category"],
                                              )));
                                  if (reExperience != null) {
                                    setState(() {
                                      courses[index] = reExperience;
                                    });
                                  }
                                },
                                heroTag: (index + 1).toString() + "mediakooo",
                                backgroundColor: Pallete.mainAppColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    'assets/icons/pencil.png',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              width: 50,
                              height: 50,
                              child: FloatingActionButton(
                                onPressed: () {
                                  if (courses.length == 1) {
                                    setState(() {
                                      courses.removeAt(index);
                                    });
                                    Navigator.pop(context, courses);
                                  } else {
                                    setState(() {
                                      courses.removeAt(index);
                                    });
                                  }
                                },
                                heroTag: (index + 1).toString() + "media",
                                backgroundColor: Colors.red,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    'assets/icons/close.png',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                }),
      ),
    );
  }
}
