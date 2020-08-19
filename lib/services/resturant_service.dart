import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nearby/config/collections.dart';
import 'package:nearby/models/resturant.dart';
import 'package:uuid/uuid.dart';

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
        bool status = ratings
            .where((element) => element["userId"] == userId)
            .toList()
            .isEmpty;
        if (!status) {
          ratings.add(rateObj);
        } else {
          int indexRe =
              ratings.indexWhere((element) => element["userId"] == userId);
          ratings[indexRe]["rate"] = rate;
        }
      } else {
        var rateObj = {
          "rate": rate.toInt(),
          "userId": userId,
          "timestamp": timestamp.toIso8601String(),
        };
        ratings.add(rateObj);
      }
    } else {
      var rateObj = {
        "rate": rate.toInt(),
        "userId": userId,
        "timestamp": timestamp.toIso8601String(),
      };
      ratings.add(rateObj);
    }

    var updatedObj = {
      "initialImage": obj["initialImage"],
      "item_type": obj["item_type"],
      "item_name": obj["item_name"],
      "price": obj["price"],
      "portion_count": obj["portion_count"],
      "about": obj["about"],
      "foodTake": obj["foodTake"],
      "gallery": obj["gallery"],
      "ratings": ratings,
    };

    List menuItems = rest.menu;
    menuItems[index] = json.encode(updatedObj);
    await resturantsRef.document(restId).updateData({
      "menu": menuItems,
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
      "initialImage": obj["initialImage"],
      "item_type": obj["item_type"],
      "item_name": obj["item_name"],
      "price": obj["price"],
      "portion_count": obj["portion_count"],
      "about": obj["about"],
      "foodTake": obj["foodTake"],
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
