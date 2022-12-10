import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  String id;
  String ownerId;
  String placeName;
  String type;
  String intialImage;
  String aboutThePlace;
  String district;
  double latitude;
  double longitude;
  String entranceFee;
  List daysOfUnavailable;
  String specialUnavailable;
  List gallery;
  List ratings;
  double totalratings;
  List reviews;
  Timestamp timestamp;

  Place(
      {this.id,
      this.ownerId,
      this.placeName,
      this.type,
      this.intialImage,
      this.aboutThePlace,
      this.district,
      this.latitude,
      this.longitude,
      this.entranceFee,
      this.daysOfUnavailable,
      this.specialUnavailable,
      this.gallery,
      this.ratings,
      this.reviews,
      this.totalratings,
      this.timestamp});

  factory Place.fromDocument(DocumentSnapshot doc) {
    return Place(
        id: doc['id'],
        ownerId: doc['ownerId'],
        placeName: doc['placeName'],
        type: doc['type'],
        intialImage: doc['intialImage'],
        aboutThePlace: doc['aboutThePlace'],
        district: doc['district'],
        latitude: doc['latitude'],
        longitude: doc['longitude'],
        entranceFee: doc['entranceFee'],
        daysOfUnavailable: doc['daysOfUnavailable'],
        specialUnavailable: doc['specialUnavailable'],
        gallery: doc['gallery'],
        totalratings: doc['total_ratings'],
        ratings: doc['ratings'],
        reviews: doc['reviews'],
        timestamp: doc['timestamp']);
  }
}
