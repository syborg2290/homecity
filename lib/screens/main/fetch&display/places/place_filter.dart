import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby/models/place.dart';
import 'package:nearby/models/user.dart';
import 'package:nearby/screens/main/fetch&display/places/place_filter_result.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/services/place_service.dart';
import 'package:nearby/utils/flush_bars.dart';
import 'package:nearby/utils/pallete.dart';

class PlaceFilterPage extends StatefulWidget {
  PlaceFilterPage({Key key}) : super(key: key);

  @override
  _PlaceFilterPageState createState() => _PlaceFilterPageState();
}

class _PlaceFilterPageState extends State<PlaceFilterPage> {
  AuthServcies _auth = AuthServcies();
  PlaceService _placeService = PlaceService();
  List<String> _districtsList = [
    "Ampara",
    "Anuradhapura",
    "Badulla",
    "Batticaloa",
    "Colombo",
    "Galle",
    "Gampaha",
    "Hambantota",
    "Jaffna",
    "Kalutara",
    "Kandy",
    "Kegalle",
    "Kilinochchi",
    "Kurunegala",
    "Mannar",
    "Matale",
    "Matara",
    "Moneragala",
    "Mullaitivu",
    "Nuwara Eliya",
    "Polonnaruwa",
    "Puttalam",
    "Ratnapura",
    "Trincomalee",
    "Vavuniya"
  ];

  List<String> placeTypes = [
    "Beach",
    "National Park",
    "Mountain",
    "Forest",
    "Waterfall",
    "Lake",
    "Historical Place",
    "Ancient Temple",
    "Museum",
    "Theme Park",
    "Zoo and Aquaria",
    "Botanical Garden",
    "Water sports & scuba diving destinations",
    "Medical and Meditations",
    "Adventure",
    "Authentic & Local",
    "Agri",
    "Other",
  ];

  List selectedDistrict = [];
  List selectedPlaceTypes = [];
  List<Place> allPlaces = [];
  String currentUserId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _auth.getCurrentUser().then((fUser) {
      setState(() {
        currentUserId = fUser.uid;
      });
      _auth.getUserObj(fUser.uid).then((value) {
        User user = User.fromDocument(value);

        setState(() {
          selectedDistrict.add(user.district);
        });
      });
    });
    getAllPlaces();
  }

  getAllPlaces() async {
    QuerySnapshot qSnap = await _placeService.getAllPlaces();
    qSnap.documents.forEach((docRest) {
      Place place = Place.fromDocument(docRest);

      setState(() {
        allPlaces.add(place);
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          "Filters",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 20,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(
            12,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset(
              'assets/icons/close.png',
              width: 30,
              height: 30,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      List<Place> filteredPlace = [];
                      selectedDistrict.forEach((dis) {
                        allPlaces
                            .where((fetchRest) => fetchRest.district == dis)
                            .toList()
                            .forEach((fRERest) {
                          if (filteredPlace.firstWhere(
                                  (testRest) => testRest.id == fRERest.id,
                                  orElse: () => null) ==
                              null) {
                            filteredPlace.add(fRERest);
                          }
                        });
                      });

                      selectedPlaceTypes.forEach((dis) {
                        allPlaces
                            .where((fetchItem) => fetchItem.type == dis)
                            .toList()
                            .forEach((fRERest) {
                          if (filteredPlace.firstWhere(
                                  (testRest) => testRest.id == fRERest.id,
                                  orElse: () => null) ==
                              null) {
                            filteredPlace.add(fRERest);
                          }
                        });
                      });

                      if (filteredPlace.isNotEmpty) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FilteredPlace(
                                      currentUserId: currentUserId,
                                      list: filteredPlace,
                                    )));
                      } else {
                        GradientSnackBar.showMessage(context,
                            "Not available any results on this filter");
                      }
                    },
              child: Center(
                  child: Text("Apply filter",
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
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Select districts",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey[900],
                    fontFamily: "Roboto",
                    fontSize: 25,
                    fontWeight: FontWeight.w800),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: _districtsList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 16 / 5,
                ),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                      onTap: () {
                        if (selectedDistrict.contains(_districtsList[index])) {
                          setState(() {
                            selectedDistrict.remove(_districtsList[index]);
                          });
                        } else {
                          setState(() {
                            selectedDistrict.add(_districtsList[index]);
                          });
                        }
                      },
                      child: Chip(
                          backgroundColor:
                              selectedDistrict.contains(_districtsList[index])
                                  ? Pallete.mainAppColor
                                  : null,
                          label: Text(
                            _districtsList[index],
                            style: TextStyle(
                              color: selectedDistrict
                                      .contains(_districtsList[index])
                                  ? Colors.white
                                  : null,
                            ),
                          )));
                }),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Select place categories",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey[900],
                    fontFamily: "Roboto",
                    fontSize: 25,
                    fontWeight: FontWeight.w800),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: placeTypes.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 16 / 5,
                ),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                      onTap: () {
                        if (selectedPlaceTypes.contains(placeTypes[index])) {
                          setState(() {
                            selectedPlaceTypes.remove(placeTypes[index]);
                          });
                        } else {
                          setState(() {
                            selectedPlaceTypes.add(placeTypes[index]);
                          });
                        }
                      },
                      child: Chip(
                          backgroundColor:
                              selectedPlaceTypes.contains(placeTypes[index])
                                  ? Pallete.mainAppColor
                                  : null,
                          label: Text(
                            placeTypes[index],
                            style: TextStyle(
                              color:
                                  selectedPlaceTypes.contains(placeTypes[index])
                                      ? Colors.white
                                      : null,
                            ),
                          )));
                }),
            SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}
