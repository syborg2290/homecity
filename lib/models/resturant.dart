import 'package:cloud_firestore/cloud_firestore.dart';

class Resturant {
  String id;
  String ownerId;
  String restName;
  String aboutRest;
  String initialImage;
  double latitude;
  double longitude;
  String district;
  String address;
  String email;
  String website;
  String telephone1;
  String telephone2;
  List serviceType;
  Timestamp closingTime;
  Timestamp openingTime;
  String specialHolidayshoursOfClosing;
  List menu;
  List gallery;
  Timestamp timestamp;

  Resturant({
    this.id,
    this.ownerId,
    this.restName,
    this.aboutRest,
    this.initialImage,
    this.district,
    this.address,
    this.latitude,
    this.longitude,
    this.telephone1,
    this.telephone2,
    this.email,
    this.website,
    this.closingTime,
    this.openingTime,
    this.serviceType,
    this.specialHolidayshoursOfClosing,
    this.menu,
    this.gallery,
    this.timestamp,
  });

  factory Resturant.fromDocument(DocumentSnapshot doc) {
    return Resturant(
      id: doc['id'],
      ownerId: doc['ownerId'],
      restName: doc['restName'],
      aboutRest: doc['aboutRest'],
      initialImage: doc['initialImage'],
      district: doc['district'],
      address: doc['address'],
      latitude: doc['latitude'],
      longitude: doc['longitude'],
      email: doc['email'],
      website: doc['website'],
      closingTime: doc['closingTime'],
      openingTime: doc['openingTime'],
      telephone1: doc['telephone1'],
      telephone2: doc['telephone2'],
      serviceType: doc['serviceType'],
      specialHolidayshoursOfClosing: doc['specialHolidayshoursOfClosing'],
      menu: doc['menu'],
      gallery: doc['gallery'],
      timestamp: doc['timestamp'],
    );
  }
}
