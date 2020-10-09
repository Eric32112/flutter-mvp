import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

// To parse this JSON data, do
//
//     final flyer = flyerFromJson(jsonString);

import 'dart:convert';

import 'package:geolocator/geolocator.dart';

Flyer flyerFromJson(String str) => Flyer.fromJson(json.decode(str));

String flyerToJson(Flyer data) => json.encode(data.toJson());

class Flyer {
  Flyer(
      {this.id,
      this.location,
      this.eventName,
      this.imageUrl,
      this.date,
      this.endDate,
      this.liveTill,
      this.googleMapsObject});

  final String id;
  final Position location;
  final String eventName;
  final String imageUrl;
  final String date;
  final String endDate;
  final String liveTill;
  final dynamic googleMapsObject;
  Flyer copyWith(
          {String id,
          Position location,
          String eventName,
          String imageUrl,
          String date,
          String endDate,
          String liveTill,
          dynamic googleMapsObject}) =>
      Flyer(
          id: id ?? this.id,
          location: location ?? this.location,
          eventName: eventName ?? this.eventName,
          imageUrl: imageUrl ?? this.imageUrl,
          date: date ?? this.date,
          endDate: endDate ?? this.endDate,
          liveTill: liveTill ?? this.liveTill,
          googleMapsObject: googleMapsObject ?? googleMapsObject);

  factory Flyer.fromJson(Map<String, dynamic> json) => Flyer(
      id: json["id"] == null ? null : json["id"],
      location: json["location"] == null
          ? null
          : Position(
              latitude: (json['location']['geopoint'] as GeoPoint).latitude,
              longitude: (json['location']['geopoint'] as GeoPoint).longitude),
      eventName: json["eventName"] == null ? null : json["eventName"],
      imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
      date: json["date"] == null ? null : json["date"],
      endDate: json["endDate"] == null ? null : json["endDate"],
      liveTill: json['liveTill'] == null ? null : json['liveTill'],
      googleMapsObject: json['googleMapsObject']);

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "location": location == null ? null : GeoFirePoint(location.latitude, location.longitude).data,
        "eventName": eventName == null ? null : eventName,
        "imageUrl": imageUrl == null ? null : imageUrl,
        "date": date == null ? null : date,
        "endDate": endDate == null ? null : endDate,
        "liveTill": endDate == null ? null : liveTill,
        "googleMapsObject": googleMapsObject == null ? null : googleMapsObject
      };
}
