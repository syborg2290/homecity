import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nearby/config/collections.dart';
import 'package:uuid/uuid.dart';

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
  ) async {
    var uuid = Uuid();
    DocumentReference docRe = await placesRef.add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "ownerId": ownerId,
      "placeName": placeName,
      "intialImage": intialImage,
      "aboutThePlace": about,
      "district": district,
      "latitude": latitude,
      "longitude": longitude,
      "entranceFee": entranceFee,
      "daysOfUnavailable": daysOfUn,
      "specialUnavailable": specialUn,
      "gallery": gallery,
      "timestamp": timestamp
    });
    return docRe.documentID;
  }

  addMainBanner(
    String placeName,
    String initialImage,
    String placeId,
    String title,
  ) async {
    var uuid = Uuid();
    await mainBannerRef.add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "placeId": placeId,
      "title": title,
      "type": "place",
      "placeName": placeName,
      "intialImage": initialImage,
      "timestamp": timestamp,
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
