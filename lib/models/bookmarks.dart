import 'package:cloud_firestore/cloud_firestore.dart';

class Bookmarks {
  final String id;
  final String userId;
  final String type;
  final String typeId;
  final int anyIndex;
  final Timestamp timestamp;

  Bookmarks({
    this.id,
    this.userId,
    this.type,
    this.typeId,
    this.anyIndex,
    this.timestamp,
  });

  factory Bookmarks.fromDocument(DocumentSnapshot doc) {
    return Bookmarks(
      id: doc['id'],
      userId: doc['userId'],
      type: doc['type'],
      typeId: doc['typeId'],
      anyIndex: doc['anyIndex'],
      timestamp: doc['timestamp'],
    );
  }
}
