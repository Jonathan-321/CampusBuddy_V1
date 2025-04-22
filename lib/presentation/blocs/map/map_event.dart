import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllLocations extends MapEvent {}

class LoadLocationDetails extends MapEvent {
  final String id;

  const LoadLocationDetails(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadLocationsByCategory extends MapEvent {
  final String category;

  const LoadLocationsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchLocations extends MapEvent {
  final String query;

  const SearchLocations(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterLocationsByCategory extends MapEvent {
  final String category;

  const FilterLocationsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class LoadNearbyLocations extends MapEvent {
  final LatLng userLocation;
  final double radiusInMeters;

  const LoadNearbyLocations({
    required this.userLocation,
    required this.radiusInMeters,
  });

  @override
  List<Object?> get props => [userLocation, radiusInMeters];
}

class LoadLocationCategories extends MapEvent {}

class LoadRecommendedLocations extends MapEvent {}

class RefreshLocations extends MapEvent {}
