import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nearby/config/collections.dart';
import 'package:uuid/uuid.dart';

class NightLifeService {
  Future<String> addNightLife(
    String ownerId,
    String name,
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
    String specialHolidayshoursOfClosing,
    String district,
    List gallery,
    String type,
  ) async {
    var uuid = Uuid();
    DocumentReference docRe = await nightLifeRef.add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "ownerId": ownerId,
      "name": name,
      "type": type,
      "about": about,
      "intialImage": initialImage,
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
      "specialHolidayshoursOfClosing": specialHolidayshoursOfClosing,
      "gallery": gallery,
      "total_ratings": 0.0,
      "timestamp": timestamp,
    });
    return docRe.documentID;
  }

  Future<String> uploadImageNightLife(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child("nightlife/nightlife_image/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadImageNightLifeThumbnail(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child(
            "nightlife/nightlife_image_thumbnail/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToNightLife(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child(
            "nightlife/nightlife_video/user_$path${uuid.v1().toString()}.mp4")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToNightLifeThumb(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child(
            "nightlife/nightlife_videoThumb/user_$path${uuid.v1().toString()}.jpg")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }
}
