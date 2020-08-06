import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nearby/config/collections.dart';
import 'package:uuid/uuid.dart';

class EventServices {
  Future<String> addEvent(
    String ownerId,
    String eventTitle,
    String details,
    String initialImage,
    String address,
    double latitude,
    double longitude,
    String email,
    String entranceFee,
    DateTime heldOn,
    DateTime startTime,
    String telephone1,
    String telephone2,
    List gallery,
    String district,
  ) async {
    var uuid = Uuid();
    DocumentReference docRe = await eventsRef.add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "ownerId": ownerId,
      "eventTitle": eventTitle,
      "intialImage": initialImage,
      "eventDetails": details,
      "address": address,
      "district": district,
      "latitude": latitude,
      "longitude": longitude,
      "entranceFee": entranceFee,
      "telephone1": telephone1,
      "telephone2": telephone2,
      "email": email,
      "heldDate": heldOn,
      "startTime": startTime,
      "gallery": gallery,
      "timestamp": timestamp,
    });
    return docRe.documentID;
  }

  addMainBanner(
    String eventTitle,
    String details,
    String initialImage,
    String entranceFee,
    DateTime heldOn,
    DateTime startTime,
    String eventId,
  ) async {
    var uuid = Uuid();
    await mainBannerRef.add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "serviceId": eventId,
      "type": "event",
      "eventTitle": eventTitle,
      "intialImage": initialImage,
      "eventDetails": details,
      "heldDate": heldOn,
      "entranceFee": entranceFee,
      "startTime": startTime,
      "timestamp": timestamp,
    });
  }

  Future<String> uploadImageEvent(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child("event/event_image/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadImageEventThumbnail(File imageFile) async {
    var uuid = Uuid();
    StorageUploadTask uploadTask = storageRef
        .child("event/event_image_thumbnail/user_${uuid.v1().toString()}.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToEvent(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child("event/event_video/user_$path${uuid.v1().toString()}.mp4")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToEventThumb(File video) async {
    var uuid = Uuid();
    String path = uuid.v1().toString() + new DateTime.now().toString();
    StorageUploadTask uploadTask = storageRef
        .child("event/event_videoThumb/user_$path${uuid.v1().toString()}.jpg")
        .putFile(video);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadURL = await storageSnapshot.ref.getDownloadURL();
    return downloadURL;
  }
}
