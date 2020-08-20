import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final StorageReference storageRef = FirebaseStorage.instance.ref();
final Firestore firestore = Firestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
final DateTime timestamp = DateTime.now();
final userRef = Firestore.instance.collection('user');
final activityFeedRef = Firestore.instance.collection("feedNotification");
final servicesRef = Firestore.instance.collection('services');
final resturantsRef = Firestore.instance.collection('resturants');
final placesRef = Firestore.instance.collection('places');
final groceriesRef = Firestore.instance.collection('groceries');
final eventsRef = Firestore.instance.collection('events');
final apparelRef = Firestore.instance.collection('apparel');
final vehicleServicesRef = Firestore.instance.collection('vehicleServices');
final nightLifeRef = Firestore.instance.collection('nightlife');
final stayRef = Firestore.instance.collection('stay');
final educationRef = Firestore.instance.collection('education');
final electronicsRef = Firestore.instance.collection('electronics');
final saloonsandBeautyRef = Firestore.instance.collection('saloonsandBeauty');
final propertyRef = Firestore.instance.collection('property');
final homeRef = Firestore.instance.collection('home');
final hardwareAndMaterialsRef =
    Firestore.instance.collection('hardwareAndMaterials');
final musicRef = Firestore.instance.collection('music');
final sportsNwellnessRef = Firestore.instance.collection('sportsNwellness');
