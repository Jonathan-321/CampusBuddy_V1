import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../domain/usecases/map_usecase.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final MapUseCase _mapUseCase;

  MapBloc(this._mapUseCase) : super(MapInitial()) {
    on<LoadAllLocations>(_onLoadAllLocations);
    on<LoadLocationDetails>(_onLoadLocationDetails);
    on<LoadLocationsByCategory>(_onLoadLocationsByCategory);
    on<SearchLocations>(_onSearchLocations);
    on<LoadNearbyLocations>(_onLoadNearbyLocations);
    on<LoadLocationCategories>(_onLoadLocationCategories);
    on<LoadRecommendedLocations>(_onLoadRecommendedLocations);
    on<RefreshLocations>(_onRefreshLocations);
    on<FilterLocationsByCategory>(_onFilterLocationsByCategory);
  }

  Future<void> _onLoadAllLocations(
      LoadAllLocations event, Emitter<MapState> emit) async {
    emit(MapLoading());
    try {
      final locations = await _mapUseCase.getAllLocations();

      if (locations.isEmpty) {
        emit(MapEmpty());
      } else {
        emit(MapLocationsLoaded(locations));
      }
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }

  Future<void> _onLoadLocationDetails(
      LoadLocationDetails event, Emitter<MapState> emit) async {
    emit(MapLoading());
    try {
      final location = await _mapUseCase.getLocationById(event.id);
      emit(MapLocationDetailsLoaded(location));
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }

  Future<void> _onLoadLocationsByCategory(
      LoadLocationsByCategory event, Emitter<MapState> emit) async {
    emit(MapLoading());
    try {
      final locations =
          await _mapUseCase.getLocationsByCategory(event.category);

      if (locations.isEmpty) {
        emit(MapEmpty());
      } else {
        emit(MapLocationsByCategoryLoaded(
          category: event.category,
          locations: locations,
        ));
      }
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }

  Future<void> _onSearchLocations(
      SearchLocations event, Emitter<MapState> emit) async {
    emit(MapLoading());
    try {
      final locations = await _mapUseCase.searchLocations(event.query);

      if (locations.isEmpty) {
        emit(MapSearchEmpty(event.query));
      } else {
        emit(MapSearchResults(
          query: event.query,
          results: locations,
        ));
      }
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }

  Future<void> _onLoadNearbyLocations(
      LoadNearbyLocations event, Emitter<MapState> emit) async {
    emit(MapLoading());
    try {
      final locations = await _mapUseCase.getNearbyLocations(
        event.userLocation,
        event.radiusInMeters,
      );

      if (locations.isEmpty) {
        emit(NoNearbyLocationsFound(
          userLocation: event.userLocation,
          radiusInMeters: event.radiusInMeters,
        ));
      } else {
        emit(NearbyLocationsLoaded(
          userLocation: event.userLocation,
          radiusInMeters: event.radiusInMeters,
          locations: locations,
        ));
      }
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }

  Future<void> _onLoadLocationCategories(
      LoadLocationCategories event, Emitter<MapState> emit) async {
    emit(MapLoading());
    try {
      final categories = await _mapUseCase.getAllLocationCategories();

      if (categories.isEmpty) {
        emit(MapEmpty());
      } else {
        emit(MapCategoriesLoaded(categories));
      }
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }

  Future<void> _onLoadRecommendedLocations(
      LoadRecommendedLocations event, Emitter<MapState> emit) async {
    emit(MapLoading());
    try {
      final locations = await _mapUseCase.getRecommendedLocations();

      if (locations.isEmpty) {
        emit(MapEmpty());
      } else {
        emit(RecommendedLocationsLoaded(locations));
      }
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }

  Future<void> _onRefreshLocations(
      RefreshLocations event, Emitter<MapState> emit) async {
    emit(MapLoading());
    try {
      await _mapUseCase.refreshLocations();
      final locations = await _mapUseCase.getAllLocations();

      if (locations.isEmpty) {
        emit(MapEmpty());
      } else {
        emit(MapLocationsLoaded(locations));
      }
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }

  Future<void> _onFilterLocationsByCategory(
      FilterLocationsByCategory event, Emitter<MapState> emit) async {
    emit(MapLoading());
    try {
      final locations =
          await _mapUseCase.getLocationsByCategory(event.category);

      if (locations.isEmpty) {
        emit(MapEmpty());
      } else {
        emit(MapLocationsByCategoryLoaded(
          category: event.category,
          locations: locations,
        ));
      }
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }
}
