import 'package:cloud_firestore/cloud_firestore.dart';

class Events {
  String id;
  String ownerId;
  String eventTitle;
  String intialImage;
  String eventDetails;
  String address;
  String district;
  double latitude;
  double longitude;
  String entranceFee;
  String telephone1;
  String telephone2;
  String email;
  Timestamp heldDate;
  Timestamp startTime;
  List gallery;
  double totalratings;
  Timestamp timestamp;

  Events(
      {this.id,
      this.ownerId,
      this.eventTitle,
      this.intialImage,
      this.eventDetails,
      this.address,
      this.district,
      this.latitude,
      this.longitude,
      this.entranceFee,
      this.telephone1,
      this.telephone2,
      this.email,
      this.heldDate,
      this.startTime,
      this.gallery,
      this.totalratings,
      this.timestamp});

  factory Events.fromDocument(DocumentSnapshot doc) {
    return Events(
        id: doc['id'],
        ownerId: doc['ownerId'],
        eventTitle: doc['eventTitle'],
        intialImage: doc['intialImage'],
        eventDetails: doc['eventDetails'],
        address: doc['address'],
        district: doc['district'],
        latitude: doc['latitude'],
        longitude: doc['longitude'],
        entranceFee: doc['entranceFee'],
        telephone1: doc['telephone1'],
        telephone2: doc['telephone2'],
        email: doc['email'],
        heldDate: doc['heldDate'],
        startTime: doc['startTime'],
        gallery: doc['gallery'],
        totalratings: doc['total_ratings'],
        timestamp: doc['timestamp']);
  }
}
