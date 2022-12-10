import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby/screens/main/sub/education/experience.dart';
import 'package:nearby/utils/pallete.dart';

class ViewExperiences extends StatefulWidget {
  final List experiences;
  ViewExperiences({this.experiences, Key key}) : super(key: key);

  @override
  _ViewExperiencesState createState() => _ViewExperiencesState();
}

class _ViewExperiencesState extends State<ViewExperiences> {
  List experiences = [];

  @override
  void initState() {
    setState(() {
      experiences = widget.experiences;
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
        Navigator.pop(context, experiences);
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
                Navigator.pop(context, experiences);
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
            "Experiences",
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
                            builder: (context) => ExperienceIn(
                                  obj: null,
                                )));
                    if (reExperience != null) {
                      setState(() {
                        experiences.add(reExperience);
                      });
                    }
                  },
                ))
          ],
        ),
        body: experiences.isEmpty
            ? Center(
                child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  'assets/icons/experience.png',
                  color: Colors.black.withOpacity(0.2),
                ),
              ))
            : ListView.builder(
                itemCount: experiences.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return Stack(
                    children: <Widget>[
                      Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Column(
                          children: <Widget>[
                            Image.file(
                              experiences[index]["initialImage"],
                              width: width,
                              height: height * 0.4,
                              fit: BoxFit.fill,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              experiences[index]["about"],
                              style: TextStyle(
                                fontSize: 18,
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
                      Align(
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
                                        builder: (context) => ExperienceIn(
                                              obj: experiences[index],
                                            )));
                                if (reExperience != null) {
                                  setState(() {
                                    experiences[index] = reExperience;
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
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            width: 50,
                            height: 50,
                            child: FloatingActionButton(
                              onPressed: () {
                                setState(() {
                                  experiences.removeAt(index);
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
                      )
                    ],
                  );
                }),
      ),
    );
  }
}
