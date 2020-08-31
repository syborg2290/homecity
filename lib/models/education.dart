import 'package:cloud_firestore/cloud_firestore.dart';

class Education {
  String id;
  String ownerId;
  String intialImage;
  String name;
  String subject;
  String subjectCategory;
  String aboutTheInstructor;
  String tutionType;
  String about;
  String type;
  List experiencesIn;
  String address;
  String district;
  double latitude;
  double longitude;
  String telephone1;
  String telephone2;
  String website;
  String email;
  List gallery;
  List schedule;
  List courses;
  double totalratings;
  List ratings;
  List reviews;
  Timestamp timestamp;

  Education({
    this.id,
    this.ownerId,
    this.intialImage,
    this.name,
    this.about,
    this.experiencesIn,
    this.address,
    this.district,
    this.latitude,
    this.longitude,
    this.telephone1,
    this.telephone2,
    this.website,
    this.email,
    this.gallery,
    this.type,
    this.aboutTheInstructor,
    this.schedule,
    this.courses,
    this.subject,
    this.subjectCategory,
    this.tutionType,
    this.totalratings,
    this.ratings,
    this.reviews,
    this.timestamp,
  });

  factory Education.fromDocument(DocumentSnapshot doc) {
    return Education(
      id: doc['id'],
      ownerId: doc['ownerId'],
      name: doc['name'],
      about: doc['about'],
      experiencesIn: doc['experiencesIn'],
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
      type: doc['type'],
      aboutTheInstructor: doc['aboutTheInstructor'],
      schedule: doc['schedule'],
      subject: doc['subject'],
      tutionType: doc['tutionType'],
      subjectCategory: doc['subjectCategory'],
      courses: doc['courses'],
      totalratings: doc['total_ratings'],
      ratings: doc['ratings'],
      reviews: doc['reviews'],
      timestamp: doc['timestamp'],
    );
  }
}
