import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityFeed {
  final String id;
  final String userId;
  final String type;
  final String typeId;
  final int anyIndex;
  final bool read;
  final Timestamp timestamp;

  ActivityFeed({
    this.id,
    this.userId,
    this.type,
    this.typeId,
    this.anyIndex,
    this.read,
    this.timestamp,
  });

  factory ActivityFeed.fromDocument(DocumentSnapshot doc) {
    return ActivityFeed(
      id: doc['id'],
      userId: doc['userId'],
      type: doc['type'],
      typeId: doc['typeId'],
      read: doc['read'],
      anyIndex: doc['anyIndex'],
      timestamp: doc['timestamp'],
    );
  }
}
