import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nearby/config/collections.dart';
import 'package:uuid/uuid.dart';

class SportsNwellnessService {
  Future<String> addSportsNwellness(
    String ownerId,
    String name,
    String about,
    String initialImage,
    String address,
    double latitude,
    double longitude,
    String email,
    String website,
    List closingDays,
    DateTime closingTime,
    DateTime openingTime,
    String telephone1,
    String telephone2,
    String specialHolidayshoursOfClosing,
    String district,
    List gallery,
    List items,
  ) async {
    var uuid = Uuid();
    DocumentReference docRe = await sportsNwellnessRef.add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "ownerId": ownerId,
      "name": name,
      "about": about,
      "intialImage": initialImage,
      "district": district,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "email": email,
      "website": website,
      "closingDays": closingDays,
      "closingTime": closingTime,
      "openingTime": openingTime,
      "telephone1": telephone1,
      "telephone2": telephone2,
      "specialHolidayshoursOfClosing": specialHolidayshoursOfClosing,
      "gallery": gallery,
      "items": items,
      "timestamp": timestamp,
    });
    return docRe.documentID;
  }

  Future<String> uploadImage(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child(
            "sportsNwellness/sportsNwellness_image/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadImageThumbnail(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child(
            "sportsNwellness/sportsNwellness_image_thumbnail/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideo(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child(
            "sportsNwellness/sportsNwellness_video/user_$path${uuid.v1().toString()}.mp4")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToThumb(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child(
            "sportsNwellness/sportsNwellness_videoThumb/user_$path${uuid.v1().toString()}.jpg")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }
}
