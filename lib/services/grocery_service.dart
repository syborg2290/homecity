import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nearby/config/collections.dart';
import 'package:nearby/models/grocery.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as Path;

class GroceryService {
  Future<String> addGrocery(
    String ownerId,
    String grocname,
    String about,
    String initialImage,
    String address,
    double latitude,
    double longitude,
    String email,
    DateTime closingTime,
    DateTime openingTime,
    String telephone1,
    String telephone2,
    String specialHolidayshoursOfClosing,
    List items,
    String district,
    List gallery,
  ) async {
    var uuid = Uuid();
    DocumentReference docRe = await groceriesRef.add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "ownerId": ownerId,
      "grocName": grocname,
      "aboutRest": about,
      "initialImage": initialImage,
      "district": district,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "email": email,
      "closingTime": closingTime,
      "openingTime": openingTime,
      "telephone1": telephone1,
      "telephone2": telephone2,
      "specialHolidayshoursOfClosing": specialHolidayshoursOfClosing,
      "items": items,
      "gallery": gallery,
      "total_ratings": 0.0,
      "timestamp": timestamp,
    });
    return docRe.documentID;
  }

  Future<QuerySnapshot> getAllGrocery() async {
    return groceriesRef.orderBy('timestamp', descending: true).getDocuments();
  }

  Stream<QuerySnapshot> streamGrocery() {
    return groceriesRef.orderBy('timestamp', descending: true).snapshots();
  }

  Stream<QuerySnapshot> streamSingleGrocery(String id) {
    return groceriesRef.where("id", isEqualTo: id).snapshots();
  }

  Future<QuerySnapshot> fetchSingleGrocery(String id) {
    return groceriesRef.where("id", isEqualTo: id).getDocuments();
  }

  setRatingsToGrocery(String grocId, double rate, String userId) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocId).get();
    Grocery rest = Grocery.fromDocument(docSnap);
    List ratings = [];
    if (rest.ratings != null) {
      ratings = rest.ratings;
    }

    if (ratings.isNotEmpty) {
      var rateObj = {
        "rate": rate.toInt(),
        "userId": userId,
        "timestamp": timestamp.toIso8601String(),
      };

      dynamic status = ratings.firstWhere(
          (element) => element["userId"] == userId,
          orElse: () => null);
      if (status == null) {
        ratings.add(rateObj);
      } else {
        int indexRe =
            ratings.indexWhere((element) => element["userId"] == userId);
        ratings[indexRe]["rate"] = rate.toInt();
        ratings[indexRe]["timestamp"] = timestamp.toIso8601String();
      }
    } else {
      var rateObj = {
        "rate": rate.toInt(),
        "userId": userId,
        "timestamp": timestamp.toIso8601String(),
      };
      ratings.add(rateObj);
    }

    double totalRatings =
        rest.totalratings == null ? 0.0 : rest.totalratings + rate;

    await groceriesRef.document(grocId).updateData({
      "ratings": ratings,
      "total_ratings": totalRatings,
    });
  }

  setRatingsToItem(int index, String grocId, double rate, String userId) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocId).get();
    Grocery groc = Grocery.fromDocument(docSnap);
    var obj = json.decode(groc.items[index]);
    List ratings = [];
    if (obj["ratings"] != null) {
      ratings = obj["ratings"];
    }

    if (ratings != null) {
      if (ratings.isNotEmpty) {
        var rateObj = {
          "rate": rate.toInt(),
          "userId": userId,
          "timestamp": timestamp.toIso8601String(),
        };
        dynamic status = ratings.firstWhere(
            (element) => element["userId"] == userId,
            orElse: () => null);
        if (status == null) {
          ratings.add(rateObj);
        } else {
          int indexRe =
              ratings.indexWhere((element) => element["userId"] == userId);
          ratings[indexRe]["rate"] = rate.toInt();
          ratings[indexRe]["timestamp"] = timestamp.toIso8601String();
        }

        double totalRatings =
            obj["total_ratings"] == null ? 0.0 : obj["total_ratings"] + rate;

        var updatedObj = {
          "id": obj["id"],
          "initialImage": obj["initialImage"],
          "item_type": obj["item_type"],
          "item_name": obj["item_name"],
          "status": obj["status"],
          "price": obj["price"],
          "about": obj["about"],
          "brand": obj["brand"],
          "gallery": obj["gallery"],
          "total_ratings": totalRatings,
          "ratings": ratings,
        };

        List grocItems = groc.items;
        grocItems[index] = json.encode(updatedObj);
        await groceriesRef.document(grocId).updateData({
          "items": grocItems,
        });
      } else {
        var rateObj = {
          "rate": rate.toInt(),
          "userId": userId,
          "timestamp": timestamp.toIso8601String(),
        };
        ratings.add(rateObj);
        double totalRatings =
            obj["total_ratings"] == null ? 0.0 : obj["total_ratings"] + rate;
        var updatedObj = {
          "id": obj["id"],
          "initialImage": obj["initialImage"],
          "item_type": obj["item_type"],
          "item_name": obj["item_name"],
          "status": obj["status"],
          "price": obj["price"],
          "about": obj["about"],
          "brand": obj["brand"],
          "gallery": obj["gallery"],
          "total_ratings": totalRatings,
          "ratings": ratings,
        };

        List grocItems = groc.items;
        grocItems[index] = json.encode(updatedObj);
        await groceriesRef.document(grocId).updateData({
          "items": grocItems,
        });
      }
    } else {
      var rateObj = {
        "rate": rate.toInt(),
        "userId": userId,
        "timestamp": timestamp.toIso8601String(),
      };
      ratings.add(rateObj);

      double totalRatings =
          obj["total_ratings"] == null ? 0.0 : obj["total_ratings"] + rate;

      var updatedObj = {
        "id": obj["id"],
        "initialImage": obj["initialImage"],
        "item_type": obj["item_type"],
        "item_name": obj["item_name"],
        "status": obj["status"],
        "price": obj["price"],
        "about": obj["about"],
        "brand": obj["brand"],
        "gallery": obj["gallery"],
        "total_ratings": totalRatings,
        "ratings": ratings,
      };

      List grocItems = groc.items;
      grocItems[index] = json.encode(updatedObj);
      await groceriesRef.document(grocId).updateData({
        "items": grocItems,
      });
    }
  }

  setReviewToGrocery(
      String grocId, String review, dynamic media, String userId) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocId).get();
    Grocery groc = Grocery.fromDocument(docSnap);
    List reviewsList = [];
    if (groc.reviews != null) {
      reviewsList = groc.reviews;
    }

    var reviewObj = {
      "review": review,
      "media": json.encode(media),
      "userId": userId,
      "reactions": null,
      "replys": null,
      "timestamp": timestamp.toIso8601String(),
    };

    reviewsList.add(reviewObj);

    await groceriesRef.document(grocId).updateData({
      "reviews": reviewsList,
    });
  }

  setReviewToGrocItem(int index, String grocId, String review, dynamic media,
      String userId) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocId).get();
    Grocery groc = Grocery.fromDocument(docSnap);
    var obj = json.decode(groc.items[index]);

    List reviewsList = [];
    if (obj["review"] != null) {
      reviewsList = obj["review"];
    }

    var reviewObj = {
      "review": review,
      "media": json.encode(media),
      "userId": userId,
      "reactions": null,
      "replys": null,
      "timestamp": timestamp.toIso8601String(),
    };

    reviewsList.add(reviewObj);

    var updatedObj = {
      "id": obj["id"],
      "initialImage": obj["initialImage"],
      "item_type": obj["item_type"],
      "item_name": obj["item_name"],
      "status": obj["status"],
      "price": obj["price"],
      "about": obj["about"],
      "brand": obj["brand"],
      "gallery": obj["gallery"],
      "total_ratings": obj["total_ratings"],
      "ratings": obj["ratings"],
      "review": reviewsList,
    };

    List grocItems = groc.items;
    grocItems[index] = json.encode(updatedObj);
    await groceriesRef.document(grocId).updateData({
      "items": grocItems,
    });
  }

  setReactionToGroceryReview(
      String grocId, String userId, int reviewIndex, String reaction) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocId).get();
    Grocery groc = Grocery.fromDocument(docSnap);
    List reviewsList = [];

    if (groc.reviews != null) {
      reviewsList = groc.reviews;
    }

    List reactions = [];

    if (reviewsList[reviewIndex]["reactions"] != null) {
      reactions = reviewsList[reviewIndex]["reactions"];
    }

    var reactionObj = {
      "userId": userId,
      "reaction": reaction,
      "timestamp": timestamp.toIso8601String(),
    };

    dynamic status = reactions.firstWhere(
        (element) => element["userId"] == userId,
        orElse: () => null);

    if (status == null) {
      reactions.add(reactionObj);
    } else {
      int indexRe =
          reactions.indexWhere((element) => element["userId"] == userId);
      reactions[indexRe] = reactionObj;
    }

    var reviewObj = {
      "review": reviewsList[reviewIndex]["review"],
      "media": reviewsList[reviewIndex]["media"],
      "userId": reviewsList[reviewIndex]["userId"],
      "reactions": reactions,
      "replys": reviewsList[reviewIndex]["replys"],
      "timestamp": reviewsList[reviewIndex]["timestamp"],
    };

    reviewsList[reviewIndex] = reviewObj;

    await groceriesRef.document(grocId).updateData({
      "reviews": reviewsList,
    });
  }

  setReactionsToGroceryItemReview(int index, String grocId, String userId,
      int reviewIndex, String reaction) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocId).get();
    Grocery groc = Grocery.fromDocument(docSnap);
    var obj = json.decode(groc.items[index]);

    List reviewsList = [];
    if (obj["review"] != null) {
      reviewsList = obj["review"];
    }

    List reactions = [];

    if (reviewsList[reviewIndex]["reactions"] != null) {
      reactions = reviewsList[reviewIndex]["reactions"];
    }

    var reactionObj = {
      "userId": userId,
      "reaction": reaction,
      "timestamp": timestamp.toIso8601String(),
    };

    dynamic status = reactions.firstWhere(
        (element) => element["userId"] == userId,
        orElse: () => null);

    if (status == null) {
      reactions.add(reactionObj);
    } else {
      int indexRe =
          reactions.indexWhere((element) => element["userId"] == userId);
      reactions[indexRe] = reactionObj;
    }

    var reviewObj = {
      "review": reviewsList[reviewIndex]["review"],
      "media": reviewsList[reviewIndex]["media"],
      "userId": reviewsList[reviewIndex]["userId"],
      "reactions": reactions,
      "replys": reviewsList[reviewIndex]["replys"],
      "timestamp": reviewsList[reviewIndex]["timestamp"],
    };

    reviewsList[reviewIndex] = reviewObj;

    var updatedObj = {
      "id": obj["id"],
      "initialImage": obj["initialImage"],
      "item_type": obj["item_type"],
      "item_name": obj["item_name"],
      "status": obj["status"],
      "price": obj["price"],
      "about": obj["about"],
      "brand": obj["brand"],
      "gallery": obj["gallery"],
      "total_ratings": obj["total_ratings"],
      "ratings": obj["ratings"],
      "review": reviewsList,
    };

    List grocItems = groc.items;
    grocItems[index] = json.encode(updatedObj);
    await groceriesRef.document(grocId).updateData({
      "items": grocItems,
    });
  }

  addReplyToGroceryReview(String grocId, List media, String userId,
      int reviewIndex, String reply) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocId).get();
    Grocery groc = Grocery.fromDocument(docSnap);
    List reviewsList = [];

    if (groc.reviews != null) {
      reviewsList = groc.reviews;
    }

    List replys = [];

    if (reviewsList[reviewIndex]["replys"] != null) {
      replys = reviewsList[reviewIndex]["replys"];
    }

    var replyObj = {
      "userId": userId,
      "reply": reply,
      "media": media,
      "reactions": null,
      "timestamp": timestamp.toIso8601String(),
    };

    replys.add(replyObj);

    var reviewObj = {
      "review": reviewsList[reviewIndex]["review"],
      "media": reviewsList[reviewIndex]["media"],
      "userId": reviewsList[reviewIndex]["userId"],
      "reactions": reviewsList[reviewIndex]["reactions"],
      "replys": replys,
      "timestamp": reviewsList[reviewIndex]["timestamp"],
    };

    reviewsList[reviewIndex] = reviewObj;

    await groceriesRef.document(grocId).updateData({
      "reviews": reviewsList,
    });
  }

  addReplyToGroceryItemReview(int index, String grocId, List media,
      String userId, int reviewIndex, String reply) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocId).get();
    Grocery groc = Grocery.fromDocument(docSnap);
    var obj = json.decode(groc.items[index]);

    List reviewsList = [];
    if (obj["review"] != null) {
      reviewsList = obj["review"];
    }

    List replys = [];

    if (reviewsList[reviewIndex]["replys"] != null) {
      replys = reviewsList[reviewIndex]["replys"];
    }

    var replyObj = {
      "userId": userId,
      "reply": reply,
      "media": media,
      "reactions": null,
      "timestamp": timestamp.toIso8601String(),
    };

    replys.add(replyObj);

    var reviewObj = {
      "review": reviewsList[reviewIndex]["review"],
      "media": reviewsList[reviewIndex]["media"],
      "userId": reviewsList[reviewIndex]["userId"],
      "reactions": reviewsList[reviewIndex]["reactions"],
      "replys": replys,
      "timestamp": reviewsList[reviewIndex]["timestamp"],
    };

    reviewsList[reviewIndex] = reviewObj;

    var updatedObj = {
      "id": obj["id"],
      "initialImage": obj["initialImage"],
      "item_type": obj["item_type"],
      "item_name": obj["item_name"],
      "status": obj["status"],
      "price": obj["price"],
      "about": obj["about"],
      "brand": obj["brand"],
      "gallery": obj["gallery"],
      "total_ratings": obj["total_ratings"],
      "ratings": obj["ratings"],
      "review": reviewsList,
    };

    List grocItems = groc.items;
    grocItems[index] = json.encode(updatedObj);
    await groceriesRef.document(grocId).updateData({
      "items": grocItems,
    });
  }

  setReactionToGroceryReviewReply(String grocId, String userId, int reviewIndex,
      int replyIndex, String reaction) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocId).get();
    Grocery groc = Grocery.fromDocument(docSnap);

    List reviewsList = [];

    if (groc.reviews != null) {
      reviewsList = groc.reviews;
    }

    List reactions = [];
    List replyList = [];

    if (reviewsList[reviewIndex]["replys"] != null) {
      replyList = reviewsList[reviewIndex]["replys"];
      if (reviewsList[reviewIndex]["replys"][replyIndex]["reactions"] != null) {
        reactions = reviewsList[reviewIndex]["replys"][replyIndex]["reactions"];
      }
    }

    var reactionObj = {
      "userId": userId,
      "reaction": reaction,
      "timestamp": timestamp.toIso8601String(),
    };

    dynamic status = reactions.firstWhere(
        (element) => element["userId"] == userId,
        orElse: () => null);

    if (status == null) {
      reactions.add(reactionObj);
    } else {
      int indexRe =
          reactions.indexWhere((element) => element["userId"] == userId);
      reactions[indexRe] = reactionObj;
    }

    var singleReply = {
      "userId": replyList[replyIndex]["userId"],
      "reply": replyList[replyIndex]["reply"],
      "media": replyList[replyIndex]["media"],
      "reactions": reactions,
      "timestamp": replyList[replyIndex]["timestamp"],
    };

    replyList[replyIndex] = singleReply;

    var reviewObj = {
      "review": reviewsList[reviewIndex]["review"],
      "media": reviewsList[reviewIndex]["media"],
      "userId": reviewsList[reviewIndex]["userId"],
      "reactions": reviewsList[reviewIndex]["reactions"],
      "replys": replyList,
      "timestamp": reviewsList[reviewIndex]["timestamp"],
    };

    reviewsList[reviewIndex] = reviewObj;

    await groceriesRef.document(grocId).updateData({
      "reviews": reviewsList,
    });
  }

  setReactionGrocItemToReviewReply(int index, String grocId, String userId,
      int reviewIndex, int replyIndex, String reaction) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocId).get();
    Grocery groc = Grocery.fromDocument(docSnap);
    var obj = json.decode(groc.items[index]);

    List reviewsList = [];
    if (obj["review"] != null) {
      reviewsList = obj["review"];
    }

    List reactions = [];
    List replyList = [];

    if (reviewsList[reviewIndex]["replys"] != null) {
      replyList = reviewsList[reviewIndex]["replys"];
      if (reviewsList[reviewIndex]["replys"][replyIndex]["reactions"] != null) {
        reactions = reviewsList[reviewIndex]["replys"][replyIndex]["reactions"];
      }
    }

    var reactionObj = {
      "userId": userId,
      "reaction": reaction,
      "timestamp": timestamp.toIso8601String(),
    };

    dynamic status = reactions.firstWhere(
        (element) => element["userId"] == userId,
        orElse: () => null);

    if (status == null) {
      reactions.add(reactionObj);
    } else {
      int indexRe =
          reactions.indexWhere((element) => element["userId"] == userId);
      reactions[indexRe] = reactionObj;
    }

    var singleReply = {
      "userId": replyList[replyIndex]["userId"],
      "reply": replyList[replyIndex]["reply"],
      "media": replyList[replyIndex]["media"],
      "reactions": reactions,
      "timestamp": replyList[replyIndex]["timestamp"],
    };

    replyList[replyIndex] = singleReply;

    var reviewObj = {
      "review": reviewsList[reviewIndex]["review"],
      "media": reviewsList[reviewIndex]["media"],
      "userId": reviewsList[reviewIndex]["userId"],
      "reactions": reviewsList[reviewIndex]["reactions"],
      "replys": replyList,
      "timestamp": reviewsList[reviewIndex]["timestamp"],
    };

    reviewsList[reviewIndex] = reviewObj;

    var updatedObj = {
      "id": obj["id"],
      "initialImage": obj["initialImage"],
      "item_type": obj["item_type"],
      "item_name": obj["item_name"],
      "status": obj["status"],
      "price": obj["price"],
      "about": obj["about"],
      "brand": obj["brand"],
      "gallery": obj["gallery"],
      "total_ratings": obj["total_ratings"],
      "ratings": obj["ratings"],
      "review": reviewsList,
    };

    List grocItems = groc.items;
    grocItems[index] = json.encode(updatedObj);
    await groceriesRef.document(grocId).updateData({
      "items": grocItems,
    });
  }

  getAllGrocReviewReplys(String grocId, int reviewIndex) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocId).get();
    Grocery groc = Grocery.fromDocument(docSnap);
    List reviewsList = [];

    if (groc.reviews != null) {
      reviewsList = groc.reviews;
    }

    List replyList = [];

    if (reviewsList[reviewIndex]["replys"] != null) {
      replyList = reviewsList[reviewIndex]["replys"];
      return replyList;
    } else {
      return replyList;
    }
  }

  Future<List> getAllGrocItemsReviewReplys(
      int index, String grocId, int reviewIndex) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocId).get();
    Grocery groc = Grocery.fromDocument(docSnap);
    var obj = json.decode(groc.items[index]);

    List reviewsList = [];
    if (obj["review"] != null) {
      reviewsList = obj["review"];
    }

    List replyList = [];

    if (reviewsList[reviewIndex]["replys"] != null) {
      replyList = reviewsList[reviewIndex]["replys"];
      return replyList;
    } else {
      return replyList;
    }
  }

  deleteGroceryReview(String grocId, int reviewIndex) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocId).get();
    Grocery groc = Grocery.fromDocument(docSnap);

    List reviewsList = [];

    if (groc.reviews != null) {
      reviewsList = groc.reviews;
    }

    for (var element in reviewsList) {
      if (element["media"] != null) {
        if (element["media"].isNotEmpty) {
          for (var med in element["media"]) {
            await deleteStorage(json.decode(med)["url"]);
            await deleteStorage(json.decode(med)["thumb"]);
          }
        }
      }
    }

    reviewsList.removeAt(reviewIndex);
    await groceriesRef.document(grocId).updateData({
      "reviews": reviewsList,
    });
  }

  deleteGroceryItemReview(int index, String grocId, int reviewIndex) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocId).get();
    Grocery groc = Grocery.fromDocument(docSnap);
    var obj = json.decode(groc.items[index]);

    List reviewsList = [];
    if (obj["review"] != null) {
      reviewsList = obj["review"];
    }

    for (var element in reviewsList) {
      if (element["media"] != null) {
        if (element["media"].isNotEmpty) {
          for (var med in element["media"]) {
            await deleteStorage(json.decode(med)["url"]);
            await deleteStorage(json.decode(med)["thumb"]);
          }
        }
      }
    }

    reviewsList.removeAt(reviewIndex);

    var updatedObj = {
      "id": obj["id"],
      "initialImage": obj["initialImage"],
      "item_type": obj["item_type"],
      "item_name": obj["item_name"],
      "status": obj["status"],
      "price": obj["price"],
      "about": obj["about"],
      "brand": obj["brand"],
      "gallery": obj["gallery"],
      "total_ratings": obj["total_ratings"],
      "ratings": obj["ratings"],
      "review": reviewsList,
    };

    List grocItems = groc.items;
    grocItems[index] = json.encode(updatedObj);
    await groceriesRef.document(grocId).updateData({
      "items": grocItems,
    });
  }

  deleteGroceryReviewReply(
      String grocId, int reviewIndex, int replyIndex) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocId).get();
    Grocery groc = Grocery.fromDocument(docSnap);

    List reviewsList = [];

    if (groc.reviews != null) {
      reviewsList = groc.reviews;
    }

    List replyList = [];

    if (reviewsList[reviewIndex]["replys"] != null) {
      replyList = reviewsList[reviewIndex]["replys"];
    }

    for (var element in replyList) {
      if (element["media"] != null) {
        if (element["media"].isNotEmpty) {
          for (var med in element["media"]) {
            await deleteStorage(json.decode(med)["url"]);
            await deleteStorage(json.decode(med)["thumb"]);
          }
        }
      }
    }

    replyList.removeAt(replyIndex);

    var reviewObj = {
      "review": reviewsList[reviewIndex]["review"],
      "media": reviewsList[reviewIndex]["media"],
      "userId": reviewsList[reviewIndex]["userId"],
      "reactions": reviewsList[reviewIndex]["reactions"],
      "replys": replyList,
      "timestamp": reviewsList[reviewIndex]["timestamp"],
    };

    reviewsList[reviewIndex] = reviewObj;
    await groceriesRef.document(grocId).updateData({
      "reviews": reviewsList,
    });
  }

  deleteGroceryItemReviewReply(
      int index, String grocId, int reviewIndex, int replyIndex) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocId).get();
    Grocery groc = Grocery.fromDocument(docSnap);
    var obj = json.decode(groc.items[index]);

    List reviewsList = [];
    if (obj["review"] != null) {
      reviewsList = obj["review"];
    }

    List replyList = [];

    if (reviewsList[reviewIndex]["replys"] != null) {
      replyList = reviewsList[reviewIndex]["replys"];
    }

    for (var element in replyList) {
      if (element["media"] != null) {
        if (element["media"].isNotEmpty) {
          for (var med in element["media"]) {
            await deleteStorage(json.decode(med)["url"]);
            await deleteStorage(json.decode(med)["thumb"]);
          }
        }
      }
    }

    replyList.removeAt(replyIndex);

    var reviewObj = {
      "review": reviewsList[reviewIndex]["review"],
      "media": reviewsList[reviewIndex]["media"],
      "userId": reviewsList[reviewIndex]["userId"],
      "reactions": reviewsList[reviewIndex]["reactions"],
      "replys": replyList,
      "timestamp": reviewsList[reviewIndex]["timestamp"],
    };

    reviewsList[reviewIndex] = reviewObj;

    var updatedObj = {
      "id": obj["id"],
      "initialImage": obj["initialImage"],
      "item_type": obj["item_type"],
      "item_name": obj["item_name"],
      "status": obj["status"],
      "price": obj["price"],
      "about": obj["about"],
      "brand": obj["brand"],
      "gallery": obj["gallery"],
      "total_ratings": obj["total_ratings"],
      "ratings": obj["ratings"],
      "review": reviewsList,
    };

    List grocItems = groc.items;
    grocItems[index] = json.encode(updatedObj);
    await groceriesRef.document(grocId).updateData({
      "items": grocItems,
    });
  }

  Future<void> deleteStorage(String imageFileUrl) async {
    var fileUrl = Uri.decodeFull(Path.basename(imageFileUrl))
        .replaceAll(new RegExp(r'(\?alt).*'), '');

    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileUrl);
    await firebaseStorageRef.delete();
  }

  updateGroceryGallery(String grocId, dynamic mediaObj) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocId).get();
    Grocery groc = Grocery.fromDocument(docSnap);

    List gallery = [];
    if (groc.gallery != null) {
      gallery = groc.gallery;
    }

    gallery.add(mediaObj);

    await groceriesRef.document(grocId).updateData({
      "gallery": gallery,
    });
  }

  updateItemGallery(String grocId, int index, dynamic mediaObj) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocId).get();
    Grocery groc = Grocery.fromDocument(docSnap);
    var obj = json.decode(groc.items[index]);

    List gallery = [];

    if (obj["gallery"] != null) {
      gallery = obj["gallery"];
    }

    gallery.add(mediaObj);

    var updatedObj = {
      "id": obj["id"],
      "initialImage": obj["initialImage"],
      "item_type": obj["item_type"],
      "item_name": obj["item_name"],
      "status": obj["status"],
      "price": obj["price"],
      "about": obj["about"],
      "brand": obj["brand"],
      "gallery": gallery,
      "total_ratings": obj["total_ratings"],
      "ratings": obj["ratings"],
      "review": obj["review"],
    };

    List grocItems = groc.items;
    grocItems[index] = json.encode(updatedObj);
    await groceriesRef.document(grocId).updateData({
      "items": grocItems,
    });
  }

  deleteGroceryGalleryMedia(int index, String grocDocId) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocDocId).get();
    Grocery rest = Grocery.fromDocument(docSnap);
    List gallery = rest.gallery;
    await deleteStorage(json.decode(gallery[index])["url"]);
    await deleteStorage(json.decode(gallery[index])["thumb"]);
    gallery.removeAt(index);

    await groceriesRef.document(grocDocId).updateData({
      "gallery": gallery,
    });
  }

  deleteGrocItemGalleryMedia(int index, int itemIndex, String grocDocId) async {
    DocumentSnapshot docSnap = await groceriesRef.document(grocDocId).get();
    Grocery groc = Grocery.fromDocument(docSnap);
    List gallery = json.decode(groc.items[itemIndex])["gallery"];

    await deleteStorage(json.decode(gallery[index])["url"]);
    await deleteStorage(json.decode(gallery[index])["thumb"]);
    gallery.removeAt(index);

    var obj = json.decode(groc.items[itemIndex]);

    var updatedObj = {
      "id": obj["id"],
      "initialImage": obj["initialImage"],
      "item_type": obj["item_type"],
      "item_name": obj["item_name"],
      "status": obj["status"],
      "price": obj["price"],
      "about": obj["about"],
      "brand": obj["brand"],
      "gallery": gallery,
      "total_ratings": obj["total_ratings"],
      "ratings": obj["ratings"],
      "review": obj["review"],
    };

    List grocItems = groc.items;
    grocItems[itemIndex] = json.encode(updatedObj);

    await groceriesRef.document(grocDocId).updateData({
      "items": grocItems,
    });
  }

  Future<String> uploadImageGroc(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child("groc/groc_image/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadImageGrocThumbnail(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child("groc/groc_image_thumbnail/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToGroc(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child("groc/groc_video/user_$path${uuid.v1().toString()}.mp4")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToGrocThumb(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child("groc/groc_videoThumb/user_$path${uuid.v1().toString()}.jpg")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }
}
