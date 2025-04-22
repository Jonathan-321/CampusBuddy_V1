import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/map_location.dart';

class MapLocationModel extends MapLocation {
  MapLocationModel({
    required super.id,
    required super.name,
    required super.description,
    required LatLng coordinates,
    required super.category,
    super.imageUrl,
    super.floor,
    super.details,
    super.facilities,
    super.hours,
  }) : super(
          latitude: coordinates.latitude,
          longitude: coordinates.longitude,
        );

  factory MapLocationModel.fromJson(Map<String, dynamic> json) {
    return MapLocationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      coordinates: LatLng(
        json['coordinates']['latitude'] ?? 0.0,
        json['coordinates']['longitude'] ?? 0.0,
      ),
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'],
      floor: json['floor'] != null ? List<String>.from(json['floor']) : [],
      details: json['details'] != null
          ? Map<String, String>.from(json['details'])
          : {},
      facilities: json['facilities'] != null
          ? List<String>.from(json['facilities'])
          : [],
      hours: json['hours'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'category': category,
      'imageUrl': imageUrl,
      'floor': floor,
      'details': details,
      'facilities': facilities,
      'hours': hours,
    };
  }

  factory MapLocationModel.fromEntity(MapLocation location) {
    return MapLocationModel(
      id: location.id,
      name: location.name,
      description: location.description,
      coordinates: LatLng(location.latitude, location.longitude),
      category: location.category,
      imageUrl: location.imageUrl,
      floor: location.floor,
      details: location.details,
      facilities: location.facilities,
      hours: location.hours,
    );
  }
}
