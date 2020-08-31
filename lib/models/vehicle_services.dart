import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleS {
  String id;
  String ownerId;
  String type;
  String serviceName;
  String details;
  String initialImage;
  double latitude;
  double longitude;
  String district;
  String address;
  String email;
  String website;
  String telephone1;
  String telephone2;
  Timestamp closingTime;
  Timestamp openingTime;
  String specialHolidayshoursOfClosing;
  dynamic repaircustomize;
  List vehicles;
  List gallery;
  String price;
  String condition;
  String brand;
  String model;
  String fuel;
  String transmission;
  String year;
  String mileage;
  List spareVehicles;
  String vehicleType;
  String enginecapacity;
  String status;
  double totalratings;
  List ratings;
  List reviews;
  Timestamp timestamp;

  VehicleS({
    this.id,
    this.ownerId,
    this.type,
    this.serviceName,
    this.details,
    this.initialImage,
    this.latitude,
    this.longitude,
    this.district,
    this.address,
    this.email,
    this.website,
    this.telephone1,
    this.telephone2,
    this.closingTime,
    this.openingTime,
    this.specialHolidayshoursOfClosing,
    this.repaircustomize,
    this.vehicles,
    this.gallery,
    this.brand,
    this.condition,
    this.mileage,
    this.model,
    this.price,
    this.year,
    this.spareVehicles,
    this.vehicleType,
    this.status,
    this.timestamp,
    this.fuel,
    this.enginecapacity,
    this.totalratings,
    this.ratings,
    this.reviews,
    this.transmission,
  });

  factory VehicleS.fromDocument(DocumentSnapshot doc) {
    return VehicleS(
      id: doc['id'],
      ownerId: doc['ownerId'],
      type: doc['type'],
      serviceName: doc['serviceName'],
      details: doc['details'],
      initialImage: doc['initialImage'],
      latitude: doc['latitude'],
      longitude: doc['longitude'],
      district: doc['district'],
      address: doc['address'],
      email: doc['email'],
      website: doc['website'],
      telephone1: doc['telephone1'],
      telephone2: doc['telephone2'],
      closingTime: doc['closingTime'],
      openingTime: doc['openingTime'],
      specialHolidayshoursOfClosing: doc['specialHolidayshoursOfClosing'],
      repaircustomize: doc['repaircustomize'],
      vehicles: doc['vehicles'],
      gallery: doc['gallery'],
      brand: doc['brand'],
      condition: doc['condition'],
      mileage: doc['mileage'],
      model: doc['model'],
      price: doc['price'],
      year: doc['year'],
      spareVehicles: doc['spareVehicles'],
      vehicleType: doc['vehicleType'],
      status: doc['status'],
      fuel: doc['fuel'],
      transmission: doc['transmission'],
      enginecapacity: doc['enginecapacity'],
      totalratings: doc['total_ratings'],
      ratings: doc['ratings'],
      reviews: doc['reviews'],
      timestamp: doc['timestamp'],
    );
  }
}
