import 'package:cloud_firestore/cloud_firestore.dart';

class NightLife {
  String id;
  String ownerId;
  String intialImage;
  String name;
  String about;
  String address;
  String district;
  double latitude;
  double longitude;
  String telephone1;
  String telephone2;
  String website;
  String email;
  Timestamp closingTime;
  Timestamp openingTime;
  String specialHolidayshoursOfClosing;
  List gallery;
  double totalratings;
  Timestamp timestamp;

  NightLife({
    this.id,
    this.ownerId,
    this.intialImage,
    this.name,
    this.about,
    this.address,
    this.district,
    this.latitude,
    this.longitude,
    this.telephone1,
    this.telephone2,
    this.website,
    this.email,
    this.closingTime,
    this.openingTime,
    this.specialHolidayshoursOfClosing,
    this.gallery,
    this.totalratings,
    this.timestamp,
  });

  factory NightLife.fromDocument(DocumentSnapshot doc) {
    return NightLife(
      id: doc['id'],
      ownerId: doc['ownerId'],
      name: doc['name'],
      about: doc['about'],
      intialImage: doc['initialImage'],
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
      specialHolidayshoursOfClosing: doc['specialHolidayshoursOfClosing'],
      gallery: doc['gallery'],
      totalratings: doc['total_ratings'],
      timestamp: doc['timestamp'],
    );
  }
}
