import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nearby/config/collections.dart';
import 'package:nearby/models/resturant.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as Path;

class ResturantService {
  Future<String> addResturant(
    String ownerId,
    String restname,
    String about,
    String initialImage,
    String address,
    double latitude,
    double longitude,
    String email,
    String website,
    DateTime closingTime,
    DateTime openingTime,
    String telephone1,
    String telephone2,
    List serviceType,
    String specialHolidayshoursOfClosing,
    List menu,
    String district,
    List gallery,
    String deliveryRange,
  ) async {
    var uuid = Uuid();
    DocumentReference docRe = await resturantsRef.add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "ownerId": ownerId,
      "restName": restname,
      "aboutRest": about,
      "initialImage": initialImage,
      "district": district,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "email": email,
      "website": website,
      "closingTime": closingTime,
      "openingTime": openingTime,
      "telephone1": telephone1,
      "telephone2": telephone2,
      "serviceType": serviceType,
      "specialHolidayshoursOfClosing": specialHolidayshoursOfClosing,
      "menu": menu,
      "gallery": gallery,
      "total_ratings": 0.0,
      "delivery_range": deliveryRange,
      "timestamp": timestamp,
    });
    return docRe.documentID;
  }

  Future<QuerySnapshot> getAllResturant() async {
    return resturantsRef.orderBy('timestamp', descending: true).getDocuments();
  }

  Stream<QuerySnapshot> streamResturant() {
    return resturantsRef.orderBy('timestamp', descending: true).snapshots();
  }

  Stream<QuerySnapshot> streamSingleRest(String id) {
    return resturantsRef.where("id", isEqualTo: id).snapshots();
  }

  Future<QuerySnapshot> fetchSingleRest(String id) {
    return resturantsRef.where("id", isEqualTo: id).getDocuments();
  }

  setRatingsToResturant(String restId, double rate, String userId) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restId).get();
    Resturant rest = Resturant.fromDocument(docSnap);
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

    await resturantsRef.document(restId).updateData({
      "ratings": ratings,
      "total_ratings": totalRatings,
    });
  }

  setRatingsToFoodItem(
      int index, String restId, double rate, String userId) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restId).get();
    Resturant rest = Resturant.fromDocument(docSnap);
    var obj = json.decode(rest.menu[index]);
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
          "price": obj["price"],
          "portion_count": obj["portion_count"],
          "about": obj["about"],
          "foodTake": obj["foodTake"],
          "gallery": obj["gallery"],
          "total_ratings": totalRatings,
          "ratings": ratings,
        };

        List menuItems = rest.menu;
        menuItems[index] = json.encode(updatedObj);
        await resturantsRef.document(restId).updateData({
          "menu": menuItems,
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
          "price": obj["price"],
          "portion_count": obj["portion_count"],
          "about": obj["about"],
          "foodTake": obj["foodTake"],
          "gallery": obj["gallery"],
          "total_ratings": totalRatings,
          "ratings": ratings,
        };

        List menuItems = rest.menu;
        menuItems[index] = json.encode(updatedObj);
        await resturantsRef.document(restId).updateData({
          "menu": menuItems,
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
        "price": obj["price"],
        "portion_count": obj["portion_count"],
        "about": obj["about"],
        "foodTake": obj["foodTake"],
        "gallery": obj["gallery"],
        "total_ratings": totalRatings,
        "ratings": ratings,
      };

      List menuItems = rest.menu;
      menuItems[index] = json.encode(updatedObj);
      await resturantsRef.document(restId).updateData({
        "menu": menuItems,
      });
    }
  }

  setReviewToResturant(
      String restId, String review, dynamic media, String userId) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restId).get();
    Resturant rest = Resturant.fromDocument(docSnap);
    List reviewsList = [];
    if (rest.reviews != null) {
      reviewsList = rest.reviews;
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

    await resturantsRef.document(restId).updateData({
      "reviews": reviewsList,
    });
  }

  setReviewToFoodItem(int index, String restId, String review, dynamic media,
      String userId) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restId).get();
    Resturant rest = Resturant.fromDocument(docSnap);
    var obj = json.decode(rest.menu[index]);

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
      "price": obj["price"],
      "portion_count": obj["portion_count"],
      "about": obj["about"],
      "foodTake": obj["foodTake"],
      "gallery": obj["gallery"],
      "total_ratings": obj["total_ratings"],
      "ratings": obj["ratings"],
      "review": reviewsList,
    };

    List menuItems = rest.menu;
    menuItems[index] = json.encode(updatedObj);
    await resturantsRef.document(restId).updateData({
      "menu": menuItems,
    });
  }

  setReactionToResturantReview(
      String restId, String userId, int reviewIndex, String reaction) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restId).get();
    Resturant rest = Resturant.fromDocument(docSnap);
    List reviewsList = [];

    if (rest.reviews != null) {
      reviewsList = rest.reviews;
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

    await resturantsRef.document(restId).updateData({
      "reviews": reviewsList,
    });
  }

  setReactionsToResturantItemReview(int index, String restId, String userId,
      int reviewIndex, String reaction) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restId).get();
    Resturant rest = Resturant.fromDocument(docSnap);
    var obj = json.decode(rest.menu[index]);

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
      "price": obj["price"],
      "portion_count": obj["portion_count"],
      "about": obj["about"],
      "foodTake": obj["foodTake"],
      "gallery": obj["gallery"],
      "total_ratings": obj["total_ratings"],
      "ratings": obj["ratings"],
      "review": reviewsList,
    };

    List menuItems = rest.menu;
    menuItems[index] = json.encode(updatedObj);
    await resturantsRef.document(restId).updateData({
      "menu": menuItems,
    });
  }

  addReplyToResturantReview(String restId, List media, String userId,
      int reviewIndex, String reply) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restId).get();
    Resturant rest = Resturant.fromDocument(docSnap);
    List reviewsList = [];

    if (rest.reviews != null) {
      reviewsList = rest.reviews;
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

    await resturantsRef.document(restId).updateData({
      "reviews": reviewsList,
    });
  }

  addReplyToResturantItemReview(int index, String restId, List media,
      String userId, int reviewIndex, String reply) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restId).get();
    Resturant rest = Resturant.fromDocument(docSnap);
    var obj = json.decode(rest.menu[index]);

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
      "price": obj["price"],
      "portion_count": obj["portion_count"],
      "about": obj["about"],
      "foodTake": obj["foodTake"],
      "gallery": obj["gallery"],
      "total_ratings": obj["total_ratings"],
      "ratings": obj["ratings"],
      "review": reviewsList,
    };

    List menuItems = rest.menu;
    menuItems[index] = json.encode(updatedObj);
    await resturantsRef.document(restId).updateData({
      "menu": menuItems,
    });
  }

  setReactionToResturantReviewReply(String restId, String userId,
      int reviewIndex, int replyIndex, String reaction) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restId).get();
    Resturant rest = Resturant.fromDocument(docSnap);

    List reviewsList = [];

    if (rest.reviews != null) {
      reviewsList = rest.reviews;
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

    await resturantsRef.document(restId).updateData({
      "reviews": reviewsList,
    });
  }

  setReactionRestItemToReviewReply(int index, String restId, String userId,
      int reviewIndex, int replyIndex, String reaction) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restId).get();
    Resturant rest = Resturant.fromDocument(docSnap);
    var obj = json.decode(rest.menu[index]);

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
      "price": obj["price"],
      "portion_count": obj["portion_count"],
      "about": obj["about"],
      "foodTake": obj["foodTake"],
      "gallery": obj["gallery"],
      "total_ratings": obj["total_ratings"],
      "ratings": obj["ratings"],
      "review": reviewsList,
    };

    List menuItems = rest.menu;
    menuItems[index] = json.encode(updatedObj);
    await resturantsRef.document(restId).updateData({
      "menu": menuItems,
    });
  }

  getAllRestReviewReplys(String restId, int reviewIndex) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restId).get();
    Resturant rest = Resturant.fromDocument(docSnap);
    List reviewsList = [];

    if (rest.reviews != null) {
      reviewsList = rest.reviews;
    }

    List replyList = [];

    if (reviewsList[reviewIndex]["replys"] != null) {
      replyList = reviewsList[reviewIndex]["replys"];
      return replyList;
    } else {
      return replyList;
    }
  }

  Future<List> getAllRestItemsReviewReplys(
      int index, String restId, int reviewIndex) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restId).get();
    Resturant rest = Resturant.fromDocument(docSnap);
    var obj = json.decode(rest.menu[index]);

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

  deleteResturantReview(String restId, int reviewIndex) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restId).get();
    Resturant rest = Resturant.fromDocument(docSnap);

    List reviewsList = [];

    if (rest.reviews != null) {
      reviewsList = rest.reviews;
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
    await resturantsRef.document(restId).updateData({
      "reviews": reviewsList,
    });
  }

  deleteResturantItemReview(int index, String restId, int reviewIndex) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restId).get();
    Resturant rest = Resturant.fromDocument(docSnap);
    var obj = json.decode(rest.menu[index]);

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
      "price": obj["price"],
      "portion_count": obj["portion_count"],
      "about": obj["about"],
      "foodTake": obj["foodTake"],
      "gallery": obj["gallery"],
      "total_ratings": obj["total_ratings"],
      "ratings": obj["ratings"],
      "review": reviewsList,
    };

    List menuItems = rest.menu;
    menuItems[index] = json.encode(updatedObj);
    await resturantsRef.document(restId).updateData({
      "menu": menuItems,
    });
  }

  deleteResturantReviewReply(
      String restId, int reviewIndex, int replyIndex) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restId).get();
    Resturant rest = Resturant.fromDocument(docSnap);

    List reviewsList = [];

    if (rest.reviews != null) {
      reviewsList = rest.reviews;
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
    await resturantsRef.document(restId).updateData({
      "reviews": reviewsList,
    });
  }

  deleteResturantItemReviewReply(
      int index, String restId, int reviewIndex, int replyIndex) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restId).get();
    Resturant rest = Resturant.fromDocument(docSnap);
    var obj = json.decode(rest.menu[index]);

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
      "price": obj["price"],
      "portion_count": obj["portion_count"],
      "about": obj["about"],
      "foodTake": obj["foodTake"],
      "total_ratings": obj["total_ratings"],
      "gallery": obj["gallery"],
      "ratings": obj["ratings"],
      "review": reviewsList,
    };

    List menuItems = rest.menu;
    menuItems[index] = json.encode(updatedObj);
    await resturantsRef.document(restId).updateData({
      "menu": menuItems,
    });
  }

  Future<void> deleteStorage(String imageFileUrl) async {
    var fileUrl = Uri.decodeFull(Path.basename(imageFileUrl))
        .replaceAll(new RegExp(r'(\?alt).*'), '');

    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileUrl);
    await firebaseStorageRef.delete();
  }

  updateResturantGallery(String restId, dynamic mediaObj) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restId).get();
    Resturant rest = Resturant.fromDocument(docSnap);

    List gallery = [];
    if (rest.gallery != null) {
      gallery = rest.gallery;
    }

    gallery.add(mediaObj);

    await resturantsRef.document(restId).updateData({
      "gallery": gallery,
    });
  }

  updateItemGallery(String restId, int index, dynamic mediaObj) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restId).get();
    Resturant rest = Resturant.fromDocument(docSnap);
    var obj = json.decode(rest.menu[index]);

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
      "price": obj["price"],
      "portion_count": obj["portion_count"],
      "about": obj["about"],
      "foodTake": obj["foodTake"],
      "total_ratings": obj["total_ratings"],
      "gallery": gallery,
      "ratings": obj["ratings"],
      "review": obj["review"],
    };

    List menuItems = rest.menu;
    menuItems[index] = json.encode(updatedObj);
    await resturantsRef.document(restId).updateData({
      "menu": menuItems,
    });
  }

  deleteRestGalleryMedia(int index, String restDocId) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restDocId).get();
    Resturant rest = Resturant.fromDocument(docSnap);
    List gallery = rest.gallery;
    await deleteStorage(json.decode(gallery[index])["url"]);
    await deleteStorage(json.decode(gallery[index])["thumb"]);
    gallery.removeAt(index);

    await resturantsRef.document(restDocId).updateData({
      "gallery": gallery,
    });
  }

  deleteRestItemGalleryMedia(int index, int itemIndex, String restDocId) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restDocId).get();
    Resturant rest = Resturant.fromDocument(docSnap);
    List gallery = json.decode(rest.menu[itemIndex])["gallery"];

    await deleteStorage(json.decode(gallery[index])["url"]);
    await deleteStorage(json.decode(gallery[index])["thumb"]);
    gallery.removeAt(index);

    var obj = json.decode(rest.menu[itemIndex]);
    var updatedObj = {
      "id": obj["id"],
      "initialImage": obj["initialImage"],
      "item_type": obj["item_type"],
      "item_name": obj["item_name"],
      "price": obj["price"],
      "portion_count": obj["portion_count"],
      "about": obj["about"],
      "foodTake": obj["foodTake"],
      "total_ratings": obj["total_ratings"],
      "gallery": gallery,
      "ratings": obj["ratings"],
      "review": obj["review"],
    };
    List menuItems = rest.menu;
    menuItems[itemIndex] = json.encode(updatedObj);

    await resturantsRef.document(restDocId).updateData({
      "menu": menuItems,
    });
  }

  Future<String> uploadImageRest(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child("resturant/rest_image/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadImageRestThumbnail(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child(
            "resturant/rest_image_thumbnail/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToRest(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child("resturant/rest_video/user_$path${uuid.v1().toString()}.mp4")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToRestThumb(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child(
            "resturant/rest_videoThumb/user_$path${uuid.v1().toString()}.jpg")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }
}
