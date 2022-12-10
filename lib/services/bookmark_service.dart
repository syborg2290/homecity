import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nearby/config/collections.dart';
import 'package:nearby/models/bookmarks.dart';
import 'package:uuid/uuid.dart';

class BookmarkService {
  Future<bool> checkBookmarkAlreadyIn(
    String userId,
    String docId,
    int index,
  ) async {
    bool status = false;
    QuerySnapshot qSnap =
        await bookmarksRef.where("userId", isEqualTo: userId).getDocuments();
    qSnap.documents.forEach((element) {
      Bookmarks bookmarks = Bookmarks.fromDocument(element);
      if (index != null) {
        if (bookmarks.typeId == docId && bookmarks.anyIndex == index) {
          status = true;
        } else {
          status = false;
        }
      } else {
        if (bookmarks.typeId == docId) {
          status = true;
        } else {
          status = false;
        }
      }
    });
    return status;
  }

  addToBookmark(
    String userId,
    String type,
    String typeId,
    int index,
  ) async {
    var uuid = Uuid();

    await bookmarksRef.add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "userId": userId,
      "type": type,
      "typeId": typeId,
      "anyIndex": index,
      "timestamp": timestamp,
    });
  }

  Stream<QuerySnapshot> streamBookmarks(String userId) {
    return bookmarksRef
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
