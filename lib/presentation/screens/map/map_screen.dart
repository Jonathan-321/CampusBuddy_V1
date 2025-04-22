import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<CampusLocation> _locations = [
    CampusLocation(
      id: '1',
      name: 'Main Library',
      description: 'Central campus library with study spaces and resources',
      latitude: 37.7749,
      longitude: -122.4194,
      category: 'Academic',
      imageUrl: 'assets/images/main_library.webp',
      hours: 'Mon-Fri: 7:00 AM - 11:00 PM\nSat-Sun: 9:00 AM - 9:00 PM',
    ),
    CampusLocation(
      id: '2',
      name: 'Student Center',
      description: 'Central hub for student activities and services',
      latitude: 37.7750,
      longitude: -122.4180,
      category: 'Services',
      imageUrl: 'assets/images/student_center.jpg',
      hours: 'Mon-Fri: 7:00 AM - 10:00 PM\nSat-Sun: 9:00 AM - 8:00 PM',
    ),
    CampusLocation(
      id: '3',
      name: 'Science Building',
      description: 'Houses science departments and research labs',
      latitude: 37.7755,
      longitude: -122.4165,
      category: 'Academic',
      imageUrl: 'assets/images/science_building.jpg',
      hours: 'Mon-Fri: 7:00 AM - 9:00 PM\nSat: 9:00 AM - 5:00 PM\nSun: Closed',
    ),
    CampusLocation(
      id: '4',
      name: 'Campus Dining Hall',
      description: 'Main dining facility with multiple food options',
      latitude: 37.7760,
      longitude: -122.4170,
      category: 'Dining',
      imageUrl: 'assets/images/Campus-dininghall.jpg',
      hours: 'Mon-Fri: 7:00 AM - 9:00 PM\nSat-Sun: 9:00 AM - 8:00 PM',
    ),
    CampusLocation(
      id: '5',
      name: 'Recreation Center',
      description: 'Fitness facilities, courts, and wellness programs',
      latitude: 37.7765,
      longitude: -122.4175,
      category: 'Recreation',
      imageUrl: 'assets/images/recreation_center.jpg',
      hours: 'Mon-Fri: 6:00 AM - 11:00 PM\nSat-Sun: 8:00 AM - 9:00 PM',
    ),
    CampusLocation(
      id: '6',
      name: 'Arts Building',
      description: 'Home to visual and performing arts departments',
      latitude: 37.7770,
      longitude: -122.4180,
      category: 'Academic',
      imageUrl: 'assets/images/arts_building.jpg',
      hours: 'Mon-Fri: 8:00 AM - 9:00 PM\nSat: 10:00 AM - 6:00 PM\nSun: Closed',
    ),
  ];

  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Academic',
    'Services',
    'Dining',
    'Recreation'
  ];

  List<CampusLocation> get _filteredLocations {
    if (_selectedCategory == 'All') {
      return _locations;
    }
    return _locations
        .where((location) => location.category == _selectedCategory)
        .toList();
  }

  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.navigation),
            tooltip: 'Switch to Enhanced Map',
            onPressed: () {
              Navigator.pushNamed(context, '/enhanced-map');
            },
          ),
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
        ],
      ),
      body: Column(
        children: [
          // Category filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.blue.withOpacity(0.2),
                    checkmarkColor: Colors.blue,
                  ),
                );
              },
            ),
          ),

          // Map placeholder
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/images/campus_map.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Interactive Campus Map',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Location list
          Expanded(
            flex: 3,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredLocations.length,
              itemBuilder: (context, index) {
                final location = _filteredLocations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      _showLocationDetails(location);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location image
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            image: location.imageUrl.isNotEmpty
                                ? DecorationImage(
                                    image: AssetImage(location.imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: location.imageUrl.isEmpty
                              ? Center(
                                  child: Icon(
                                    _getCategoryIcon(location.category),
                                    size: 48,
                                    color: Colors.blue[700],
                                  ),
                                )
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      location.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      location.category,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor:
                                        Colors.blue.withOpacity(0.1),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                location.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Academic':
        return Icons.school;
      case 'Services':
        return Icons.business_center;
      case 'Dining':
        return Icons.restaurant;
      case 'Recreation':
        return Icons.sports_basketball;
      default:
        return Icons.location_on;
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Locations'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter location name',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            // Implement search functionality
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement search
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showLocationDetails(CampusLocation location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Location image
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        image: location.imageUrl.isNotEmpty
                            ? DecorationImage(
                                image: AssetImage(location.imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: location.imageUrl.isEmpty
                          ? Center(
                              child: Icon(
                                _getCategoryIcon(location.category),
                                size: 64,
                                color: Colors.blue[700],
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Location name
                    Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Category chip
                    Chip(
                      label: Text(location.category),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      location.description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hours
                    const Text(
                      'Hours',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      location.hours,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Open in maps app
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Opening in Maps app...'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.directions),
                            label: const Text('Directions'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Show virtual tour
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Virtual tour coming soon!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.view_in_ar),
                            label: const Text('Virtual Tour'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class CampusLocation {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String category;
  final String imageUrl;
  final String hours;

  CampusLocation({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.imageUrl,
    required this.hours,
  });
}
