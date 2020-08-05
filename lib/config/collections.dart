import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final StorageReference storageRef = FirebaseStorage.instance.ref();
final Firestore firestore = Firestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
final DateTime timestamp = DateTime.now();
final userRef = Firestore.instance.collection('user');
final servicesRef = Firestore.instance.collection('services');
final resturantsRef = Firestore.instance.collection('resturants');
final placesRef = Firestore.instance.collection('places');
final groceriesRef = Firestore.instance.collection('groceries');
final eventsRef = Firestore.instance.collection('events');
final mainBannerRef = Firestore.instance.collection('mainBanner');
final apparelRef = Firestore.instance.collection('apparel');
final vehicleServicesRef = Firestore.instance.collection('vehicleServices');
