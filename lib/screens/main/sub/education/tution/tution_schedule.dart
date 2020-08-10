import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby/screens/main/sub/education/tution/add_schedule.dart';
import 'package:nearby/utils/pallete.dart';

class TutionSchedule extends StatefulWidget {
  final List schedule;
  TutionSchedule({this.schedule, Key key}) : super(key: key);

  @override
  _TutionScheduleState createState() => _TutionScheduleState();
}

class _TutionScheduleState extends State<TutionSchedule> {
  List schedule = [];

  @override
  void initState() {
    setState(() {
      schedule = widget.schedule;
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
        Navigator.pop(context, schedule);
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
                Navigator.pop(context, schedule);
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
            "Tution schedule",
            style: TextStyle(
                color: Colors.grey[700],
                fontFamily: "Roboto",
                fontSize: 18,
                fontWeight: FontWeight.w400),
          ),
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: Image.asset(
                    'assets/icons/add.png',
                    width: 40,
                    height: 40,
                  ),
                  onPressed: () async {
                    var reExperience = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddSchedule(
                                  obj: null,
                                )));
                    if (reExperience != null) {
                      setState(() {
                        schedule.add(reExperience);
                      });
                    }
                  },
                ))
          ],
        ),
        body: schedule.isEmpty
            ? Center(
                child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  'assets/icons/schedule.png',
                  color: Colors.black.withOpacity(0.2),
                ),
              ))
            : ListView.builder(
                itemCount: schedule.length,
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
                                  "Schedule * : " + (index + 1).toString(),
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
                                          builder: (context) => AddSchedule(
                                                obj: schedule[index],
                                              )));
                                  if (reExperience != null) {
                                    setState(() {
                                      schedule[index] = reExperience;
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
                                  setState(() {
                                    schedule.removeAt(index);
                                  });
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
