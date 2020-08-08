import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nearby/config/collections.dart';
import 'package:uuid/uuid.dart';

class StayService {
  Future<String> addStay(
      String ownerId,
      String name,
      String about,
      String initialImage,
      String address,
      double latitude,
      double longitude,
      String email,
      String website,
      String telephone1,
      String telephone2,
      String district,
      List gallery,
      int bathrooms,
      int beds,
      int bedrooms,
      int maxGuests,
      List features,
      String costPerNight) async {
    var uuid = Uuid();
    DocumentReference docRe = await stayRef.add({
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
      "gallery": gallery,
      "bathrooms": bathrooms,
      "bedrooms": bedrooms,
      "beds": beds,
      "costPerNight": costPerNight,
      "features": features,
      "maxguests": maxGuests,
      "timestamp": timestamp,
    });
    return docRe.documentID;
  }

  addMainBanner(
    String restName,
    String initialImage,
    String restId,
    String title,
    String address,
  ) async {
    var uuid = Uuid();
    await mainBannerRef.add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "serviceId": restId,
      "title": title,
      "type": "stay",
      "address": address,
      "serviceName": restName,
      "intialImage": initialImage,
      "timestamp": timestamp,
    });
  }

  Future<String> uploadImageStay(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child("stay/stay_image/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadImageStayThumbnail(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child("stay/stay_image_thumbnail/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToStay(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child("stay/stay_video/user_$path${uuid.v1().toString()}.mp4")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToStayThumb(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child("stay/stay_videoThumb/user_$path${uuid.v1().toString()}.jpg")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }
}
