import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  String id;
  String serviceId;
  String type;
  String subType;
  String name;
  double latitude;
  double longitude;
  Timestamp timestamp;

  Service({
    this.id,
    this.serviceId,
    this.type,
    this.subType,
    this.name,
    this.latitude,
    this.longitude,
    this.timestamp,
  });

  factory Service.fromDocument(DocumentSnapshot doc) {
    return Service(
      id: doc['id'],
      name: doc['name'],
      serviceId: doc['serviceId'],
      subType: doc['subType'],
      type: doc['type'],
      latitude: doc['latitude'],
      longitude: doc['longitude'],
      timestamp: doc['timestamp'],
    );
  }
}
