import 'package:cloud_firestore/cloud_firestore.dart';

class Grocery {
  String id;
  String ownerId;
  String grocName;
  String about;
  String initialImage;
  double latitude;
  double longitude;
  String district;
  String address;
  String email;
  String telephone1;
  String telephone2;
  List closingDays;
  Timestamp closingTime;
  Timestamp openingTime;
  String specialHolidayshoursOfClosing;
  List items;
  List gallery;
  Timestamp timestamp;

  Grocery({
    this.id,
    this.ownerId,
    this.grocName,
    this.about,
    this.initialImage,
    this.district,
    this.address,
    this.latitude,
    this.longitude,
    this.telephone1,
    this.telephone2,
    this.email,
    this.closingDays,
    this.closingTime,
    this.openingTime,
    this.specialHolidayshoursOfClosing,
    this.items,
    this.gallery,
    this.timestamp,
  });

  factory Grocery.fromDocument(DocumentSnapshot doc) {
    return Grocery(
      id: doc['id'],
      ownerId: doc['ownerId'],
      grocName: doc['grocName'],
      about: doc['about'],
      initialImage: doc['initialImage'],
      district: doc['district'],
      address: doc['address'],
      latitude: doc['latitude'],
      longitude: doc['longitude'],
      email: doc['email'],
      closingDays: doc['closingDays'],
      closingTime: doc['closingTime'],
      openingTime: doc['openingTime'],
      telephone1: doc['telephone1'],
      telephone2: doc['telephone2'],
      specialHolidayshoursOfClosing: doc['specialHolidayshoursOfClosing'],
      items: doc['items'],
      gallery: doc['gallery'],
      timestamp: doc['timestamp'],
    );
  }
}
