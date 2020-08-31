import 'package:cloud_firestore/cloud_firestore.dart';

class Apparel {
  String id;
  String ownerId;
  String shopName;
  String details;
  String initialImage;
  double latitude;
  double longitude;
  String district;
  String address;
  String email;
  String website;
  String telephone1;
  String telephone2;
  Timestamp closingTime;
  Timestamp openingTime;
  String specialHolidayshoursOfClosing;
  List items;
  List tailor;
  List rent;
  List gallery;
  List ratings;
  List reviews;
  double totalratings;
  Timestamp timestamp;

  Apparel({
    this.id,
    this.ownerId,
    this.shopName,
    this.details,
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
    this.specialHolidayshoursOfClosing,
    this.items,
    this.tailor,
    this.rent,
    this.gallery,
    this.totalratings,
    this.ratings,
    this.reviews,
    this.timestamp,
  });

  factory Apparel.fromDocument(DocumentSnapshot doc) {
    return Apparel(
      id: doc['id'],
      ownerId: doc['ownerId'],
      shopName: doc['shopName'],
      details: doc['details'],
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
      specialHolidayshoursOfClosing: doc['specialHolidayshoursOfClosing'],
      items: doc['items'],
      rent: doc['rent'],
      tailor: doc['tailor'],
      gallery: doc['gallery'],
      totalratings: doc['total_ratings'],
      ratings: doc['ratings'],
      reviews: doc['reviews'],
      timestamp: doc['timestamp'],
    );
  }
}
