import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nearby/config/collections.dart';
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
    List closingDays,
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
      "closingDays": closingDays,
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
      "resturantId": restId,
      "title": title,
      "type": "resturant",
      "address": address,
      "resturantName": restName,
      "intialImage": initialImage,
      "timestamp": timestamp,
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
