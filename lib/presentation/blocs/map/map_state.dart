import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../domain/entities/map_location.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLocationsLoaded extends MapState {
  final List<MapLocation> locations;

  const MapLocationsLoaded(this.locations);

  @override
  List<Object?> get props => [locations];
}

class MapLocationDetailsLoaded extends MapState {
  final MapLocation location;

  const MapLocationDetailsLoaded(this.location);

  @override
  List<Object?> get props => [location];
}

class MapLocationSelected extends MapState {
  final MapLocation location;

  const MapLocationSelected(this.location);

  @override
  List<Object?> get props => [location];
}

class MapLocationsByCategoryLoaded extends MapState {
  final String category;
  final List<MapLocation> locations;

  const MapLocationsByCategoryLoaded({
    required this.category,
    required this.locations,
  });

  @override
  List<Object?> get props => [category, locations];
}

class MapSearchResults extends MapState {
  final String query;
  final List<MapLocation> results;

  const MapSearchResults({
    required this.query,
    required this.results,
  });

  @override
  List<Object?> get props => [query, results];
}

class MapSearchEmpty extends MapState {
  final String query;

  const MapSearchEmpty(this.query);

  @override
  List<Object?> get props => [query];
}

class NearbyLocationsLoaded extends MapState {
  final LatLng userLocation;
  final double radiusInMeters;
  final List<MapLocation> locations;

  const NearbyLocationsLoaded({
    required this.userLocation,
    required this.radiusInMeters,
    required this.locations,
  });

  @override
  List<Object?> get props => [userLocation, radiusInMeters, locations];
}

class NoNearbyLocationsFound extends MapState {
  final LatLng userLocation;
  final double radiusInMeters;

  const NoNearbyLocationsFound({
    required this.userLocation,
    required this.radiusInMeters,
  });

  @override
  List<Object?> get props => [userLocation, radiusInMeters];
}

class MapCategoriesLoaded extends MapState {
  final List<String> categories;

  const MapCategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class RecommendedLocationsLoaded extends MapState {
  final List<MapLocation> locations;

  const RecommendedLocationsLoaded(this.locations);

  @override
  List<Object?> get props => [locations];
}

class MapEmpty extends MapState {}

class MapError extends MapState {
  final String message;

  const MapError(this.message);

  @override
  List<Object?> get props => [message];
}
