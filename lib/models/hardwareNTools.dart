import 'package:cloud_firestore/cloud_firestore.dart';

class HardwareNTools {
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
  List closingDays;
  Timestamp closingTime;
  Timestamp openingTime;
  String specialHolidayshoursOfClosing;
  List gallery;
  List items;
  List rent;
  Timestamp timestamp;

  HardwareNTools({
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
    this.closingDays,
    this.closingTime,
    this.openingTime,
    this.specialHolidayshoursOfClosing,
    this.gallery,
    this.items,
    this.rent,
    this.timestamp,
  });

  factory HardwareNTools.fromDocument(DocumentSnapshot doc) {
    return HardwareNTools(
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
      closingDays: doc['closingDays'],
      closingTime: doc['closingTime'],
      openingTime: doc['openingTime'],
      telephone1: doc['telephone1'],
      telephone2: doc['telephone2'],
      specialHolidayshoursOfClosing: doc['specialHolidayshoursOfClosing'],
      gallery: doc['gallery'],
      items: doc['items'],
      rent: doc['rent'],
      timestamp: doc['timestamp'],
    );
  }
}
