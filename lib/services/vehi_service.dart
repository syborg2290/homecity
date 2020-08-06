import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nearby/config/collections.dart';
import 'package:uuid/uuid.dart';

class VehiService {
  Future<String> addVehiSe(
    String ownerId,
    String shopName,
    String details,
    String initialImage,
    String address,
    double latitude,
    double longitude,
    String email,
    String district,
    String website,
    List closingDays,
    DateTime closingTime,
    DateTime openingTime,
    String telephone1,
    String telephone2,
    String specialHolidayshoursOfClosing,
    List vehicles,
    List gallery,
    dynamic repaircustomize,
    String type,
  ) async {
    var uuid = Uuid();
    DocumentReference docRe = await vehicleServicesRef.add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "ownerId": ownerId,
      "shopName": shopName,
      "type": type,
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
      "vehicles": vehicles,
      "repaircustomize": repaircustomize,
      "gallery": gallery,
      "timestamp": timestamp,
    });
    return docRe.documentID;
  }

  addMainBanner(
    String shopName,
    String initialImage,
    String vehiSeId,
    String title,
    String address,
  ) async {
    var uuid = Uuid();
    await mainBannerRef.add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "serviceId": vehiSeId,
      "title": title,
      "type": "vehiSe",
      "address": address,
      "serviceName": shopName,
      "intialImage": initialImage,
      "timestamp": timestamp,
    });
  }

  Future<String> uploadImageVehiSe(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child("vehiSe/vehiSe_image/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadImageVehiSeThumbnail(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child("vehiSe/vehiSe_image_thumbnail/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToVehiSe(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child("vehiSe/vehiSe_video/user_$path${uuid.v1().toString()}.mp4")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToVehiSeThumb(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child("vehiSe/vehiSe_videoThumb/user_$path${uuid.v1().toString()}.jpg")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }
}
