import 'package:cloud_firestore/cloud_firestore.dart';

class Stay {
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
  List gallery;
  int maxguests;
  int bedrooms;
  int beds;
  int bathrooms;
  List features;
  String costPerNight;
  double totalratings;
   List ratings;
  List reviews;
  Timestamp timestamp;

  Stay({
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
    this.gallery,
    this.bathrooms,
    this.bedrooms,
    this.beds,
    this.costPerNight,
    this.features,
    this.maxguests,
    this.totalratings,
    this.ratings,
    this.reviews,
    this.timestamp,
  });

  factory Stay.fromDocument(DocumentSnapshot doc) {
    return Stay(
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
      telephone1: doc['telephone1'],
      telephone2: doc['telephone2'],
      gallery: doc['gallery'],
      bathrooms: doc['bathrooms'],
      bedrooms: doc['bedrooms'],
      beds: doc['beds'],
      costPerNight: doc['costPerNight'],
      features: doc['features'],
      maxguests: doc['maxguests'],
      totalratings: doc['total_ratings'],
       ratings: doc['ratings'],
      reviews: doc['reviews'],
      timestamp: doc['timestamp'],
    );
  }
}
