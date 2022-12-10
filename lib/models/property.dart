import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  String id;
  String ownerId;
  String type;
  String intialImage;
  String title;
  String details;
  String address;
  String district;
  String size;
  String price;
  double latitude;
  double longitude;
  String telephone1;
  String telephone2;
  String email;
  List gallery;
  double totalratings;
   List ratings;
  List reviews;
  Timestamp timestamp;

  Property({
    this.id,
    this.ownerId,
    this.intialImage,
    this.type,
    this.title,
    this.details,
    this.address,
    this.size,
    this.price,
    this.district,
    this.latitude,
    this.longitude,
    this.telephone1,
    this.telephone2,
    this.email,
    this.gallery,
    this.totalratings,
    this.ratings,
    this.reviews,
    this.timestamp,
  });

  factory Property.fromDocument(DocumentSnapshot doc) {
    return Property(
      id: doc['id'],
      ownerId: doc['ownerId'],
      type: doc['type'],
      title: doc['title'],
      details: doc['details'],
      intialImage: doc['initialImage'],
      district: doc['district'],
      address: doc['address'],
      latitude: doc['latitude'],
      longitude: doc['longitude'],
      email: doc['email'],
      telephone1: doc['telephone1'],
      telephone2: doc['telephone2'],
      size: doc['size'],
      price: doc['price'],
      gallery: doc['gallery'],
      totalratings: doc['total_ratings'],
       ratings: doc['ratings'],
      reviews: doc['reviews'],
      timestamp: doc['timestamp'],
    );
  }
}
