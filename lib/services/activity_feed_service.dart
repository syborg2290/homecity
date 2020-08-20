import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nearby/config/collections.dart';
import 'package:uuid/uuid.dart';

class ActivityFeedService {
  createActivityFeed(String currentUserId, String userId, String typeId,
      String type, int anyIndex) async {
    var uuid = Uuid();

    activityFeedRef.document(userId).collection('feedItems').add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "userId": currentUserId,
      "type": type,
      "typeId": typeId,
      "read": false,
      "anyIndex": anyIndex,
      "timestamp": timestamp,
    });
  }

  Stream<QuerySnapshot> streamActivityFeed(String currentUserId) {
    return activityFeedRef
        .document(currentUserId)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
