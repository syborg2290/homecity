import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String username;
  String district;
  String userPhotoUrl;
  String thumbnailUserPhotoUrl;
  String aboutYou;
  String email;
  String homecity;
  bool isOnline;
  Timestamp recentOnline;
  bool active;
  String androidNotificationToken;
  Timestamp timestamp;

  User(
      {this.id,
      this.username,
      this.district,
      this.userPhotoUrl,
      this.thumbnailUserPhotoUrl,
      this.aboutYou,
      this.email,
      this.homecity,
      this.isOnline,
      this.recentOnline,
      this.active,
      this.androidNotificationToken,
      this.timestamp});

  Map toMap(User user) {
    var data = Map<String, dynamic>();
    data['id'] = user.id;
    data['username'] = user.username;
    data['userPhotoUrl'] = user.userPhotoUrl;
    data['thumbnailUserPhotoUrl'] = user.thumbnailUserPhotoUrl;
    data['aboutYou'] = user.aboutYou;
    data['email'] = user.email;
    data['homecity'] = user.homecity;
    return data;
  }

  User.fromMap(Map<String, dynamic> mapData) {
    this.id = mapData['id'];
    this.username = mapData["username"];
    this.userPhotoUrl = mapData["userPhotoUrl"];
    this.thumbnailUserPhotoUrl = mapData["thumbnailUserPhotoUrl"];
    this.aboutYou = mapData["aboutYou"];
    this.email = mapData["email"];
    this.homecity = mapData["homecity"];
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc["id"],
        username: doc['username'],
        district: doc['district'],
        userPhotoUrl: doc['userPhotoUrl'],
        thumbnailUserPhotoUrl: doc['thumbnailUserPhotoUrl'],
        aboutYou: doc['aboutYou'],
        email: doc['email'],
        homecity: doc['homecity'],
        isOnline: doc['isOnline'],
        recentOnline: doc['recentOnline'],
        active: doc['active'],
        androidNotificationToken: doc['androidNotificationToken'],
        timestamp: doc['timestamp']);
  }
}
