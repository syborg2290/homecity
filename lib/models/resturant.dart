import 'package:cloud_firestore/cloud_firestore.dart';

class Resturant {
  String id;
  String ownerId;
  String restName;
  String aboutRest;
  String initialImage;
  double latitude;
  double longitude;
  String address;
  String email;
  String website;
  String telephone1;
  String telephone2;
  List serviceType;
  List closingDays;
  Timestamp closingTime;
  Timestamp openingTime;
  String specialHolidayshoursOfClosing;
  List menu;
  Timestamp timestamp;

  Resturant({
    this.id,
    this.ownerId,
    this.restName,
    this.aboutRest,
    this.initialImage,
    this.address,
    this.latitude,
    this.longitude,
    this.telephone1,
    this.telephone2,
    this.email,
    this.website,
    this.closingDays,
    this.closingTime,
    this.openingTime,
    this.serviceType,
    this.specialHolidayshoursOfClosing,
    this.menu,
    this.timestamp,
  });

  factory Resturant.fromDocument(DocumentSnapshot doc) {
    return Resturant(
      id: doc['id'],
      ownerId: doc['ownerId'],
      restName: doc['restName'],
      aboutRest: doc['aboutRest'],
      initialImage: doc['initialImage'],
      address: doc['address'],
      latitude: doc['latitude'],
      longitude: doc['longitude'],
      email: doc['email'],
      website: doc['website'],
      closingDays: doc['closingDays'],
      closingTime: doc['closingTime'],
      openingTime: doc['openingTime'],
      telephone1: doc['telephone1'],
      telephone2: doc['telephone2'],
      serviceType: doc['serviceType'],
      specialHolidayshoursOfClosing: doc['specialHolidayshoursOfClosing'],
      menu: doc['menu'],
      timestamp: doc['timestamp'],
    );
  }
}
