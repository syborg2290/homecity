import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby/utils/flush_bars.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:uuid/uuid.dart';

class AddCourse extends StatefulWidget {
  final String category;
  final obj;
  AddCourse({this.category, this.obj, Key key}) : super(key: key);

  @override
  _AddCourseState createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {
  TextEditingController _courseName = TextEditingController();
  TextEditingController _overview = TextEditingController();
  TextEditingController _suitableFor = TextEditingController();
  TextEditingController _aboutDurationandFee = TextEditingController();
  bool isForEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.obj != null) {
      setState(() {
        isForEdit = true;
        _courseName.text = widget.obj["Course_name"];
        _overview.text = widget.obj["overview"];
        _suitableFor.text = widget.obj["suitableFor"];
        _aboutDurationandFee.text = widget.obj["aboutTheDurationAndFee"];
      });
    }
  }

  done() async {
    if (_courseName.text.trim() != "") {
      if (_overview.text.trim() != "") {
        var uuid = Uuid();
        String id = uuid.v1().toString() + new DateTime.now().toString();
        var obj = {
          "id": id,
          "category": widget.category,
          "Course_name": _courseName.text.trim(),
          "overview": _overview.text.trim(),
          "suitableFor": _suitableFor.text.trim(),
          "aboutTheDurationAndFee": _aboutDurationandFee.text.trim(),
          "total_ratings": 0.0,
        };
        Navigator.pop(context, obj);
      } else {
        GradientSnackBar.showMessage(context, "Course overview is required");
      }
    } else {
      GradientSnackBar.showMessage(context, "Course name is required");
    }
  }

  Widget textBoxContainer(TextEditingController _contro, String hint, int lines,
      double width, bool autoFocus, TextInputType typeText) {
    return Container(
      width: width * 0.89,
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
          'Add new course',
          style: TextStyle(
              color: Colors.grey[700],
              fontFamily: "Roboto",
              fontSize: 18,
              fontWeight: FontWeight.w400),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              onPressed: () {
                done();
              },
              child: Center(
                  child: Text(isForEdit ? "Edit" : "Add",
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.white,
                      ))),
              color: Pallete.mainAppColor,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: Pallete.mainAppColor,
                  )),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              textBoxContainer(
                _courseName,
                "* Name of the course",
                1,
                width,
                false,
                TextInputType.text,
              ),
              SizedBox(
                height: 20,
              ),
              textBoxContainer(
                _overview,
                "* Overview & programme structure",
                8,
                width,
                false,
                TextInputType.text,
              ),
              SizedBox(
                height: 20,
              ),
              textBoxContainer(
                _suitableFor,
                "The course is suitable for",
                4,
                width,
                false,
                TextInputType.text,
              ),
              SizedBox(
                height: 20,
              ),
              textBoxContainer(
                _aboutDurationandFee,
                "About duration & fee of the course",
                4,
                width,
                false,
                TextInputType.text,
              ),
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
