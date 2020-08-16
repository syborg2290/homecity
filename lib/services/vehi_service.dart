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
    DateTime closingTime,
    DateTime openingTime,
    String telephone1,
    String telephone2,
    String specialHolidayshoursOfClosing,
    List vehicles,
    List gallery,
    dynamic repaircustomize,
    String type,
    String brand,
    String condition,
    String mileage,
    String model,
    String year,
    String price,
    List spareVehicles,
    String vehicleType,
    String status,
    String fuel,
    String transmission,
    String enginecapacity,
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
      "closingTime": closingTime,
      "openingTime": openingTime,
      "telephone1": telephone1,
      "telephone2": telephone2,
      "specialHolidayshoursOfClosing": specialHolidayshoursOfClosing,
      "vehicles": vehicles,
      "repaircustomize": repaircustomize,
      "gallery": gallery,
      "brand": brand,
      "condition": condition,
      "mileage": mileage,
      "model": model,
      "price": price,
      "year": year,
      "spareVehicles": spareVehicles,
      "vehicleType": vehicleType,
      "fuel": fuel,
      "transmission": transmission,
      "enginecapacity": enginecapacity,
      "status": status,
      "timestamp": timestamp,
    });
    return docRe.documentID;
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
