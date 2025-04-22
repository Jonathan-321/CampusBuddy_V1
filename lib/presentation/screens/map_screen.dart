import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../config/theme.dart';
import '../blocs/map/map_bloc.dart';
import '../blocs/map/map_event.dart';
import '../blocs/map/map_state.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart' as error_widget;
import '../../domain/entities/map_location.dart';

class MapScreen extends StatefulWidget {
  final String? initialLocationId;

  const MapScreen({
    Key? key,
    this.initialLocationId,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Location _location = Location();
  LatLng? _currentPosition;
  MapLocation? _selectedLocation;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  List<String> _categories = [];
  String? _selectedCategory;

  // Default campus position (replace with your university coordinates)
  final LatLng _campusPosition = const LatLng(40.7128, -74.0060);

  @override
  void initState() {
    super.initState();

    // Get the current location
    _getCurrentLocation();

    // Load all locations
    context.read<MapBloc>().add(LoadAllLocations());

    // Load location categories
    context.read<MapBloc>().add(LoadLocationCategories());

    // If an initial location is specified, load its details
    if (widget.initialLocationId != null) {
      context
          .read<MapBloc>()
          .add(LoadLocationDetails(widget.initialLocationId!));
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Request and update the user's current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check for location permissions
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Get the current location
    try {
      final locationData = await _location.getLocation();
      setState(() {
        _currentPosition = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
      });

      // Move the camera to current position if available
      if (_mapController != null && _currentPosition != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition!, 15),
        );
      }

      // Load nearby locations
      if (_currentPosition != null) {
        context.read<MapBloc>().add(
              LoadNearbyLocations(
                userLocation: _currentPosition!,
                radiusInMeters: 1000,
              ),
            );
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map'),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MapBloc>().add(RefreshLocations());
              _getCurrentLocation();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          BlocConsumer<MapBloc, MapState>(
            listener: (context, state) {
              if (state is MapLocationsLoaded) {
                _updateMarkers(state.locations);
              } else if (state is MapLocationsByCategoryLoaded) {
                _updateMarkers(state.locations);
              } else if (state is MapLocationDetailsLoaded) {
                _selectLocation(state.location);
              } else if (state is MapSearchResults) {
                _updateMarkers(state.results);
              } else if (state is NearbyLocationsLoaded) {
                _updateMarkers(state.locations);
              } else if (state is MapCategoriesLoaded) {
                setState(() {
                  _categories = state.categories;
                });
              }
            },
            builder: (context, state) {
              if (state is MapLoading && _markers.isEmpty) {
                return const Center(child: LoadingIndicator());
              } else if (state is MapError && _markers.isEmpty) {
                return error_widget.ErrorWidget(
                  message: state.message,
                  onRetry: () {
                    context.read<MapBloc>().add(LoadAllLocations());
                  },
                );
              } else if (state is MapEmpty && _markers.isEmpty) {
                return const Center(
                  child: Text('No locations available on the map.'),
                );
              }

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition ?? _campusPosition,
                  zoom: 14.0,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                onMapCreated: (controller) {
                  setState(() {
                    _mapController = controller;
                  });
                },
                onTap: (_) {
                  setState(() {
                    _selectedLocation = null;
                  });
                },
              );
            },
          ),

          // Search Bar (visible when search is active)
          if (_isSearchVisible)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search locations',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  context
                                      .read<MapBloc>()
                                      .add(LoadAllLocations());
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          context.read<MapBloc>().add(SearchLocations(value));
                        } else {
                          context.read<MapBloc>().add(LoadAllLocations());
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _categories.map((category) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: FilterChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory =
                                      selected ? category : null;
                                });

                                if (selected) {
                                  context
                                      .read<MapBloc>()
                                      .add(LoadLocationsByCategory(category));
                                } else {
                                  context
                                      .read<MapBloc>()
                                      .add(LoadAllLocations());
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Location Details Card (when a location is selected)
          if (_selectedLocation != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Card(
                margin: const EdgeInsets.all(16.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedLocation!.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _selectedLocation = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Category: ${_selectedLocation!.category}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_selectedLocation!.description),
                      if (_selectedLocation!.hours != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 4),
                            Text('Hours: ${_selectedLocation!.hours}'),
                          ],
                        ),
                      ],
                      if (_selectedLocation!.facilities.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Facilities',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children:
                              _selectedLocation!.facilities.map((facility) {
                            return Chip(
                              label: Text(facility),
                              backgroundColor: Colors.grey[200],
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to location details
                          _showLocationDetailsScreen(_selectedLocation!);
                        },
                        icon: const Icon(Icons.info_outline),
                        label: const Text('More Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 40),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Floating action buttons
          Positioned(
            bottom: _selectedLocation != null ? 180 : 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Center on current location
                FloatingActionButton(
                  heroTag: 'location',
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  child: const Icon(Icons.my_location),
                  onPressed: () {
                    _getCurrentLocation();
                  },
                ),
                const SizedBox(height: 8),
                // Center on campus
                FloatingActionButton(
                  heroTag: 'campus',
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  child: const Icon(Icons.school),
                  onPressed: () {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(_campusPosition, 15),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateMarkers(List<MapLocation> locations) {
    setState(() {
      _markers.clear();

      // Add markers for each location
      for (final location in locations) {
        final marker = Marker(
          markerId: MarkerId(location.id),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: location.name,
            snippet: location.category,
          ),
          onTap: () {
            setState(() {
              _selectedLocation = location;
            });
          },
        );

        _markers.add(marker);
      }

      // If an initial location was specified, select it
      if (widget.initialLocationId != null) {
        final initialLocation = locations.firstWhere(
          (loc) => loc.id == widget.initialLocationId,
          orElse: () => locations.first,
        );

        _selectLocation(initialLocation);
      }
    });
  }

  void _selectLocation(MapLocation location) {
    setState(() {
      _selectedLocation = location;
    });

    // Move camera to the selected location
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
          LatLng(location.latitude, location.longitude), 17),
    );
  }

  void _showLocationDetailsScreen(MapLocation location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationDetailsScreen(location: location),
      ),
    );
  }
}

class LocationDetailsScreen extends StatelessWidget {
  final MapLocation location;

  const LocationDetailsScreen({
    Key? key,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(location.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Image or Placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                image: location.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(location.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: location.imageUrl == null
                  ? Center(
                      child: Icon(
                        Icons.location_on,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                    )
                  : null,
            ),

            const SizedBox(height: 16),

            // Location Name
            Text(
              location.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            // Category
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  location.category,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(location.description),

            const SizedBox(height: 16),

            // Operating Hours
            if (location.hours != null) ...[
              const Text(
                'Operating Hours',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 8),
                      Text(location.hours!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Facilities
            if (location.facilities.isNotEmpty) ...[
              const Text(
                'Facilities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: location.facilities.map((facility) {
                  return Chip(
                    label: Text(facility),
                    backgroundColor: Colors.grey[200],
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Details Table
            if (location.details.isNotEmpty) ...[
              const Text(
                'Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: location.details.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(entry.value),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Floor Plans
            if (location.floor.isNotEmpty) ...[
              const Text(
                'Floor Plans',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: location.floor.map((floor) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.layers, size: 16),
                            const SizedBox(width: 8),
                            Text(floor),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate back to map and center on this location
          Navigator.pop(context);
        },
        icon: const Icon(Icons.navigation),
        label: const Text('Navigate'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
