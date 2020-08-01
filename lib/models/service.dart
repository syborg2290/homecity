import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  String id;
  String serviceId;
  String type;
  String subType;
  String name;
  Timestamp timestamp;

  Service({
    this.id,
    this.serviceId,
    this.type,
    this.subType,
    this.name,
    this.timestamp,
  });

  factory Service.fromDocument(DocumentSnapshot doc) {
    return Service(
      id: doc['id'],
      name: doc['name'],
      serviceId: doc['serviceId'],
      subType: doc['subType'],
      type: doc['type'],
      timestamp: doc['timestamp'],
    );
  }
}
