import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nearby/config/collections.dart';
import 'package:nearby/models/place.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as Path;

class PlaceService {
  Future<String> addPlace(
    String ownerId,
    String placeName,
    String intialImage,
    String about,
    double latitude,
    double longitude,
    String entranceFee,
    List daysOfUn,
    String specialUn,
    String district,
    List gallery,
    String type,
  ) async {
    var uuid = Uuid();
    DocumentReference docRe = await placesRef.add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "ownerId": ownerId,
      "placeName": placeName,
      "type": type,
      "intialImage": intialImage,
      "aboutThePlace": about,
      "district": district,
      "latitude": latitude,
      "longitude": longitude,
      "entranceFee": entranceFee,
      "daysOfUnavailable": daysOfUn,
      "specialUnavailable": specialUn,
      "gallery": gallery,
      "total_ratings": 0.0,
      "timestamp": timestamp
    });
    return docRe.documentID;
  }

  Future<QuerySnapshot> getAllPlaces() async {
    return placesRef.orderBy('timestamp', descending: true).getDocuments();
  }

  Stream<QuerySnapshot> streamPlaces() {
    return placesRef.orderBy('timestamp', descending: true).snapshots();
  }

  Stream<QuerySnapshot> streamSinglePlace(String id) {
    return placesRef.where("id", isEqualTo: id).snapshots();
  }

  Future<QuerySnapshot> fetchSinglePlace(String id) {
    return placesRef.where("id", isEqualTo: id).getDocuments();
  }

  setRatingsToPlace(String placeId, double rate, String userId) async {
    DocumentSnapshot docSnap = await placesRef.document(placeId).get();
    Place rest = Place.fromDocument(docSnap);
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

    await placesRef.document(placeId).updateData({
      "ratings": ratings,
      "total_ratings": totalRatings,
    });
  }

  setReviewToPlace(
      String placeId, String review, dynamic media, String userId) async {
    DocumentSnapshot docSnap = await placesRef.document(placeId).get();
    Place rest = Place.fromDocument(docSnap);
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

    await placesRef.document(placeId).updateData({
      "reviews": reviewsList,
    });
  }

  setReactionToPlaceReview(
      String placeId, String userId, int reviewIndex, String reaction) async {
    DocumentSnapshot docSnap = await placesRef.document(placeId).get();
    Place rest = Place.fromDocument(docSnap);
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

    await placesRef.document(placeId).updateData({
      "reviews": reviewsList,
    });
  }

  addReplyToPlaceReview(String placeId, List media, String userId,
      int reviewIndex, String reply) async {
    DocumentSnapshot docSnap = await placesRef.document(placeId).get();
    Place rest = Place.fromDocument(docSnap);
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

    await placesRef.document(placeId).updateData({
      "reviews": reviewsList,
    });
  }

  setReactionToPlaceReviewReply(String placeId, String userId, int reviewIndex,
      int replyIndex, String reaction) async {
    DocumentSnapshot docSnap = await placesRef.document(placeId).get();
    Place rest = Place.fromDocument(docSnap);

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

    await placesRef.document(placeId).updateData({
      "reviews": reviewsList,
    });
  }

  getAllPlaceReviewReplys(String placeId, int reviewIndex) async {
    DocumentSnapshot docSnap = await placesRef.document(placeId).get();
    Place rest = Place.fromDocument(docSnap);
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

  deletePlaceReview(String placeId, int reviewIndex) async {
    DocumentSnapshot docSnap = await placesRef.document(placeId).get();
    Place rest = Place.fromDocument(docSnap);

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
    await placesRef.document(placeId).updateData({
      "reviews": reviewsList,
    });
  }

  deletePlaceReviewReply(
      String placeId, int reviewIndex, int replyIndex) async {
    DocumentSnapshot docSnap = await placesRef.document(placeId).get();
    Place rest = Place.fromDocument(docSnap);

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
    await placesRef.document(placeId).updateData({
      "reviews": reviewsList,
    });
  }

  Future<void> deleteStorage(String imageFileUrl) async {
    var fileUrl = Uri.decodeFull(Path.basename(imageFileUrl))
        .replaceAll(new RegExp(r'(\?alt).*'), '');

    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileUrl);
    await firebaseStorageRef.delete();
  }

  updatePlaceGallery(String placeId, dynamic mediaObj) async {
    DocumentSnapshot docSnap = await placesRef.document(placeId).get();
    Place rest = Place.fromDocument(docSnap);

    List gallery = [];
    if (rest.gallery != null) {
      gallery = rest.gallery;
    }

    gallery.add(mediaObj);

    await placesRef.document(placeId).updateData({
      "gallery": gallery,
    });
  }

  deletePlaceGalleryMedia(int index, String restDocId) async {
    DocumentSnapshot docSnap = await resturantsRef.document(restDocId).get();
    Place rest = Place.fromDocument(docSnap);
    List gallery = rest.gallery;
    await deleteStorage(json.decode(gallery[index])["url"]);
    await deleteStorage(json.decode(gallery[index])["thumb"]);
    gallery.removeAt(index);

    await resturantsRef.document(restDocId).updateData({
      "gallery": gallery,
    });
  }

  Future<String> uploadImagePlace(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child("place/place_image/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadImagePlaceThumbnail(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child("place/place_image_thumbnail/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToPlace(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child("place/place_video/user_$path${uuid.v1().toString()}.mp4")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToPlaceThumb(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child("place/place_videoThumb/user_$path${uuid.v1().toString()}.jpg")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }
}
