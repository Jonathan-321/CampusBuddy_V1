import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/theme.dart';
import '../../../domain/entities/map_location.dart';
import '../../blocs/map/map_bloc.dart';
import '../../blocs/map/map_event.dart';
import '../../blocs/map/map_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart' as error_widget;

class EnhancedMapScreen extends StatefulWidget {
  final String? initialLocationId;

  const EnhancedMapScreen({
    Key? key,
    this.initialLocationId,
  }) : super(key: key);

  @override
  State<EnhancedMapScreen> createState() => _EnhancedMapScreenState();
}

class _EnhancedMapScreenState extends State<EnhancedMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Location _location = Location();
  LatLng? _currentPosition;
  MapLocation? _selectedLocation;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoading = true;

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

    // Add listener for search
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      context.read<MapBloc>().add(SearchLocations(_searchController.text));
    } else {
      context.read<MapBloc>().add(LoadAllLocations());
    }
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

    // Check if permission is granted
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Get the current location
    final locationData = await _location.getLocation();
    setState(() {
      _currentPosition = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );
    });

    // Move camera to current location if map is ready
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 16),
      );
    }
  }

  // Create markers from locations
  void _createMarkers(List<MapLocation> locations) {
    _markers.clear();

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

          // Animate to the selected location
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(location.latitude, location.longitude),
              17.0,
            ),
          );
        },
        icon: _getMarkerIcon(location.category),
      );

      _markers.add(marker);
    }
  }

  // Get custom marker icon based on category
  BitmapDescriptor _getMarkerIcon(String category) {
    // In a real app, you would use custom icons for each category
    // For now, we'll use the default marker
    return BitmapDescriptor.defaultMarker;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search locations...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _isSearchVisible = false;
                      });
                      context.read<MapBloc>().add(LoadAllLocations());
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
              )
            : const Text('Campus Map'),
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
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions();
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
                setState(() {
                  _isLoading = false;
                });
                _createMarkers(state.locations);
              } else if (state is MapLocationSelected) {
                setState(() {
                  _selectedLocation = state.location;
                  _isLoading = false;
                });

                // Add marker for selected location
                _markers.clear();
                _markers.add(
                  Marker(
                    markerId: MarkerId(state.location.id),
                    position: LatLng(
                      state.location.latitude,
                      state.location.longitude,
                    ),
                    infoWindow: InfoWindow(
                      title: state.location.name,
                      snippet: state.location.category,
                    ),
                  ),
                );

                // Animate to the selected location
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(
                      state.location.latitude,
                      state.location.longitude,
                    ),
                    17.0,
                  ),
                );
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

          // Category filter chips
          if (!_isLoading && _categories.isNotEmpty)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              height: 50,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : null;
                          });

                          if (selected) {
                            context
                                .read<MapBloc>()
                                .add(FilterLocationsByCategory(category));
                          } else {
                            context.read<MapBloc>().add(LoadAllLocations());
                          }
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Colors.blue.withOpacity(0.2),
                        checkmarkColor: Colors.blue,
                      ),
                    );
                  },
                ),
              ),
            ),

          // Selected location details
          if (_selectedLocation != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildLocationDetails(_selectedLocation!),
            ),

          // Loading indicator
          if (_isLoading)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: LoadingIndicator(),
                ),
              ),
            ),

          // Floating action buttons
          Positioned(
            bottom: _selectedLocation != null ? 220 : 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // My location button
                FloatingActionButton(
                  mini: true,
                  heroTag: 'myLocation',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  child: const Icon(Icons.my_location),
                  onPressed: () {
                    _getCurrentLocation();
                  },
                ),
                const SizedBox(height: 8),
                // Campus center button
                FloatingActionButton(
                  mini: true,
                  heroTag: 'campusCenter',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
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

  Widget _buildLocationDetails(MapLocation location) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Building image
          if (location.imageUrl != null)
            Container(
              height: 120,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(location.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(location.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(location.category),
                  color: _getCategoryColor(location.category),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      location.category,
                      style: TextStyle(
                        color: _getCategoryColor(location.category),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
          const SizedBox(height: 16),
          Text(location.description),
          if (location.hours != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Expanded(child: Text(location.hours!)),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.directions,
                label: 'Directions',
                onPressed: () {
                  _openDirections(location);
                },
              ),
              _buildActionButton(
                icon: Icons.info,
                label: 'Details',
                onPressed: () {
                  _showLocationDetails(location);
                },
              ),
              _buildActionButton(
                icon: Icons.share,
                label: 'Share',
                onPressed: () {
                  _shareLocation(location);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Locations'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._categories.map((category) {
                return RadioListTile<String>(
                  title: Text(category),
                  value: category,
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    Navigator.pop(context);
                    if (value != null) {
                      context
                          .read<MapBloc>()
                          .add(FilterLocationsByCategory(value));
                    }
                  },
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'academic':
        return Colors.blue;
      case 'dining':
        return Colors.orange;
      case 'residence':
        return Colors.green;
      case 'athletics':
        return Colors.red;
      case 'parking':
        return Colors.purple;
      case 'services':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'academic':
        return Icons.school;
      case 'dining':
        return Icons.restaurant;
      case 'residence':
        return Icons.home;
      case 'athletics':
        return Icons.sports;
      case 'parking':
        return Icons.local_parking;
      case 'services':
        return Icons.miscellaneous_services;
      default:
        return Icons.location_on;
    }
  }

  void _openDirections(MapLocation location) {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}',
    );
    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _showLocationDetails(MapLocation location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location image
                    if (location.imageUrl != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: AssetImage(location.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      location.category,
                      style: TextStyle(
                        color: _getCategoryColor(location.category),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(location.description),
                    if (location.hours != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Hours',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(location.hours!),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _shareLocation(MapLocation location) {
    final text =
        'Check out ${location.name} on campus at https://maps.google.com/?q=${location.latitude},${location.longitude}';

    // This would ideally use a share package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing functionality will be implemented soon'),
      ),
    );
  }
}
