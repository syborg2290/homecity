import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nearby/config/collections.dart';
import 'package:nearby/models/activity_feed.dart';
import 'package:uuid/uuid.dart';

class ActivityFeedService {
  createActivityFeed(String currentUserId, String userId, String typeId,
      String type, int anyIndex, int anyListIndex, int thirdIndex) async {
    var uuid = Uuid();

    activityFeedRef.document(userId).collection('feedItems').add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "userId": currentUserId,
      "type": type,
      "typeId": typeId,
      "read": false,
      "anyIndex": anyIndex,
      "anyListIndex": anyListIndex,
      "thirdIndex": thirdIndex,
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

  removeFromActivityFeed(
    String userId,
    String addedId,
    String type,
  ) async {
    QuerySnapshot snp = await activityFeedRef
        .document(addedId)
        .collection('feedItems')
        .getDocuments();

    snp.documents.forEach((element) async {
      ActivityFeed activityFeed = ActivityFeed.fromDocument(element);
      if (activityFeed.type == type) {
        QuerySnapshot single = await activityFeedRef
            .document(addedId)
            .collection('feedItems')
            .where("userId", isEqualTo: userId)
            .getDocuments();
        await activityFeedRef
            .document(addedId)
            .collection('feedItems')
            .document(single.documents[0].documentID)
            .delete();
      }
    });
  }

  removeReviewFeeds(
    String reviewOwnerId,
    String restOwnerId,
    String typeId,
    int index1,
    int index2,
  ) async {
    QuerySnapshot snpReview = await activityFeedRef
        .document(reviewOwnerId)
        .collection('feedItems')
        .getDocuments();

    QuerySnapshot snpRestReview = await activityFeedRef
        .document(restOwnerId)
        .collection('feedItems')
        .getDocuments();

    snpReview.documents.forEach((element) async {
      ActivityFeed activityFeed = ActivityFeed.fromDocument(element);
      if (activityFeed.typeId == typeId) {
        if (activityFeed.anyIndex == index1) {
          if (activityFeed.anyIndex == index2) {
            QuerySnapshot single = await activityFeedRef
                .document(reviewOwnerId)
                .collection('feedItems')
                .where("userId", isEqualTo: activityFeed.userId)
                .getDocuments();

            await activityFeedRef
                .document(reviewOwnerId)
                .collection('feedItems')
                .document(single.documents[0].documentID)
                .delete();
          }
        }
      }
    });

    snpRestReview.documents.forEach((element) async {
      ActivityFeed activityFeed = ActivityFeed.fromDocument(element);
      if (activityFeed.typeId == typeId) {
        if (activityFeed.anyIndex == index1) {
          if (activityFeed.type == "review_item") {
            QuerySnapshot single = await activityFeedRef
                .document(restOwnerId)
                .collection('feedItems')
                .where("userId", isEqualTo: activityFeed.userId)
                .getDocuments();

            await activityFeedRef
                .document(restOwnerId)
                .collection('feedItems')
                .document(single.documents[0].documentID)
                .delete();
          }
        }
      }
    });
  }

  removeReviewReplyFromFeed(
    String reviewOwnerId,
    String replyOwnerId,
    String typeId,
    int index1,
    int index2,
    int index3,
  ) async {
    QuerySnapshot snpReview = await activityFeedRef
        .document(reviewOwnerId)
        .collection('feedItems')
        .getDocuments();

    QuerySnapshot snp = await activityFeedRef
        .document(replyOwnerId)
        .collection('feedItems')
        .getDocuments();

    snp.documents.forEach((element) async {
      ActivityFeed activityFeed = ActivityFeed.fromDocument(element);
      if (activityFeed.typeId == typeId) {
        if (activityFeed.anyIndex == index1) {
          if (activityFeed.anyIndex == index2) {
            if (activityFeed.anyIndex == index3) {
              QuerySnapshot single = await activityFeedRef
                  .document(replyOwnerId)
                  .collection('feedItems')
                  .where("userId", isEqualTo: activityFeed.userId)
                  .getDocuments();

              await activityFeedRef
                  .document(replyOwnerId)
                  .collection('feedItems')
                  .document(single.documents[0].documentID)
                  .delete();
            }
          }
        }
      }
    });

    snpReview.documents.forEach((element) async {
      ActivityFeed activityFeed = ActivityFeed.fromDocument(element);
      if (activityFeed.typeId == typeId) {
        if (activityFeed.anyIndex == index1) {
          if (activityFeed.anyIndex == index2) {
            if (activityFeed.anyIndex == index3) {
              QuerySnapshot single = await activityFeedRef
                  .document(reviewOwnerId)
                  .collection('feedItems')
                  .where("userId", isEqualTo: activityFeed.userId)
                  .getDocuments();

              await activityFeedRef
                  .document(reviewOwnerId)
                  .collection('feedItems')
                  .document(single.documents[0].documentID)
                  .delete();
            }
          }
        }
      }
    });
  }
}
