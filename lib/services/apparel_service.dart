import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nearby/config/collections.dart';
import 'package:uuid/uuid.dart';

class ApparelService {
  Future<String> addApparel(
    String ownerId,
    String shopName,
    String details,
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
    List items,
    String district,
    List gallery,
    List rent,
    List tailor,
  ) async {
    var uuid = Uuid();
    DocumentReference docRe = await apparelRef.add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "ownerId": ownerId,
      "shopName": shopName,
      "details": details,
      "initialImage": initialImage,
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
      "items": items,
      "rent": rent,
      "tailor": tailor,
      "gallery": gallery,
      "timestamp": timestamp,
    });
    return docRe.documentID;
  }

  Future<String> uploadImageApparel(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child("apparel/apparel_image/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadImageApparelThumbnail(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child(
            "apparel/apparel_image_thumbnail/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToApparel(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child("apparel/apparel_video/user_$path${uuid.v1().toString()}.mp4")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToApparelThumb(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child(
            "apparel/apparel_videoThumb/user_$path${uuid.v1().toString()}.jpg")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }
}
