import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  String id;
  String ownerId;
  String placeName;
  String intialImage;
  String aboutThePlace;
  String district;
  double latitude;
  double longitude;
  String entranceFee;
  List daysOfUnavailable;
  String specialUnavailable;
  Timestamp timestamp;

  Place(
      {this.id,
      this.ownerId,
      this.placeName,
      this.intialImage,
      this.aboutThePlace,
      this.district,
      this.latitude,
      this.longitude,
      this.entranceFee,
      this.daysOfUnavailable,
      this.specialUnavailable,
      this.timestamp});

  factory Place.fromDocument(DocumentSnapshot doc) {
    return Place(
        id: doc['id'],
        ownerId: doc['ownerId'],
        placeName: doc['placeName'],
        intialImage: doc['intialImage'],
        aboutThePlace: doc['aboutThePlace'],
        district: doc['district'],
        latitude: doc['latitude'],
        longitude: doc['longitude'],
        entranceFee: doc['entranceFee'],
        daysOfUnavailable: doc['daysOfUnavailable'],
        specialUnavailable: doc['specialUnavailable'],
        timestamp: doc['timestamp']);
  }
}
